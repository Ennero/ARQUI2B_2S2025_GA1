# 1) Crear venv e instalar
python -m venv .venv
source .venv/bin/activate   # en Windows: .venv\Scripts\activate
pip install -r requirements.txt

# 2) Crear DB y tablas
psql -U postgres -c "CREATE DATABASE iotcity;"
psql -U postgres -d iotcity -f sql/create_tables.sql

# 3) Configurar .env
cp .env.example .env
# (ajusta DB_HOST si corres en otra máquina)

# 4) Levantar API
python run.py
# Abre: http://localhost:8080/api/health
