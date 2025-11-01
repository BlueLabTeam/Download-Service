#!/usr/bin/env bash
# provision-gestcoop.sh
set -euo pipefail
IFS=$'\n\t'

# ===== Colores y logging =====
GREEN='\033[0;32m' ; YELLOW='\033[1;33m' ; RED='\033[0;31m' ; NC='\033[0m'
log(){  echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $*${NC}"; }
info(){ echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] $*${NC}"; }
err(){  echo -e "${RED}ERROR: $*${NC}" >&2; exit 1; }

trap 'err "Fallo en la línea $LINENO (exit $?)"' ERR

# ===== Variables configurables =====
REPO_URL="${1:-${REPO_URL:-}}"          # 1er argumento o variable de entorno
TARGET_DIR="${TARGET_DIR:-/srv/}"
DC_FILE="${DC_FILE:-docker-compose.yml}"
APP_SERVICE="${APP_SERVICE:-gestcoop_php}"
DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-3306}"
WAIT_TIMEOUT="${WAIT_TIMEOUT:-60}"
ENV_FILE_PATH="${ENV_FILE_PATH:-./gestcoop-env/.env}"  # Path al .env de producción
BACKUP_HOUR="${BACKUP_HOUR:-2}"  # Hora del día para backup (0-23)

# ===== Usuario real (para chown) =====
REAL_USER="${SUDO_USER:-$(logname 2>/dev/null || echo $USER)}"

# ===== sudo helper =====
if [ "$(id -u)" -ne 0 ]; then
  if command -v sudo >/dev/null 2>&1; then SUDO='sudo'; else err "Necesitás sudo o root"; fi
else
  SUDO=''
fi

# ===== Detección de OS =====
detect_os(){
  if [ -f /etc/os-release ]; then . /etc/os-release; OS=$ID; OS_VER=$VERSION_ID; else OS=unknown; fi
}
detect_os
log "OS detectado: ${OS:-unknown} ${OS_VER:-}"

# ===== Paquetes básicos =====
update_and_install(){
  log "Actualizando e instalando herramientas básicas..."
  case "$OS" in
    ubuntu|debian)
      $SUDO apt-get update -y
      $SUDO apt-get install -y curl git wget ca-certificates gnupg lsb-release unzip netcat-openbsd
      ;;
    centos|rhel|rocky)
      $SUDO dnf install -y curl git wget ca-certificates unzip nc
      ;;
    fedora)
      $SUDO dnf install -y curl git wget ca-certificates unzip nc
      ;;
    *)
      err "Instalación automática no soportada para $OS. Instala dependencias manualmente."
      ;;
  esac
}

# ===== Instalación de Docker =====
install_docker(){
  if command -v docker >/dev/null 2>&1; then
    log "Docker ya instalado: $(docker --version)"
    return
  fi
  log "Instalando Docker (modo automático para Debian/Ubuntu/Rocky)..."

  if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
    $SUDO apt-get remove -y docker docker-engine docker.io containerd runc || true
    $SUDO apt-get update -y
    $SUDO apt-get install -y ca-certificates curl gnupg lsb-release
    $SUDO mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $SUDO gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | $SUDO tee /etc/apt/sources.list.d/docker.list > /dev/null
    $SUDO apt-get update -y
    $SUDO apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  elif [[ "$OS" == "rocky" || "$OS" == "centos" || "$OS" == "rhel" ]]; then
    log "Instalando Docker en $OS vía repos oficial"
    $SUDO dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine || true
    $SUDO dnf -y install dnf-plugins-core
    $SUDO dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    $SUDO dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    $SUDO systemctl enable --now docker
  else
    err "Instalación automática de Docker no implementada para $OS. Instálalo manualmente."
  fi

  # Añadir usuario al grupo docker
  $SUDO usermod -aG docker "$REAL_USER" || true

  log "Docker instalado (versión: $(docker --version || echo 'no disponible'))"
}

# ===== Helper para comando docker compose =====
docker_compose_cmd(){
  if docker compose version >/dev/null 2>&1; then
    echo "docker compose"
  elif command -v docker-compose >/dev/null 2>&1; then
    echo "docker-compose"
  else
    echo "docker-compose"
  fi
}

# ===== Clonar/actualizar repo =====
clone_repo(){
  local repo="$1"; local target="$2"
  if [ -z "$repo" ]; then err "REPO_URL no provisto"; fi
  log "Clonando/actualizando repo: $repo -> $target"
  if [ -d "$target/.git" ]; then
    $SUDO chown -R "$REAL_USER":"$REAL_USER" "$target"
    $SUDO -u "$REAL_USER" bash -lc "cd '$target' && git fetch --all && git reset --hard origin/main || git pull"
  else
    $SUDO mkdir -p "$target"
    $SUDO chown "$REAL_USER":"$REAL_USER" "$target"
    $SUDO -u "$REAL_USER" git clone "$repo" "$target"
  fi
}

# ===== Espera TCP =====
wait_for_tcp(){
  local host=$1; local port=$2; local timeout=$3
  log "Esperando $host:$port (timeout ${timeout}s)..."
  local start=$(date +%s)
  while ! nc -z "$host" "$port" >/dev/null 2>&1; do
    sleep 1
    if [ $(( $(date +%s) - start )) -ge "$timeout" ]; then
      err "Timeout esperando $host:$port"
    fi
  done
  log "$host:$port accesible"
}

# ===== Setup del proyecto =====
setup_project(){
  local dir="$1"
  cd "$dir"
  local dc=$(docker_compose_cmd)
  log "Construyendo e iniciando contenedores con: $dc -f $DC_FILE up -d"
  $SUDO $dc -f "$DC_FILE" build --no-cache || $SUDO $dc -f "$DC_FILE" build || true
  $SUDO $dc -f "$DC_FILE" up -d

  # Esperar DB
  wait_for_tcp "${DB_HOST}" "${DB_PORT}" "${WAIT_TIMEOUT}"

  # Composer si existe composer.json
  if [ -f composer.json ]; then
    log "Se detectó composer.json. Intentando composer install en ${APP_SERVICE}..."
    if $SUDO $dc -f "$DC_FILE" exec -T "$APP_SERVICE" composer --version >/dev/null 2>&1; then
      $SUDO $dc -f "$DC_FILE" exec -T "$APP_SERVICE" composer install --no-interaction --prefer-dist || true
    else
      log "Composer no está en la imagen. Instala dependencias desde host o agrega composer a la imagen."
    fi
  fi

  # # Storage
  mkdir -p storage/
  # # Permisos en storage/uploads
  # if [ -d storage/uploads ]; then
  #   log "Ajustando permisos en storage/uploads..."
  #   $SUDO chmod -R 775 storage/uploads || true
  #   if $SUDO $dc -f "$DC_FILE" exec -T "$APP_SERVICE" id www-data >/dev/null 2>&1; then
  #     $SUDO $dc -f "$DC_FILE" exec -T "$APP_SERVICE" chown -R www-data:www-data /var/www/storage/uploads || true
  #   fi
  # fi

  # Permisos en public
  if [ -d public ]; then
    log "Ajustando permisos en public..."
    $SUDO chmod -R 755 public || true
  fi

  if [ -f scripts/backup-db.sh ]; then
    log "Se detectó scripts/backup-db.sh. Ajustando permisos..."
    $SUDO chmod +x scripts/backup-db.sh || true
  fi

  #crontab

  info "Configurando tarea cron para backup diario a las 2am..."
  (crontab -l 2>/dev/null; echo "0 2 * * * bash $(pwd)/scripts/backup.sh >> $(pwd)/logs/backup.log 2>&1") | crontab -


  log "Setup completado."
}

backups(){
  PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
  SCRIPT_PATH="$PROJECT_DIR/scripts/backup.sh"
  LOG_PATH="$PROJECT_DIR/logs/cron_backup.log"

  HORA="${1:-2}"

  # Cron job (hora configurable)
  CRON_JOB="0 $HORA * * * cd $PROJECT_DIR && ./scripts/backup.sh >> $LOG_PATH 2>&1"

  echo "🔧 Configurando cron para ejecutar backups diarios a las $HORA:00..."

  # Asegurar que cron esté instalado
  if ! command -v cron &> /dev/null; then
    echo "📦 Instalando cron..."
    sudo apt update && sudo apt install -y cron
  fi

  # Crear carpeta si no existe
  mkdir -p "$PROJECT_DIR/storage/backups"

  # Agregar job (evitando duplicados)
  (crontab -l 2>/dev/null | grep -v "$SCRIPT_PATH" ; echo "$CRON_JOB") | crontab -

  # Reiniciar servicio cron
  sudo service cron restart

  echo "✅ Cron configurado correctamente."
  echo "   El backup se ejecutará todos los días a las $HORA:00 y se guardará en storage/backups/"
}

### ===== MAIN =====
log "Iniciando provisioning para GestCoop"

if [ -z "${REPO_URL:-}" ]; then
  log "Introduce la URL SSH de tu repositorio (ej: git@github.com:usuario/repo.git): "
  read -r REPO_URL
fi
[ -n "$REPO_URL" ] || err "No proporcionaste REPO_URL."

update_and_install
install_docker

log "Si te añadí al grupo docker, cerrá sesión y volvé a entrar para evitar usar sudo en docker."

clone_repo "$REPO_URL" "$TARGET_DIR"

# Copiar .env si no existe
if [ ! -f "$TARGET_DIR/.env" ]; then
    if [ -f "$ENV_FILE_PATH" ]; then
        log "Copiando .env desde $ENV_FILE_PATH..."
        cp "$ENV_FILE_PATH" "$TARGET_DIR/.env"
    else
        err "No se encontró .env en $ENV_FILE_PATH. Proporciona uno válido."
    fi
fi

setup_project "$TARGET_DIR"

backups ${BACKUP_HOUR:-2}

log "Provisionamiento completado. Revisa 'docker ps' para ver contenedores corriendo."
log "Contenedores activos:"
$SUDO $(docker_compose_cmd) -f "$DC_FILE" ps
