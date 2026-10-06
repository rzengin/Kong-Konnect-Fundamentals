@echo off
setlocal enabledelayedexpansion

cd %~dp0..

if "%KONNECT_TOKEN%"=="" (
    echo [ERROR] La variable KONNECT_TOKEN no esta configurada correctamente. Es obligatoria.
    exit /b 1
)
if "%KONNECT_TOKEN%"=="kpat_XXXXXXXXX" (
    echo [ERROR] La variable KONNECT_TOKEN no esta configurada correctamente. Es obligatoria.
    exit /b 1
)

if "%DEMO_PREFIX%"=="" (
    echo [ERROR] La variable DEMO_PREFIX no esta configurada correctamente. Es obligatoria.
    exit /b 1
)
if "%DEMO_PREFIX%"=="tu_nombre" (
    echo [ERROR] La variable DEMO_PREFIX no esta configurada correctamente. Es obligatoria.
    exit /b 1
)

echo ======================================================
echo  Preparando Entorno para Ejercicio 000  
echo ======================================================
echo.

echo [1/3] Levantando backend simulado (MockAPI) con Docker Compose...
docker network create kong-workshop >nul 2>&1
docker compose up -d

echo.
echo [2/3] Creando Control Plane en Konnect (Terraform)...
echo Limpiando estado anterior del Control Plane (si existe)...
deck gateway reset --konnect-token "%KONNECT_TOKEN%" --konnect-control-plane-name "%DEMO_PREFIX%_MockAPI" --force >nul 2>&1

cd terraform
terraform init || echo Asegurate de tener Terraform instalado.
terraform apply -var="konnect_token=%KONNECT_TOKEN%" -var="demo_prefix=%DEMO_PREFIX%" -auto-approve
cd ..

echo.
echo [3/3] Generando certificados e iniciando Kong Data Plane...
python -c "import requests, cryptography" 2>nul
if errorlevel 1 (
    echo Instalando dependencias de Python (requests, cryptography)...
    pip install -q requests cryptography
)

python scripts\generate_certs.py
if %errorlevel% == 0 (
    call scripts\start_dps.bat
) else (
    echo Hubo un error al generar los certificados. Asegurate de tener los Control Planes creados y tus credenciales ^(KONNECT_TOKEN y DEMO_PREFIX^) bien configuradas.
)

echo ======================================================
echo  !Entorno listo! Ya puedes continuar con la creacion de infraestructura.
echo  MockAPI Backend: http://localhost:9081
echo  Kong DP: http://localhost:8000
echo ======================================================
echo.
