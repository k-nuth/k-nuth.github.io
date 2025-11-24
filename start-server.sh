#!/bin/bash

# Script para iniciar servidor local
# Uso: ./start-server.sh [puerto]

PORT=${1:-8000}

echo "🚀 Iniciando servidor local en el puerto $PORT..."
echo ""
echo "📂 Directorio: $(pwd)"
echo "🌐 Accede a:"
echo "   - Versión original:     http://localhost:$PORT/index.html"
echo "   - Versión modernizada:  http://localhost:$PORT/index-modern.html"
echo ""
echo "⏹️  Presiona Ctrl+C para detener el servidor"
echo ""

# Detectar qué comando usar
if command -v python3 &> /dev/null; then
    python3 -m http.server $PORT
elif command -v python &> /dev/null; then
    python -m SimpleHTTPServer $PORT
elif command -v php &> /dev/null; then
    php -S localhost:$PORT
else
    echo "❌ Error: No se encontró Python ni PHP"
    echo "Por favor instala Python 3 o usa otra opción del archivo SERVER-LOCAL.md"
    exit 1
fi
