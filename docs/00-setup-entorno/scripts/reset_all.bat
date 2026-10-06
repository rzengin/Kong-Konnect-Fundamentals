@echo off
setlocal enabledelayedexpansion

echo =================================================
echo  🧹 RESET TOTAL - Kong Training Workshop
echo =================================================
echo.

if "%KONNECT_TOKEN%"=="" (
  if "%KONNECT_TOKEN%"=="kpat_XXXXXXXXX" (
      echo [ERROR] La variable KONNECT_TOKEN no esta configurada correctamente. Es obligatoria.
      exit /b 1
  )
)
if "%DEMO_PREFIX%"=="" (
  if "%DEMO_PREFIX%"=="tu_nombre" (
      echo [ERROR] La variable DEMO_PREFIX no esta configurada correctamente. Es obligatoria.
      exit /b 1
  )
)

set KONNECT_CONTROL_PLANE_NAME=%DEMO_PREFIX%_MockAPI

echo [1/4] Deteniendo contenedores Docker y MkDocs...
taskkill /F /IM "mkdocs.exe" >nul 2>&1

set "CONTAINERS=kong-dp httpbin-backend mock-kong otel-collector openobserve phoenix"
for %%c in (%CONTAINERS%) do (
  docker rm -f %%c >nul 2>&1
  echo    Eliminado/Verificado: %%c
)

echo.
echo [2/4] Limpiando redes Docker del workshop...
set "NETWORKS=ejercicio-001_default ejercicio-004_default otel-stack kong-workshop"
for %%n in (%NETWORKS%) do (
  docker network rm %%n >nul 2>&1
)

echo.
echo [3/4] Reseteando Control Plane en Konnect...
echo    Reseteando %KONNECT_CONTROL_PLANE_NAME%...
deck gateway reset --konnect-token "%KONNECT_TOKEN%" --konnect-control-plane-name "%KONNECT_CONTROL_PLANE_NAME%" --force >nul 2>&1
echo Hecho.

echo.
echo [4/4] Limpiando archivos temporales...
if exist "..\release-external.yaml" del "..\release-external.yaml"
if exist "..\release-internal.yaml" del "..\release-internal.yaml"
if exist "..\release.yaml" del "..\release.yaml"
if exist "..\estado-base.yaml" del "..\estado-base.yaml"

echo.
echo =================================================
echo  ✅ RESET COMPLETO
echo =================================================
echo.
