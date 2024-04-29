# Chargement des variables d'environnement depuis le fichier .env.local
source .env.local

CURRENT_DATE=$(date +%Y%m%d)

# Création du répertoire de sauvegarde avec les bonnes permissions
mkdir -p $BACKUP_DIR_BASE/$CURRENT_DATE
chown $DB_USER:$DB_USER $BACKUP_DIR_BASE

# Supprimer les fichiers de sauvegarde datant de plus d'une semaine, sauf pour un fichier par jour de la semaine
for file in $(find $BACKUP_DIR_BASE/$CURRENT_DATE -type f -name "backup_*.sql.gz" -mtime +7); do
    day=$(date -d "$(basename "$file" | cut -d'_' -f2 | cut -d'.' -f1)" "+%A")
    if [ "$day" != "Monday" ]; then
        rm "$file"
    fi
done

# Récupération de la liste des bases de données
databases=$(mysql -u "$DB_USER" -p"$DB_PASSWORD" -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|sys)")

# # Sauvegarde de chaque base de données séparément
for db in $databases; do
    mysqldump --single-transaction -u "$DB_USER" -p"$DB_PASSWORD" "$db" | gzip > "$BACKUP_DIR_BASE/$CURRENT_DATE/mysql/$db-$CURRENT_DATE.sql.gz"
done