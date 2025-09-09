import time
from paho.mqtt import client as mqtt

broker = "broker.emqx.io"
topic = "fiusac/arqui2/g1/system/zone1/events"

# Forzar API versión 1
c = mqtt.Client()


c.connect(broker, 1883, 60)
c.loop_start()
for i in range(3):
    payload = f"test-event #{i}"
    print("PUB ->", payload)
    c.publish(topic, payload=payload, qos=1)
    time.sleep(1)
c.loop_stop()
c.disconnect()

