# Chargement des variables d'environnement depuis le fichier .env
source .env.local

CURRENT_DATE=$(date +%Y%m%d)

# Création du répertoire de sauvegarde avec les bonnes permissions
sudo mkdir -p $BACKUP_DIR_BASE
sudo chown $USER:$USER $BACKUP_DIR_BASE

# Création du répertoire de sauvegarde du jour
BACKUP_DIR="$BACKUP_DIR_BASE/backup_$CURRENT_DATE"
mkdir -p $BACKUP_DIR/html
mkdir -p $BACKUP_DIR/nginx
mkdir -p $BACKUP_DIR/mysql
mkdir -p $BACKUP_DIR/letsencrypt

# Sauvegarde du répertoire avec rsync
sudo rsync -aAXv /var/www/html/testNext/ $BACKUP_DIR/html
sudo rsync -aAXv /etc/nginx/ $BACKUP_DIR/nginx
sudo rsync -aAXv /etc/letsencrypt/ $BACKUP_DIR/letsencrypt
# Sauvegarde de la base de données
sudo mysqldump -u $DB_USER -p$DB_PASS --all-databases | gzip > $BACKUP_DIR/mysql/backup_$CURRENT_DATE.sql.gz

# Compression du répertoire
sudo tar czvf $BACKUP_DIR.tar.gz $BACKUP_DIR

# Suppression du répertoire de sauvegarde
sudo rm -rf $BACKUP_DIR

# Suppression des sauvegardes datant de plus de 7 jours
find $BACKUP_DIR_BASE -maxdepth 1 -type d -name "backup_*" -mtime +7 -exec rm -rf {} \;

