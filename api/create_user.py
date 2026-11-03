import getpass
import os

import psycopg
from dotenv import load_dotenv

from security import hash_password

load_dotenv()

username = input("Nom d'utilisateur : ").strip()
password = getpass.getpass("Mot de passe (12 caractères minimum) : ")
confirm = getpass.getpass("Confirme le mot de passe : ")

if not username:
    raise SystemExit("Refusé : le nom d'utilisateur est vide.")
if len(password) < 12:
    raise SystemExit(f"Refusé : mot de passe trop court ({len(password)} caractères).")
if password != confirm:
    raise SystemExit(
        f"Refusé : les deux saisies diffèrent ({len(password)} et {len(confirm)} caractères)."
    )

with psycopg.connect(
    host=os.getenv("DB_HOST", "localhost"),
    port=os.getenv("DB_PORT", "5432"),
    dbname=os.getenv("DB_NAME", "server_watch"),
    user=os.getenv("DB_USER", "postgres"),
    password=os.getenv("DB_PASSWORD"),
) as conn:
    conn.execute(
        "INSERT INTO users (username, password_hash) VALUES (%s, %s)",
        (username, hash_password(password)),
    )

print("Utilisateur créé.")