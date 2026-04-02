@echo off
setlocal
title Generar Catalogos — AmecoDashboards
cd /d "%~dp0"

echo.
echo  ================================================
echo   Generando catalogos de valores para Superset
echo  ================================================
echo.

REM ── Verificar que Docker este corriendo ──────────────────────────────────────
docker info >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo  ERROR: Docker no esta corriendo.
    echo  Abri Docker Desktop y espera a que el icono sea verde.
    echo.
    pause
    exit /b 1
)

REM ── Obtener ID del contenedor superset ──────────────────────────────────────
echo  Buscando contenedor superset...
for /f %%i in ('docker compose ps -q superset 2^>nul') do set CONTAINER_ID=%%i

if "%CONTAINER_ID%"=="" (
    echo.
    echo  ERROR: El contenedor superset no esta corriendo.
    echo  Ejecuta primero:  docker compose up -d
    echo.
    pause
    exit /b 1
)

echo  Contenedor encontrado: %CONTAINER_ID:~0,12%...
echo.

REM ── Copiar script al contenedor ─────────────────────────────────────────────
echo  [1/3] Copiando script al contenedor...
docker cp generar_lookup.py %CONTAINER_ID%:/tmp/gen.py
if %ERRORLEVEL% NEQ 0 (
    echo  ERROR al copiar el script.
    pause
    exit /b 1
)

REM ── Ejecutar script dentro del contenedor ────────────────────────────────────
echo  [2/3] Consultando AmecoDashboards...
echo.
docker exec %CONTAINER_ID% sh -c "python3 /tmp/gen.py"
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo  ERROR al ejecutar el script dentro del contenedor.
    pause
    exit /b 1
)

REM ── Copiar JS de vuelta al host ─────────────────────────────────────────────
echo.
echo  [3/3] Copiando resultados al host...
docker cp %CONTAINER_ID%:/tmp/lookup_data.js "%~dp0documentacion\lookup_data.js"
if %ERRORLEVEL% NEQ 0 (
    echo  ERROR al copiar lookup_data.js de vuelta.
    pause
    exit /b 1
)

echo.
echo  ================================================
echo   Listo!  documentacion\lookup_data.js creado.
echo   Recarga diccionario.html para ver los catalogos.
echo  ================================================
echo.
pause
