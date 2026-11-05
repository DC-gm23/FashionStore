CREATE DATABASE IF NOT EXISTS local_xampp_d
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE local_xampp_d;

-- 2. Crear usuario seguro para la aplicación
CREATE USER IF NOT EXISTS 'app_fashionstore'@'localhost' IDENTIFIED BY 'Fashion@2024$Pass';

-- 3. Asignar privilegios exclusivos sobre la base de datos del proyecto
GRANT ALL PRIVILEGES ON fashionstore_db.* TO 'app_fashionstore'@'localhost';

-- 4. Aplicar cambios de privilegios
FLUSH PRIVILEGES;
SELECT VERSION();