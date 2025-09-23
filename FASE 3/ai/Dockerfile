FROM python:3.13.4-slim-bullseye AS development
WORKDIR /app
COPY . .

# Create a virtual environment
RUN python -m venv /opt/venv
# Activate the virtual environment
ENV PATH="/opt/venv/bin:$PATH"

RUN pip install -r requirements.txt
EXPOSE 8000
CMD ["fastapi", "dev", "src/main.py"]