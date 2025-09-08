# start.ps1
Write-Host "🔧 Activando entorno virtual y levantando API..." -ForegroundColor Cyan

# Verifica si existe el venv
if (-Not (Test-Path ".venv")) {
    Write-Host "⚠️  No se encontró .venv, creando uno nuevo..." -ForegroundColor Yellow
    python -m venv .venv
}

# Ajusta la política de ejecución solo para esta sesión
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Activa el venv
. .\.venv\bin\Activate.ps1

# Instala dependencias (si falta algo lo instala)
pip install -r requirements.txt

# Levanta la API
python app.py
