# ChefMaster Software

Sistema web para operaciones de una cocina turca: pedidos, inventario de ingredientes, reportes y configuración. Los datos se guardan en **MySQL** a través de una API en **Node.js + Express**.

## Tecnologías

- **Front:** HTML, CSS (Tailwind por CDN) y JavaScript puro
- **Backend:** Node.js + Express
- **Base de datos:** MySQL (`mysql2`)

## Funciones

- Crear pedidos con varios platillos, prioridad y notas
- Cambiar el estado: Nuevo → En preparación → Listo → Entregado
- El inventario se descuenta **una sola vez** al pasar a "En preparación"
- Entradas y salidas manuales de stock (la salida pide motivo y no puede superar el stock)
- Alertas de bajo stock y agotados
- Pedidos entregados: se envían a "eliminados", se pueden restaurar o borrar definitivamente
- Registro de movimientos de inventario

## Requisitos

- [Node.js](https://nodejs.org) (LTS)
- [MySQL Community Server](https://dev.mysql.com/downloads/)
- [Git](https://git-scm.com)

## Cómo correrlo

1. Clona el repo e instala dependencias:
   ```
   git clone https://github.com/kansaito-ctrl/ChefMasterSoftware.git
   cd ChefMasterSoftware
   npm install
   ```
2. Crea tu archivo de entorno y pon tu contraseña de MySQL:
   ```
   cp .env.example .env
   ```
   (En PowerShell: `Copy-Item .env.example .env`)
3. Carga la base de datos. Entra a MySQL y ejecuta el esquema:
   ```
   mysql -u root -p --default-character-set=utf8mb4
   ```
   ```
   source schema.sql;
   exit
   ```
4. Arranca el servidor:
   ```
   npm run dev
   ```
5. Abre http://localhost:3000

> El archivo `.env` **no** se sube a Git: contiene credenciales.

## Estructura

```
chefmaster/
├── public/
│   ├── index.html   # interfaz
│   └── api.js       # conecta la interfaz con la API
├── server.js        # API Express + MySQL
├── schema.sql       # tablas y datos iniciales
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

## Autor

Gerónimo Lugo, estudiante de Ingeniería en Software, Universidad ICEL-UI.