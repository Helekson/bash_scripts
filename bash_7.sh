#!/bin/bash

# Функция для вывода инструкции по использованию
function print_help() {
  echo "Использование: $0 [-d каталог] [-o каталог_для_ссылок] [-s] [-e файл_ошибок] строка файлы..."
  echo "-d каталог        : Указать каталог для поиска файлов. По умолчанию текущий каталог."
  echo "-o каталог_для_ссылок : Указать каталог для создания ссылок. По умолчанию текущий каталог."
  echo "-s                : Создать символические ссылки вместо жестких."
  echo "-e файл_ошибок    : Перенаправить ошибки в указанный файл."
  echo "-h                : Печать этой инструкции."
}

# Обработка аргументов командной строки
directory="."
output_directory="."
create_symlink=false
error_file=""

while getopts "d:o:se:h" opt; do
  case $opt in
    d)
      directory="$OPTARG"
      ;;
    o)
      output_directory="$OPTARG"
      ;;
    s)
      create_symlink=true
      ;;
    e)
      error_file="$OPTARG"
      ;;
    h)
      print_help
      exit 0
      ;;
    *)
      print_help
      exit 1
      ;;
  esac
done

shift $((OPTIND-1))

if [ $# -lt 1 ]; then
  echo "Ошибка: Не указана строка для поиска." >&2
  print_help
  exit 1
fi

search_string="$1"
shift

# Убедитесь, что директория для поиска существует
if [ ! -d "$directory" ]; then
  echo "Ошибка: Каталог $directory не существует." >&2
  exit 1
fi

# Убедитесь, что директория для создания ссылок существует
if [ ! -d "$output_directory" ]; then
  echo "Ошибка: Каталог для ссылок $output_directory не существует." >&2
  exit 1
fi

# Перенаправление ошибок в файл, если указано
if [ -n "$error_file" ]; then
  exec 2>>"$error_file"
fi

# Рекурсивный поиск файлов и создание ссылок
for file in "$@"; do
  if [ -f "$directory/$file" ]; then
    grep -l "$search_string" "$directory/$file" &>/dev/null
    if [ $? -eq 0 ]; then
      # Если строка найдена, создаём ссылку
      if $create_symlink; then
        ln -s "$directory/$file" "$output_directory/$file"
        echo "Создана символическая ссылка на файл $file"
      else
        ln "$directory/$file" "$output_directory/$file"
        echo "Создана жёсткая ссылка на файл $file"
      fi
    fi
  else
    echo "Ошибка: Файл $file не найден в каталоге $directory." >&2
  fi
done
