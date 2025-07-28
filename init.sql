-- Инициализация базы данных Cursor Account Manager
-- Этот файл выполняется автоматически при первом запуске контейнера MySQL

-- Создание базы данных (если не существует)
CREATE DATABASE IF NOT EXISTS cursor_accounts CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Использование базы данных
USE cursor_accounts;

-- Создание пользователя (если не существует)
-- Примечание: пользователь создается автоматически через переменные окружения MySQL

-- Установка прав доступа
GRANT ALL PRIVILEGES ON cursor_accounts.* TO 'root'@'%';
FLUSH PRIVILEGES;

-- Логирование успешной инициализации
SELECT 'Cursor Account Manager database initialized successfully' as status;