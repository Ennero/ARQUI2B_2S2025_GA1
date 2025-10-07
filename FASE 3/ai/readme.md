# FastAPI + AI Models
***Python >= 3.13.4***

---

## Installation

```bash
    # Create an isolated environment
    python3 -m venv ./.venv

    # Activate env
    source ./.venv/bin/activate # Linux/MacOS
    deactivate # Just in case you need to deactivate the env

    # Install Python dependencies
    pip3 install -r requirements.txt

    # Run the application
    fastapi dev src/main.py
```

---

## Use Docker containers

First, ensure you have the `.env` file with all the required variables configured.
Then, run this command in the terminal.

```bash
    docker compose up # pass '-d' flag to run it detached
```

---


## Add a new person to the face recognition model


```bash
    python3 src/utils/capture_faces.py --person "marcos"
    python src/train/faces.py
    fastapi dev src/main.py
```

Built with :blue_heart: by **Bondel Technologies S, A.**