
# Chargement des variables d'environnement depuis le fichier .env.local
source .env.local

CURRENT_DATE=$(date +%Y%m%d)

# Création du répertoire de sauvegarde avec les bonnes permissions
mkdir -p $BACKUP_DIR_BASE
chown $USER:$USER $BACKUP_DIR_BASE

# Supprimer les fichiers de sauvegarde datant de plus d'une semaine, sauf pour un fichier par jour de la semaine
for file in $(find $BACKUP_DIR_BASE -type f -name "backup_*.sql.gz" -mtime +7); do
    day=$(date -d "$(basename "$file" | cut -d'_' -f2 | cut -d'.' -f1)" "+%A")
    if [ "$day" != "Monday" ]; then
        rm "$file"
    fi
done

# Création du répertoire de sauvegarde du jour
BACKUP_DIR="$BACKUP_DIR_BASE/backup_$CURRENT_DATE"
mkdir -p $BACKUP_DIR/mysql

# Sauvegarde de la base de données
mysqldump --all-databases | gzip > $BACKUP_DIR/mysql/backup_$CURRENT_DATE.sql.gz

