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

🧱 Arquitectura (simple y clara)

Flask (rutas) → Define endpoints HTTP.

Servicios (services/) → Reglas ligeras y transformación a JSON.

Repositorios (repositories/) → Consultas a la base de datos (SQLAlchemy).

Modelos (models.py) → ORM que mapea a tablas PostgreSQL.

DB (db.py) → Engine y sesiones de SQLAlchemy.

Config (config.py) → Variables de entorno (.env).

routes  ->  services  ->  repositories  ->  models/DB

📦 Estructura de carpetas
iot-city-flask/
├─ app/
│  ├─ config.py
│  ├─ db.py
│  ├─ models.py
│  ├─ repositories/
│  │   ├─ sensors_repo.py
│  │   ├─ alerts_repo.py
│  │   └─ transport_repo.py
│  ├─ services/
│  │   ├─ sensors_service.py
│  │   ├─ alerts_service.py
│  │   └─ transport_service.py
│  └─ routes/
│      ├─ health_routes.py
│      ├─ sensors_routes.py
│      ├─ alerts_routes.py
│      └─ transport_routes.py
├─ run.py
├─ requirements.txt
└─ sql/
   └─ create_tables.sql

🗄️ Modelo de datos (PostgreSQL)

Tablas creadas en sql/create_tables.sql:

sensor_readings

id SERIAL PK

source VARCHAR(40)

type VARCHAR(30) NOT NULL (ej. gas, sismo, distancia)

value NUMERIC(10,3)

unit VARCHAR(10)

zone VARCHAR(40)

ts TIMESTAMPTZ DEFAULT NOW()

Índices por type, ts y por ts.

alerts

id SERIAL PK

category VARCHAR(30) NOT NULL (ej. panico, infraccion)

payload JSONB NOT NULL (contenido libre del evento)

severity INT DEFAULT 1

ack BOOLEAN DEFAULT FALSE (reconocida o no)

ts TIMESTAMPTZ DEFAULT NOW()

Índices por category, ts y GIN sobre payload.

bus_positions

id SERIAL PK

bus_id VARCHAR(20) NOT NULL

stop_distance_m INT NOT NULL

eta_seconds INT NOT NULL

ts TIMESTAMPTZ DEFAULT NOW()

Índice por bus_id, ts.

Importante: La API lee de estas tablas. La inserción/actualización se espera de otro proceso (p. ej., un integrador de MQTT o scripts de datos).

🔌 Endpoints disponibles (hasta ahora)
Salud
GET /api/health

Comprueba la disponibilidad del API.

Ejemplo de respuesta

{ "status": "ok" }

Sensores
GET /api/sensors/history

Devuelve lecturas históricas de sensores con filtros y paginación.

Query params

type (opcional): gas | sismo | distancia | ...

zone (opcional)

source (opcional)

from (opcional, ISO-8601)

to (opcional, ISO-8601)

page (default 1)

page_size (default 50)

Ejemplo

GET /api/sensors/history?type=gas&page=1&page_size=20


Respuesta

{
  "items": [
    {
      "id": 1,
      "source": "arduino1",
      "type": "gas",
      "value": 180.0,
      "unit": "ppm",
      "zone": "zona_historica_1",
      "ts": "2025-08-28T20:00:00+00:00"
    }
  ],
  "page": 1,
  "page_size": 20,
  "total": 123
}

Alertas
GET /api/alerts/recent?limit=50

Lista de alertas más recientes.

Respuesta

{
  "items": [
    {
      "id": 10,
      "category": "panico",
      "payload": { "button_id": "P1", "zone": "plaza" },
      "severity": 2,
      "ack": false,
      "ts": "2025-08-28T20:05:00+00:00"
    }
  ]
}

POST /api/alerts/ack/{id}

Marca una alerta como reconocida.

204 No Content si se actualiza.

404 si el id no existe.

Transporte
GET /api/transport/buses

Devuelve el último estado conocido por bus (distancia a parada y ETA), resolviendo internamente “último registro por bus”.

Respuesta

{
  "items": [
    {
      "id": 42,
      "bus_id": "bus1",
      "stop_distance_m": 320,
      "eta_seconds": 90,
      "ts": "2025-08-28T20:06:00+00:00"
    },
    {
      "id": 51,
      "bus_id": "bus2",
      "stop_distance_m": 900,
      "eta_seconds": 260,
      "ts": "2025-08-28T20:06:05+00:00"
    }
  ]
}

🧪 Cómo probar rápido (curl)
# Salud
curl http://localhost:8080/api/health

# Sensores (histórico filtrado)
curl "http://localhost:8080/api/sensors/history?type=gas&page=1&page_size=10"

# Alertas recientes
curl "http://localhost:8080/api/alerts/recent?limit=20"

# Reconocer alerta 1
curl -i -X POST http://localhost:8080/api/alerts/ack/1

# Transporte (últimas posiciones por bus)
curl http://localhost:8080/api/transport/buses

⚙️ Variables de entorno ( .env )
FLASK_ENV=development
API_PORT=8080

DB_HOST=localhost
DB_PORT=5432
DB_NAME=iotcity
DB_USER=iotuser
DB_PASSWORD=changeme

CORS_ORIGINS=*

▶️ Ejecución
# Instalar dependencias
python -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
pip install -r requirements.txt

# Crear base y tablas
psql -U postgres -c "CREATE DATABASE iotcity;"
psql -U postgres -d iotcity -f sql/create_tables.sql

# Configurar .env (copiar de .env.example)
python run.py   # levanta en http://localhost:8080

📱 Consumo desde Flutter (resumen)

Cliente HTTP recomendado: dio.

Rutas ya disponibles:

/api/alerts/recent

/api/transport/buses

/api/sensors/history

/api/health

Ejemplo sencillo

final api = Dio(BaseOptions(baseUrl: 'http://<IP_BACKEND>:8080'));
final r = await api.get('/api/alerts/recent', queryParameters: {'limit': 20});
final items = r.data['items'] as List; // List<Map<String, dynamic>>

📌 Estado actual & próximos pasos

✅ Lectura de datos lista (sensores, alertas, buses).

✅ Reconocimiento de alertas por id.

✅ Estructura limpia por capas (routes → services → repositories).

✅ Lista para que otro proceso inserte datos a las tablas.

Siguientes mejoras sugeridas:

Validaciones de entrada y errores uniformes.

Autenticación (si se requiere).

Paginación en /transport/buses/{id}/history (si se agrega ruta).

Pruebas unitarias ligeras de servicios/repositorios.
