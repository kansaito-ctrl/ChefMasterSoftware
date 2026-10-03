# ChefMaster Software

Sistema web para operaciones de una cocina turca: pedidos, inventario de ingredientes, reportes y configuración. Los datos se guardan en **MySQL** a través de una API en **Node.js + Express**.

**Demo en línea:** https://chefmastersoftware.onrender.com

> La demo corre en un plan gratuito: si nadie la visita por un rato se "duerme", y la primera carga puede tardar hasta 1 minuto.

## Tecnologías

- **Front:** HTML, CSS (Tailwind por CDN) y JavaScript
- **Backend:** Node.js + Express
- **Base de datos:** MySQL (`mysql2`)
- **Publicación:** Render (servidor) + Aiven (MySQL en la nube)

## Funciones

- Crear pedidos con varios platillos, prioridad y notas
- Cambiar el estado: Nuevo → En preparación → Listo → Entregado
- El inventario se descuenta **una sola vez** al pasar a "En preparación"
- Entradas y salidas manuales de stock (la salida pide motivo y no puede superar el stock)
- Alertas de bajo stock y agotados
- Pedidos entregados: se envían a "eliminados", se pueden restaurar o borrar definitivamente
- Registro de movimientos de inventario
- Botón **Restaurar datos** (protegido con clave) que reinicia la demo

## Requisitos

- [Node.js](https://nodejs.org) (LTS)
- [MySQL Community Server](https://dev.mysql.com/downloads/)
- [Git](https://git-scm.com)

## Cómo correrlo en tu computadora

1. Clona el repo e instala dependencias:
   ```
   Abrir Windows , Buscar PowerShell y copia y pega lo siguiente:
   git clone https://github.com/kansaito-ctrl/ChefMasterSoftware.git
   cd ChefMasterSoftware
   npm install
   ```
2. Crea tu archivo de entorno:
   ```
   cp .env.example .env
   ```
   (En PowerShell: `Copy-Item .env.example .env`) y llena tus datos de MySQL.
3. Carga la base de datos. Entra a MySQL:
   ```
   mysql -u root -p --default-character-set=utf8mb4
   ```
   y ejecuta:
   ```
   source schema.sql;
   source seed_demo.sql;
   exit
   ```
4. Arranca el servidor:
   ```
   npm run dev
   ```
5. Abre http://localhost:3000

## Variables de entorno

| Variable | Descripción |
|----------|-------------|
| `DB_HOST` | Servidor de MySQL (`localhost` en local) |
| `DB_PORT` | Puerto de MySQL (3306 por defecto) |
| `DB_USER` | Usuario de MySQL |
| `DB_PASSWORD` | Contraseña de MySQL |
| `DB_NAME` | Nombre de la base de datos (`chefmaster`) |
| `DB_SSL` | `true` solo si la base en la nube exige conexión segura |
| `RESET_KEY` | Clave que protege el botón "Restaurar datos" |

> El archivo `.env` **no** se sube a Git: contiene credenciales. Usa `.env.example` como plantilla.

## Publicación en línea

- **Base de datos:** servicio MySQL en Aiven. Se cargan `schema.sql` y `seed_demo.sql` con el cliente `mysql` usando `--ssl-mode=REQUIRED`.
- **Servidor:** Web Service en Render conectado a este repo, con Build Command `npm install` y Start Command `node server.js`. Las variables de entorno se configuran en el panel de Render.
- **Actualizaciones:** cada `git push` a `main` vuelve a publicar la app automáticamente.

## Estructura

```
chefmaster/
├── public/
│   ├── index.html   # interfaz
│   └── api.js       # conecta la interfaz con la API
├── server.js        # API Express + MySQL
├── schema.sql       # tablas y datos iniciales
├── seed_demo.sql    # pedidos de ejemplo (también lo usa "Restaurar datos")
├── .env.example     # plantilla de variables de entorno
└── package.json
```

## Base de datos

Tablas: `ingredients`, `recipes`, `recipe_ingredients`, `orders`, `order_items`, `movements`.

## API

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/api/recipes` | Platillos con sus ingredientes |
| GET | `/api/inventory` | Ingredientes y stock |
| GET | `/api/movements` | Últimos 100 movimientos |
| GET | `/api/orders` | Pedidos activos |
| GET | `/api/orders/deleted` | Pedidos eliminados |
| POST | `/api/orders` | Crear pedido |
| PATCH | `/api/orders/:id/status` | Cambiar estado (descuenta inventario al iniciar preparación) |
| PATCH | `/api/orders/:id/delete` | Enviar a eliminados (solo si está Entregado) |
| PATCH | `/api/orders/:id/restore` | Restaurar pedido eliminado |
| DELETE | `/api/orders/:id` | Eliminar definitivamente |
| POST | `/api/inventory/:id/movement` | Entrada o salida manual de stock |
| POST | `/api/reset` | Reiniciar la demo (requiere `key` en el cuerpo) |

## Limitaciones

No hay inicio de sesión ni roles: la protección de `/api/reset` es solo una clave simple pensada para la demo. Para un uso real habría que agregar usuarios y permisos.

## Autor

Lugo Flores Jose Geronimo, Emiliano Resendiz Gonzalez, Miguel Reyes Montiel, Humberto Quintana Banda, Jose Ramon Garcia Alvarez ,Lizbeth Santiago Martinez estudiantes de Ingeniería en Software y Ciber Seguridad en Universidad ICEL-UI. Campus Ermita