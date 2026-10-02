USE chefmaster;

-- 1) Limpiar pedidos y movimientos
DELETE FROM movements;
DELETE FROM order_items;
DELETE FROM orders;

-- 2) Stock inicial
UPDATE ingredients i JOIN (
 SELECT 'Carne molida' n,1600 q UNION ALL SELECT 'Cebolla',1200 UNION ALL SELECT 'Pimiento rojo',210
 UNION ALL SELECT 'Pimiento verde',90 UNION ALL SELECT 'Perejil',75 UNION ALL SELECT 'Especias',100
 UNION ALL SELECT 'Pan lavash',18 UNION ALL SELECT 'Masa',850 UNION ALL SELECT 'Yogur',450
 UNION ALL SELECT 'Ajo',90 UNION ALL SELECT 'Mantequilla',250 UNION ALL SELECT 'Salsa de tomate',240
 UNION ALL SELECT 'Tomate',500 UNION ALL SELECT 'Berenjena',5 UNION ALL SELECT 'Aceite de oliva',400
 UNION ALL SELECT 'Lentejas rojas',400 UNION ALL SELECT 'Zanahoria',300 UNION ALL SELECT 'Papa',500
 UNION ALL SELECT 'Caldo',1200 UNION ALL SELECT 'Masa filo',360 UNION ALL SELECT 'Nuez',240
 UNION ALL SELECT 'Azúcar',400 UNION ALL SELECT 'Miel',220
) t ON t.n=i.name SET i.quantity=t.q;

-- 3) Pedidos de ejemplo
INSERT INTO orders (id,customer,notes,priority,status,discounted,created_at) VALUES
(1039,'Mesa 03','','Media','Entregado',1,NOW() - INTERVAL 80 MINUTE),
(1041,'Para llevar','','Baja','Listo',1,NOW() - INTERVAL 50 MINUTE),
(1042,'Mesa 07','Sin cebolla en una porción','Alta','En preparación',1,NOW() - INTERVAL 35 MINUTE),
(1043,'Mesa 12','Yogur aparte','Media','Nuevo',0,NOW() - INTERVAL 25 MINUTE);
ALTER TABLE orders AUTO_INCREMENT=1044;

INSERT INTO order_items (order_id,recipe_id,qty)
SELECT t.o, r.id, t.q FROM (
 SELECT 1039 o,'Lahmacun' p,2 q
 UNION ALL SELECT 1041,'İmam bayıldı',1 UNION ALL SELECT 1041,'Lahmacun',1
 UNION ALL SELECT 1042,'Adana kebab',2 UNION ALL SELECT 1042,'Baklava',1
 UNION ALL SELECT 1043,'Mantı',2 UNION ALL SELECT 1043,'Mercimek çorbası',2
) t JOIN recipes r ON r.name=t.p;

-- 4) Consumo de inventario de los pedidos ya en preparación (1039, 1041, 1042)
INSERT INTO movements (type,ingredient_id,order_id,amount,before_qty,after_qty,created_at)
SELECT 'Consumo por pedido',n.ingredient_id,1039,n.need,i.quantity,GREATEST(0,i.quantity-n.need),NOW() - INTERVAL 75 MINUTE
FROM (SELECT ri.ingredient_id,SUM(ri.qty*oi.qty) need FROM order_items oi JOIN recipe_ingredients ri ON ri.recipe_id=oi.recipe_id WHERE oi.order_id=1039 GROUP BY ri.ingredient_id) n
JOIN ingredients i ON i.id=n.ingredient_id;
UPDATE ingredients i JOIN (SELECT ri.ingredient_id,SUM(ri.qty*oi.qty) need FROM order_items oi JOIN recipe_ingredients ri ON ri.recipe_id=oi.recipe_id WHERE oi.order_id=1039 GROUP BY ri.ingredient_id) n ON n.ingredient_id=i.id SET i.quantity=GREATEST(0,i.quantity-n.need);

INSERT INTO movements (type,ingredient_id,order_id,amount,before_qty,after_qty,created_at)
SELECT 'Consumo por pedido',n.ingredient_id,1041,n.need,i.quantity,GREATEST(0,i.quantity-n.need),NOW() - INTERVAL 45 MINUTE
FROM (SELECT ri.ingredient_id,SUM(ri.qty*oi.qty) need FROM order_items oi JOIN recipe_ingredients ri ON ri.recipe_id=oi.recipe_id WHERE oi.order_id=1041 GROUP BY ri.ingredient_id) n
JOIN ingredients i ON i.id=n.ingredient_id;
UPDATE ingredients i JOIN (SELECT ri.ingredient_id,SUM(ri.qty*oi.qty) need FROM order_items oi JOIN recipe_ingredients ri ON ri.recipe_id=oi.recipe_id WHERE oi.order_id=1041 GROUP BY ri.ingredient_id) n ON n.ingredient_id=i.id SET i.quantity=GREATEST(0,i.quantity-n.need);

INSERT INTO movements (type,ingredient_id,order_id,amount,before_qty,after_qty,created_at)
SELECT 'Consumo por pedido',n.ingredient_id,1042,n.need,i.quantity,GREATEST(0,i.quantity-n.need),NOW() - INTERVAL 30 MINUTE
FROM (SELECT ri.ingredient_id,SUM(ri.qty*oi.qty) need FROM order_items oi JOIN recipe_ingredients ri ON ri.recipe_id=oi.recipe_id WHERE oi.order_id=1042 GROUP BY ri.ingredient_id) n
JOIN ingredients i ON i.id=n.ingredient_id;
UPDATE ingredients i JOIN (SELECT ri.ingredient_id,SUM(ri.qty*oi.qty) need FROM order_items oi JOIN recipe_ingredients ri ON ri.recipe_id=oi.recipe_id WHERE oi.order_id=1042 GROUP BY ri.ingredient_id) n ON n.ingredient_id=i.id SET i.quantity=GREATEST(0,i.quantity-n.need);