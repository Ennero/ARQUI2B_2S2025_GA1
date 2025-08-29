-- Base de datos: iotcity (crea la DB si no existe)
-- CREATE DATABASE iotcity;

-- Usuario sugerido:
-- CREATE USER iotuser WITH PASSWORD 'changeme';
-- GRANT ALL PRIVILEGES ON DATABASE iotcity TO iotuser;

-- Extensión útil para índices JSONB (opcional):
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tablas
CREATE TABLE IF NOT EXISTS sensor_readings (
  id SERIAL PRIMARY KEY,
  source VARCHAR(40),
  type VARCHAR(30) NOT NULL,          -- gas | sismo | distancia | ...
  value NUMERIC(10,3),
  unit VARCHAR(10),
  zone VARCHAR(40),
  ts TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sensor_type_ts ON sensor_readings(type, ts DESC);
CREATE INDEX IF NOT EXISTS idx_sensor_ts ON sensor_readings(ts DESC);

CREATE TABLE IF NOT EXISTS alerts (
  id SERIAL PRIMARY KEY,
  category VARCHAR(30) NOT NULL,      -- panico | infraccion | sismo | incendio
  payload JSONB NOT NULL,
  severity INT NOT NULL DEFAULT 1,
  ack BOOLEAN NOT NULL DEFAULT FALSE,
  ts TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_alerts_category_ts ON alerts(category, ts DESC);
CREATE INDEX IF NOT EXISTS idx_alerts_payload_gin ON alerts USING GIN (payload);

CREATE TABLE IF NOT EXISTS bus_positions (
  id SERIAL PRIMARY KEY,
  bus_id VARCHAR(20) NOT NULL,
  stop_distance_m INT NOT NULL,
  eta_seconds INT NOT NULL,
  ts TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_bus_latest ON bus_positions(bus_id, ts DESC);

-- Permisos al esquema público (si usas iotuser)
-- GRANT USAGE, CREATE ON SCHEMA public TO iotuser;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO iotuser;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO iotuser;
