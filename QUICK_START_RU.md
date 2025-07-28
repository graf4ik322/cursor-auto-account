# Быстрый старт - Cursor Account Manager

## 🚀 Установка за 5 минут

Это краткое руководство поможет вам быстро развернуть Cursor Account Manager на вашем сервере.

### Предварительные требования

- Сервер с Ubuntu 20.04+ или Debian 11+
- Минимум 2GB RAM
- Статический IP-адрес
- Домен (опционально, но рекомендуется)

### Шаг 1: Подготовка сервера

```bash
# Обновление системы
sudo apt update && sudo apt upgrade -y

# Установка необходимых пакетов
sudo apt install -y curl git python3 python3-pip
```

### Шаг 2: Установка Docker

```bash
# Установка Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Добавление пользователя в группу docker
sudo usermod -aG docker $USER

# Установка Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Перезагрузка (важно!)
sudo reboot
```

### Шаг 3: Установка MySQL

```bash
# Установка MySQL
sudo apt install mysql-server -y

# Настройка безопасности
sudo mysql_secure_installation
```

### Шаг 4: Создание базы данных

```bash
# Подключение к MySQL
sudo mysql -u root -p
```

В MySQL консоли выполните:

```sql
CREATE DATABASE cursor_accounts;
CREATE USER 'cursor_user'@'localhost' IDENTIFIED BY 'your_password_123!';
GRANT ALL PRIVILEGES ON cursor_accounts.* TO 'cursor_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### Шаг 5: Клонирование и настройка

```bash
# Клонирование репозитория
cd ~
git clone https://github.com/zoowayss/cursor-auto-account.git
cd cursor-auto-account

# Копирование конфигурации
cp .env.example .env

# Редактирование настроек
nano .env
```

Настройте следующие переменные в файле `.env`:

```env
DB_USER=cursor_user
DB_PASSWORD=your_password_123!
EMAIL_DOMAIN=yourdomain.com
ADMIN_PASSWORD=your_admin_password
SECRET_KEY=your_generated_secret_key
```

### Шаг 6: Генерация секретного ключа

```bash
# Генерация секретного ключа
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

Скопируйте результат в переменную `SECRET_KEY` в файле `.env`.

### Шаг 7: Запуск приложения

```bash
# Запуск контейнеров
docker-compose up -d

# Проверка статуса
docker-compose ps
```

### Шаг 8: Проверка работы

Откройте браузер и перейдите по адресу:
```
http://YOUR_SERVER_IP:8001
```

## 🔧 Настройка домена (опционально)

### Настройка DNS в Cloudflare

1. Добавьте ваш домен в Cloudflare
2. Создайте A-запись:
   - **Имя**: cursor (или любое другое)
   - **IP**: IP-адрес вашего сервера
   - **Прокси**: Включен (оранжевое облачко)

### Установка Caddy

```bash
# Установка Caddy
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy -y
```

### Создание Caddyfile

```bash
sudo nano /etc/caddy/Caddyfile
```

Содержимое:

```caddyfile
cursor.yourdomain.com {
    reverse_proxy localhost:8001
}
```

### Перезапуск Caddy

```bash
sudo systemctl restart caddy
```

Теперь ваше приложение доступно по адресу: `https://cursor.yourdomain.com`

## 🛠️ Основные команды

```bash
# Просмотр статуса
docker-compose ps

# Просмотр логов
docker-compose logs -f app

# Остановка
docker-compose down

# Перезапуск
docker-compose restart

# Обновление
git pull
docker-compose down
docker-compose up -d --build
```

## 🔍 Устранение неполадок

### Приложение не запускается

```bash
# Проверка логов
docker-compose logs app

# Проверка статуса MySQL
sudo systemctl status mysql

# Проверка портов
sudo netstat -tulpn | grep :8001
```

### Проблемы с базой данных

```bash
# Проверка подключения
mysql -u cursor_user -p cursor_accounts

# Перезапуск MySQL
sudo systemctl restart mysql
```

### Проблемы с доменом

```bash
# Проверка DNS
nslookup cursor.yourdomain.com

# Проверка Caddy
sudo systemctl status caddy
sudo journalctl -u caddy -f
```

## 📋 Чек-лист установки

- [ ] Docker установлен и работает
- [ ] MySQL установлен и настроен
- [ ] База данных создана
- [ ] Файл .env настроен
- [ ] Контейнеры запущены
- [ ] Приложение доступно по IP:8001
- [ ] Домен настроен (опционально)
- [ ] SSL сертификат работает (опционально)

## 🆘 Получение помощи

Если у вас возникли проблемы:

1. Проверьте раздел "Устранение неполадок"
2. Посмотрите логи: `docker-compose logs app`
3. Создайте issue в репозитории проекта
4. Обратитесь к полному руководству: `DEPLOYMENT_GUIDE_RU.md`

## 🔐 Безопасность

После установки обязательно:

1. Измените пароли по умолчанию
2. Настройте файрвол
3. Регулярно обновляйте систему
4. Делайте резервные копии базы данных

---

**Готово!** 🎉 Ваше приложение Cursor Account Manager успешно установлено и готово к использованию.