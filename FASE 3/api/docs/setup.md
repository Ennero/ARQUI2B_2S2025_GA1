# Setup


### Init virtual env
```shell
    python -m venv .venv
    source .venv/bin/activate
    deactivate # deactivate env
    pip3 freeze > requirements.txt # Generate requirements.txt
    pip3 install -r requirements.txt # Install packages from the requirements.txt
```

### Run App
```bash
    fastapi dev main.**py**
```


### Setup
This is just a guide on how I started this project.

```bash
python3 -m venv .venv
pip3 install "fastapi[standard]"
pip3 install motor
pip3 install python-dotenv
pip3 install pydantic_settings
```



### Troubleshooting

```shell
    pip3 install -r requirements.txt --break-system-packages # Install packages from the requirements.txt
    pip3 freeze > requirements.txt --break-system-packages
```

```shell
    ssh fichaje@123.local
    # password: fichaje
```

```bash
    sudo pigpiod
    python3 ./main.py
```

### Credentials

#### Connect to MongoDB Atlas

In order to get access to your cluster, your `.env` file must have the following structure:
```env
MONGODB_URI=mongodb+srv://<username>:<password>@arqui1g11siepacluster.r2uoqj2.mongodb.net/?retryWrites=true&w=majority&appName=Arqui1G11SiepaCluster
```


### Siepa Deamon On Raspberry PI

The service file is located at

```
/etc/systemd/system/siepa.service
```

Any change in that file requires deamon and service reload

```bash
    sudo systemctl daemon-reload
    sudo systemctl enable siepa
    sudo systemctl restart siepa
```

#### Check Siepa services status

```bash
    sudo systemctl status siepa.service
```

#### Stop the service

```bash
    sudo systemctl stop siepa.service
```

#### Enable/Disable the service

```bash
    sudo systemctl disable siepa.service
    sudo systemctl enable siepa.service
```

#### Start the service

```bash
    sudo systemctl start siepa.service
```

#### Restart the service

```bash
    sudo systemctl restart siepa.service
```

#### Track logs on live

```bash
    journalctl -u siepa.service -f
```

### Turn the Raspberry PI off

```bash
    sudo shutdown now
```

```bash
i2cdetect -y 1
```




```
{
  "summary": {
    "recorridoTransmetro": 57,
    "recorridoTransurbano": 13,
    "calidadAirePromedio": 158.5,
    "alertasCriticas": 2
  },
  "airQualityChart": {
    "label": "Calidad del Aire (Hoy)",
    "dataPoints": [
      { "hour": 0, "value": 178.4 },
      { "hour": 2, "value": 205.1 },
      { "hour": 4, "value": 129.9 },
      { "hour": 6, "value": 155.6 },
      { "hour": 8, "value": 188.2 },
      { "hour": 10, "value": 215.7 },
      { "hour": 12, "value": 140.3 },
      { "hour": 14, "value": 199.0 },
      { "hour": 16, "value": 162.8 },
      { "hour": 18, "value": 145.4 },
      { "hour": 20, "value": 218.1 },
      { "hour": 22, "value": 133.7 }
    ]
  }
}



SEM1=VERDE;SEM2=ROJO;BUS1=120;BUS2=80;PM1=155;PM2=162;INC1=0;INC2=0;PANICO1=0;PANICO2=0;PANICO3=1;PANICO4=0;PANICO5=0;SISMO=0;INFRAA=0;INFRAB=1;INFRAC=0;INFRAD=0;DIST1=0;DIST2=0
```