#!/usr/bin/env bash

echo "Проверка VM"
echo "Текущая директория:"$(pwd)
echo "Текущий пользователь:" $(whoami)
echo "Свободная память:"
free -h
echo "Свободное место на диске:"
df -h
