-- ChefMaster: precios actualizados (insumos según investigación de Iztapalapa / Central de Abasto).
-- Se puede ejecutar varias veces sin problema:  source precios.sql;
USE chefmaster;

-- 1) Costo por unidad (g, ml o pieza) de cada insumo
UPDATE ingredients i JOIN (
SELECT 'Diezmillo de res' n,0.2 p
 UNION ALL SELECT 'Chambarete de res' n,0.14 p
 UNION ALL SELECT 'Arrachera' n,0.24 p
 UNION ALL SELECT 'Muslo de pollo' n,0.12 p
 UNION ALL SELECT 'Manteca de cerdo' n,0.06 p
 UNION ALL SELECT 'Tocino' n,0.16 p
 UNION ALL SELECT 'Chorizo' n,0.11 p
 UNION ALL SELECT 'Pechuga de pato' n,104.5 p
 UNION ALL SELECT 'Chile morita' n,0.115 p
 UNION ALL SELECT 'Chile guajillo' n,0.135 p
 UNION ALL SELECT 'Chile ancho' n,0.175 p
 UNION ALL SELECT 'Chile pasilla' n,0.175 p
 UNION ALL SELECT 'Chile chilhuacle amarillo' n,1.1 p
 UNION ALL SELECT 'Chile serrano' n,0.25 p
 UNION ALL SELECT 'Chile jalapeño' n,0.75 p
 UNION ALL SELECT 'Pepita' n,0.16 p
 UNION ALL SELECT 'Achiote' n,0.25 p
 UNION ALL SELECT 'Cacao en polvo' n,0.18 p
 UNION ALL SELECT 'Nuez' n,0.24 p
 UNION ALL SELECT 'Piloncillo' n,0.04 p
 UNION ALL SELECT 'Comino' n,0.2 p
 UNION ALL SELECT 'Canela' n,0.2 p
 UNION ALL SELECT 'Clavo' n,0.2 p
 UNION ALL SELECT 'Tomillo' n,0.2 p
 UNION ALL SELECT 'Hoja de laurel' n,0.1 p
 UNION ALL SELECT 'Aguacate' n,13.0 p
 UNION ALL SELECT 'Cebolla' n,0.026 p
 UNION ALL SELECT 'Tomate' n,0.024 p
 UNION ALL SELECT 'Tomate verde' n,0.024 p
 UNION ALL SELECT 'Jugo de naranja' n,0.075 p
 UNION ALL SELECT 'Naranja sanguina' n,9.0 p
 UNION ALL SELECT 'Mandarina' n,2.8 p
 UNION ALL SELECT 'Limón amarillo' n,1.5 p
 UNION ALL SELECT 'Betabel' n,4.4 p
 UNION ALL SELECT 'Calabaza italiana' n,0.022 p
 UNION ALL SELECT 'Coliflor' n,0.031 p
 UNION ALL SELECT 'Elote' n,0.032 p
 UNION ALL SELECT 'Piña' n,0.025 p
 UNION ALL SELECT 'Frutos rojos' n,0.14 p
 UNION ALL SELECT 'Romero fresco' n,0.5 p
 UNION ALL SELECT 'Brotes comestibles' n,2.25 p
 UNION ALL SELECT 'Leche' n,0.028 p
 UNION ALL SELECT 'Crema para batir' n,0.095 p
 UNION ALL SELECT 'Queso fresco' n,0.12 p
 UNION ALL SELECT 'Queso de cabra' n,0.325 p
 UNION ALL SELECT 'Parmesano' n,0.55 p
 UNION ALL SELECT 'Chocolate oscuro' n,0.21 p
 UNION ALL SELECT 'Chocolate blanco' n,0.19 p
 UNION ALL SELECT 'Harina de trigo' n,0.024 p
 UNION ALL SELECT 'Harina de maíz azul' n,0.024 p
 UNION ALL SELECT 'Tortilla azul' n,0.93 p
 UNION ALL SELECT 'Gelatina sin sabor' n,0.35 p
 UNION ALL SELECT 'Agar-agar' n,0.35 p
 UNION ALL SELECT 'Lecitina de soya' n,0.4 p
 UNION ALL SELECT 'Glucosa' n,0.4 p
 UNION ALL SELECT 'Aceite vegetal' n,0.042 p
 UNION ALL SELECT 'Aceite de oliva' n,0.16 p
 UNION ALL SELECT 'Flor de jamaica' n,0.14 p
) t ON t.n=i.name SET i.price=t.p;

-- 2) Precio de venta por platillo (margen de ~50% sobre el costo real de la receta)
UPDATE recipes r JOIN (
SELECT 'Taco de res glaseada de chile morita' n,30 p
 UNION ALL SELECT 'Taco de birria de res al carbón' n,55 p
 UNION ALL SELECT 'Taco de asada con adobo de guajillo y achiote' n,37 p
 UNION ALL SELECT 'Taco de pastor de res' n,38 p
 UNION ALL SELECT 'Taco de calabaza y elote' n,17 p
 UNION ALL SELECT 'Taco de carnitas de pollo al carbón' n,25 p
 UNION ALL SELECT 'Taco de mole amarillo con pollo y elote' n,35 p
 UNION ALL SELECT 'Frijoles puercos contemporáneos' n,38 p
 UNION ALL SELECT 'Frijoles charros' n,34 p
 UNION ALL SELECT 'Betabel en tres texturas' n,95 p
 UNION ALL SELECT 'Raviol de hongos, yema curada y espuma de parmesano' n,80 p
 UNION ALL SELECT 'Pato glaseado con mole de cacao' n,290 p
 UNION ALL SELECT 'Entremet de chocolate, elote dulce y mandarina' n,80 p
 UNION ALL SELECT 'Jamaica, frutos rojos, romero y humo' n,33 p
 UNION ALL SELECT 'Menú degustación (5 tiempos)' n,560 p
) t ON t.n=r.name SET r.price=t.p;

-- OPCIÓN B (precios exactos del documento): quita los '-- ' de abajo y vuelve a correr el archivo.
-- UPDATE recipes SET price=30 WHERE name='Taco de res glaseada de chile morita';
-- UPDATE recipes SET price=46 WHERE name='Taco de birria de res al carbón';
-- UPDATE recipes SET price=37 WHERE name='Taco de asada con adobo de guajillo y achiote';
-- UPDATE recipes SET price=38 WHERE name='Taco de pastor de res';
-- UPDATE recipes SET price=17 WHERE name='Taco de calabaza y elote';
-- UPDATE recipes SET price=21 WHERE name='Taco de carnitas de pollo al carbón';
-- UPDATE recipes SET price=24 WHERE name='Taco de mole amarillo con pollo y elote';
-- UPDATE recipes SET price=37.5 WHERE name='Frijoles puercos contemporáneos';
-- UPDATE recipes SET price=34 WHERE name='Frijoles charros';
-- UPDATE recipes SET price=55 WHERE name='Betabel en tres texturas';
-- UPDATE recipes SET price=72.5 WHERE name='Raviol de hongos, yema curada y espuma de parmesano';
-- UPDATE recipes SET price=270 WHERE name='Pato glaseado con mole de cacao';
-- UPDATE recipes SET price=80 WHERE name='Entremet de chocolate, elote dulce y mandarina';
-- UPDATE recipes SET price=32.5 WHERE name='Jamaica, frutos rojos, romero y humo';
-- UPDATE recipes SET price=510 WHERE name='Menú degustación (5 tiempos)';

SELECT name, price FROM recipes WHERE category <> 'Cocina turca' ORDER BY id;