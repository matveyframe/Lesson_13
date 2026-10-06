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
