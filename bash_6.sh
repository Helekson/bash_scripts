#!/bin/bash

# Функция для вывода инструкции по использованию
function usage() {
  echo "Использование: $0 [-d каталог] [-e файл_ошибок] [-r] файл1 файл2 ..."
  echo "  -d каталог    Указывает каталог, в котором искать файлы. По умолчанию текущий."
  echo "  -e файл_ошибок Перенаправляет сообщения об ошибках в указанный файл."
  echo "  -r            Удаляет все жёсткие ссылки с расширениями .1 до .9."
  echo "  -h            Печатает инструкцию."
}

# Обработка параметров
directory="."
error_file=""
remove_links=false

while getopts "d:e:rh" opt; do
  case $opt in
    d) directory="$OPTARG" ;;
    e) error_file="$OPTARG" ;;
    r) remove_links=true ;;
    h) usage; exit 0 ;;
    *) usage; exit 1 ;;
  esac
done

shift $((OPTIND - 1))

# Функция для создания жёстких ссылок
function create_hard_links() {
  for file in "$@"; do
    if [[ ! -f "$directory/$file" ]]; then
      echo "Ошибка: Файл $file не найден в каталоге $directory." >&2
      continue
    fi

    # Создание жёстких ссылок с расширением .1, .2, ..., .9
    for i in {1..9}; do
      link_name="$directory/$file.$i"
      if [[ ! -e "$link_name" ]]; then
        ln "$directory/$file" "$link_name"
        echo "Создана ссылка: $link_name"
        break
      fi
    done
  done
}

# Функция для удаления жёстких ссылок
function remove_hard_links() {
  for file in "$@"; do
    if [[ ! -f "$directory/$file" ]]; then
      echo "Ошибка: Файл $file не найден в каталоге $directory." >&2
      continue
    fi

    # Удаление ссылок с расширением .1, .2, ..., .9
    for i in {1..9}; do
      link_name="$directory/$file.$i"
      if [[ -e "$link_name" ]]; then
        rm "$link_name"
        echo "Удалена ссылка: $link_name"
      fi
    done
  done
}

# Если передан ключ -r, удаляем ссылки
if [[ "$remove_links" == true ]]; then
  remove_hard_links "$@"
else
  create_hard_links "$@"
fi
