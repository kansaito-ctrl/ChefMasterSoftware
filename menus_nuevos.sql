-- ChefMaster: recetario turco y 4 menús de 5 tiempos. Se puede ejecutar más de una vez:  source menus_nuevos.sql;
-- Requiere haber corrido antes inventario_base.sql (columna base_quantity).
USE chefmaster;

-- 1) Retira los platillos turcos de ejemplo (los borra si nunca se pidieron; si no, solo los oculta)
UPDATE recipes SET active=0 WHERE category='Cocina turca' AND name<>'Baklava';
DELETE ri FROM recipe_ingredients ri JOIN recipes r ON r.id=ri.recipe_id WHERE r.category='Cocina turca' AND r.name<>'Baklava' AND r.id NOT IN (SELECT recipe_id FROM order_items);
DELETE FROM recipes WHERE category='Cocina turca' AND name<>'Baklava' AND id NOT IN (SELECT recipe_id FROM order_items);
DELETE FROM recipe_ingredients WHERE recipe_id=(SELECT id FROM recipes WHERE name='Baklava');

-- 2) Ingredientes nuevos (precios y existencias estimados)
INSERT IGNORE INTO ingredients (name,category,unit,quantity,minimum,price,base_quantity) VALUES
('Garbanzo cocido','Despensa','g',2500,500,0.04,2500),
('Tahini','Despensa','g',380,76,0.25,380),
('Jugo de limón','Despensa','ml',880,176,0.06,880),
('Paprika','Chiles y especias','g',70,14,0.3,70),
('Queso feta','Lácteos','g',1250,250,0.3,1250),
('Queso mozzarella','Lácteos','g',500,100,0.18,500),
('Grasa de res','Proteínas','g',630,126,0.05,630),
('Pasta de chile rojo','Chiles y especias','g',100,20,0.08,100),
('Hojuelas de chile','Chiles y especias','g',40,8,0.25,40),
('Levadura seca','Panadería','g',50,10,0.35,50),
('Melaza de uva','Despensa','ml',630,126,0.1,630),
('Pistache','Despensa','g',600,120,0.8,600),
('Café turco molido','Bebidas','g',250,50,0.3,250),
('Vinagre balsámico','Despensa','ml',380,76,0.12,380),
('Espárragos','Vegetales','g',3750,750,0.1,3750),
('Poro','Vegetales','g',750,150,0.04,750),
('Caldo de verduras','Despensa','ml',8130,1626,0.015,8130),
('Aceite de cebollín','Despensa','ml',190,38,0.1,190),
('Filete de res','Proteínas','g',4500,900,0.45,4500),
('Vino tinto','Bebidas','ml',1880,376,0.15,1880),
('Leche evaporada','Lácteos','ml',1000,200,0.03,1000),
('Leche condensada','Lácteos','ml',1000,200,0.05,1000),
('Glaseado espejo de chocolate','Despensa','g',2500,500,0.12,2500),
('Corazón de alcachofa','Vegetales','piezas',50,10,14,50),
('Albahaca','Hierbas','g',130,26,0.12,130),
('Suprema de pollo','Proteínas','g',4500,900,0.12,4500),
('Arroz arborio','Despensa','g',2000,400,0.07,2000),
('Vino blanco','Bebidas','ml',750,150,0.12,750),
('Azafrán','Chiles y especias','g',5,5,80,5),
('Azúcar glass','Despensa','g',630,126,0.035,630),
('Jitomate heirloom','Vegetales','g',3750,750,0.08,3750),
('Pepino','Vegetales','g',1000,200,0.02,1000),
('Cilantro','Hierbas','g',130,26,0.06,130),
('Cebolla morada','Vegetales','g',380,76,0.03,380),
('Tostada de maíz','Panadería','piezas',25,5,1.2,25),
('Epazote','Hierbas','g',70,14,0.08,70),
('Mole negro preparado','Despensa','g',2250,450,0.15,2250),
('Camote','Vegetales','g',4380,876,0.02,4380),
('Calabacita baby','Vegetales','g',1250,250,0.06,1250),
('Puré de guayaba','Frutas','g',2250,450,0.08,2250),
('Vaina de vainilla','Despensa','piezas',10,2,35,10),
('Infusión de jamaica','Bebidas','ml',1500,300,0.02,1500),
('Queso ricotta','Lácteos','g',1500,300,0.12,1500),
('Espinaca','Vegetales','g',1000,200,0.05,1000),
('Salvia','Hierbas','g',30,6,0.6,30),
('Aceite de trufa','Despensa','ml',100,20,1.5,100),
('Short rib de res','Proteínas','g',7500,1500,0.28,7500),
('Apio','Vegetales','g',630,126,0.03,630),
('Ejote','Vegetales','g',1250,250,0.05,1250),
('Puré de frambuesa','Frutas','g',1500,300,0.2,1500),
('Glaseado espejo rojo','Despensa','g',2250,450,0.14,2250);

-- 3) Sube la existencia de ingredientes que ya tenías y ahora se usan más
UPDATE ingredients i JOIN (
SELECT 'Aceite de oliva' n,3750 q
 UNION ALL SELECT 'Aceite vegetal' n,3130 q
 UNION ALL SELECT 'Agar-agar' n,20 q
 UNION ALL SELECT 'Ajo' n,100 q
 UNION ALL SELECT 'Ajonjolí' n,630 q
 UNION ALL SELECT 'Azúcar' n,2630 q
 UNION ALL SELECT 'Betabel' n,25 q
 UNION ALL SELECT 'Brotes comestibles' n,250 q
 UNION ALL SELECT 'Cacao en polvo' n,190 q
 UNION ALL SELECT 'Canela' n,20 q
 UNION ALL SELECT 'Carne molida' n,3750 q
 UNION ALL SELECT 'Cebolla' n,1000 q
 UNION ALL SELECT 'Chalota' n,500 q
 UNION ALL SELECT 'Chile serrano' n,13 q
 UNION ALL SELECT 'Chocolate blanco' n,1250 q
 UNION ALL SELECT 'Chocolate oscuro' n,2000 q
 UNION ALL SELECT 'Coliflor' n,5000 q
 UNION ALL SELECT 'Comino' n,40 q
 UNION ALL SELECT 'Crema para batir' n,3880 q
 UNION ALL SELECT 'Elote' n,4380 q
 UNION ALL SELECT 'Fondo de pollo' n,2250 q
 UNION ALL SELECT 'Fondo de res' n,4380 q
 UNION ALL SELECT 'Gelatina sin sabor' n,100 q
 UNION ALL SELECT 'Harina de trigo' n,3130 q
 UNION ALL SELECT 'Hongos mixtos' n,3750 q
 UNION ALL SELECT 'Huevo' n,63 q
 UNION ALL SELECT 'Leche' n,1880 q
 UNION ALL SELECT 'Limón amarillo' n,13 q
 UNION ALL SELECT 'Mantequilla' n,1690 q
 UNION ALL SELECT 'Masa filo' n,1570 q
 UNION ALL SELECT 'Miel' n,130 q
 UNION ALL SELECT 'Papa' n,7500 q
 UNION ALL SELECT 'Parmesano' n,440 q
 UNION ALL SELECT 'Pechuga de pato' n,25 q
 UNION ALL SELECT 'Perejil' n,190 q
 UNION ALL SELECT 'Pimienta negra' n,20 q
 UNION ALL SELECT 'Queso de cabra' n,1000 q
 UNION ALL SELECT 'Sal' n,70 q
 UNION ALL SELECT 'Tomate' n,7500 q
 UNION ALL SELECT 'Tomillo' n,40 q
 UNION ALL SELECT 'Zanahoria' n,1000 q
 UNION ALL SELECT 'Zanahoria baby' n,125 q
) t ON t.n=i.name SET i.quantity=GREATEST(i.quantity,t.q), i.base_quantity=GREATEST(COALESCE(i.base_quantity,0),t.q);

-- 4) Platillos (precio provisional: costo real de la receta x 2, redondeado a 5 pesos)
INSERT IGNORE INTO recipes (name,price,category,description) VALUES
('Hummus',25,'Cocina turca','Puré cremoso de garbanzo con tahini, limón y ajo, servido con aceite de oliva, paprika y perejil.'),
('Sigara Böreği',60,'Cocina turca','Rollitos crujientes de masa filo rellenos de queso feta, mozzarella y perejil, fritos hasta dorar.'),
('Adana Kebap',70,'Cocina turca','Brocheta de carne especiada con pasta de chile rojo, paprika y comino, asada al carbón. Se sirve con pan pita, cebolla morada, perejil y jitomate asado.'),
('Simit',25,'Cocina turca','Rosca turca de masa fermentada, bañada en melaza de uva y cubierta de ajonjolí tostado.'),
('Café turco',10,'Cocina turca','Café turco finamente molido, preparado lentamente en cezve y servido con su espuma.'),
('Carpaccio de betabel rostizado con queso de cabra',90,'Menú 1 · Cocina contemporánea europea','Entrada. Betabel rostizado en láminas finas con queso de cabra desmoronado, vinagre balsámico, aceite de oliva y brotes tiernos.'),
('Crema de espárragos verdes',60,'Menú 1 · Cocina contemporánea europea','Sopa. Crema de espárragos verdes con poro y cebolla, servida con puntas blanqueadas y aceite de cebollín.'),
('Filete de res con salsa de vino tinto',205,'Menú 1 · Cocina contemporánea europea','Plato fuerte. Filete de res sellado al término deseado sobre salsa de vino tinto con echalote y mantequilla.'),
('Papa fondant y zanahorias baby glaseadas',60,'Menú 1 · Cocina contemporánea europea','Guarnición. Papa fondant dorada en mantequilla con tomillo y zanahorias baby glaseadas.'),
('Entremet de chocolate tres leches',110,'Menú 1 · Cocina contemporánea europea','Postre. Entremet de bizcocho de chocolate humedecido con tres leches y mousse de chocolate, cubierto con glaseado espejo.'),
('Alcachofa confitada con emulsión de papa',115,'Menú 2 · Cocina mediterránea de lujo','Entrada. Corazones de alcachofa confitados en aceite de oliva sobre emulsión de papa, con paprika ahumada y perejil.'),
('Consomé de jitomate rostizado',30,'Menú 2 · Cocina mediterránea de lujo','Sopa. Consomé claro de jitomate rostizado con cebolla y ajo, servido con albahaca fresca y aceite de oliva.'),
('Suprema de pollo al limón amarillo y tomillo',55,'Menú 2 · Cocina mediterránea de lujo','Plato fuerte. Suprema de pollo sellada y horneada, con salsa de fondo, limón amarillo, tomillo y mantequilla.'),
('Risotto de azafrán y espárragos',85,'Menú 2 · Cocina mediterránea de lujo','Guarnición. Risotto de arroz arborio con azafrán y espárragos, terminado con mantequilla y parmesano.'),
('Tartaleta de limón amarillo y merengue italiano',60,'Menú 2 · Cocina mediterránea de lujo','Postre. Tartaleta de masa sablée con crema de limón amarillo y merengue italiano flameado.'),
('Tartar de jitomate heirloom con aguachile verde',35,'Menú 3 · Cocina mexicana contemporánea','Entrada. Tartar de jitomate heirloom y pepino con aguachile verde de chile serrano, limón y cilantro, con tostadas de maíz.'),
('Crema de elote tatemado',35,'Menú 3 · Cocina mexicana contemporánea','Sopa. Crema de elote tatemado con cebolla y ajo, servida con aceite de epazote.'),
('Magret de pato con mole negro',240,'Menú 3 · Cocina mexicana contemporánea','Plato fuerte. Magret de pato de piel crujiente sobre mole negro.'),
('Puré de camote y vegetales baby glaseados',45,'Menú 3 · Cocina mexicana contemporánea','Guarnición. Puré de camote con zanahorias y calabacitas baby glaseadas.'),
('Cremoso de guayaba, mousse de vainilla y gel de jamaica',110,'Menú 3 · Cocina mexicana contemporánea','Postre. Cremoso de guayaba con mousse de vainilla, gel de jamaica y crumble de cocoa.'),
('Raviol de ricotta y espinaca con salvia',55,'Menú 4 · Alta cocina internacional','Entrada. Raviolis de pasta fresca rellenos de ricotta y espinaca, salteados en mantequilla con salvia.'),
('Velouté de hongos con aceite de trufa',65,'Menú 4 · Alta cocina internacional','Sopa. Velouté de champiñones y hongos mixtos con aceite de trufa.'),
('Short rib de res a baja temperatura',210,'Menú 4 · Alta cocina internacional','Plato fuerte. Short rib de res cocinado a baja temperatura durante horas, con su salsa reducida.'),
('Puré de coliflor y vegetales de temporada',45,'Menú 4 · Alta cocina internacional','Guarnición. Puré sedoso de coliflor con zanahorias baby y ejotes.'),
('Entremet de frutos rojos y vainilla',135,'Menú 4 · Alta cocina internacional','Postre. Entremet de mousse de chocolate blanco y vainilla con inserto de frambuesa y glaseado espejo rojo.'),
('Menú 1 completo (5 tiempos)',500,'Menú 1 · Cocina contemporánea europea','Recorrido completo de 5 tiempos: entrada (carpaccio de betabel rostizado con queso de cabra); sopa (crema de espárragos verdes); plato fuerte (filete de res con salsa de vino tinto); guarnición (papa fondant y zanahorias baby glaseadas); postre (entremet de chocolate tres leches).'),
('Menú 2 completo (5 tiempos)',330,'Menú 2 · Cocina mediterránea de lujo','Recorrido completo de 5 tiempos: entrada (alcachofa confitada con emulsión de papa); sopa (consomé de jitomate rostizado); plato fuerte (suprema de pollo al limón amarillo y tomillo); guarnición (risotto de azafrán y espárragos); postre (tartaleta de limón amarillo y merengue italiano).'),
('Menú 3 completo (5 tiempos)',440,'Menú 3 · Cocina mexicana contemporánea','Recorrido completo de 5 tiempos: entrada (tartar de jitomate heirloom con aguachile verde); sopa (crema de elote tatemado); plato fuerte (magret de pato con mole negro); guarnición (puré de camote y vegetales baby glaseados); postre (cremoso de guayaba, mousse de vainilla y gel de jamaica).'),
('Menú 4 completo (5 tiempos)',485,'Menú 4 · Alta cocina internacional','Recorrido completo de 5 tiempos: entrada (raviol de ricotta y espinaca con salvia); sopa (velouté de hongos con aceite de trufa); plato fuerte (short rib de res a baja temperatura); guarnición (puré de coliflor y vegetales de temporada); postre (entremet de frutos rojos y vainilla).');
UPDATE recipes SET price=110, category='Cocina turca', description='Capas de masa filo con pistache (o nuez) y mantequilla clarificada, bañadas en almíbar de limón y miel.', active=1, image_url=NULL WHERE name='Baklava';

-- 5) Recetas: cantidad de cada ingrediente por porción de venta
INSERT IGNORE INTO recipe_ingredients (recipe_id,ingredient_id,qty)
SELECT r.id,i.id,t.q FROM (
SELECT 'Hummus' r,'Garbanzo cocido' i,100.0 q
 UNION ALL SELECT 'Hummus' r,'Tahini' i,15.0 q
 UNION ALL SELECT 'Hummus' r,'Jugo de limón' i,10.0 q
 UNION ALL SELECT 'Hummus' r,'Ajo' i,1.0 q
 UNION ALL SELECT 'Hummus' r,'Aceite de oliva' i,12.5 q
 UNION ALL SELECT 'Hummus' r,'Sal' i,1.0 q
 UNION ALL SELECT 'Hummus' r,'Comino' i,0.5 q
 UNION ALL SELECT 'Hummus' r,'Perejil' i,2.5 q
 UNION ALL SELECT 'Hummus' r,'Paprika' i,2.5 q
 UNION ALL SELECT 'Sigara Böreği' r,'Masa filo' i,30.0 q
 UNION ALL SELECT 'Sigara Böreği' r,'Queso feta' i,50.0 q
 UNION ALL SELECT 'Sigara Böreği' r,'Queso mozzarella' i,20.0 q
 UNION ALL SELECT 'Sigara Böreği' r,'Perejil' i,7.5 q
 UNION ALL SELECT 'Sigara Böreği' r,'Huevo' i,0.25 q
 UNION ALL SELECT 'Sigara Böreği' r,'Aceite vegetal' i,125.0 q
 UNION ALL SELECT 'Sigara Böreği' r,'Pimienta negra' i,0.5 q
 UNION ALL SELECT 'Adana Kebap' r,'Carne molida' i,150.0 q
 UNION ALL SELECT 'Adana Kebap' r,'Grasa de res' i,25.0 q
 UNION ALL SELECT 'Adana Kebap' r,'Cebolla' i,20.0 q
 UNION ALL SELECT 'Adana Kebap' r,'Ajo' i,3.75 q
 UNION ALL SELECT 'Adana Kebap' r,'Pasta de chile rojo' i,3.75 q
 UNION ALL SELECT 'Adana Kebap' r,'Paprika' i,2.0 q
 UNION ALL SELECT 'Adana Kebap' r,'Hojuelas de chile' i,1.25 q
 UNION ALL SELECT 'Adana Kebap' r,'Comino' i,1.25 q
 UNION ALL SELECT 'Adana Kebap' r,'Sal' i,2.0 q
 UNION ALL SELECT 'Adana Kebap' r,'Pimienta negra' i,0.75 q
 UNION ALL SELECT 'Adana Kebap' r,'Perejil' i,5.0 q
 UNION ALL SELECT 'Simit' r,'Harina de trigo' i,125.0 q
 UNION ALL SELECT 'Simit' r,'Levadura seca' i,1.75 q
 UNION ALL SELECT 'Simit' r,'Azúcar' i,5.0 q
 UNION ALL SELECT 'Simit' r,'Sal' i,2.5 q
 UNION ALL SELECT 'Simit' r,'Aceite vegetal' i,7.5 q
 UNION ALL SELECT 'Simit' r,'Ajonjolí' i,25.0 q
 UNION ALL SELECT 'Simit' r,'Melaza de uva' i,25.0 q
 UNION ALL SELECT 'Baklava' r,'Masa filo' i,62.5 q
 UNION ALL SELECT 'Baklava' r,'Pistache' i,50.0 q
 UNION ALL SELECT 'Baklava' r,'Mantequilla' i,37.5 q
 UNION ALL SELECT 'Baklava' r,'Azúcar' i,55.0 q
 UNION ALL SELECT 'Baklava' r,'Canela' i,0.5 q
 UNION ALL SELECT 'Baklava' r,'Jugo de limón' i,3.75 q
 UNION ALL SELECT 'Baklava' r,'Miel' i,5.0 q
 UNION ALL SELECT 'Café turco' r,'Café turco molido' i,10.0 q
 UNION ALL SELECT 'Café turco' r,'Azúcar' i,5.0 q
 UNION ALL SELECT 'Carpaccio de betabel rostizado con queso de cabra' r,'Betabel' i,1.0 q
 UNION ALL SELECT 'Carpaccio de betabel rostizado con queso de cabra' r,'Queso de cabra' i,40.0 q
 UNION ALL SELECT 'Carpaccio de betabel rostizado con queso de cabra' r,'Vinagre balsámico' i,15.0 q
 UNION ALL SELECT 'Carpaccio de betabel rostizado con queso de cabra' r,'Aceite de oliva' i,12.5 q
 UNION ALL SELECT 'Carpaccio de betabel rostizado con queso de cabra' r,'Brotes comestibles' i,10.0 q
 UNION ALL SELECT 'Crema de espárragos verdes' r,'Espárragos' i,150.0 q
 UNION ALL SELECT 'Crema de espárragos verdes' r,'Poro' i,30.0 q
 UNION ALL SELECT 'Crema de espárragos verdes' r,'Cebolla' i,25.0 q
 UNION ALL SELECT 'Crema de espárragos verdes' r,'Mantequilla' i,12.5 q
 UNION ALL SELECT 'Crema de espárragos verdes' r,'Caldo de verduras' i,250.0 q
 UNION ALL SELECT 'Crema de espárragos verdes' r,'Crema para batir' i,50.0 q
 UNION ALL SELECT 'Crema de espárragos verdes' r,'Aceite de cebollín' i,7.5 q
 UNION ALL SELECT 'Filete de res con salsa de vino tinto' r,'Filete de res' i,180.0 q
 UNION ALL SELECT 'Filete de res con salsa de vino tinto' r,'Vino tinto' i,75.0 q
 UNION ALL SELECT 'Filete de res con salsa de vino tinto' r,'Fondo de res' i,125.0 q
 UNION ALL SELECT 'Filete de res con salsa de vino tinto' r,'Chalota' i,20.0 q
 UNION ALL SELECT 'Filete de res con salsa de vino tinto' r,'Mantequilla' i,15.0 q
 UNION ALL SELECT 'Filete de res con salsa de vino tinto' r,'Aceite vegetal' i,7.5 q
 UNION ALL SELECT 'Papa fondant y zanahorias baby glaseadas' r,'Papa' i,300.0 q
 UNION ALL SELECT 'Papa fondant y zanahorias baby glaseadas' r,'Zanahoria baby' i,5.0 q
 UNION ALL SELECT 'Papa fondant y zanahorias baby glaseadas' r,'Mantequilla' i,22.5 q
 UNION ALL SELECT 'Papa fondant y zanahorias baby glaseadas' r,'Caldo de verduras' i,125.0 q
 UNION ALL SELECT 'Papa fondant y zanahorias baby glaseadas' r,'Tomillo' i,1.0 q
 UNION ALL SELECT 'Papa fondant y zanahorias baby glaseadas' r,'Azúcar' i,2.5 q
 UNION ALL SELECT 'Entremet de chocolate tres leches' r,'Huevo' i,1.0 q
 UNION ALL SELECT 'Entremet de chocolate tres leches' r,'Azúcar' i,30.0 q
 UNION ALL SELECT 'Entremet de chocolate tres leches' r,'Harina de trigo' i,22.5 q
 UNION ALL SELECT 'Entremet de chocolate tres leches' r,'Cacao en polvo' i,7.5 q
 UNION ALL SELECT 'Entremet de chocolate tres leches' r,'Leche evaporada' i,40.0 q
 UNION ALL SELECT 'Entremet de chocolate tres leches' r,'Leche condensada' i,40.0 q
 UNION ALL SELECT 'Entremet de chocolate tres leches' r,'Crema para batir' i,155.0 q
 UNION ALL SELECT 'Entremet de chocolate tres leches' r,'Chocolate oscuro' i,80.0 q
 UNION ALL SELECT 'Entremet de chocolate tres leches' r,'Gelatina sin sabor' i,2.5 q
 UNION ALL SELECT 'Entremet de chocolate tres leches' r,'Glaseado espejo de chocolate' i,100.0 q
 UNION ALL SELECT 'Alcachofa confitada con emulsión de papa' r,'Corazón de alcachofa' i,2.0 q
 UNION ALL SELECT 'Alcachofa confitada con emulsión de papa' r,'Aceite de oliva' i,150.0 q
 UNION ALL SELECT 'Alcachofa confitada con emulsión de papa' r,'Papa' i,90.0 q
 UNION ALL SELECT 'Alcachofa confitada con emulsión de papa' r,'Caldo de verduras' i,40.0 q
 UNION ALL SELECT 'Alcachofa confitada con emulsión de papa' r,'Paprika' i,1.0 q
 UNION ALL SELECT 'Alcachofa confitada con emulsión de papa' r,'Perejil' i,5.0 q
 UNION ALL SELECT 'Alcachofa confitada con emulsión de papa' r,'Limón amarillo' i,0.5 q
 UNION ALL SELECT 'Consomé de jitomate rostizado' r,'Tomate' i,300.0 q
 UNION ALL SELECT 'Consomé de jitomate rostizado' r,'Cebolla' i,40.0 q
 UNION ALL SELECT 'Consomé de jitomate rostizado' r,'Ajo' i,4.0 q
 UNION ALL SELECT 'Consomé de jitomate rostizado' r,'Albahaca' i,5.0 q
 UNION ALL SELECT 'Consomé de jitomate rostizado' r,'Caldo de verduras' i,250.0 q
 UNION ALL SELECT 'Consomé de jitomate rostizado' r,'Aceite de oliva' i,10.0 q
 UNION ALL SELECT 'Suprema de pollo al limón amarillo y tomillo' r,'Suprema de pollo' i,180.0 q
 UNION ALL SELECT 'Suprema de pollo al limón amarillo y tomillo' r,'Limón amarillo' i,0.5 q
 UNION ALL SELECT 'Suprema de pollo al limón amarillo y tomillo' r,'Tomillo' i,1.5 q
 UNION ALL SELECT 'Suprema de pollo al limón amarillo y tomillo' r,'Fondo de pollo' i,90.0 q
 UNION ALL SELECT 'Suprema de pollo al limón amarillo y tomillo' r,'Mantequilla' i,12.5 q
 UNION ALL SELECT 'Suprema de pollo al limón amarillo y tomillo' r,'Aceite vegetal' i,7.5 q
 UNION ALL SELECT 'Risotto de azafrán y espárragos' r,'Arroz arborio' i,80.0 q
 UNION ALL SELECT 'Risotto de azafrán y espárragos' r,'Espárragos' i,75.0 q
 UNION ALL SELECT 'Risotto de azafrán y espárragos' r,'Cebolla' i,20.0 q
 UNION ALL SELECT 'Risotto de azafrán y espárragos' r,'Vino blanco' i,30.0 q
 UNION ALL SELECT 'Risotto de azafrán y espárragos' r,'Caldo de verduras' i,325.0 q
 UNION ALL SELECT 'Risotto de azafrán y espárragos' r,'Azafrán' i,0.1 q
 UNION ALL SELECT 'Risotto de azafrán y espárragos' r,'Mantequilla' i,15.0 q
 UNION ALL SELECT 'Risotto de azafrán y espárragos' r,'Parmesano' i,17.5 q
 UNION ALL SELECT 'Tartaleta de limón amarillo y merengue italiano' r,'Harina de trigo' i,75.0 q
 UNION ALL SELECT 'Tartaleta de limón amarillo y merengue italiano' r,'Mantequilla' i,67.5 q
 UNION ALL SELECT 'Tartaleta de limón amarillo y merengue italiano' r,'Azúcar glass' i,25.0 q
 UNION ALL SELECT 'Tartaleta de limón amarillo y merengue italiano' r,'Huevo' i,2.5 q
 UNION ALL SELECT 'Tartaleta de limón amarillo y merengue italiano' r,'Jugo de limón' i,35.0 q
 UNION ALL SELECT 'Tartaleta de limón amarillo y merengue italiano' r,'Azúcar' i,105.0 q
 UNION ALL SELECT 'Tartar de jitomate heirloom con aguachile verde' r,'Jitomate heirloom' i,150.0 q
 UNION ALL SELECT 'Tartar de jitomate heirloom con aguachile verde' r,'Pepino' i,40.0 q
 UNION ALL SELECT 'Tartar de jitomate heirloom con aguachile verde' r,'Chile serrano' i,0.5 q
 UNION ALL SELECT 'Tartar de jitomate heirloom con aguachile verde' r,'Jugo de limón' i,25.0 q
 UNION ALL SELECT 'Tartar de jitomate heirloom con aguachile verde' r,'Cilantro' i,5.0 q
 UNION ALL SELECT 'Tartar de jitomate heirloom con aguachile verde' r,'Cebolla morada' i,15.0 q
 UNION ALL SELECT 'Tartar de jitomate heirloom con aguachile verde' r,'Tostada de maíz' i,1.0 q
 UNION ALL SELECT 'Crema de elote tatemado' r,'Elote' i,175.0 q
 UNION ALL SELECT 'Crema de elote tatemado' r,'Cebolla' i,30.0 q
 UNION ALL SELECT 'Crema de elote tatemado' r,'Ajo' i,2.0 q
 UNION ALL SELECT 'Crema de elote tatemado' r,'Caldo de verduras' i,225.0 q
 UNION ALL SELECT 'Crema de elote tatemado' r,'Crema para batir' i,50.0 q
 UNION ALL SELECT 'Crema de elote tatemado' r,'Mantequilla' i,12.5 q
 UNION ALL SELECT 'Crema de elote tatemado' r,'Epazote' i,2.5 q
 UNION ALL SELECT 'Crema de elote tatemado' r,'Aceite vegetal' i,7.5 q
 UNION ALL SELECT 'Magret de pato con mole negro' r,'Pechuga de pato' i,1.0 q
 UNION ALL SELECT 'Magret de pato con mole negro' r,'Mole negro preparado' i,90.0 q
 UNION ALL SELECT 'Magret de pato con mole negro' r,'Fondo de pollo' i,75.0 q
 UNION ALL SELECT 'Puré de camote y vegetales baby glaseados' r,'Camote' i,175.0 q
 UNION ALL SELECT 'Puré de camote y vegetales baby glaseados' r,'Mantequilla' i,17.5 q
 UNION ALL SELECT 'Puré de camote y vegetales baby glaseados' r,'Crema para batir' i,30.0 q
 UNION ALL SELECT 'Puré de camote y vegetales baby glaseados' r,'Zanahoria baby' i,2.5 q
 UNION ALL SELECT 'Puré de camote y vegetales baby glaseados' r,'Calabacita baby' i,50.0 q
 UNION ALL SELECT 'Puré de camote y vegetales baby glaseados' r,'Caldo de verduras' i,50.0 q
 UNION ALL SELECT 'Cremoso de guayaba, mousse de vainilla y gel de jamaica' r,'Puré de guayaba' i,90.0 q
 UNION ALL SELECT 'Cremoso de guayaba, mousse de vainilla y gel de jamaica' r,'Chocolate blanco' i,50.0 q
 UNION ALL SELECT 'Cremoso de guayaba, mousse de vainilla y gel de jamaica' r,'Crema para batir' i,130.0 q
 UNION ALL SELECT 'Cremoso de guayaba, mousse de vainilla y gel de jamaica' r,'Gelatina sin sabor' i,3.5 q
 UNION ALL SELECT 'Cremoso de guayaba, mousse de vainilla y gel de jamaica' r,'Vaina de vainilla' i,0.5 q
 UNION ALL SELECT 'Cremoso de guayaba, mousse de vainilla y gel de jamaica' r,'Infusión de jamaica' i,60.0 q
 UNION ALL SELECT 'Cremoso de guayaba, mousse de vainilla y gel de jamaica' r,'Azúcar' i,22.5 q
 UNION ALL SELECT 'Cremoso de guayaba, mousse de vainilla y gel de jamaica' r,'Agar-agar' i,0.6 q
 UNION ALL SELECT 'Cremoso de guayaba, mousse de vainilla y gel de jamaica' r,'Harina de trigo' i,20.0 q
 UNION ALL SELECT 'Cremoso de guayaba, mousse de vainilla y gel de jamaica' r,'Mantequilla' i,12.5 q
 UNION ALL SELECT 'Cremoso de guayaba, mousse de vainilla y gel de jamaica' r,'Cacao en polvo' i,4.0 q
 UNION ALL SELECT 'Raviol de ricotta y espinaca con salvia' r,'Harina de trigo' i,75.0 q
 UNION ALL SELECT 'Raviol de ricotta y espinaca con salvia' r,'Huevo' i,1.0 q
 UNION ALL SELECT 'Raviol de ricotta y espinaca con salvia' r,'Aceite vegetal' i,2.5 q
 UNION ALL SELECT 'Raviol de ricotta y espinaca con salvia' r,'Queso ricotta' i,60.0 q
 UNION ALL SELECT 'Raviol de ricotta y espinaca con salvia' r,'Espinaca' i,40.0 q
 UNION ALL SELECT 'Raviol de ricotta y espinaca con salvia' r,'Parmesano' i,12.5 q
 UNION ALL SELECT 'Raviol de ricotta y espinaca con salvia' r,'Salvia' i,1.5 q
 UNION ALL SELECT 'Raviol de ricotta y espinaca con salvia' r,'Mantequilla' i,22.5 q
 UNION ALL SELECT 'Velouté de hongos con aceite de trufa' r,'Hongos mixtos' i,150.0 q
 UNION ALL SELECT 'Velouté de hongos con aceite de trufa' r,'Cebolla' i,25.0 q
 UNION ALL SELECT 'Velouté de hongos con aceite de trufa' r,'Mantequilla' i,12.5 q
 UNION ALL SELECT 'Velouté de hongos con aceite de trufa' r,'Harina de trigo' i,10.0 q
 UNION ALL SELECT 'Velouté de hongos con aceite de trufa' r,'Caldo de verduras' i,250.0 q
 UNION ALL SELECT 'Velouté de hongos con aceite de trufa' r,'Crema para batir' i,40.0 q
 UNION ALL SELECT 'Velouté de hongos con aceite de trufa' r,'Aceite de trufa' i,2.5 q
 UNION ALL SELECT 'Short rib de res a baja temperatura' r,'Short rib de res' i,300.0 q
 UNION ALL SELECT 'Short rib de res a baja temperatura' r,'Fondo de res' i,175.0 q
 UNION ALL SELECT 'Short rib de res a baja temperatura' r,'Vino tinto' i,75.0 q
 UNION ALL SELECT 'Short rib de res a baja temperatura' r,'Zanahoria' i,40.0 q
 UNION ALL SELECT 'Short rib de res a baja temperatura' r,'Apio' i,25.0 q
 UNION ALL SELECT 'Short rib de res a baja temperatura' r,'Cebolla' i,40.0 q
 UNION ALL SELECT 'Short rib de res a baja temperatura' r,'Ajo' i,4.0 q
 UNION ALL SELECT 'Short rib de res a baja temperatura' r,'Tomillo' i,1.0 q
 UNION ALL SELECT 'Puré de coliflor y vegetales de temporada' r,'Coliflor' i,200.0 q
 UNION ALL SELECT 'Puré de coliflor y vegetales de temporada' r,'Leche' i,75.0 q
 UNION ALL SELECT 'Puré de coliflor y vegetales de temporada' r,'Mantequilla' i,17.5 q
 UNION ALL SELECT 'Puré de coliflor y vegetales de temporada' r,'Zanahoria baby' i,2.5 q
 UNION ALL SELECT 'Puré de coliflor y vegetales de temporada' r,'Ejote' i,50.0 q
 UNION ALL SELECT 'Puré de coliflor y vegetales de temporada' r,'Caldo de verduras' i,50.0 q
 UNION ALL SELECT 'Entremet de frutos rojos y vainilla' r,'Huevo' i,0.5 q
 UNION ALL SELECT 'Entremet de frutos rojos y vainilla' r,'Azúcar' i,30.0 q
 UNION ALL SELECT 'Entremet de frutos rojos y vainilla' r,'Harina de trigo' i,15.0 q
 UNION ALL SELECT 'Entremet de frutos rojos y vainilla' r,'Crema para batir' i,110.0 q
 UNION ALL SELECT 'Entremet de frutos rojos y vainilla' r,'Chocolate blanco' i,50.0 q
 UNION ALL SELECT 'Entremet de frutos rojos y vainilla' r,'Vaina de vainilla' i,0.5 q
 UNION ALL SELECT 'Entremet de frutos rojos y vainilla' r,'Gelatina sin sabor' i,4.0 q
 UNION ALL SELECT 'Entremet de frutos rojos y vainilla' r,'Puré de frambuesa' i,60.0 q
 UNION ALL SELECT 'Entremet de frutos rojos y vainilla' r,'Glaseado espejo rojo' i,90.0 q
) t JOIN recipes r ON r.name=t.r JOIN ingredients i ON i.name=t.i;

-- 6) Cada menú completo suma los ingredientes de sus 5 platillos
INSERT IGNORE INTO recipe_ingredients (recipe_id,ingredient_id,qty)
SELECT (SELECT id FROM recipes WHERE name='Menú 1 completo (5 tiempos)'),ri.ingredient_id,SUM(ri.qty) FROM recipe_ingredients ri JOIN recipes r ON r.id=ri.recipe_id WHERE r.name IN ('Carpaccio de betabel rostizado con queso de cabra','Crema de espárragos verdes','Filete de res con salsa de vino tinto','Papa fondant y zanahorias baby glaseadas','Entremet de chocolate tres leches') GROUP BY ri.ingredient_id;
INSERT IGNORE INTO recipe_ingredients (recipe_id,ingredient_id,qty)
SELECT (SELECT id FROM recipes WHERE name='Menú 2 completo (5 tiempos)'),ri.ingredient_id,SUM(ri.qty) FROM recipe_ingredients ri JOIN recipes r ON r.id=ri.recipe_id WHERE r.name IN ('Alcachofa confitada con emulsión de papa','Consomé de jitomate rostizado','Suprema de pollo al limón amarillo y tomillo','Risotto de azafrán y espárragos','Tartaleta de limón amarillo y merengue italiano') GROUP BY ri.ingredient_id;
INSERT IGNORE INTO recipe_ingredients (recipe_id,ingredient_id,qty)
SELECT (SELECT id FROM recipes WHERE name='Menú 3 completo (5 tiempos)'),ri.ingredient_id,SUM(ri.qty) FROM recipe_ingredients ri JOIN recipes r ON r.id=ri.recipe_id WHERE r.name IN ('Tartar de jitomate heirloom con aguachile verde','Crema de elote tatemado','Magret de pato con mole negro','Puré de camote y vegetales baby glaseados','Cremoso de guayaba, mousse de vainilla y gel de jamaica') GROUP BY ri.ingredient_id;
INSERT IGNORE INTO recipe_ingredients (recipe_id,ingredient_id,qty)
SELECT (SELECT id FROM recipes WHERE name='Menú 4 completo (5 tiempos)'),ri.ingredient_id,SUM(ri.qty) FROM recipe_ingredients ri JOIN recipes r ON r.id=ri.recipe_id WHERE r.name IN ('Raviol de ricotta y espinaca con salvia','Velouté de hongos con aceite de trufa','Short rib de res a baja temperatura','Puré de coliflor y vegetales de temporada','Entremet de frutos rojos y vainilla') GROUP BY ri.ingredient_id;

SELECT category, COUNT(*) AS platillos FROM recipes WHERE active=1 GROUP BY category ORDER BY MIN(id);