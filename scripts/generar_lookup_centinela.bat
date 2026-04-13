@echo off
setlocal
title Generar Catalogos — CentinelaDashboards
cd /d "%~dp0"

echo.
echo  ================================================
echo   Generando catalogos de Centinela (PROD directo)
echo  ================================================
echo.

REM ── Verificar que Python este disponible ────────────────────────────────────
python --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    python3 --version >nul 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo  ERROR: Python no esta instalado.
        echo  Instala Python desde python.org o Microsoft Store.
        echo.
        pause
        exit /b 1
    )
    set PYTHON=python3
) else (
    set PYTHON=python
)

echo  Usando: %PYTHON%
echo.

REM ── Verificar que pymssql este instalado ────────────────────────────────────
%PYTHON% -c "import pymssql" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo  Instalando pymssql...
    %PYTHON% -m pip install pymssql
    echo.
)

REM ── Ejecutar script ─────────────────────────────────────────────────────────
%PYTHON% generar_lookup_centinela.py
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo  ERROR al ejecutar el script.
    pause
    exit /b 1
)

echo.
echo  ================================================
echo   Listo!  docs\lookup_data_centinela.js creado.
echo   Recarga diccionario_centinela.html para ver los catalogos.
echo  ================================================
echo.
pause
