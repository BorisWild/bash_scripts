#!/bin/bash
#restart docker if 5** status resieved from backend host
#create log file
#touch reloadlog.log
#chmod 0777 reloadlog.log

#volume attached to container:
#sudo mkdir /var/log/service
#sudo chown -R root:www-data service
#sudo chmod 775 -R /var/log/service

URL="https://example.com"
SCRIPT_DIR=$(dirname "$0")
LOG_FILE="$SCRIPT_DIR/reloadlog.log"

log_status() {
    local status=$1
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $status" >> "$LOG_FILE"
}


if [ "$1" == "force" ]; then
    #copy laravel logs container volume 
    cp -r /var/log/service /var/log/service_dump

    #restart all containers
    docker restart $(docker ps -q)
     
    log_status "Force restart of all containers."
    exit 0
fi


HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}" $URL)

if [ "$HTTP_STATUS" -eq 504 ] || [ "$HTTP_STATUS" -eq 503 ] || [ "$HTTP_STATUS" -eq 502 ] || [ "$HTTP_STATUS" -eq 501 ] || [ "$HTTP_STATUS" -eq 500 ]; then
    #copy logs
    cp -r /var/log/service /var/log/service_dump

    #restart all containers
    docker restart $(docker ps -q)

    #stop all containers except the latest one
    docker stop $(docker ps -a -q | grep -v $(docker ps -q --latest))
    
    log_status "Containers restarted due to HTTP status $HTTP_STATUS."
else
    log_status "HTTP status $HTTP_STATUS - no action taken."
fi
