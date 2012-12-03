PORT=8080
FQDN="wiki.nginx.org"
DOCUMENT_ROOT="/var/www"
SRV_GROUP=www-data
PASSWD_FILE="/etc/nginx/.htpasswd"
ALBUM_DIR=""
RESIZED_DIR="/.resized"
RESOURCES_DIR="/.resources"
CACHE_PATH="/var/www/.cache"
BIN_PATH="/var/www/.bin"
TMP_PATH="/var/www/.tmp"
BACKEND_SOCK="/tmp/album_backend.sock"
XSLT_FILE="/etc/nginx/album_index.xslt"
SIZE_THUMB=100
SIZE_FULL=800

SYNC_SRC_USR=album
SYNC_SRC_SRV=sync.source
SYNC_SRC=*
SYNC_SRV=127.0.0.1
SYNC_PORT=8099
SYNC_FILE=/tmp/synchronize.done

