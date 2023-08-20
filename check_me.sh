#!/bin/bash

set -e
GREEN=$'\e[0;32m'
RED=$'\e[0;31m'
NC=$'\e[0m'

echo "Проверяем поднятое приложение"

echo "..."; sleep 2

# check that we have container listening on port 9001
for port in 9001 
do
    if ! docker container ls | grep "$port->" > /dev/null; then
        echo "${RED}Контейнер с приложением на порту $port не запущен${NC}"
        exit 1
    else
        echo "${GREEN}Контейнер с приложением на порту $port запущен${NC}"
        echo "..."; sleep 1
    fi
done

# check that container 9001 gives 200 on root endpoint
status_code=$(curl --write-out %{http_code} --silent --output /dev/null http://127.0.0.1:9001)
if ! [[ "$status_code" -ne 200 ]] ; then
    echo "${GREEN}Главная страница на порту 9001 открывается${NC}"
    echo "..."; sleep 1
else
    echo "${RED}Главная страница на порту 9001 не открывается:${NC}"
    echo "$(curl -X GET -I http://127.0.0.1:9001/ | head)"
    exit 1
fi

echo "Проверка завершена"
