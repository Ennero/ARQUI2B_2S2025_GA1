# Setup

### Serial message example

```
SEM1=AMARILLO;SEM2=ROJO;BUS1=64;BUS2=12;PM1=267;PM2=100;INC1=0;INC2=0;PANICO1=0;PANICO2=0;PANICO3=0;PANICO4=0;PANICO5=0;SISMO=0
SEM1=AMARILLO;SEM2=ROJO;BUS1=66;BUS2=13;PM1=275;PM2=112;INC1=0;INC2=0;PANICO1=0;PANICO2=0;PANICO3=0;PANICO4=0;PANICO5=0;SISMO=0
SEM1=AMARILLO;SEM2=ROJO;BUS1=68;BUS2=14;PM1=274;PM2=115;INC1=0;INC2=0;PANICO1=0;PANICO2=0;PANICO3=0;PANICO4=0;PANICO5=0;SISMO=0
SEM1=AMARILLO;SEM2=ROJO;BUS1=70;BUS2=15;PM1=289;PM2=107;INC1=0;INC2=0;PANICO1=0;PANICO2=0;PANICO3=0;PANICO4=0;PANICO5=0;SISMO=0
SEM1=AMARILLO;SEM2=ROJO;BUS1=72;BUS2=16;PM1=282;PM2=100;INC1=0;INC2=0;PANICO1=0;PANICO2=0;PANICO3=0;PANICO4=0;PANICO5=0;SISMO=0
SEM1=AMARILLO;SEM2=ROJO;BUS1=74;BUS2=17;PM1=276;PM2=101;INC1=0;INC2=0;PANICO1=0;PANICO2=0;PANICO3=0;PANICO4=0;PANICO5=0;SISMO=0
SEM1=AMARILLO;SEM2=ROJO;BUS1=76;BUS2=18;PM1=264;PM2=103;INC1=0;INC2=0;PANICO1=0;PANICO2=0;PANICO3=0;PANICO4=0;PANICO5=0;SISMO=0
SEM1=AMARILLO;SEM2=ROJO;BUS1=78;BUS2=19;PM1=254;PM2=100;INC1=0;INC2=0;PANICO1=0;PANICO2=0;PANICO3=0;PANICO4=0;PANICO5=0;SISMO=0
SEM1=VERDE;SEM2=AMARILLO;BUS1=80;BUS2=20;PM1=265;PM2=100;INC1=0;INC2=0;PANICO1=0;PANICO2=0;PANICO3=0;PANICO4=0;PANICO5=0;SISMO=0
SEM1=VERDE;SEM2=AMARILLO;BUS1=82;BUS2=21;PM1=255;PM2=104;INC1=0;INC2=0;PANICO1=0;PANICO2=0;PANICO3=0;PANICO4=0;PANICO5=0;SISMO=0
SEM1=VERDE;SEM2=AMARILLO;BUS1=84;BUS2=22;PM1=247;PM2=118;INC1=0;INC2=0;PANICO1=0;PANICO2=0;PANICO3=0;PANICO4=0;PANICO5=0;SISMO=0
SEM1=VERDE;SEM2=AMARILLO;BUS1=86;BUS2=23;PM1=240;PM2=127;INC1=0;INC2=0;PANICO1=0;PANICO2=0;PANICO3=0;PANICO4=0;PANICO5=0;SISMO=0
SEM1=VERDE;SEM2=AMARILLO;BUS1=88;BUS2=24;PM1=249;PM2=140;INC1=0;INC2=0;PANICO1=0;PANICO2=0;PANICO3=0;PANICO4=0;PANICO5=0;SISMO=0
SEM1=VERDE;SEM2=AMARILLO;BUS1=90;BUS2=25;PM1=261;PM2=136;INC1=0;INC2=0;PANICO1=0;PANICO2=0;PANICO3=0;PANICO4=0;PANICO5=0;SISMO=0
```


### Init virtual env
```shell
    python3 -m venv env
    source ./env/bin/activate
    deactivate # deactivate env
    pip3 freeze > requirements.txt # Generate requirements.txt
    pip3 install -r requirements.txt # Install packages from the requirements.txt
```

### Run the app manually
```bash
    python3 ./main.py
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