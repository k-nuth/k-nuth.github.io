# 🚀 Cómo ver el sitio web modernizado localmente

Este archivo contiene instrucciones para ejecutar y previsualizar el sitio web Knuth en tu máquina local.

## 📋 Opciones disponibles

Tienes varias opciones para ejecutar un servidor local. Elige la que prefieras:

---

## Opción 1: Python (Recomendado - más simple)

### Python 3 (recomendado)
```bash
# Navega al directorio del proyecto
cd /Users/fernando/dev/kth/k-nuth.github.io

# Ejecuta el servidor en el puerto 8000
python3 -m http.server 8000
```

### Python 2 (si solo tienes Python 2)
```bash
cd /Users/fernando/dev/kth/k-nuth.github.io
python -m SimpleHTTPServer 8000
```

**Abrir en el navegador:**
```
http://localhost:8000/index-modern.html
```

---

## Opción 2: Node.js con npx (Sin instalación)

Si tienes Node.js instalado:

```bash
cd /Users/fernando/dev/kth/k-nuth.github.io

# Usando http-server (se instala automáticamente)
npx http-server -p 8000

# O usando serve
npx serve -l 8000
```

**Abrir en el navegador:**
```
http://localhost:8000/index-modern.html
```

---

## Opción 3: PHP

Si tienes PHP instalado:

```bash
cd /Users/fernando/dev/kth/k-nuth.github.io
php -S localhost:8000
```

**Abrir en el navegador:**
```
http://localhost:8000/index-modern.html
```

---

## Opción 4: VS Code Live Server (Si usas VS Code)

1. Instala la extensión "Live Server" en VS Code
2. Abre el proyecto en VS Code
3. Click derecho en `index-modern.html`
4. Selecciona "Open with Live Server"

Automáticamente se abrirá en tu navegador con recarga en vivo.

---

## 🎨 Comparar versiones

- **Versión original:** `http://localhost:8000/index.html`
- **Versión modernizada:** `http://localhost:8000/index-modern.html`

---

## 🔍 Características de la versión modernizada

### ✅ Mejoras implementadas:

1. **Tailwind CSS** en lugar de Bootstrap
   - Diseño más moderno y limpio
   - Mejor control sobre estilos
   - Sin dependencias de jQuery

2. **Animaciones suaves**
   - Fade-in en el hero
   - Slide-up en secciones
   - Hover effects en tarjetas y botones
   - Transiciones suaves

3. **Diseño responsive mejorado**
   - Mobile-first approach
   - Breakpoints optimizados
   - Menú hamburguesa moderno

4. **Componentes modernizados**
   - Cards con sombras y efectos hover
   - Botones con gradientes
   - Navegación fija con efecto scroll
   - Iconos de redes sociales con animaciones

5. **Mejor tipografía y espaciado**
   - Mayor legibilidad
   - Jerarquía visual clara
   - Espaciado consistente

6. **Sin jQuery**
   - JavaScript vanilla puro
   - Mejor performance
   - Menos dependencias

---

## 📝 Próximos pasos sugeridos

Si quieres reemplazar la versión original con la modernizada:

```bash
# Hacer backup del original
cp index.html index-original-backup.html

# Reemplazar con la versión moderna
cp index-modern.html index.html
```

Luego puedes hacer commit de los cambios:

```bash
git add index.html index-modern.html
git commit -m "Modernizar diseño con Tailwind CSS"
git push origin master
```

---

## 🛠️ Modo oscuro (Futuro)

El sistema está preparado para modo oscuro. Para habilitarlo en el futuro:

1. Añadir un botón de toggle en el navbar
2. Usar las clases `dark:` de Tailwind
3. Guardar preferencia en localStorage

Ejemplo de código para toggle:
```javascript
// Toggle dark mode
const darkModeToggle = document.getElementById('dark-mode-toggle');
darkModeToggle.addEventListener('click', () => {
  document.documentElement.classList.toggle('dark');
  localStorage.setItem('darkMode',
    document.documentElement.classList.contains('dark')
  );
});
```

---

## 💡 Tips

- **Puerto ocupado?** Usa otro puerto: `python3 -m http.server 3000`
- **Auto-reload?** Usa VS Code Live Server o `npx browser-sync`
- **HTTPS local?** Usa `npx http-server -S` (requiere certificados)

---

## 🐛 Troubleshooting

**Problema:** "Address already in use"
- **Solución:** Cambia el puerto o mata el proceso:
  ```bash
  lsof -ti:8000 | xargs kill
  ```

**Problema:** Estilos no se cargan
- **Solución:** Verifica que estés accediendo a través del servidor HTTP, no abriendo el archivo directamente (`file://`)

**Problema:** Fuentes no se cargan
- **Solución:** Verifica tu conexión a internet (Google Fonts se carga desde CDN)

---

¡Disfruta tu sitio modernizado! 🎉
