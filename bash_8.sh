#!/bin/bash

# Функция для вывода справки
function print_help() {
    echo "Использование: $0 [-d каталог] [-e файл_ошибок] [-h]"
    echo "  -d каталог        Указать каталог, в котором будут искаться подкаталоги (по умолчанию текущий каталог)"
    echo "  -e файл_ошибок    Перенаправить сообщения об ошибках в указанный файл"
    echo "  -h                Вывести справку"
}

# Обработка аргументов
directory="."
error_file=""
while getopts "d:e:h" opt; do
    case "$opt" in
        d) directory="$OPTARG" ;;
        e) error_file="$OPTARG" ;;
        h) print_help; exit 0 ;;
        *) print_help; exit 1 ;;
    esac
done

# Проверка каталога
if [ ! -d "$directory" ]; then
    error_message="Ошибка: Каталог '$directory' не существует."
    if [ -n "$error_file" ]; then
        echo "$error_message" >> "$error_file"
    else
        echo "$error_message"
    fi
    exit 1
fi

# Вывод подкаталогов, отсортированных по размеру
find "$directory" -mindepth 1 -maxdepth 1 -type d -exec du -sh {} + | sort -h
