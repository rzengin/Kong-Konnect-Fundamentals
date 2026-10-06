@echo off
setlocal enabledelayedexpansion

cd %~dp0..

:: Read endpoints.env and export variables
for /f "usebackq tokens=1,* delims==" %%a in ("endpoints.env") do (
    if not "%%a"=="" (
        set "%%a=%%b"
    )
)

docker rm -f kong-dp kong-dp-external kong-dp-internal >nul 2>&1
docker network create kong-workshop >nul 2>&1

echo Starting kong-dp...
docker run -d --name kong-dp ^
  --network kong-workshop ^
  -p 8000:8000 -p 8443:8443 ^
  -e "KONG_ROLE=data_plane" ^
  -e "KONG_DATABASE=off" ^
  -e "KONG_CLUSTER_MTLS=pki" ^
  -e "KONG_CLUSTER_CONTROL_PLANE=%CONTROL_PLANE_ENDPOINT%:443" ^
  -e "KONG_CLUSTER_TELEMETRY_ENDPOINT=%TELEMETRY_ENDPOINT%:443" ^
  -e "KONG_CLUSTER_CERT=/certs/tls.crt" ^
  -e "KONG_CLUSTER_CERT_KEY=/certs/tls.key" ^
  -e "KONG_LUA_SSL_TRUSTED_CERTIFICATE=system" ^
  -e "KONG_KONNECT_MODE=on" ^
  -e "KONG_VITALS=off" ^
  -e "KONG_TRACING_INSTRUMENTATIONS=all" ^
  -e "KONG_TRACING_SAMPLING_RATE=1.0" ^
  -e "KONG_PROXY_LISTEN=0.0.0.0:8000, 0.0.0.0:8443 ssl" ^
  -e "KONG_TRUSTED_IPS=0.0.0.0/0,::/0" ^
  -e "KONG_REAL_IP_HEADER=X-Real-Ip" ^
  -v "%cd%\certs\mock:/certs" ^
  kong/kong-gateway:latest

echo Done.
