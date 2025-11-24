# Knuth Examples - Testing Framework

Este directorio contiene ejemplos de uso de Knuth en diferentes lenguajes, cada uno en su propia carpeta autocontenida.

## Estructura

```
test-examples/
├── c/                      # Ejemplo en C
│   ├── example.c           # Código fuente
│   ├── CMakeLists.txt      # Configuración CMake
│   ├── conanfile.txt       # Dependencias Conan
│   ├── Dockerfile          # Pre-requisitos del sistema
│   ├── test-docker.sh      # Script para Docker
│   ├── test-local.sh       # Script para ejecución local
│   ├── .gitignore          # Ignora build/
│   └── README.md           # Documentación específica
│
├── cpp/                    # (Futuro) Ejemplo en C++
├── csharp/                 # (Futuro) Ejemplo en C#
├── javascript/             # (Futuro) Ejemplo en JavaScript
└── executable/             # (Futuro) Nodo ejecutable
```

## Principio de Diseño

**Cada lenguaje es completamente autocontenido y ejecuta exactamente los pasos de la web.**

### Ventajas de esta estructura:

1. **Autocontenida**: Cada carpeta tiene todo lo necesario para ejecutar el ejemplo
2. **Sin duplicación**: No hay scripts compartidos que puedan romperse
3. **Fácil de mantener**: Cambios en un lenguaje no afectan a otros
4. **Verificación**: Los scripts garantizan que lo que está en la web realmente funciona

### Diferencias permitidas:

Los scripts de Docker y local **solo** pueden diferir en:
- Instalación de pre-requisitos del sistema (Python, pip, GCC, CMake, etc.)
- Manejo de rutas (Docker usa `/workspace`, local usa subdirectorios)

Todo lo demás debe ser **idéntico** a la web:
- Tooling Setup (instalación y configuración de Conan)
- Project Setup (archivos de configuración)
- Build (comandos de compilación)
- Run (ejecución del ejemplo)

## Uso

### Para Desarrolladores

Cada carpeta de lenguaje contiene su propio README con instrucciones específicas.

Ejemplo para C:
```bash
cd c/

# Docker
docker build -t knuth-c-example .
docker run --rm knuth-c-example ./test-docker.sh

# Local
./test-local.sh --clean
```

### Para CI/CD

Puedes ejecutar todos los tests en Docker:
```bash
for lang in c cpp csharp javascript executable; do
  if [ -d "$lang" ]; then
    cd "$lang"
    docker build -t "knuth-$lang-example" .
    docker run --rm "knuth-$lang-example" ./test-docker.sh
    cd ..
  fi
done
```

## Agregar un Nuevo Lenguaje

1. Crear directorio: `mkdir newlang/`
2. Copiar archivos del ejemplo
3. Crear `Dockerfile` con pre-requisitos del sistema
4. Crear `test-docker.sh` siguiendo el template de C
5. Crear `test-local.sh` siguiendo el template de C
6. Crear `README.md` explicando el ejemplo
7. Crear `.gitignore` para ignorar `build/`

## Archivos Obsoletos

Los siguientes archivos en la raíz son obsoletos y se pueden eliminar:
- `compile-*.sh` (obsoletos)
- `test-all.sh` (obsoleto)
- `run-tests.sh` (obsoleto)
- `test-c-only.sh` (reemplazado por `c/test-docker.sh`)
- `test-local.sh` (reemplazado por `c/test-local.sh`)
- `examples/` (contenido movido a carpetas individuales)
- `build-local/` (cada lenguaje tiene su propio build/)
- `Dockerfile` (cada lenguaje tiene su propio Dockerfile)

## Verificación

Para verificar que un ejemplo funciona correctamente:

1. **Web**: Copia los pasos de la página web
2. **Docker**: Ejecuta `./test-docker.sh` en la carpeta del lenguaje
3. **Local**: Ejecuta `./test-local.sh` en la carpeta del lenguaje

Si todos funcionan, significa que la documentación web está correcta y actualizada.
