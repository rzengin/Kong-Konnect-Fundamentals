#!/usr/bin/env bash
# =============================================================================
# workshop-assets/dia-4/scripts/load_rag.sh — carga la base de conocimiento RAG
#
# Lee workshop-assets/dia-4/rag/documentos.json, calcula los embeddings con
# Ollama nomic-embed-text (768 dimensiones, sin salir de la red) y los guarda en
# Redis con el prefijo que lee la policy ai-rag-injector (vectordb_namespace:
# kong_rag_injector). Modelo y dimensiones deben coincidir con lab_05_rag.yaml.
# Adaptado de scripts/load-rag.sh del Demo Track AI Gateway 2.
# =============================================================================
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
aigw_load_env
require_cmd docker python3
running aigw-lab-redis || die "Redis (aigw-lab-redis) no está corriendo: ejecuta setup_lab.sh"
redis_cli PING 2>/dev/null | grep -q PONG || die "Redis inaccesible"

export RAG_DOCS="${AIGW_ROOT}/rag/documentos.json"
export EMBED_CMD="docker run --rm -i --network aigw-lab --add-host host.docker.internal:host-gateway ${CURL_IMAGE} -s --max-time 300 -H Content-Type:application/json -d @- ${AIGW_OLLAMA_URL}/api/embed"
export REDIS_CMD_PREFIX="docker exec -i aigw-lab-redis redis-cli"

python3 <<'PYEOF'
import json, os, subprocess, hashlib, time, sys
docs = json.load(open(os.environ["RAG_DOCS"], encoding="utf-8"))
texts = [d["content"] for d in docs]
r = subprocess.run(os.environ["EMBED_CMD"], shell=True, capture_output=True, text=True,
                   input=json.dumps({"model": os.environ.get("AIGW_MODELO_EMBED", "nomic-embed-text"), "input": texts}))
try:
    embs = json.loads(r.stdout)["embeddings"]
except Exception as e:
    print(f"  [FAIL] no se pudieron calcular los embeddings: {e} {r.stdout[:200]} {r.stderr[:200]}"); sys.exit(1)
print(f"  [OK] {len(embs)} embeddings ({len(embs[0])} dimensiones)")
redis = os.environ["REDIS_CMD_PREFIX"]
lua = "local k = redis.call('KEYS', 'kong_rag_injector:*') if #k > 0 then return redis.call('DEL', unpack(k)) else return 0 end"
subprocess.run(f"{redis} EVAL \"{lua}\" 0", shell=True, capture_output=True)
subprocess.run(f"{redis} FT.DROPINDEX idx:vss_kong_rag_injector", shell=True, capture_output=True)
now = int(time.time())
for i, (doc, emb) in enumerate(zip(docs, embs)):
    k = "kong_rag_injector:" + hashlib.sha256(doc["content"].encode()).hexdigest()[:16]
    data = json.dumps({"payload": doc["content"], "vector": emb,
                       "metadata": {"source": doc["title"], "date": now, "tags": doc["tags"], "collection": "banco-demo"}})
    r = subprocess.run(f"{redis} -x JSON.SET '{k}' '$'", shell=True, input=data, capture_output=True, text=True)
    print(("  [OK] " if r.returncode == 0 else "  [FAIL] ") + f"[{i+1}/{len(docs)}] {doc['title']}" + ("" if r.returncode == 0 else f": {r.stderr.strip()}"))
PYEOF
rc=$?
(( rc == 0 )) && pass "base RAG cargada en Redis (prefijo kong_rag_injector:)" || fail "carga RAG incompleta"
exit $rc
