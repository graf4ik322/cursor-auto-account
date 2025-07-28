# Подробное руководство по развертыванию Cursor Account Manager

## Содержание

1. [Подготовка сервера](#подготовка-сервера)
2. [Установка необходимого ПО](#установка-необходимого-по)
3. [Настройка домена в Cloudflare](#настройка-домена-в-cloudflare)
4. [Настройка базы данных](#настройка-базы-данных)
5. [Развертывание приложения](#развертывание-приложения)
6. [Настройка Caddy для поддомена](#настройка-caddy-для-поддомена)
7. [Решение конфликтов портов](#решение-конфликтов-портов)
8. [Настройка SSL сертификатов](#настройка-ssl-сертификатов)
9. [Мониторинг и логирование](#мониторинг-и-логирование)
10. [Устранение неполадок](#устранение-неполадок)

## Подготовка сервера

### Требования к системе

- **ОС**: Ubuntu 20.04+ / CentOS 8+ / Debian 11+
- **RAM**: Минимум 2GB (рекомендуется 4GB+)
- **CPU**: 2 ядра (рекомендуется 4+)
- **Диск**: 20GB свободного места
- **Сеть**: Статический IP-адрес

### Обновление системы

```bash
# Ubuntu/Debian
sudo apt update && sudo apt upgrade -y

# CentOS/RHEL
sudo yum update -y
```

## Установка необходимого ПО

### 1. Установка Docker и Docker Compose

```bash
# Установка Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Добавление пользователя в группу docker
sudo usermod -aG docker $USER

# Установка Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Перезагрузка для применения изменений группы
sudo reboot
```

### 2. Установка MySQL

```bash
# Ubuntu/Debian
sudo apt install mysql-server -y

# CentOS/RHEL
sudo yum install mysql-server -y
sudo systemctl start mysqld
sudo systemctl enable mysqld

# Настройка безопасности MySQL
sudo mysql_secure_installation
```

### 3. Установка Docker и Docker Compose

```bash
# Установка Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Добавление пользователя в группу docker
sudo usermod -aG docker $USER

# Установка Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Перезагрузка для применения изменений группы
sudo reboot
```

### 4. Установка Caddy (веб-сервер)

```bash
# Добавление репозитория Caddy
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list

# Установка Caddy
sudo apt update
sudo apt install caddy -y

# Создание директорий для логов
sudo mkdir -p /var/log/caddy
sudo chown caddy:caddy /var/log/caddy
```

## Настройка домена в Cloudflare

### 1. Добавление домена в Cloudflare

1. Войдите в [Cloudflare Dashboard](https://dash.cloudflare.com)
2. Нажмите "Add a Site"
3. Введите ваш домен (например: `yourdomain.com`)
4. Выберите план (Free подходит для большинства случаев)
5. Cloudflare автоматически обнаружит DNS записи

### 2. Настройка DNS записей

В разделе DNS добавьте следующие записи:

#### Основная A-запись для домена:
- **Тип**: A
- **Имя**: @ (или оставьте пустым)
- **IPv4 адрес**: IP-адрес вашего сервера
- **Прокси-статус**: Включен (оранжевое облачко)

#### A-запись для поддомена:
- **Тип**: A
- **Имя**: cursor (или любое другое для поддомена)
- **IPv4 адрес**: IP-адрес вашего сервера
- **Прокси-статус**: Включен (оранжевое облачко)

### 3. Настройка Email Routing

1. В Cloudflare перейдите в раздел "Email"
2. Нажмите "Email Routing"
3. Настройте Email Routing для вашего домена
4. Создайте правило переадресации:
   - **Правило**: Catch-all
   - **Действие**: Forward to
   - **Email**: ваш-email@gmail.com

### 4. Настройка SSL/TLS

1. В разделе SSL/TLS установите режим "Full (strict)"
2. Включите "Always Use HTTPS"
3. Включите "Minimum TLS Version" и установите TLS 1.2

## Настройка базы данных

### 1. Создание пользователя базы данных

**Важно:** Приложение автоматически создаст базу данных при первом запуске. Вам нужно только создать пользователя MySQL.

```bash
# Подключение к MySQL
sudo mysql -u root -p
```

В MySQL консоли выполните:

```sql
-- Создание пользователя
CREATE USER 'cursor_user'@'localhost' IDENTIFIED BY 'your_very_secure_password_123!';

-- Предоставление прав (приложение само создаст базу данных)
GRANT ALL PRIVILEGES ON *.* TO 'cursor_user'@'localhost';

-- Применение изменений
FLUSH PRIVILEGES;

-- Проверка создания пользователя
SELECT User, Host FROM mysql.user WHERE User = 'cursor_user';

-- Выход
EXIT;
```

## Настройка переменных окружения

### 1. Создание файла конфигурации

```bash
# Редактирование конфигурации MySQL
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

Добавьте или измените следующие строки:

```ini
[mysqld]
# Привязка к localhost только
bind-address = 127.0.0.1

# Максимальное количество соединений
max_connections = 100

# Таймаут неактивных соединений
wait_timeout = 600
interactive_timeout = 600

# Логирование
log_error = /var/log/mysql/error.log
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 2
```

Перезапустите MySQL:

```bash
sudo systemctl restart mysql
```

## Развертывание приложения

### 1. Клонирование репозитория

```bash
# Переход в домашнюю директорию
cd ~

# Клонирование репозитория
git clone https://github.com/YOUR_USERNAME/cursor-auto-account.git
cd cursor-auto-account
```

### 2. Настройка переменных окружения

```bash
# Копирование примера конфигурации
cp .env.example .env

# Редактирование конфигурации
nano .env
```

Настройте следующие переменные:

```env
# Настройки безопасности (обязательно измените!)
SECRET_KEY=your_generated_secret_key_here
ADMIN_PASSWORD=your_admin_password_here

# Настройки базы данных (опционально)
DB_PASSWORD=your_secure_password_here

# Настройки email
EMAIL_DOMAIN=yourdomain.com

# Настройки сервера
HOST=0.0.0.0
PORT=8001
DEBUG=false
```

### 2. Генерация секретного ключа

```bash
# Генерация случайного секретного ключа
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

Скопируйте результат в переменную `SECRET_KEY` в файле `.env`.

## Развертывание приложения

### 1. Клонирование репозитория

```bash
# Переход в домашнюю директорию
cd ~

# Клонирование репозитория
git clone https://github.com/YOUR_USERNAME/cursor-auto-account.git
cd cursor-auto-account
```

### 2. Запуск приложения

```bash
# Сборка и запуск контейнеров
docker-compose up -d

# Проверка статуса
docker-compose ps

# Просмотр логов
docker-compose logs -f app
```

**Что происходит при запуске:**
- ✅ Запускается приложение Cursor Account Manager
- ✅ Автоматически создается база данных `cursor_accounts`
- ✅ Создается администратор по умолчанию

## Настройка Caddy для поддомена

### 1. Настройка Caddyfile

**Важно:** В репозитории уже есть готовый `Caddyfile`. Вам нужно только изменить домен в нем.

```bash
# Редактирование существующего Caddyfile
nano Caddyfile
```

Замените домен в первой строке на ваш:
```caddyfile
# Измените эту строку на ваш домен
cursor.yourdomain.com {
    # ... остальная конфигурация уже готова ...
}
```

**Для использования с системным Caddy:**
```bash
# Создание директории для конфигураций
sudo mkdir -p /etc/caddy/sites

# Копирование и редактирование конфигурации
sudo cp Caddyfile /etc/caddy/sites/cursor.yourdomain.com
sudo nano /etc/caddy/sites/cursor.yourdomain.com
```

### 2. Настройка основного Caddyfile

```bash
# Редактирование основного Caddyfile
sudo nano /etc/caddy/Caddyfile
```

Добавьте импорт вашего сайта:

```caddyfile
# Основной Caddyfile
import /etc/caddy/sites/*

# Дополнительные настройки глобального уровня
{
    # Глобальные настройки
    admin off
    auto_https disable_redirects
}
```

### 3. Перезапуск Caddy

```bash
# Проверка конфигурации
sudo caddy validate --config /etc/caddy/Caddyfile

# Перезапуск Caddy
sudo systemctl restart caddy

# Проверка статуса
sudo systemctl status caddy
```

## Решение конфликтов портов

### Ситуация: Основной домен уже использует порт 8001

Если ваш основной сайт уже работает на порту 8001, выполните следующие шаги:

### 1. Изменение порта в .env файле

```bash
# Редактирование .env файла
nano .env
```

Измените порт:

```env
PORT=8002
```

### 2. Обновление docker-compose.yml

```bash
# Редактирование docker-compose.yml
nano docker-compose.yml
```

Измените маппинг портов:

```yaml
ports:
  - "8002:8002"  # Измененный порт
  - "9223:9223"
```

### 3. Обновление Caddyfile

```bash
# Редактирование Caddyfile
nano Caddyfile
```

Измените порт в reverse_proxy:

```caddyfile
cursor.yourdomain.com {
    # ... другие настройки ...
    
    reverse_proxy localhost:8002 {
        # ... остальные настройки ...
    }
}
```

**Если используете системный Caddy:**
```bash
# Редактирование Caddyfile для поддомена
sudo nano /etc/caddy/sites/cursor.yourdomain.com
```

### 4. Перезапуск сервисов

```bash
# Остановка контейнеров
cd ~/cursor-auto-account
docker-compose down

# Запуск с новыми настройками
docker-compose up -d

# Перезапуск Caddy
sudo systemctl restart caddy
```

### Проверка занятости портов

```bash
# Проверка занятых портов
sudo netstat -tulpn | grep :8001
sudo netstat -tulpn | grep :8002

# Или с помощью ss
sudo ss -tulpn | grep :8001
sudo ss -tulpn | grep :8002
```

## Настройка SSL сертификатов

### Автоматическая настройка через Caddy

Caddy автоматически получает и обновляет SSL сертификаты Let's Encrypt. Убедитесь, что:

1. DNS записи правильно настроены в Cloudflare
2. Прокси-статус включен (оранжевое облачко)
3. Порт 80 и 443 открыты в файрволе

### Проверка SSL сертификата

```bash
# Проверка сертификата
openssl s_client -connect cursor.yourdomain.com:443 -servername cursor.yourdomain.com

# Проверка через curl
curl -I https://cursor.yourdomain.com
```

## Мониторинг и логирование

### 1. Настройка логирования

```bash
# Создание директории для логов приложения
mkdir -p ~/cursor-auto-account/logs

# Добавление ротации логов в docker-compose.yml
nano docker-compose.yml
```

Добавьте в секцию volumes:

```yaml
volumes:
  - ./logs:/app/logs
  # ... другие volumes ...
```

### 2. Мониторинг контейнеров

```bash
# Просмотр статуса контейнеров
docker-compose ps

# Просмотр использования ресурсов
docker stats

# Просмотр логов
docker-compose logs -f app
```

### 3. Мониторинг базы данных

```bash
# Подключение к MySQL для мониторинга
mysql -u cursor_user -p cursor_accounts

# Проверка размера базы данных
SELECT 
    table_schema AS 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.tables 
WHERE table_schema = 'cursor_accounts'
GROUP BY table_schema;

# Проверка количества аккаунтов
SELECT COUNT(*) as total_accounts FROM accounts;
```

### 4. Настройка автоматических резервных копий

```bash
# Создание скрипта резервного копирования
nano ~/backup_cursor_db.sh
```

Содержимое скрипта:

```bash
#!/bin/bash

# Настройки
DB_USER="cursor_user"
DB_NAME="cursor_accounts"
BACKUP_DIR="/home/$USER/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Создание директории для резервных копий
mkdir -p $BACKUP_DIR

# Создание резервной копии
mysqldump -u $DB_USER -p$DB_PASSWORD $DB_NAME > $BACKUP_DIR/cursor_accounts_$DATE.sql

# Сжатие резервной копии
gzip $BACKUP_DIR/cursor_accounts_$DATE.sql

# Удаление резервных копий старше 30 дней
find $BACKUP_DIR -name "*.sql.gz" -mtime +30 -delete

echo "Резервная копия создана: $BACKUP_DIR/cursor_accounts_$DATE.sql.gz"
```

```bash
# Сделать скрипт исполняемым
chmod +x ~/backup_cursor_db.sh

# Добавить в crontab для ежедневного резервного копирования
crontab -e
```

Добавьте строку:

```cron
0 2 * * * /home/$USER/backup_cursor_db.sh
```

## Устранение неполадок

### Проблемы с подключением к базе данных

```bash
# Проверка статуса MySQL
sudo systemctl status mysql

# Проверка подключения
mysql -u cursor_user -p -h localhost cursor_accounts

# Проверка логов MySQL
sudo tail -f /var/log/mysql/error.log
```

### Проблемы с Docker

```bash
# Проверка статуса контейнеров
docker-compose ps

# Просмотр логов контейнера
docker-compose logs app

# Перезапуск контейнеров
docker-compose restart

# Полная пересборка
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Проблемы с Caddy

```bash
# Проверка статуса Caddy
sudo systemctl status caddy

# Проверка конфигурации
sudo caddy validate --config /etc/caddy/Caddyfile

# Просмотр логов Caddy
sudo journalctl -u caddy -f

# Проверка портов
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :443
```

### Проблемы с SSL сертификатами

```bash
# Проверка DNS записей
nslookup cursor.yourdomain.com
dig cursor.yourdomain.com

# Проверка доступности портов
telnet cursor.yourdomain.com 80
telnet cursor.yourdomain.com 443

# Проверка SSL сертификата
echo | openssl s_client -connect cursor.yourdomain.com:443 -servername cursor.yourdomain.com 2>/dev/null | openssl x509 -noout -dates
```

### Проблемы с производительностью

```bash
# Мониторинг ресурсов
htop
free -h
df -h

# Проверка использования диска
du -sh ~/cursor-auto-account/

# Очистка неиспользуемых Docker ресурсов
docker system prune -a
```

### Частые ошибки и их решения

#### Ошибка: "Connection refused" при подключении к базе данных
**Решение**: Проверьте, что MySQL запущен и доступен на правильном порту.

#### Ошибка: "Port already in use"
**Решение**: Измените порт в .env файле и обновите конфигурацию.

#### Ошибка: "SSL certificate not found"
**Решение**: Убедитесь, что DNS записи правильно настроены и прокси включен в Cloudflare.

#### Ошибка: "Permission denied" при создании логов
**Решение**: Проверьте права доступа к директориям логов.

## Дополнительные рекомендации

### Безопасность

1. **Регулярно обновляйте систему и ПО**
2. **Используйте надежные пароли**
3. **Ограничьте доступ к SSH только необходимыми IP**
4. **Настройте файрвол**
5. **Мониторьте логи на предмет подозрительной активности**

### Производительность

1. **Регулярно очищайте старые логи**
2. **Мониторьте использование ресурсов**
3. **Настройте автоматические резервные копии**
4. **Оптимизируйте настройки MySQL**

### Мониторинг

1. **Настройте уведомления о критических ошибках**
2. **Регулярно проверяйте статус сервисов**
3. **Мониторьте использование диска и памяти**
4. **Ведите журнал изменений конфигурации**

---

## Заключение

После выполнения всех шагов ваше приложение Cursor Account Manager будет доступно по адресу `https://cursor.yourdomain.com` с автоматически настроенным SSL сертификатом.

Не забудьте:
- Регулярно обновлять систему
- Делать резервные копии базы данных
- Мониторить логи и производительность
- Следить за безопасностью

При возникновении проблем обращайтесь к разделу "Устранение неполадок" или создавайте issue в репозитории проекта.