#!/bin/bash

SERVICE_NAME="lesson13.service"
PORT=8080
URL="http://localhost:$PORT/health"
APP_USER="webuser"
APP_DIR="/var/www/http_service/app"
REP_DIR="https://github.com/matveyframe/Lesson_13.git" 
LOG_FILE="/var/log/http-server-deploy.log"
SERVICE_NAME="lesson13.service"

log() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$message"
    echo "$message" >> "$LOG_FILE"
}

user_add() {
if id "$APP_USER"  &>/dev/null; then
	log "$APP_USER already exists"
else useradd /bin/bash "$APP_USER" >> "$LOG_FILE" 2>&1 
 log "User $APP_USER successfully created"
fi
}

check_dir() {
if [ -d "$APP_DIR" ]; then
 log "The directory $APP_DIR already exists"
else mkdir -p "$APP_DIR" >>"$LOG_FILE" 2>&1
 log "Directory successfully created"
fi
}

health_check() {
HEALTH=$(curl -s "$URL")
if [[ "$HEALTH" == *"ok"* ]]; then
        log "successfully! Server is Work"
else 
        log "Error! Server not working"
fi
}

deploy_app() {
if [ -d "$APP_DIR/.git" ]; then
 log "The repository already exists. Updating code..."
 cd "$APP_DIR" && git pull >> "$LOG_FILE" 2>&1
else sudo git clone "$REP_DIR" "$APP_DIR" >> "$LOG_FILE" 2>&1
 log "repository successfully cloned"
fi
chown -R "$APP_USER":"$APP_USER" "$APP_DIR"
sudo cp "$APP_DIR/lesson13.service" /etc/systemd/system/
python3 -m venv app/venv 
sudo systemctl daemon-reload		
systemctl restart $SERVICE_NAME
log "service $SERVICE_NAME is restarting"
sleep 5 
}

user_add
check_dir
deploy_app
health_check
