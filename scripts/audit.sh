#!/bin/bash
fail=0
check() {
  label="$1"; shift
  if "$@"; then echo "[OK] $label"; else echo "[FAIL] $label"; fail=1; fi
}
echo '[5] Контейнеризация'
check 'Docker active' systemctl is-active --quiet docker
check 'PostgreSQL healthy' bash -c 'test "$(docker inspect -f "{{.State.Health.Status}}" app-db-1)" = healthy'
check 'Only loopback ports' python3 -c 'import subprocess,sys; lines=subprocess.check_output(["ss","-H","-ltn"],text=True).splitlines(); bad=[s for s in lines if s.split()[3].rsplit(":",1)[-1] in ("5000","5432") and s.split()[3].rsplit(":",1)[0]!="127.0.0.1"]; print("\n".join(bad)); sys.exit(bool(bad))'
check 'Environment permissions 600' bash -c 'test "$(stat -c %a ~/app/.env)" = 600'
exit "$fail"
