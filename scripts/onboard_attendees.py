#!/usr/bin/env python3
"""Alta de asistentes de una capacitación en Kong Konnect (para instructores).

A partir de un CSV con los asistentes (name,email,company[,role]):

  1. crea (o reutiliza) un team de Konnect para la capacitación,
  2. le asigna los roles indicados (por defecto "Control Planes:Viewer" sobre todos los CPs),
  3. invita a la organización a quien todavía no es usuario, y
  4. agrega al team a todos los usuarios ya existentes (o con invitación pendiente).

Por defecto corre en modo --dry-run: solo consulta Konnect (GET) y muestra el plan.
Con --apply ejecuta los cambios. Es idempotente: se puede volver a correr (por
ejemplo, después de que los asistentes acepten la invitación) sin duplicar nada.

Variables de entorno (las define `kong-env`); el script falla si falta alguna:
  KONNECT_TOKEN   PAT/SAT de Konnect con permisos de administración de la organización
  KONNECT_ADDR    URL base de la API, ej. https://us.api.konghq.com  (o https://global.api.konghq.com)

Ejemplos:
  python scripts/onboard_attendees.py attendees.csv --team "training-2026-11-acme"
  python scripts/onboard_attendees.py attendees.csv --team "training-2026-11-acme" --apply
  python scripts/onboard_attendees.py attendees.csv --team t --role "Control Planes:Viewer" --role "API Products:Viewer"

El token nunca se imprime. El CSV real contiene datos personales: no lo commitees
(attendees*.csv está en .gitignore, salvo attendees.example.csv).
"""
from __future__ import annotations

import argparse
import csv
import json
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import dataclass, field

EMAIL_RE = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")
DEFAULT_ROLES = ["Control Planes:Viewer"]


# --------------------------------------------------------------------------- CSV
@dataclass
class Attendee:
    name: str
    email: str
    company: str
    role: str = ""


def read_attendees(path: str) -> list[Attendee]:
    with open(path, newline="", encoding="utf-8-sig") as fh:
        reader = csv.DictReader(fh)
        cols = {c.strip().lower() for c in (reader.fieldnames or [])}
        missing = {"name", "email", "company"} - cols
        if missing:
            sys.exit(f"Error: al CSV le faltan columnas: {', '.join(sorted(missing))} "
                     "(esperado: name,email,company[,role])")
        attendees, seen, errors = [], set(), []
        for lineno, row in enumerate(reader, start=2):
            row = {(k or "").strip().lower(): (v or "").strip() for k, v in row.items()}
            if not any(row.values()):
                continue
            email = row.get("email", "").lower()
            if not EMAIL_RE.match(email):
                errors.append(f"  línea {lineno}: email inválido {email!r}")
                continue
            if email in seen:
                print(f"  (línea {lineno}: {email} duplicado, se ignora)")
                continue
            seen.add(email)
            attendees.append(Attendee(row.get("name", ""), email, row.get("company", ""), row.get("role", "")))
    if errors:
        sys.exit("Error: filas inválidas en el CSV:\n" + "\n".join(errors))
    return attendees


# --------------------------------------------------------------------------- API
class KonnectError(RuntimeError):
    def __init__(self, status: int, method: str, path: str, body: str):
        super().__init__(f"{method} {path} -> HTTP {status}: {body[:300]}")
        self.status = status


@dataclass
class Konnect:
    addr: str
    token: str = field(repr=False)  # nunca se imprime
    api: str = "v3"

    def request(self, method: str, path: str, payload: dict | None = None, query: dict | None = None):
        url = f"{self.addr}/{self.api}{path}"
        if query:
            url += "?" + urllib.parse.urlencode(query)
        data = json.dumps(payload).encode() if payload is not None else None
        req = urllib.request.Request(url, data=data, method=method, headers={
            "Authorization": f"Bearer {self.token}",
            "Accept": "application/json",
            "Content-Type": "application/json",
            "User-Agent": "kong-konnect-fundamentals/onboard_attendees",
        })
        try:
            with urllib.request.urlopen(req, timeout=30) as resp:
                raw = resp.read()
                return json.loads(raw) if raw else {}
        except urllib.error.HTTPError as exc:
            raise KonnectError(exc.code, method, path, exc.read().decode(errors="replace")) from None
        except urllib.error.URLError as exc:
            sys.exit(f"Error: no se pudo conectar a {self.addr}: {exc.reason}")

    def list_all(self, path: str, query: dict | None = None) -> list[dict]:
        items, page = [], 1
        while True:
            q = dict(query or {}, **{"page[size]": 100, "page[number]": page})
            body = self.request("GET", path, query=q)
            data = body.get("data", [])
            items.extend(data)
            total = (body.get("meta", {}).get("page", {}) or {}).get("total", len(items))
            if not data or len(items) >= total:
                return items
            page += 1

    # --- equipos, usuarios, roles
    def find_team(self, name: str) -> dict | None:
        return next((t for t in self.list_all("/teams", {"filter[name][eq]": name}) if t.get("name") == name), None)

    def find_user(self, email: str) -> dict | None:
        users = self.list_all("/users", {"filter[email][eq]": email})
        return next((u for u in users if (u.get("email") or "").lower() == email), None)

    def team_member_ids(self, team_id: str) -> set[str]:
        return {u["id"] for u in self.list_all(f"/teams/{team_id}/users")}

    def team_roles(self, team_id: str) -> set[tuple[str, str, str]]:
        return {(r.get("entity_type_name", ""), r.get("role_name", ""), r.get("entity_id", ""))
                for r in self.list_all(f"/teams/{team_id}/assigned-roles")}


def region_from_addr(addr: str) -> str:
    host = urllib.parse.urlparse(addr).hostname or ""
    first = host.split(".")[0]
    return first if first in {"us", "eu", "au", "me", "in", "sg"} else "us"


def parse_role(spec: str) -> tuple[str, str]:
    if ":" not in spec:
        sys.exit(f"Error: --role debe tener el formato 'Tipo de entidad:Rol' (ej. 'Control Planes:Viewer'), no {spec!r}")
    entity_type, role = (p.strip() for p in spec.split(":", 1))
    return entity_type, role


# --------------------------------------------------------------------------- main
def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("csv", help="CSV de asistentes: name,email,company[,role]")
    ap.add_argument("--team", required=True, help="nombre del team de Konnect de la capacitación (ej. training-2026-11-acme)")
    ap.add_argument("--team-description", default=None, help="descripción del team (default: generada)")
    ap.add_argument("--role", action="append", dest="roles", metavar="'TIPO:ROL'",
                    help="rol a asignar al team, repetible (default: 'Control Planes:Viewer')")
    ap.add_argument("--entity-id", default="*", help="entidad sobre la que aplica el rol (default: * = todas)")
    ap.add_argument("--region", default=None, help="región de las entidades (default: deducida de KONNECT_ADDR, si no 'us')")
    ap.add_argument("--api-version", default="v3", choices=["v2", "v3"], help="versión de la Identity API (default: v3)")
    mode = ap.add_mutually_exclusive_group()
    mode.add_argument("--dry-run", action="store_true", default=True, help="solo mostrar el plan (default)")
    mode.add_argument("--apply", action="store_true", help="ejecutar los cambios en Konnect")
    args = ap.parse_args()

    # Fail fast: variables de entorno obligatorias (nunca se imprimen sus valores)
    missing = [v for v in ("KONNECT_TOKEN", "KONNECT_ADDR") if not os.environ.get(v)]
    if missing:
        sys.exit(f"Error: faltan variables de entorno: {', '.join(missing)}. Ejecuta 'kong-env' o expórtalas.")
    addr = os.environ["KONNECT_ADDR"].rstrip("/")
    host = urllib.parse.urlparse(addr).hostname or ""
    if not (addr.startswith("https://") or host in {"localhost", "127.0.0.1"}):
        sys.exit("Error: KONNECT_ADDR debe ser una URL https:// (ej. https://us.api.konghq.com)")

    attendees = read_attendees(args.csv)
    roles = [parse_role(r) for r in (args.roles or DEFAULT_ROLES)]
    region = args.region or region_from_addr(addr)
    apply = args.apply
    k = Konnect(addr, os.environ["KONNECT_TOKEN"], args.api_version)
    tag = "" if apply else "[dry-run] "

    print(f"{'APLICANDO cambios' if apply else 'Modo dry-run (sin cambios; usa --apply para ejecutar)'}")
    print(f"Konnect: {addr}/{args.api_version} · team: {args.team} · región: {region} · asistentes: {len(attendees)}\n")

    try:
        # 1. Team
        team = k.find_team(args.team)
        if team:
            print(f"= team '{args.team}' ya existe ({team['id']})")
        elif apply:
            desc = args.team_description or f"Capacitación Kong Konnect Fundamentals ({len(attendees)} asistentes)"
            team = k.request("POST", "/teams", {"name": args.team, "description": desc})
            print(f"+ team '{args.team}' creado ({team['id']})")
        else:
            print(f"{tag}+ crearía el team '{args.team}'")
        team_id = team["id"] if team else None

        # 2. Roles del team
        current_roles = k.team_roles(team_id) if team_id else set()
        for entity_type, role in roles:
            if (entity_type, role, args.entity_id) in current_roles:
                print(f"= rol '{entity_type}:{role}' ({args.entity_id}) ya asignado")
                continue
            if apply:
                try:
                    k.request("POST", f"/teams/{team_id}/assigned-roles", {
                        "role_name": role, "entity_type_name": entity_type,
                        "entity_id": args.entity_id, "entity_region": region})
                    print(f"+ rol '{entity_type}:{role}' ({args.entity_id}, {region}) asignado")
                except KonnectError as exc:
                    if exc.status != 409:
                        raise
                    print(f"= rol '{entity_type}:{role}' ya asignado")
            else:
                print(f"{tag}+ asignaría el rol '{entity_type}:{role}' ({args.entity_id}, {region})")

        # 3. Usuarios: invitar si no existen, agregar al team
        members = k.team_member_ids(team_id) if team_id else set()
        summary = {"invitados": 0, "agregados": 0, "ya_miembros": 0, "pendientes": 0, "errores": 0}
        print()
        for a in attendees:
            label = f"{a.email:<40} {a.name} ({a.company}{', ' + a.role if a.role else ''})"
            try:
                user = k.find_user(a.email)
                if not user:
                    if apply:
                        k.request("POST", "/invites", {"email": a.email})
                        summary["invitados"] += 1
                        user = k.find_user(a.email)  # el usuario invitado queda en estado pendiente
                        print(f"+ invitado        {label}")
                    else:
                        summary["invitados"] += 1
                        print(f"{tag}+ invitaría     {label}")
                        continue
                if user and user["id"] in members:
                    summary["ya_miembros"] += 1
                    print(f"= ya en el team   {label}")
                    continue
                if not user:
                    summary["pendientes"] += 1
                    print(f"! pendiente       {label} (aún no figura como usuario: vuelve a correr el script tras la aceptación)")
                    continue
                if apply:
                    try:
                        k.request("POST", f"/teams/{team_id}/users", {"id": user["id"]})
                    except KonnectError as exc:
                        if exc.status != 409:
                            raise
                    print(f"+ agregado a team {label}")
                else:
                    print(f"{tag}+ agregaría al team {label}")
                summary["agregados"] += 1
            except KonnectError as exc:
                summary["errores"] += 1
                print(f"x error           {label}: {exc}")
    except KonnectError as exc:
        print(f"\nError de la API de Konnect: {exc}", file=sys.stderr)
        if exc.status in (401, 403):
            print("Revisa que KONNECT_TOKEN sea válido y tenga permisos de administración de la organización.", file=sys.stderr)
        return 1

    print("\nResumen: " + ", ".join(f"{k_}={v}" for k_, v in summary.items()))
    if not apply:
        print("Nada se modificó. Repite con --apply para ejecutar.")
    return 1 if summary["errores"] else 0


if __name__ == "__main__":
    sys.exit(main())
