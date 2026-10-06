# Entregas y versiones del curso

Cada vez que el curso se dicta a un cliente se crea un **tag anotado** sobre el commit exacto que se usó en la entrega. Así se puede reconstruir en cualquier momento el material (sitio, scripts y archivos de decK) tal como lo vieron los asistentes, aunque `main` siga evolucionando.

## Convención de nombres

```
vAAAA-MM-<cliente>
```

- `AAAA-MM`: año y mes de la entrega (si dura varios días, el mes del primer día).
- `<cliente>`: identificador corto del cliente en minúsculas y sin espacios (`stp`, `banco-x`, ...). Si hay dos entregas al mismo cliente en el mismo mes, agregar un sufijo: `v2026-11-acme-2`.

El mensaje del tag indica cliente, fechas de dictado y cualquier particularidad (idioma, módulos omitidos, versión de Kong Gateway usada).

## Cómo crear el tag de una entrega

Hacerlo al terminar la entrega, sobre el último commit de `main` que se usó (verificar con `git log`):

```bash
git switch main && git pull
git log --format='%h %ad %s' --date=iso -10        # identificar el commit usado en la entrega

git tag -a v2026-11-acme <commit> -m "Entrega a ACME (2026-11-12/13). Días 1–2, español, Kong Gateway 3.15."
git push origin v2026-11-acme                      # push normal del tag (nunca --force)
```

Para consultar una entrega anterior:

```bash
git tag -l 'v*' -n1                                 # listar entregas con su descripción
git switch --detach v2026-11-acme                   # ver el material tal como se entregó
```

Si hubo que corregir algo **durante** la entrega, commitear la corrección en `main` y crear el tag sobre ese commit (no mover tags ya publicados).

> **Datos sensibles:** los tags apuntan a commits del historial del curso y quedan accesibles para siempre. Nunca commitear listas de asistentes, tokens, `.env`, `endpoints.env`, claves (`*.key`, `*.pem`) ni estados de Terraform: están en `.gitignore` y CI no los necesita.

## Registro de entregas

| Tag | Cliente | Fechas | Repositorio | Notas |
|-----|---------|--------|-------------|-------|
| `v2026-09-stp` | STP | 2026-09-03 / 2026-09-04 | [`rzengin/Kong-Training-STP`](https://github.com/rzengin/Kong-Training-STP/releases/tag/v2026-09-stp) (anterior, privado) | Días 1–2. Commit `8620e6f`. El historial de ese repositorio no se migró a este (contenía secretos y datos de asistentes). |
