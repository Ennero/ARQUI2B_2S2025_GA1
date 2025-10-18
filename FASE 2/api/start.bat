REM filepath: c:\Users\willi\OneDrive\Escritorio\USAC\5. Sexto Semestre\ARQUI2B_2S2025_GA1\FASE 2\api\start.bat
@echo off
echo Activando entorno virtual...
call .venv\Scripts\activate.bat
echo Iniciando FastAPI...
fastapi dev main.py
pause