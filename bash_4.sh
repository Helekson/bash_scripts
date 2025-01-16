#!/bin/bash

# Функция для вывода инструкции по использованию
print_help() {
  echo "Использование: $0 [-d каталог] [-e файл_ошибок] имя_файла"
  echo "  -d каталог     Указать начальный каталог, в котором начать поиск (по умолчанию текущий каталог)."
  echo "  -e файл_ошибок Перенаправить сообщения об ошибках в указанный файл."
  echo "  -h             Показать эту инструкцию."
}

# Функция для поиска каталогов, содержащих указанный файл
find_file_in_dirs() {
  local dir=$1
  local filename=$2
  found=0
  
  # Ищем файл в указанном каталоге и его подкаталогах
  while IFS= read -r line; do
    if [[ -f "$line/$filename" ]]; then
      echo "Файл '$filename' найден в каталоге: $line"
      found=1
    fi
  done < <(find "$dir" -type d)
  
  if [[ $found -eq 0 ]]; then
    echo "Ошибка: Файл '$filename' не найден в указанных каталогах." >&2
  fi
}

# Обработчик аргументов
directory="."
error_file=""
filename=""

while getopts "d:e:h" opt; do
  case "$opt" in
    d) # Обработка ключа -d для указания каталога
      directory="$OPTARG"
      ;;
    e) # Обработка ключа -e для указания файла ошибок
      error_file="$OPTARG"
      ;;
    h) # Обработка ключа -h для вывода инструкции
      print_help
      exit 0
      ;;
    *)
      echo "Неверный параметр. Используйте -h для справки." >&2
      exit 1
      ;;
  esac
done

# Убираем первый аргумент из списка, так как это имя файла
shift $((OPTIND - 1))
filename=$1

# Проверка на наличие имени файла
if [[ -z "$filename" ]]; then
  echo "Ошибка: Не указано имя файла для поиска." >&2
  exit 1
fi

# Перенаправление ошибок в файл, если указан ключ -e
if [[ -n "$error_file" ]]; then
  exec 2>"$error_file"
fi

# Переход в указанный каталог
cd "$directory" || { echo "Ошибка: Не удалось перейти в каталог $directory." >&2; exit 1; }

# Поиск файла
find_file_in_dirs "$directory" "$filename"
