# Fleuropa 

> Plateforme web de gestion et de vente en ligne de fleurs coupées et compositions florales.

---

## Présentation du projet

**Fleuropa** est une application web conçue pour moderniser et simplifier la distribution florale. Inspiré des besoins réels des grossistes et artisans fleuristes, le site offre une vitrine numérique intuitive permettant de valoriser les arrivages, d'optimiser la gestion des stocks de fleurs fraîches et de faciliter le passage de commandes.

### Objectifs et but du projet
- **Mise en valeur du catalogue** : Présenter une gamme variée de fleurs de saison, feuillages et compositions florales avec photos, descriptifs et fiches détaillées.
- **Fluidification des commandes** : Offrir aux clients une expérience fluide pour consulter les stocks disponibles et passer commande rapidement.
- **Gestion des stocks & logistique** : Répondre à la contrainte de périssabilité des produits floraux grâce à une gestion dynamique des disponibilités en base de données.
- **Accessibilité & réactivité** : Proposer une interface web accessible depuis ordinateurs, tablettes et smartphones.

---

## Stack technologique

Le projet repose sur une architecture web moderne, légère et robuste :

### Backend
- **[Python](https://www.python.org/)** : Langage principal pour la logique métier et le traitement des requêtes (`main.py`).
- **[Flask](https://flask.palletsprojects.com/)** : Micro-framework léger et modulable assurant le routage, la gestion des sessions et le rendu dynamique.
- **SQL / Connexion BDD** : Gestion de la persistance des données via requêtes SQL (`db.py` / `dump.sql`).

### Frontend
- **HTML5 & Jinja2** : Moteur de templates pour la génération dynamique des pages (`templates/`).
- **CSS3** : Feuille de styles personnalisée pour l'agencement visuel, les animations et le responsive design (`style.css`, `static/`).
- **JavaScript (Vanilla)** : Interactivité côté client (validation de formulaires, filtres dynamiques, gestion du panier).

---

## Méthodes et architecture

Le projet suit les principes de séparation des responsabilités pour faciliter sa maintenance et son évolution :

1. **Architecture Modulaire (Pattern MVC adapté)** :
   - **Modèle (`db.py`)** : Couche d'accès aux données, requêtes préparées, initialisation et interactions avec la base (`dump.sql`).
   - **Contrôleur (`main.py`)** : Définition des routes HTTP, contrôle des entrées utilisateur, authentification et coordination de la logique métier.
   - **Vue (`templates/`, `static/`)** : Gabarits HTML découpés (header, footer, fiches produits) stylisés via les ressources statiques.

2. **Cycle de vie de la donnée** :
   - Schéma relationnel stockant les tables clés : produits, catégories, utilisateurs et commandes.
   - Script de dump (`dump.sql`) permettant de reconstituer facilement la base de données avec des jeux d'essai.

---

## Structure du projet

```text
FLEUROPA/
├── static/              # Fichiers statiques (images, scripts JS, polices)
├── templates/           # Templates HTML Jinja2 (pages d'accueil, catalogue, panier, etc.)
├── .gitignore           # Exclusion des fichiers temporaires (.DS_Store, caches...)
├── db.py                # Fonctions d'accès et requêtes à la base de données
├── dump.sql             # Schéma et données initiales de la base de données
├── main.py              # Point d'entrée de l'application Flask
├── rapport.pdf          # Rapport technique / documentation du projet
├── style.css            # Styles CSS principaux
└── README.md            # Documentation du dépôt
```

---

## Installation et exécution

### Prérequis
- **Python 3.8+** installé
- **Git** installé

### 1. Cloner le dépôt
```bash
git clone https://github.com/SM4TH13/FLEUROPA.git
cd FLEUROPA
```

### 2. Créer et activer un environnement virtuel (recommandé)
```bash
# Sous macOS / Linux :
python3 -m venv venv
source venv/bin/activate

# Sous Windows :
python -m venv venv
venv\Scripts\activate
```

### 3. Installer les dépendances
```bash
pip install flask
# (installez les packages additionnels selon votre environnement, ex: mysql-connector-python, etc.)
```

### 4. Initialiser la base de données
Importez le fichier `dump.sql` dans votre serveur de base de données (SQLite ou MySQL selon la configuration définie dans `db.py`).

### 5. Lancer l'application
```bash
python main.py
```
L'application sera accessible localement à l'adresse suivante : **`http://127.0.0.1:5000`**.

---

