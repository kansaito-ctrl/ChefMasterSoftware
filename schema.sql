CREATE DATABASE IF NOT EXISTS chefmaster CHARACTER SET utf8mb4;
USE chefmaster;

CREATE TABLE ingredients (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(80) NOT NULL UNIQUE,
  category VARCHAR(40) NOT NULL,
  unit VARCHAR(10) NOT NULL,
  quantity DECIMAL(10,2) NOT NULL DEFAULT 0,
  minimum DECIMAL(10,2) NOT NULL DEFAULT 0,
  price DECIMAL(10,3) NOT NULL DEFAULT 0
);
CREATE TABLE recipes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(80) NOT NULL UNIQUE,
  price DECIMAL(10,2) NOT NULL
);
CREATE TABLE recipe_ingredients (
  recipe_id INT NOT NULL, ingredient_id INT NOT NULL, qty DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (recipe_id, ingredient_id),
  FOREIGN KEY (recipe_id) REFERENCES recipes(id),
  FOREIGN KEY (ingredient_id) REFERENCES ingredients(id)
);
CREATE TABLE orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  customer VARCHAR(80) NOT NULL,
  notes TEXT,
  priority ENUM('Alta','Media','Baja') NOT NULL DEFAULT 'Media',
  status ENUM('Nuevo','En preparación','Listo','Entregado') NOT NULL DEFAULT 'Nuevo',
  discounted BOOLEAN NOT NULL DEFAULT FALSE,
  deleted_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) AUTO_INCREMENT=1042;
CREATE TABLE order_items (
  order_id INT NOT NULL, recipe_id INT NOT NULL, qty INT NOT NULL,
  PRIMARY KEY (order_id, recipe_id),
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (recipe_id) REFERENCES recipes(id)
);
CREATE TABLE movements (
  id INT AUTO_INCREMENT PRIMARY KEY,
  type ENUM('Entrada','Salida manual','Consumo por pedido') NOT NULL,
  ingredient_id INT NOT NULL,
  order_id INT NULL,
  amount DECIMAL(10,2) NOT NULL,
  before_qty DECIMAL(10,2), after_qty DECIMAL(10,2),
  reason VARCHAR(40), supplier VARCHAR(80), cost DECIMAL(10,2), note VARCHAR(200),
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (ingredient_id) REFERENCES ingredients(id)
);

INSERT INTO ingredients (name,category,unit,quantity,minimum,price) VALUES
('Carne molida','Proteínas','g',1600,350,.19),('Cebolla','Vegetales','g',1200,250,.03),
('Pimiento rojo','Vegetales','g',210,100,.07),('Pimiento verde','Vegetales','g',90,100,.06),
('Perejil','Hierbas','g',75,40,.08),('Especias','Despensa','g',100,30,.12),
('Pan lavash','Panadería','piezas',18,5,8),('Masa','Panadería','g',850,250,.05),
('Yogur','Lácteos','g',450,150,.08),('Ajo','Vegetales','g',90,30,.1),
('Mantequilla','Lácteos','g',250,70,.16),('Salsa de tomate','Despensa','g',240,80,.06),
('Tomate','Vegetales','g',500,150,.04),('Berenjena','Vegetales','piezas',5,2,16),
('Aceite de oliva','Despensa','ml',400,100,.11),('Lentejas rojas','Despensa','g',400,100,.06),
('Zanahoria','Vegetales','g',300,80,.03),('Papa','Vegetales','g',500,150,.025),
('Caldo','Despensa','ml',1200,300,.018),('Masa filo','Panadería','g',360,100,.07),
('Nuez','Despensa','g',240,80,.22),('Azúcar','Despensa','g',400,100,.03),('Miel','Despensa','g',220,50,.17);

INSERT INTO recipes (name,price) VALUES
('Adana kebab',245),('Mantı',225),('Lahmacun',185),('İmam bayıldı',210),('Mercimek çorbası',145),('Baklava',135);

INSERT INTO recipe_ingredients (recipe_id,ingredient_id,qty)
SELECT r.id,i.id,t.q FROM (
 SELECT 'Adana kebab' r,'Carne molida' i,250 q UNION ALL SELECT 'Adana kebab','Cebolla',50 UNION ALL SELECT 'Adana kebab','Pimiento rojo',40 UNION ALL SELECT 'Adana kebab','Perejil',10 UNION ALL SELECT 'Adana kebab','Especias',5 UNION ALL SELECT 'Adana kebab','Pan lavash',1
 UNION ALL SELECT 'Mantı','Masa',120 UNION ALL SELECT 'Mantı','Carne molida',150 UNION ALL SELECT 'Mantı','Cebolla',30 UNION ALL SELECT 'Mantı','Yogur',100 UNION ALL SELECT 'Mantı','Ajo',5 UNION ALL SELECT 'Mantı','Mantequilla',15 UNION ALL SELECT 'Mantı','Salsa de tomate',30
 UNION ALL SELECT 'Lahmacun','Masa',180 UNION ALL SELECT 'Lahmacun','Carne molida',120 UNION ALL SELECT 'Lahmacun','Tomate',80 UNION ALL SELECT 'Lahmacun','Cebolla',40 UNION ALL SELECT 'Lahmacun','Pimiento verde',30 UNION ALL SELECT 'Lahmacun','Perejil',10
 UNION ALL SELECT 'İmam bayıldı','Berenjena',1 UNION ALL SELECT 'İmam bayıldı','Cebolla',100 UNION ALL SELECT 'İmam bayıldı','Tomate',120 UNION ALL SELECT 'İmam bayıldı','Ajo',8 UNION ALL SELECT 'İmam bayıldı','Aceite de oliva',20 UNION ALL SELECT 'İmam bayıldı','Perejil',10
 UNION ALL SELECT 'Mercimek çorbası','Lentejas rojas',100 UNION ALL SELECT 'Mercimek çorbası','Cebolla',50 UNION ALL SELECT 'Mercimek çorbası','Zanahoria',60 UNION ALL SELECT 'Mercimek çorbası','Papa',80 UNION ALL SELECT 'Mercimek çorbası','Caldo',400 UNION ALL SELECT 'Mercimek çorbası','Aceite de oliva',15 UNION ALL SELECT 'Mercimek çorbası','Especias',5
 UNION ALL SELECT 'Baklava','Masa filo',120 UNION ALL SELECT 'Baklava','Nuez',80 UNION ALL SELECT 'Baklava','Mantequilla',40 UNION ALL SELECT 'Baklava','Azúcar',70 UNION ALL SELECT 'Baklava','Miel',30
) t JOIN recipes r ON r.name=t.r JOIN ingredients i ON i.name=t.i;
