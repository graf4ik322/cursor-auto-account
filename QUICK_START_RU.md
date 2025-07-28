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

**Важно:** Приложение автоматически создаст базу данных при первом запуске. Вам нужно только установить MySQL сервер.

```bash
# Установка MySQL
sudo apt install mysql-server -y

# Настройка безопасности
sudo mysql_secure_installation
```

### Шаг 4: Настройка переменных окружения (опционально)

Если вы хотите изменить настройки по умолчанию:

```bash
# Редактирование конфигурации
nano .env
```

Настройте следующие переменные:
```env
# Настройки безопасности (обязательно измените!)
SECRET_KEY=your_generated_secret_key
ADMIN_PASSWORD=your_admin_password

# Настройки базы данных (опционально)
DB_PASSWORD=your_secure_password
```

### Шаг 5: Клонирование и настройка

```bash
# Клонирование репозитория
cd ~
git clone https://github.com/YOUR_USERNAME/cursor-auto-account.git
cd cursor-auto-account

# Копирование конфигурации
cp .env.example .env

# Редактирование настроек (опционально)
nano .env
```

Настройте следующие переменные в файле `.env` (обязательно измените пароли!):

```env
# Настройки безопасности (обязательно!)
SECRET_KEY=your_generated_secret_key
ADMIN_PASSWORD=your_admin_password

# Настройки базы данных (опционально)
DB_PASSWORD=your_secure_password

# Настройки email
EMAIL_DOMAIN=yourdomain.com
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

**Что происходит при запуске:**
- ✅ Запускается приложение Cursor Account Manager
- ✅ Автоматически создается база данных
- ✅ Создается администратор по умолчанию

### Шаг 8: Проверка работы

Откройте браузер и перейдите по адресу:
```
http://YOUR_SERVER_IP:8001
```

**Просмотр логов:**
```bash
docker-compose logs -f
```

## 🔧 Настройка домена (опционально)

### Настройка DNS в Cloudflare

1. Добавьте ваш домен в Cloudflare
2. Создайте A-запись:
   - **Имя**: cursor (или любое другое)
   - **IP**: IP-адрес вашего сервера
   - **Прокси**: Включен (оранжевое облачко)

### Настройка Caddy

**Важно:** В репозитории уже есть готовый `Caddyfile`. Вам нужно только изменить домен в нем.

```bash
# Редактирование существующего Caddyfile
nano Caddyfile
```

Замените домен в первой строке на ваш:
```caddyfile
cursor.yourdomain.com {
    # ... остальная конфигурация уже готова ...
}
```

**Для использования с системным Caddy:**
```bash
# Копирование конфигурации в системную директорию
sudo cp Caddyfile /etc/caddy/Caddyfile

# Перезапуск Caddy
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