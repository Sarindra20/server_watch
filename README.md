# ServerWatch

Application mobile de supervision de serveurs. Elle affiche l'état de plusieurs machines (en ligne ou hors ligne, CPU, RAM, disque) et détecte automatiquement quand un serveur cesse d'envoyer des mesures.

Projet personnel réalisé en autonomie dans le cadre de ma formation (L2 Informatique, Administration Système et Réseau).

## Captures d'écran

| Liste des serveurs | Détail d'un serveur | Ajout d'un serveur |
|---|---|---|
| ![Liste](docs/screenshots/liste.png) | ![Détail](docs/screenshots/detail.png) | ![Ajout](docs/screenshots/ajout.png) |

## Fonctionnement

```
Agent Python  →  API FastAPI  →  PostgreSQL  ←  Appli Flutter
(mesures)        (REST, JSON)     (données)      (affichage)
```

1. L'**agent** (`agent/`) mesure le CPU, la RAM et le disque de la machine toutes les 10 secondes et les envoie à l'API.
2. L'**API** (`api/`) enregistre les mesures dans PostgreSQL.
3. Un serveur est considéré **en ligne** s'il a envoyé une mesure dans les 90 dernières secondes, sinon **hors ligne**.
4. L'**appli mobile** (`lib/`) interroge l'API toutes les 5 secondes et met l'affichage à jour.

## Fonctionnalités

- Tableau de bord avec le nombre de serveurs en ligne et hors ligne
- Détail d'un serveur avec barres CPU, RAM et disque (vert, orange ou rouge selon la charge)
- Ajout et suppression de serveurs, enregistrés en base de données
- Actualisation automatique et gestion des erreurs réseau

## Technologies

- **Appli** : Flutter (Dart)
- **API** : Python, FastAPI, psycopg
- **Base de données** : PostgreSQL
- **Agent** : Python, psutil

## Lancer le projet

### 1. Base de données

Créer une base `server_watch` dans PostgreSQL, puis exécuter `database/schema.sql`.

### 2. API

```
cd api
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install fastapi uvicorn "psycopg[binary]" python-dotenv
```

Créer un fichier `api/.env` (non versionné) :

```
DB_HOST=localhost
DB_PORT=5432
DB_NAME=server_watch
DB_USER=postgres
DB_PASSWORD=votre_mot_de_passe
```

Lancer l'API :

```
.\.venv\Scripts\python.exe -m uvicorn main:app --reload
```

La documentation interactive est disponible sur `http://127.0.0.1:8000/docs`.

### 3. Agent de mesure

```
.\api\.venv\Scripts\python.exe -m pip install psutil requests
.\api\.venv\Scripts\python.exe agent\agent.py
```

### 4. Application

```
flutter pub get
flutter run -d chrome
```

## Prochaines étapes

- Graphique d'historique des mesures
- Notifications push quand un serveur tombe
- Authentification de l'API