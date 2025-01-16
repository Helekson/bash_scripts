#!/bin/bash

# Функция для вывода инструкции
usage() {
  echo "Использование: $0 [-d каталог] [-o файл настроек] [-a] [-p путь] [-m права] [-u пользователь] [-g группа] [-e файл_ошибок] [-h]"
  echo "  -d каталог      Указать каталог для обработки (по умолчанию текущий)"
  echo "  -o файл        Указать файл настроек (по умолчанию .install-config)"
  echo "  -a              Автоматическое использование значений по умолчанию"
  echo "  -p путь         Указать путь по умолчанию"
  echo "  -m права        Указать права доступа по умолчанию"
  echo "  -u пользователь Указать пользователя по умолчанию"
  echo "  -g группа       Указать группу по умолчанию"
  echo "  -e файл         Перенаправить ошибки в указанный файл"
  echo "  -h              Вывести помощь"
}

# Инициализация переменных с значениями по умолчанию
dir="."
config_file=".install-config"
default_permissions="0644"
default_user=$(whoami)
default_group=$(id -gn "$default_user")
auto_flag=false
error_file=""

# Разбор аргументов командной строки
while getopts "d:o:ap:m:u:g:e:h" opt; do
  case "$opt" in
    d) dir="$OPTARG" ;;
    o) config_file="$OPTARG" ;;
    a) auto_flag=true ;;
    p) default_path="$OPTARG" ;;
    m) default_permissions="$OPTARG" ;;
    u) default_user="$OPTARG" ;;
    g) default_group="$OPTARG" ;;
    e) error_file="$OPTARG" ;;
    h) usage; exit 0 ;;
    *) usage; exit 1 ;;
  esac
done

# Перенаправление ошибок в файл, если указано
if [ -n "$error_file" ]; then
  exec 2>"$error_file"
fi

# Обработка файлов в указанном каталоге
for file in "$dir"/*; do
  if [ -f "$file" ]; then
    # Получение информации от пользователя
    if [ "$auto_flag" = true ]; then
      final_dir="$default_path"
      permissions="$default_permissions"
      user="$default_user"
      group="$default_group"
    else
      read -p "Для файла $file введите путь каталога (по умолчанию: $default_path): " final_dir
      read -p "Введите права доступа (по умолчанию: $default_permissions): " permissions
      read -p "Введите пользователя (по умолчанию: $default_user): " user
      read -p "Введите группу (по умолчанию: $default_group): " group
    fi

    # Использование значений по умолчанию, если пользователь не ввёл данные
    final_dir=${final_dir:-$default_path}
    permissions=${permissions:-$default_permissions}
    user=${user:-$default_user}
    group=${group:-$default_group}

    # Запись информации в файл настроек
    echo "$file : $permissions : $user : $group" >> "$config_file"
  fi
done

echo "Информация успешно записана в файл $config_file."
