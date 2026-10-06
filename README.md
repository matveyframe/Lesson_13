1) Запустить простой http-сервер https://gist.github.com/anestesia001/f50a3430d3152830bf30bab3138c6923 как systemd demon. Приложение должно работать от имени пользователя web-user
 ```
[Unit]
Description= http service
After=network-online.target

[Service]
User=webuser
Group=webuser
WorkingDirectory=/var/www/http_service
ExecStart=/var/www/http_service/app/venv/bin/python /var/www/http_service/app/http_service.py
Restart=Always

[Install]
WantedBy=multi-user.target

```
2) Написать скрипт для проверки запущенного в п1 http-сервера. Скрипт должен проверять
    <p>-статус демона</p>
    <p>-доступность порта приложения</p>
    <p>-ответ эндпоинта /health (в ответе должен быть ok)</p>
  
```
#!bin/bash

SERVICE_NAME="lesson13.service"
PORT=8080
URL="http://localhost:$PORT/health"
HEALTH=$(curl -s "$URL")

if systemctl is-active -q $SERVICE_NAME; then
	echo "Service is active"
else 
	echo "service is inactive"
fi
	
if ss -tuln | grep -q ":$PORT "; then
	echo "Port is open"
else
	echo "Port not open"
fi 


if [[ "$HEALTH" == *"ok"* ]]; then
	echo "successfully! Server is Work"
else
	echo "Error! Server not working"
fi

```

![](https://github.com/matveyframe/Lesson_13/blob/main/status%20lesson13_service.PNG "Logo Title Text 1")

3)Создать репозиторий, где будет лежать код приложения из п1 и его unit file
<p><a href="https://github.com/matveyframe/Lesson_13">Ссылка на репозиторий</a></p>

4)Написать скрипт для автоматического развертывания приложения из репозитория в п3. Скрипт должен
<p>-проверять есть ли пользователь web-user, если нет - создавать его </p>
<p>-проверять существует ли директория для проекта, если нет - создавать </p>
<p>-после развертывания проверять ответ эндпоинта /health (в ответе должен быть ok) </p>
<p>-логировать все действия в файл /var/log/http-server-deploy.log </p>

```
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
else useradd -m -s /bin/bash "$APP_USER" >> "$LOG_FILE" 2>&1 
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

```

![](https://github.com/matveyframe/Lesson_13/blob/main/status%20lesson13_service_From_REP.PNG "Logo Title Text 1")
