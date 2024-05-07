# Backup-auto

**Backup-auto** est un script automatique de sauvegarde conçu pour les systèmes Linux. Il permet de sauvegarder les bases de données MySQL ainsi que les fichiers et répertoires spécifiés sur le système.

## Instructions

1. **Configuration des variables d'environnement** :
   - Le script charge les variables d'environnement depuis le fichier `.env.local`. Assurez-vous que ce fichier contienne les variables nécessaires avec les informations correctes. Ces variables incluent :
     - `DB_USER` : Le nom d'utilisateur de la base de données MySQL.
     - `DB_PASSWORD` : Le mot de passe de l'utilisateur de la base de données MySQL.
     - `BACKUP_DIR_BASE` : Le répertoire de base où seront stockées les sauvegardes.
     - `AWS_S3_BUCKET` : Le nom du bucket S3 d'Amazon Web Services où les sauvegardes seront envoyées.

2. **Exécution du script** :
   - Exécutez le script `backup-auto.sh` pour lancer le processus de sauvegarde. Assurez-vous d'avoir les permissions appropriées pour exécuter les commandes nécessaires, notamment pour accéder aux bases de données MySQL et créer/supprimer des fichiers sur le système.

## Fonctionnement du script

Le script fonctionne de la manière suivante :

1. **Création des répertoires de sauvegarde** :
   - Il crée les répertoires de sauvegarde pour les bases de données MySQL et les fichiers clonés à partir de la source spécifiée.

2. **Sauvegarde des bases de données MySQL** :
   - Il effectue une sauvegarde de chaque base de données MySQL dans un fichier compressé avec la date actuelle dans son nom.

3. **Clonage des fichiers source** :
   - Il clone les fichiers et répertoires spécifiés depuis la source vers le répertoire de sauvegarde.

4. **Compression de l'archive** :
   - Il compresse l'ensemble des fichiers clonés dans une archive tar.gz portant la date actuelle dans son nom.

5. **Suppression des fichiers temporaires** :
   - Il supprime les fichiers temporaires utilisés pour la sauvegarde.

6. **Suppression des sauvegardes de plus de 3 jours** :
   - Il supprime les sauvegardes datant de plus de 3 jours pour libérer de l'espace.

7. **Envoi vers AWS S3** :
   - Il envoie l'archive compressée vers un bucket S3 d'Amazon Web Services pour une sauvegarde sécurisée.
