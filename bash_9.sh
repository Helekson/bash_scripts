#!/bin/bash

# Функция для вывода справки
function print_help() {
    echo "Использование: $0 [-d каталог] [-e файл_ошибок] <список_файлов>"
    echo "  -d каталог       Указывает каталог, где искать файлы (по умолчанию текущий)"
    echo "  -e файл_ошибок   Перенаправить сообщения об ошибках в указанный файл"
    echo "  -h               Вывести справку"
}

# Инициализация переменных
directory=$(pwd)
error_log=""
files_list=""

# Обработка параметров командной строки
while getopts "d:e:h" opt; do
    case "$opt" in
        d) directory="$OPTARG" ;;  # Устанавливаем каталог
        e) error_log="$OPTARG" ;;  # Устанавливаем файл для ошибок
        h) print_help; exit 0 ;;   # Выводим справку и выходим
        *) print_help; exit 1 ;;   # Если неправильный флаг
    esac
done

shift $((OPTIND - 1))  # Сдвигаем позиционные параметры

# Получаем список файлов из последующего аргумента
if [[ -z "$1" ]]; then
    echo "Ошибка: Не указан файл со списком файлов." >&2
    exit 1
else
    files_list="$1"
fi

# Проверка наличия файла со списком
if [[ ! -f "$files_list" ]]; then
    echo "Ошибка: Файл '$files_list' не существует." >&2
    exit 1
fi

# Функция для удаления файлов
function delete_files() {
    while IFS= read -r file; do
        file_path="$directory/$file"
        if [[ -f "$file_path" ]]; then
            rm "$file_path" && echo "Удален: $file_path" || echo "Ошибка при удалении: $file_path" >&2
        else
            echo "Файл не найден: $file_path" >&2
        fi
    done < "$files_list"
}

# Перенаправление ошибок, если указано
if [[ -n "$error_log" ]]; then
    exec 2>>"$error_log"
fi

# Выполняем удаление файлов
delete_files
