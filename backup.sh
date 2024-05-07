# Chargement des variables d'environnement depuis le fichier .env.local
source .env.local

CURRENT_DATE=$(date +%Y%m%d)
OLDER_DATE=$(date -d "3 days ago" +%Y%m%d)

BACKUP_DIR_BASE=$BACKUP_DIR_BASE
BACKUP_DIR=$BACKUP_DIR_BASE/$CURRENT_DATE
BACKUP_DIR_MYSQL=$BACKUP_DIR/mysql
BACKUP_DIR_CLONE=$BACKUP_DIR/rsync
# BACKUP_DIR_CLONE="/media/max/writable/$CURRENT_DATE"
SOURCE_DIR="/var /etc /home /usr/local /root" 

# Création du répertoire de sauvegarde avec les bonnes permissions
sudo mkdir -p "$BACKUP_DIR_CLONE"
sudo chown "$DB_USER:$DB_USER" "$BACKUP_DIR_CLONE"
sudo mkdir -p "$BACKUP_DIR_MYSQL"
sudo chown "$DB_USER:$DB_USER" "$BACKUP_DIR_MYSQL"


# Récupération de la liste des bases de données
databases=$(mysql -u "$DB_USER" -p"$DB_PASSWORD" -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|sys)")

# Sauvegarde de chaque base de données séparément
for db in $databases; do
    mysqldump --single-transaction -u "$DB_USER" -p"$DB_PASSWORD" "$db" | gzip > "$BACKUP_DIR_MYSQL/$db-$CURRENT_DATE.sql.gz"
done

# Récupération de la liste des répertoires
excluded_directories="--exclude=/var/cache --exclude=/var/tmp --exclude=/var/backups --exclude=/var/lib/docker --exclude=$BACKUP_DIR_BASE"
rsync -aAXv $excluded_directories  $SOURCE_DIR $BACKUP_DIR_CLONE

# Compression de l'archive
tar -czf "$BACKUP_DIR.tar.gz" -C "$BACKUP_DIR_CLONE" .

# Suppression des fichiers temporaires
rm -rf "$BACKUP_DIR"

# Supprimer les backups de plus de 3 jours
rm -rf $BACKUP_DIR_BASE/$OLDER_DATE.tar.gz
echo "Backup $OLDER_DATE terminé"
# AWS S3 
aws s3 cp "$BACKUP_DIR.tar.gz" s3://$S3_BUCKET/$CURRENT_DATE.tar.gz

# # Suppression de l'archive AWS S3 de plus de 3 jours
aws s3 rm s3://$S3_BUCKET/$OLDER_DATE.tar.gz


