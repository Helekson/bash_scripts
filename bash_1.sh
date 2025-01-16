#!/bin/bash

#Функция для вывода таблицы степеней
function print_table() {
  echo -e "Число\t0\t1\t2\t3\t4\t5\t6"
  for num in {1..9}; do
    echo -n -e "$num\t"
    for exp in {0..6}; do
      echo -n -e "$(bc <<< "$num^$exp")\t"
    done
    echo
  done
}

# Указание каталога по умолчанию (текущий каталог)
directory="."

# Проверка на наличие параметра -d
while getopts "d:e:h" option; do
  case "$option" in
    d) directory="$OPTARG" ;;  # Установить каталог из параметра -d
    e) error_file="$OPTARG" ;;  # Установить файл для ошибок
    h) echo "Использование: $0 [-d каталог] [-e файл_ошибок]" && exit 0 ;;  # Инструкция
    *) echo "Неверный параметр. Используйте -h для помощи." && exit 1 ;;
  esac
done

# Переход в указанный каталог, если он существует
if ! cd "$directory"; then
  echo "Ошибка: Не удалось перейти в каталог $directory." > "$error_file"
  exit 1
fi

# Вывод таблицы степеней
print_table

