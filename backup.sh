# Chargement des variables d'environnement depuis le fichier .env.local
source .env.local

CURRENT_DATE=$(date +%Y%m%d)
OLDER_DATE=$(date -d "3 days ago" +%Y%m%d)
BACKUP_DIR_BASE="/var/www/html/backup-auto/daily"

BACKUP_DIR=$BACKUP_DIR_BASE/$CURRENT_DATE
BACKUP_DIR_MYSQL=$BACKUP_DIR/mysql
BACKUP_DIR_CLONE=$BACKUP_DIR/rsync
# BACKUP_DIR_CLONE="/media/max/writable/$CURRENT_DATE"
# SOURCE_DIR="/var /etc /home /usr/local /root" 
SOURCE_DIR="/var/www/html/commit-auto" 

# Création du répertoire de sauvegarde avec les bonnes permissions
 mkdir -p "$BACKUP_DIR_CLONE"
 mkdir -p "$BACKUP_DIR_MYSQL"


# Récupération de la liste des bases de données
databases=$(mysql -u "$DB_USER" -p"$DB_PASSWORD" -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|sys)")

# Sauvegarde de chaque base de données séparément
for db in $databases; do
    mysqldump --single-transaction -u "$DB_USER" -p"$DB_PASSWORD" "$db" | gzip > "$BACKUP_DIR_MYSQL/$db-$CURRENT_DATE.sql.gz"
done

# Récupération de la liste des répertoires
# excluded_directories="--exclude=/var/cache --exclude=/var/tmp --exclude=/var/backups --exclude=/var/lib/docker --exclude=$BACKUP_DIR_BASE"
rsync -aAXv $excluded_directories  $SOURCE_DIR $BACKUP_DIR_CLONE

# Compression de l'archive
tar -czf "$BACKUP_DIR.tar.gz" -C "$BACKUP_DIR" .

# AWS S3 
if aws s3 cp "$BACKUP_DIR.tar.gz" s3://$S3_BUCKET/$CURRENT_DATE.tar.gz; then
    # Si la copie vers S3 réussit, supprimer les backups locaux et fichiers dans /daily
    rm -rf "$BACKUP_DIR"
    rm -rf "$BACKUP_DIR.tar.gz"
    echo "Backup local supprimé après transfert réussi vers AWS S3"
    
    # Suppression des fichiers du répertoire /daily
    rm -rf "/daily/*"
    echo "Fichiers dans /daily supprimés après transfert réussi vers S3"
else
    echo "Erreur lors du transfert vers AWS S3. Backup local non supprimé."
fi


# # Suppression de l'archive AWS S3 de plus de 3 jours
aws s3 rm s3://$S3_BUCKET/$OLDER_DATE.tar.gz