@echo off
setlocal enabledelayedexpansion

cd %~dp0..

echo ======================================================
echo  Preparando Portal de Documentacion (Solo Instructor)
echo ======================================================
echo.

if exist "..\..\mkdocs.yml" (
    echo [1/2] Levantando portal de documentacion local...
    taskkill /F /IM "mkdocs.exe" >nul 2>&1
    
    cd ..\..
    if exist ".venv\Scripts\mkdocs.exe" (
        start /b .venv\Scripts\mkdocs.exe serve -a 0.0.0.0:8001 > %TMP%\mkdocs.log 2>&1
    ) else (
        start /b python -m mkdocs serve -a 0.0.0.0:8001 > %TMP%\mkdocs.log 2>&1
    )

    echo.
    echo [2/2] Desplegando documentacion en GitHub Pages...
    if exist ".venv\Scripts\mkdocs.exe" (
        .venv\Scripts\mkdocs.exe gh-deploy --force || echo No se pudo desplegar en GitHub Pages.
    ) else (
        python -m mkdocs gh-deploy --force || echo No se pudo desplegar en GitHub Pages.
    )
    cd docs\00-setup-entorno
    
    echo.
    echo ======================================================
    echo  !Portal de documentacion listo!
    echo  Documentacion Local: http://localhost:8001
    echo ======================================================
    echo.
) else (
    echo [ERROR] Archivo mkdocs.yml no encontrado. Asegurate de estar en el repositorio principal.
)
