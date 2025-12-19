#!/bin/bash

# Configuración
MOODLE_VERSION=${MOODLE_VERSION:-5.1.1}
MOODLE_DIR="./moodle"
MOODLE_URL="https://download.moodle.org/download.php/direct/stable${MOODLE_VERSION%.*}/moodle-latest-${MOODLE_VERSION}.tgz"

echo "========================================="
echo "Instalador de Moodle ${MOODLE_VERSION}"
echo "Puerto: 7000"
echo "Adminer: 7001"
echo "========================================="

# Verificar si el directorio moodle ya existe
if [ -d "$MOODLE_DIR" ]; then
    echo "El directorio 'moodle' ya existe."
    read -p "¿Desea eliminarlo y reinstalar? (s/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        echo "Eliminando directorio moodle existente..."
        rm -rf "$MOODLE_DIR"
    else
        echo "Instalación cancelada."
        exit 1
    fi
fi

# Crear directorios necesarios
echo "Creando directorios..."
mkdir -p "$MOODLE_DIR"
mkdir -p ./nginx/logs
mkdir -p ./mysql
mkdir -p ./php

# Descargar Moodle
echo "Descargando Moodle ${MOODLE_VERSION}..."
curl -L -o moodle.tar.gz "$MOODLE_URL"

if [ $? -ne 0 ]; then
    echo "Error al descargar Moodle."
    echo "Intentando URL alternativa..."
    MOODLE_URL="https://download.moodle.org/stable${MOODLE_VERSION%.*}/moodle-latest-${MOODLE_VERSION}.tgz"
    curl -L -o moodle.tar.gz "$MOODLE_URL"
fi

# Extraer Moodle
echo "Extrayendo Moodle..."
tar -xzf moodle.tar.gz --strip-components=1 -C "$MOODLE_DIR"
rm moodle.tar.gz

# Configurar permisos
echo "Configurando permisos..."
chmod -R 755 "$MOODLE_DIR"
chmod 777 "$MOODLE_DIR"

# Crear directorio moodledata
echo "Creando directorio moodledata..."
docker volume create lemp-moodle_moodle_data 2>/dev/null || true

# Descargar configuración si no existe
if [ ! -f "./nginx/nginx.conf" ]; then
    echo "Descargando configuraciones de ejemplo..."
    # Puedes agregar aquí la descarga de configuraciones si las tienes en un repo
fi

# Crear archivo de configuración de base de datos
echo "Creando archivo de configuración de MySQL..."
cat > ./mysql/my.cnf << EOF
[mysqld]
character-set-server=utf8mb4
collation-server=utf8mb4_unicode_ci
skip-character-set-client-handshake
max_allowed_packet=64M
innodb_file_per_table=1
innodb_file_format=Barracuda
innodb_large_prefix=1

[client]
default-character-set=utf8mb4

[mysql]
default-character-set=utf8mb4
EOF

echo "========================================="
echo "Instalación completada!"
echo ""
echo "Para iniciar Moodle:"
echo "1. docker-compose up -d"
echo "2. Accede a: http://localhost:7000"
echo ""
echo "Para administrar la base de datos:"
echo "http://localhost:7001"
echo ""
echo "Credenciales de base de datos:"
echo "Host: db"
echo "Base de datos: moodle"
echo "Usuario: moodleuser"
echo "Contraseña: moodlepassword"
echo "========================================="
