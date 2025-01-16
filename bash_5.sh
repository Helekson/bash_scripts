#!/bin/bash

# Функция для вывода инструкции по использованию
print_help() {
  echo "Использование: $0 [-d каталог] [-e файл_ошибок] количество_слов каталог_1 каталог_2 ..."
  echo "  -d каталог     Указать начальный каталог, в котором искать файлы (по умолчанию текущий каталог)."
  echo "  -e файл_ошибок Перенаправить сообщения об ошибках в указанный файл."
  echo "  -h             Показать эту инструкцию."
}

# Функция для проверки файлов на количество слов
check_files_for_words() {
  local word_count=$1
  shift  # Сдвигаем аргументы, чтобы остались только каталоги
  local directories=("$@")
  local file_count=0

  for dir in "${directories[@]}"; do
    if [[ ! -d "$dir" ]]; then
      echo "Ошибка: Каталог $dir не существует." >&2
      continue
    fi

    # Проходим по всем файлам в каталоге и подкаталогах
    find "$dir" -type f | while read -r file; do
      file_word_count=$(wc -w < "$file")

      # Если количество слов в файле больше указанного, выводим полный путь к файлу
      if (( file_word_count > word_count )); then
        echo "Файл '$file' содержит больше $word_count слов. Слов: $file_word_count"
        ((file_count++))
      fi
    done
  done

  if (( file_count == 0 )); then
    echo "Нет файлов, содержащих больше $word_count слов." >&2
  fi
}

# Обработчик аргументов
directory="."
error_file=""
word_count=0
directories=()

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

# Перенаправление ошибок в файл, если указан ключ -e
if [[ -n "$error_file" ]]; then
  exec 2>"$error_file"
fi

# Проверка на наличие аргумента с количеством слов
if [[ $# -lt 1 ]]; then
  echo "Ошибка: Не указано количество слов для проверки." >&2
  exit 1
fi

# Извлекаем количество слов
word_count=$1
shift  # Сдвигаем аргументы, чтобы остались только каталоги

# Если каталоги не указаны, используем текущий каталог
if [[ $# -eq 0 ]]; then
  directories=("$directory")
else
  directories=("$@")
fi

# Проверка файлов в каталогах
check_files_for_words "$word_count" "${directories[@]}"
