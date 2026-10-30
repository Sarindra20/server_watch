import os
import time

import psutil
import requests

API_URL = "http://127.0.0.1:8000"
SERVER_ID = 1          # l'identifiant du serveur dans la base
INTERVAL = 10          # secondes entre deux envois
DISK_PATH = os.path.abspath(os.sep)  # le disque où se trouve le script


def collect():
    return {
        "cpu": psutil.cpu_percent(interval=1),
        "ram": psutil.virtual_memory().percent,
        "disk": psutil.disk_usage(DISK_PATH).percent,
    }


def main():
    print(f"Agent démarré pour le serveur {SERVER_ID}, envoi toutes les {INTERVAL} s")
    while True:
        try:
            metrics = collect()
            response = requests.post(
                f"{API_URL}/servers/{SERVER_ID}/metrics",
                json=metrics,
                timeout=5,
            )
            print(f"Envoyé {metrics} -> {response.status_code}")
        except requests.RequestException as error:
            print(f"Échec de l'envoi : {error}")
        time.sleep(INTERVAL)


if __name__ == "__main__":
    main()