#!/bin/bash

# Функция подтверждения (да-нет)
confirm() {
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}
package_manager="apt"
# Функция установки необходимого софта:
$package_manager update
$package_manager upgrade
$package_manager install docker && \
docker-compose sudo
# Функция создания пользователя:
read -p "Введите имя нового пользователя: " user
if id -u "$user" >/dev/null 2>&1; then
    echo "Пользователь $user уже существует. Выберите другое имя пользователя."
else
    echo "Создаю пользователя с именем $user"
    read -p "Введите пароль нового пользователя:" pass
    
    if confirm "Добавить пользователя в группу Docker? (y/n or enter for n)"; then
        useradd -m -s /bin/bash -G docker ${user}
        echo "%$user ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$user
    else
        useradd -m -s /bin/bash ${user}
    fi

    # set password
    echo "$user:$pass" | chpasswd
    mkdir /var/projects/$user
    chown -R $user:$user /var/projects/$user
    ln -s /var/projects/$user/ /home/$user/projects
    mkdir /home/$user/documents/
    chown -R $user:$user /home/$user/documents/
    mkdir /home/$user/downloads/
    chown -R $user:$user /home/$user/downloads/
    git clone https://github.com/GosZakaz/all_scripts.git /home/$user/scripts/
    rm -rf /home/$user/scripts/scripts
    chown -R $user:$user /home/$user/scripts/
    echo 'alias ctop="/usr/local/bin/ctop"' >> /home/$user/.bashrc
    echo "Пользователь $user успешно создан!"
fi
