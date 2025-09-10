# API

**Python version 3.13.4**

### Installation guide

First, ensure you the respective `.env` file with the correct credentials according to your execution environment placed a the root of this location.

#### Create Virtual Environment
```bash
    # Create Virtual Enviroment
    python3 -m venv .venv
```

#### Activate Virtual Environment
```bash
    # Linux/MacOS
    source .venv/bin/activate 
    # Windows powershell
    .venv\Scripts\Activate.ps1
    # Windows bash
    source .venv/Scripts/activate
```

#### Install packages
```bash
    # Install Python packages from the requirements.txt
    pip3 install -r requirements.txt
```

#### Run App
```bash
    # Run App
    fastapi dev main.py
```

*You should get an output like this:*

![Output](./docs/img/run_app_output.png)