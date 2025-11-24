# Knuth C API Example

Este ejemplo demuestra cómo usar la API C de Knuth para interactuar con la blockchain de Bitcoin Cash.

## Archivos

- `example.c` - Código fuente del ejemplo
- `CMakeLists.txt` - Configuración de CMake
- `conanfile.txt` - Dependencias de Conan
- `Dockerfile` - Imagen Docker con pre-requisitos del sistema
- `test-docker.sh` - Script para ejecutar el ejemplo en Docker
- `test-local.sh` - Script para ejecutar el ejemplo localmente

## Pre-requisitos (Solo para ejecución local)

- Python 3 con pip
- GCC o compilador C compatible
- CMake

## Ejecución en Docker

```bash
# 1. Construir la imagen
docker build -t knuth-c-example .

# 2. Ejecutar el ejemplo
docker run --rm knuth-c-example ./test-docker.sh
```

## Ejecución Local

```bash
# Ejecutar (mantiene archivos de build anteriores)
./test-local.sh

# Ejecutar con limpieza completa
./test-local.sh --clean
```

El script local:
- Crea un subdirectorio `build/` para la compilación
- Copia los archivos fuente al directorio de build
- Ejecuta todos los pasos de configuración, compilación y ejecución
- Usa `--clean` para eliminar el directorio de build antes de empezar

## Pasos Ejecutados (Idénticos a la Web)

### 1. Tooling Setup
```bash
pip3 install kthbuild conan --user
conan profile detect --force
conan remote add kth https://packages.kth.cash/api
conan config install https://github.com/k-nuth/ci-utils/raw/master/conan/config2023.zip
```

### 2. Build
```bash
conan install . --build=missing
cmake --preset conan-release
cmake --build --preset conan-release
```

### 3. Run
```bash
./build/Release/example
```

## ¿Qué hace el ejemplo?

El ejemplo:
1. Configura un nodo de Bitcoin Cash en modo mainnet
2. Espera a que la blockchain se sincronice hasta el bloque 170
3. Recupera el bloque 170 (la primera transacción persona-a-persona: Satoshi a Hal Finney)
4. Muestra el hash del bloque
5. Se queda corriendo hasta que se presiona Ctrl-C

## Nota sobre los Scripts

Los scripts `test-docker.sh` y `test-local.sh` ejecutan **exactamente** los mismos pasos que aparecen en la página web de Knuth. La única diferencia es la instalación de pre-requisitos del sistema, que Docker maneja a través del Dockerfile.
