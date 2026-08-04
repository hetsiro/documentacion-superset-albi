@echo off
REM ============================================================
REM  Actualiza docs\referencia\calculos-charts.html leyendo los
REM  charts en vivo desde la API de Superset.
REM  Doble clic para ejecutar. No requiere dashboards exportados.
REM ============================================================
title Actualizar calculos de los charts
cd /d "%~dp0"

echo.
echo  ================================================
echo   Actualizando calculos-charts.html
echo  ================================================
echo.

where node >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo  ERROR: Node.js no esta instalado o no esta en el PATH.
    echo  Instalalo desde https://nodejs.org
    echo.
    pause
    exit /b 1
)

node calculos_fetch.js
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo  Fallo la actualizacion. Revisa el mensaje de error de arriba.
    echo.
    pause
    exit /b 1
)

echo.
echo  ================================================
echo   Listo. Abre docs\referencia\calculos-charts.html
echo  ================================================
echo.
pause
