# Projet Docker DevContainer

Bienvenue dans le projet Docker DevContainer! Ce projet utilise les DevContainers pour simplifier le développement et la configuration d'un environnement de développement Symfony

## Prérequis

Avant de commencer, assurez-vous d'avoir les éléments suivants installés sur votre machine :

- [Docker](https://www.docker.com/get-started)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Extension Remote - Containers pour VS Code](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

## Installation

1. Clonez ce dépôt sur votre machine locale :

    ```bash
    git clone https://github.com/votre-utilisateur/votre-repo.git
    ```

2. Ouvrez le projet dans Visual Studio Code :

    ```bash
    code votre-repo
    ```

3. Ouvrez le dossier `.devcontainer` et cliquez sur "Reopen in Container" pour lancer le DevContainer.

## Dockerfile  

Ce projet inclut un `Dockerfile` permettant de créer une image Docker optimisée pour exécuter une application PHP avec Symfony. Il intègre plusieurs outils et dépendances essentielles pour le développement.  

### 📦 Contenu du `Dockerfile`  

#### 🔹 Base de l’image  

- Utilise **PHP 8.3 CLI** comme image de base.  

#### 🔹 Installation des dépendances système  

- Installe des outils essentiels : `git`, `libicu-dev`, `libpq-dev`, `libzip-dev`, `unzip`, `wget`, `zip`, `curl`, `htop`.  
- Nettoie le cache après l'installation pour optimiser la taille de l’image.  

#### 🔹 Extensions PHP  

- Utilise `mlocati/php-extension-installer` pour ajouter les extensions suivantes :  
- `bcmath`, `gd`, `intl`, `mbstring`, `ctype`, `pdo_pgsql`, `tokenizer`, `pdo_mysql`, `mysqli`, `zip`, `xml`.  

#### 🔹 Outils supplémentaires  

- Installe **Composer** pour la gestion des dépendances PHP.  
- Installe le **Symfony CLI** pour faciliter le développement Symfony.  

#### 🔹 Node.js et Yarn  

- Ajoute **Node.js 18** et **Yarn** pour gérer les dépendances frontend.  

#### 🔹 Configuration du shell  

- Ajoute des alias utiles (`ll`, `ss`, `slog`).  
- Personnalise l’invite de commande (PS1) pour afficher des informations utiles.  

#### 🔹 Configuration de l’environnement de travail  

- Définit le répertoire `/workspace` comme dossier de travail par défaut.  

### 🚀 Utilisation  

#### 1️⃣ **Construire l’image Docker**  

```sh
docker build -t mon-image .
```

#### 2️⃣ **Lancer un conteneur basé sur cette image**  

```sh
docker run -it --rm -v $(pwd):/workspace -p 8000:8000 mon-image bash
```

#### 3️⃣ **Démarrer un serveur Symfony (via alias)**  

```sh
ss
```

Ce `Dockerfile` est conçu pour faciliter le développement avec Symfony et inclut tous les outils nécessaires pour un environnement de travail prêt à l’emploi. 🎯  

## 🐳 Docker Compose Configuration  

Ce projet inclut un fichier `docker-compose.yml` permettant de lancer un environnement de développement complet pour une application Symfony. Il comprend plusieurs services essentiels : PHP, une base de données MariaDB, PhpMyAdmin et un serveur SMTP pour le développement des emails.  

### 📌 Services  

#### 🔹 **dev** (Environnement PHP)  

- Utilise l’image **symfony_dev_container_php8.3:latest** construite à partir du `Dockerfile`.  
- Monte le projet local dans `/workspace` pour un développement en direct.  
- Expose le port **8000** pour l’exécution de Symfony.  
- Définit les variables d’environnement comme `DATABASE_URL` et `MAILER_DSN`.  
- Commande de démarrage : `sleep infinity` (le conteneur reste actif).  

#### 🔹 **database** (MariaDB)  

- Utilise **MariaDB** pour stocker les données.  
- Redémarre automatiquement en cas d’arrêt.  
- Définit les variables d’environnement pour le mot de passe root, le nom de la base de données et l’utilisateur.  
- Monte un volume `database_data` pour persister les données.  
- Expose le port **3306** pour les connexions à la base de données.  

#### 🔹 **phpmyadmin**  

- Utilise l’image officielle **phpmyadmin**.  
- Exposé sur le port **8080** pour gérer la base de données via une interface graphique.  
- Connecté automatiquement au service `database`.  

#### 🔹 **mailer** (Serveur SMTP pour le développement)  

- Utilise **Mailpit** pour tester l’envoi d’e-mails en local.  
- Expose les ports :  
  - **1025** pour le SMTP  
  - **8025** pour l’interface web (accès : `http://localhost:8025`).  
- Désactive les restrictions d’authentification pour simplifier les tests.  

### 🚀 Démarrer l’environnement  

1️⃣ **Lancer tous les services**  

```sh
docker-compose up -d
```

2️⃣ **Accéder aux services**  

- Symfony (si démarré via `symfony serve`) → [http://localhost:8000](http://localhost:8000)  
- PhpMyAdmin → [http://localhost:8080](http://localhost:8080)  
- Mailpit (test des e-mails) → [http://localhost:8025](http://localhost:8025)  

3️⃣ **Arrêter les services**  

```sh
docker-compose down
```

Ce `docker-compose.yml` est conçu pour un environnement de développement Symfony complet, avec une base de données persistante et des outils de gestion simplifiés. 🚀  
