# ChefMaster Software

Sistema web para operar la cocina de un restaurante: **pedidos, comandas, inventario, carta y reportes**. Los datos se guardan en **MySQL** a través de una API en **Node.js + Express**.

**Demo en línea:** https://chefmastersoftware.onrender.com

> La demo corre en un plan gratuito: si nadie la visita por un rato se "duerme", y la primera carga puede tardar hasta 1 minuto.

## Tres vistas, tres tipos de acceso

Al abrir la página aparece el inicio con tres opciones:

| Vista | Acceso | Qué hace |
|-------|--------|----------|
| **Cliente** | Libre | Ve el menú por categorías con nombres e ingredientes, elige platillos y envía su pedido a cocina |
| **Cocina** | Contraseña de cocina | Monitor de comandas: pedidos nuevos, en preparación y listos, con cronómetro. Avanza el estado de cada comanda |
| **Administración** | Contraseña de administración | Pedidos, inventario, reportes, carta y configuración |

Las contraseñas se validan **en el servidor** y se configuran con variables de entorno. La cocina solo puede ver comandas y cambiar su estado: no accede al inventario ni a la configuración.

## Funciones

- Menú del cliente por categorías: tacos, guarniciones y menú de 5 tiempos (entrada, segundo tiempo, plato fuerte, postre y bebida), más el menú degustación completo
- Pedidos con varios platillos, prioridad y notas
- Estados: Nuevo → En preparación → Listo → Entregado
- **Agregar platillos a una mesa** que ya tiene un pedido abierto
- El inventario se descuenta **una sola vez** al pasar a "En preparación" (y si se agrega algo a una mesa ya en preparación, se descuenta lo nuevo)
- Entradas y salidas manuales de stock (la salida pide motivo y no puede superar el stock)
- Alertas de bajo stock y agotados, y registro de movimientos
- **Carta editable:** cambiar precios, ocultar platillos del menú del cliente y añadir platillos nuevos con sus ingredientes
- Pedidos entregados: se envían a "eliminados", se pueden restaurar o borrar definitivamente
- Botón **Restaurar datos** (protegido con clave) que reinicia la demo

## Tecnologías

- **Front:** HTML, CSS (Tailwind por CDN) y JavaScript
- **Backend:** Node.js + Express
- **Base de datos:** MySQL (`mysql2`)
- **Publicación:** Render (servidor) + Aiven (MySQL en la nube)

## Probarlo en línea (sin instalar nada)

1. Abre **https://chefmastersoftware.onrender.com**
2. La **primera vez puede tardar hasta 1 minuto** en cargar, porque el servidor gratis se "duerme". Espera y no la cierres.
3. Verás 3 opciones:

| Opción | Qué hacer |
|--------|-----------|
| **Cliente** | Entra directo. Elige platillos con **+** y **−**, escribe tu mesa (o tu nombre) y dale **Enviar** |
| **Cocina** | Pide la contraseña de cocina al autor. Aquí aparece tu pedido en **Nuevas** |
| **Administración** | Pide la contraseña al autor. Aquí ves pedidos, inventario, reportes y la carta |

**Recorrido para probarlo todo:**

1. Entra como **Cliente** y pide 2 tacos.
2. Entra como **Cocina**: tu pedido sale en la columna **Nuevas**. Dale **Iniciar**, luego **Listo**.
3. Entra como **Administración** → **Inventario** y mira cómo **bajaron los ingredientes**.

## Correrlo en tu computadora, paso a paso (Windows)

Tiempo aproximado: 30 a 40 minutos la primera vez, casi todo es instalar programas.

### Paso 0: instala lo necesario

Instala estos 4 programas con **Siguiente, Siguiente, Finalizar**:

1. **Node.js** (versión LTS): https://nodejs.org
2. **Git**: https://git-scm.com
3. **VSCode**: https://code.visualstudio.com
4. **MySQL Community Server**: https://dev.mysql.com/downloads/installer/
   - Elige el instalador **MSI** más grande.
   - En el tipo de instalación elige **Custom** y marca **MySQL Server** y **MySQL Workbench**.
   - En **Accounts and Roles** te pide una **contraseña de root**. **Anótala**, la vas a necesitar.
   - Todo lo demás lo dejas como viene.

**Revisa que quedó todo.** Abre **PowerShell** (tecla Windows, escribe *PowerShell*) y corre estos 4 comandos, uno por uno:

```
node -v
git --version
mysql --version
code --version
```

✅ **Debe salir:** un número de versión en cada uno.

❌ **Si en `mysql --version` dice que "no se reconoce":** MySQL sí se instaló, solo falta decirle a Windows dónde está.

1. Abre el Explorador de archivos y ve a `C:\Program Files\MySQL\`. Entra a la carpeta **MySQL Server ...** y luego a **bin**. Copia esa ruta de la barra de arriba (el número de versión puede ser distinto en cada compu).
2. Presiona la tecla Windows, escribe **variables de entorno** y abre **Editar las variables de entorno del sistema**.
3. Clic en **Variables de entorno...** → en la caja de arriba selecciona **Path** → **Editar...** → **Nuevo** → pega la ruta.
4. **Aceptar** en las 3 ventanas.
5. **Cierra PowerShell y ábrelo de nuevo**, y repite `mysql --version`.

---

### Paso 1: descarga el proyecto

En PowerShell:

```
cd $HOME\Desktop
git clone https://github.com/kansaito-ctrl/ChefMasterSoftware.git
cd ChefMasterSoftware
npm install
```

✅ **Debe salir:** al final algo como `added 80 packages` y `found 0 vulnerabilities`.

---

### Paso 2: crea tu archivo `.env`

Este archivo guarda tus contraseñas **solo en tu compu** (no se sube a GitHub).

```
Copy-Item .env.example .env
code .env
```

Se abre en VSCode. **Déjalo así**, cambiando solo lo que dice "tu":

```
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=tu_contraseña_de_mysql
DB_NAME=chefmaster
PORT=3000
ADMIN_PASSWORD=elige_una_contraseña
COCINA_PASSWORD=elige_otra_distinta
RESET_KEY=elige_una_clave
```

- `DB_PASSWORD` es la contraseña de **root** que pusiste al instalar MySQL.
- Las otras 3 **las inventas tú** (con letras y números, sin espacios).
- Guarda con **Ctrl + S**.

---

### Paso 3: crea la base de datos

Estando **dentro de la carpeta `ChefMasterSoftware`** (importante), entra a MySQL:

```
mysql -u root -p --default-character-set=utf8mb4
```

Te pide la contraseña de root. **Al escribirla no se ve nada, es normal.** Dale Enter.

✅ **Debe salir:** `mysql>`

Ahora corre estas 4 líneas **en este orden**, una por una (con el punto y coma):

```
source schema.sql;
source menu_nuevo.sql;
source seed_demo.sql;
source seed_stock_menu.sql;
```

✅ **Debe salir:** muchas líneas de `Query OK`. Si sale algo con `ERROR`, ve a "Si algo falla" más abajo.

Para salir de MySQL escribe:

```
exit
```

---

### Paso 4: prende el servidor

```
npm run dev
```

✅ **Debe salir:** `ChefMaster en http://localhost:3000`

⚠️ **Deja esa ventana abierta.** Si la cierras, se apaga el servidor. Para apagarlo a propósito, presiona `Ctrl + C`.

---

### Paso 5: ábrelo

En tu navegador entra a: **http://localhost:3000**

Ya puedes usar las 3 opciones (**Cliente, Cocina y Administración**). La contraseña de cada una es la que pusiste en tu `.env`.

## Si algo falla

| Lo que ves | Qué significa | Cómo arreglarlo |
|-----------|---------------|-----------------|
| `mysql no se reconoce como comando` | Falta agregar MySQL al PATH | Hazlo como en el Paso 0 y abre una PowerShell nueva |
| `Failed to open file 'schema.sql'` | Abriste MySQL desde otra carpeta | Escribe `exit`, haz `cd` a la carpeta `ChefMasterSoftware` y vuelve a entrar |
| `Access denied for user 'root'` | La contraseña está mal | Usa la contraseña de root que pusiste al instalar MySQL |
| `Table ... already exists` | Ya habías cargado la base | Dentro de MySQL corre `DROP DATABASE chefmaster;` y repite el Paso 3 |
| La página dice `Failed to fetch` | El servidor está apagado | Corre `npm run dev` y deja la ventana abierta |
| El navegador dice `ERR_CONNECTION_REFUSED` | Lo mismo: el servidor no está corriendo | Corre `npm run dev` |
| `Contraseña incorrecta` en el login | No coincide con tu `.env` | Revisa `ADMIN_PASSWORD` / `COCINA_PASSWORD`, guarda y **reinicia el servidor** (`Ctrl + C` y `npm run dev`) |
| `Cannot GET /` | Falta algún archivo en la carpeta `public` | Corre `git pull` para traer lo más nuevo |
| Cambié el `.env` y no pasa nada | El servidor solo lee el `.env` al arrancar | Reinicia el servidor (`Ctrl + C` y `npm run dev`) |

## Actualizar tu copia del proyecto

Cuando el autor suba cambios nuevos, en tu carpeta del proyecto corre:

```
git pull
npm install
```

Y reinicia el servidor. Si los cambios traen archivos `.sql` nuevos, el autor te avisa cuál cargar.

## Variables de entorno

| Variable | Descripción |
|----------|-------------|
| `DB_HOST` | Servidor de MySQL (`localhost` en local) |
| `DB_PORT` | Puerto de MySQL (3306 por defecto) |
| `DB_USER` | Usuario de MySQL |
| `DB_PASSWORD` | Contraseña de MySQL |
| `DB_NAME` | Nombre de la base de datos (`chefmaster`) |
| `DB_SSL` | `true` solo si la base en la nube exige conexión segura |
| `ADMIN_PASSWORD` | Contraseña de la vista de administración |
| `COCINA_PASSWORD` | Contraseña de la vista de cocina (distinta a la de administración) |
| `RESET_KEY` | Clave que protege el botón "Restaurar datos" |

> El archivo `.env` **no** se sube a Git: contiene credenciales. Usa `.env.example` como plantilla.

## Publicación en línea

- **Base de datos:** servicio MySQL en Aiven. Los archivos `.sql` se cargan con el cliente `mysql` usando `--ssl-mode=REQUIRED`.
- **Servidor:** Web Service en Render conectado a este repo, con Build Command `npm install` y Start Command `node server.js`. Todas las variables de entorno se configuran en el panel de Render.
- **Actualizaciones:** cada `git push` a `main` vuelve a publicar la app automáticamente.
- Los cambios en la base de datos (por ejemplo, un `.sql` nuevo) **no** se aplican solos: hay que ejecutarlos en la base de Aiven.

## Estructura

```
chefmaster/
├── public/
│   ├── index.html          # inicio: Cliente / Cocina / Administración
│   ├── cliente.html        # menú y pedido del cliente
│   ├── cocina.html         # monitor de comandas
│   ├── administracion.html # sistema de administración
│   ├── api.js              # conecta la administración con la API
│   └── admin_extras.js     # agregar a la mesa y carta editable
├── server.js               # API Express + MySQL
├── schema.sql              # tablas y datos iniciales
├── menu_nuevo.sql          # platillos, recetas e ingredientes del menú
├── seed_demo.sql           # pedidos de ejemplo (usado por "Restaurar datos")
├── seed_stock_menu.sql     # existencias iniciales del menú nuevo
├── .env.example            # plantilla de variables de entorno
└── package.json
```

## Base de datos

Tablas: `ingredients`, `recipes`, `recipe_ingredients`, `orders`, `order_items`, `movements`.

Cada platillo de la carta guarda su categoría, descripción y precio, y una receta con las cantidades de ingredientes **por porción de venta** (por ejemplo, 1 taco).

## API

**Públicas**

| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/api/login` | Inicia sesión (`role`: `admin` o `cocina`) y devuelve un token |
| GET | `/api/menu` | Menú visible para el cliente |
| POST | `/api/orders` | Crear un pedido |

**Cocina y administración**

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/api/orders` | Pedidos activos |
| GET | `/api/recipes` | Platillos con sus ingredientes |
| PATCH | `/api/orders/:id/status` | Cambiar estado (descuenta inventario al iniciar preparación) |

**Solo administración**

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/api/inventory` | Ingredientes y stock |
| GET | `/api/movements` | Últimos 100 movimientos |
| GET | `/api/orders/deleted` | Pedidos eliminados |
| POST | `/api/orders/:id/items` | Agregar platillos a un pedido abierto |
| PATCH | `/api/orders/:id/delete` | Enviar a eliminados (solo si está Entregado) |
| PATCH | `/api/orders/:id/restore` | Restaurar pedido eliminado |
| DELETE | `/api/orders/:id` | Eliminar definitivamente |
| POST | `/api/inventory/:id/movement` | Entrada o salida manual de stock |
| POST | `/api/recipes` | Añadir un platillo a la carta |
| PATCH | `/api/recipes/:id` | Cambiar precio u ocultar/mostrar un platillo |
| POST | `/api/reset` | Reiniciar la demo (requiere `key` en el cuerpo) |

Las rutas protegidas esperan el encabezado `Authorization: Bearer <token>`.

## Limitaciones

- Solo hay dos contraseñas compartidas (administración y cocina): no hay usuarios individuales ni historial de quién hizo cada cambio.
- Los pedidos de clientes se aceptan sin identificación, y no hay límite de intentos en el login.
- Las existencias iniciales, los precios y las conversiones de medidas del menú son **provisionales** y se ajustan desde el sistema.

## Autor

Lugo Flores Jose Geronimo, Emiliano Resendiz Gonzalez, Miguel Reyes Montiel, Humberto Quintana Banda, Jose Ramon Garcia Alvarez ,Lizbeth Santiago Martinez estudiantes de Ingeniería en Software y Ciber Seguridad en Universidad ICEL-UI. Campus Ermita