-- ChefMaster: menú nuevo (tacos, guarniciones y menú de 5 tiempos)
-- Ejecutar UNA sola vez:  source menu_nuevo.sql;
USE chefmaster;

ALTER TABLE recipes
  ADD COLUMN category VARCHAR(40) NOT NULL DEFAULT 'Otros',
  ADD COLUMN description TEXT NULL,
  ADD COLUMN active BOOLEAN NOT NULL DEFAULT TRUE;
UPDATE recipes SET category='Cocina turca' WHERE category='Otros';

-- Ingredientes nuevos (existencias provisionales)
INSERT INTO ingredients (name,category,unit,quantity,minimum,price) VALUES
('Diezmillo de res','Proteínas','g',1750,350,0.21),
('Chambarete de res','Proteínas','g',750,150,0.18),
('Arrachera','Proteínas','g',1500,300,0.3),
('Muslo de pollo','Proteínas','g',1750,350,0.09),
('Pechuga de pato','Proteínas','piezas',25,5,120),
('Tocino','Proteínas','g',630,126,0.2),
('Chorizo','Proteínas','g',630,126,0.15),
('Huevo','Proteínas','piezas',38,8,4),
('Manteca de cerdo','Despensa','g',380,76,0.06),
('Chile morita','Chiles y especias','g',100,20,0.35),
('Chile guajillo','Chiles y especias','g',130,26,0.25),
('Chile ancho','Chiles y especias','g',130,26,0.25),
('Chile pasilla','Chiles y especias','g',50,10,0.28),
('Chile chilhuacle amarillo','Chiles y especias','g',100,20,0.6),
('Achiote','Chiles y especias','g',50,10,0.2),
('Comino','Chiles y especias','g',50,10,0.4),
('Canela','Chiles y especias','g',50,10,0.5),
('Clavo','Chiles y especias','g',50,10,1.2),
('Pimienta negra','Chiles y especias','g',50,10,0.5),
('Pimienta blanca','Chiles y especias','g',50,10,0.6),
('Sal','Despensa','g',640,128,0.01),
('Hoja de laurel','Chiles y especias','piezas',5,1,0.3),
('Tomillo','Hierbas','g',50,10,0.6),
('Romero fresco','Hierbas','g',50,10,0.5),
('Brotes comestibles','Hierbas','g',130,26,0.8),
('Piloncillo','Despensa','g',80,16,0.05),
('Jugo de naranja','Despensa','ml',250,50,0.03),
('Vinagre','Despensa','ml',250,50,0.02),
('Aceite vegetal','Despensa','ml',320,64,0.03),
('Fondo de res','Despensa','ml',3750,750,0.03),
('Fondo de pollo','Despensa','ml',3130,626,0.02),
('Tortilla azul','Panadería','piezas',25,5,1.5),
('Tortilla de maíz','Panadería','piezas',7,1,1),
('Masa de maíz','Panadería','g',50,10,0.02),
('Pan molido','Panadería','g',250,50,0.03),
('Harina de trigo','Panadería','g',1250,250,0.02),
('Harina de maíz azul','Panadería','g',250,50,0.06),
('Calabaza italiana','Vegetales','g',1000,200,0.03),
('Elote','Vegetales','g',940,188,0.02),
('Tomate verde','Vegetales','g',250,50,0.03),
('Aguacate','Vegetales','piezas',5,1,18),
('Betabel','Vegetales','piezas',25,5,8),
('Hongos mixtos','Vegetales','g',1880,376,0.12),
('Chalota','Vegetales','g',250,50,0.08),
('Zanahoria baby','Vegetales','piezas',50,10,3),
('Cebolla cambray','Vegetales','piezas',50,10,3),
('Coliflor','Vegetales','g',3130,626,0.04),
('Chile jalapeño','Vegetales','piezas',7,1,2),
('Chile serrano','Vegetales','piezas',7,1,1.5),
('Piña','Frutas','g',500,100,0.03),
('Naranja sanguina','Frutas','piezas',19,4,8),
('Mandarina','Frutas','piezas',32,6,3),
('Frutos rojos','Frutas','g',940,188,0.2),
('Limón amarillo','Frutas','piezas',13,3,3),
('Queso fresco','Lácteos','g',630,126,0.15),
('Queso de cabra','Lácteos','g',1130,226,0.4),
('Parmesano','Lácteos','g',630,126,0.5),
('Crema para batir','Lácteos','ml',2820,564,0.08),
('Leche','Lácteos','ml',1130,226,0.02),
('Pepita','Despensa','g',130,26,0.2),
('Cacao en polvo','Despensa','g',160,32,0.3),
('Agar-agar','Despensa','g',50,10,2),
('Lecitina de soya','Despensa','g',50,10,1.5),
('Almendra','Despensa','g',190,38,0.3),
('Cacahuate','Despensa','g',190,38,0.12),
('Ajonjolí','Despensa','g',130,26,0.15),
('Pasas','Despensa','g',160,32,0.1),
('Chocolate oscuro','Despensa','g',940,188,0.25),
('Chocolate blanco','Despensa','g',630,126,0.25),
('Glucosa','Despensa','g',190,38,0.1),
('Gelatina sin sabor','Despensa','g',90,18,0.6),
('Flor de jamaica','Despensa','g',190,38,0.2),
('Frijol bayo cocido','Despensa','g',3130,626,0.03),
('Frijol pinto cocido','Despensa','g',3130,626,0.03),
('Agua mineral','Bebidas','ml',2500,500,0.02),
('Hielo','Bebidas','g',1880,376,0.005),
('Cerveza','Bebidas','ml',320,64,0.03);

-- Platillos nuevos (precios provisionales)
INSERT INTO recipes (name,price,category,description) VALUES
('Taco de res glaseada de chile morita',95,'Tacos','Diezmillo de res glaseado con chile morita, piloncillo, naranja y vinagre de manzana, sobre tortilla azul. Lleva aguacate, cebolla morada curtida, brotes de coliflor, culantro y pepita tostada. Dulce, ahumado, ácido y ligeramente picante.'),
('Taco de birria de res al carbón',90,'Tacos','Birria de diezmillo y chambarete cocida lentamente en chiles guajillo, ancho y pasilla, terminada al carbón sobre tortilla azul. Con cebolla morada curtida, culantro y aguacate. Se sirve con un pequeño recipiente de consomé.'),
('Taco de asada con adobo de guajillo y achiote',95,'Tacos','Arrachera o vacío marinado en adobo de guajillo y achiote, cocinado al carbón y cortado en tiras sobre tortilla azul. Con aguacate, cebolla morada curtida, salsa de chile de árbol y culantro.'),
('Taco de pastor de res',85,'Tacos','Res en adobo de guajillo y achiote, cocida al carbón, con piña tatemada. Sobre tortilla azul, con aguacate, cebolla morada curtida, culantro y salsa de chile morita.'),
('Taco de calabaza y elote',75,'Tacos','Opción vegetariana: calabaza italiana y elote asados al carbón, con queso fresco, aguacate, pepita tostada, aceite de epazote y brotes de coliflor sobre tortilla azul.'),
('Taco de carnitas de pollo al carbón',80,'Tacos','Muslo de pollo cocinado lentamente en manteca con naranja, leche, laurel y tomillo, terminado al carbón. Con aguacate machacado, cebolla morada curtida, culantro y salsa verde cruda sobre tortilla azul.'),
('Taco de mole amarillo con pollo y elote',90,'Tacos','Pollo deshebrado en mole amarillo de chilhuacle y guajillo, con elote y calabaza tatemados, aguacate, pepita tostada, culantro y gotas de aceite de epazote sobre tortilla azul.'),
('Frijoles puercos contemporáneos',70,'Guarniciones','Frijol bayo con chorizo, queso, cebolla y chile jalapeño, servido en cazuela de barro con queso fresco, pepita tostada y aceite de epazote.'),
('Frijoles charros',70,'Guarniciones','Frijol pinto con tocino, chorizo, cebolla, jitomate, chile serrano y un toque de cerveza, terminado con cilantro.'),
('Betabel en tres texturas',180,'Entradas','Betabel horneado, encurtido y deshidratado, con crema de queso de cabra, gel de naranja sanguina, tierra de cacao y nuez, y brotes o flores comestibles.'),
('Raviol de hongos, yema curada y espuma de parmesano',220,'Segundo tiempo','Pasta fresca rellena de hongos mixtos salteados con chalota y tomillo, con yema curada rallada y espuma de parmesano.'),
('Pato glaseado con mole de cacao',380,'Plato fuerte','Pechuga de pato de piel crujiente sobre puré de coliflor ahumada, con mole de cacao, zanahorias baby y cebollas cambray glaseadas, y teja de maíz azul.'),
('Entremet de chocolate, elote dulce y mandarina',160,'Postres','Bizcocho de chocolate, cremoso de elote dulce, inserto de mandarina y mousse de chocolate oscuro, cubierto con glaseado espejo de chocolate blanco.'),
('Jamaica, frutos rojos, romero y humo',90,'Bebidas','Infusión de flor de jamaica con concentrado de frutos rojos, limón y agua mineral, aromatizada con romero y ahumada, coronada con espuma de jamaica.'),
('Menú degustación (5 tiempos)',890,'Menú degustación','Recorrido completo de 5 tiempos: entrada (betabel en tres texturas), segundo tiempo (raviol de hongos), plato fuerte (pato con mole de cacao), postre (entremet de chocolate, elote y mandarina) y bebida (jamaica, frutos rojos, romero y humo).');

-- Ingredientes por porción de venta (1 taco, 1 porción de cada platillo)
INSERT INTO recipe_ingredients (recipe_id,ingredient_id,qty)
SELECT r.id,i.id,t.q FROM (
SELECT 'Taco de res glaseada de chile morita' r,'Diezmillo de res' i,50.0 q
 UNION ALL SELECT 'Taco de res glaseada de chile morita' r,'Chile morita' i,4.0 q
 UNION ALL SELECT 'Taco de res glaseada de chile morita' r,'Piloncillo' i,3.0 q
 UNION ALL SELECT 'Taco de res glaseada de chile morita' r,'Jugo de naranja' i,5.0 q
 UNION ALL SELECT 'Taco de res glaseada de chile morita' r,'Vinagre' i,3.0 q
 UNION ALL SELECT 'Taco de res glaseada de chile morita' r,'Cebolla' i,3.0 q
 UNION ALL SELECT 'Taco de res glaseada de chile morita' r,'Ajo' i,0.4 q
 UNION ALL SELECT 'Taco de res glaseada de chile morita' r,'Comino' i,0.1 q
 UNION ALL SELECT 'Taco de res glaseada de chile morita' r,'Canela' i,0.03 q
 UNION ALL SELECT 'Taco de res glaseada de chile morita' r,'Fondo de res' i,10.0 q
 UNION ALL SELECT 'Taco de res glaseada de chile morita' r,'Tortilla azul' i,1.0 q
 UNION ALL SELECT 'Taco de birria de res al carbón' r,'Diezmillo de res' i,70.0 q
 UNION ALL SELECT 'Taco de birria de res al carbón' r,'Chambarete de res' i,30.0 q
 UNION ALL SELECT 'Taco de birria de res al carbón' r,'Chile guajillo' i,5.0 q
 UNION ALL SELECT 'Taco de birria de res al carbón' r,'Chile ancho' i,2.0 q
 UNION ALL SELECT 'Taco de birria de res al carbón' r,'Chile pasilla' i,1.0 q
 UNION ALL SELECT 'Taco de birria de res al carbón' r,'Tomate' i,10.0 q
 UNION ALL SELECT 'Taco de birria de res al carbón' r,'Cebolla' i,8.0 q
 UNION ALL SELECT 'Taco de birria de res al carbón' r,'Ajo' i,1.2 q
 UNION ALL SELECT 'Taco de birria de res al carbón' r,'Hoja de laurel' i,0.2 q
 UNION ALL SELECT 'Taco de birria de res al carbón' r,'Comino' i,0.1 q
 UNION ALL SELECT 'Taco de birria de res al carbón' r,'Clavo' i,0.04 q
 UNION ALL SELECT 'Taco de birria de res al carbón' r,'Canela' i,0.3 q
 UNION ALL SELECT 'Taco de birria de res al carbón' r,'Vinagre' i,3.0 q
 UNION ALL SELECT 'Taco de birria de res al carbón' r,'Fondo de res' i,150.0 q
 UNION ALL SELECT 'Taco de birria de res al carbón' r,'Tortilla azul' i,1.0 q
 UNION ALL SELECT 'Taco de asada con adobo de guajillo y achiote' r,'Chile guajillo' i,5.0 q
 UNION ALL SELECT 'Taco de asada con adobo de guajillo y achiote' r,'Achiote' i,2.0 q
 UNION ALL SELECT 'Taco de asada con adobo de guajillo y achiote' r,'Jugo de naranja' i,5.0 q
 UNION ALL SELECT 'Taco de asada con adobo de guajillo y achiote' r,'Vinagre' i,2.0 q
 UNION ALL SELECT 'Taco de asada con adobo de guajillo y achiote' r,'Ajo' i,0.8 q
 UNION ALL SELECT 'Taco de asada con adobo de guajillo y achiote' r,'Comino' i,0.1 q
 UNION ALL SELECT 'Taco de asada con adobo de guajillo y achiote' r,'Arrachera' i,60.0 q
 UNION ALL SELECT 'Taco de asada con adobo de guajillo y achiote' r,'Tortilla azul' i,1.0 q
 UNION ALL SELECT 'Taco de pastor de res' r,'Diezmillo de res' i,60.0 q
 UNION ALL SELECT 'Taco de pastor de res' r,'Chile guajillo' i,5.0 q
 UNION ALL SELECT 'Taco de pastor de res' r,'Achiote' i,2.0 q
 UNION ALL SELECT 'Taco de pastor de res' r,'Jugo de naranja' i,6.0 q
 UNION ALL SELECT 'Taco de pastor de res' r,'Vinagre' i,3.0 q
 UNION ALL SELECT 'Taco de pastor de res' r,'Ajo' i,0.8 q
 UNION ALL SELECT 'Taco de pastor de res' r,'Comino' i,0.1 q
 UNION ALL SELECT 'Taco de pastor de res' r,'Piña' i,20.0 q
 UNION ALL SELECT 'Taco de pastor de res' r,'Tortilla azul' i,1.0 q
 UNION ALL SELECT 'Taco de calabaza y elote' r,'Calabaza italiana' i,40.0 q
 UNION ALL SELECT 'Taco de calabaza y elote' r,'Elote' i,25.0 q
 UNION ALL SELECT 'Taco de calabaza y elote' r,'Queso fresco' i,10.0 q
 UNION ALL SELECT 'Taco de calabaza y elote' r,'Pepita' i,5.0 q
 UNION ALL SELECT 'Taco de calabaza y elote' r,'Tortilla azul' i,1.0 q
 UNION ALL SELECT 'Taco de carnitas de pollo al carbón' r,'Muslo de pollo' i,70.0 q
 UNION ALL SELECT 'Taco de carnitas de pollo al carbón' r,'Manteca de cerdo' i,15.0 q
 UNION ALL SELECT 'Taco de carnitas de pollo al carbón' r,'Jugo de naranja' i,10.0 q
 UNION ALL SELECT 'Taco de carnitas de pollo al carbón' r,'Leche' i,5.0 q
 UNION ALL SELECT 'Taco de carnitas de pollo al carbón' r,'Ajo' i,0.8 q
 UNION ALL SELECT 'Taco de carnitas de pollo al carbón' r,'Cebolla' i,5.0 q
 UNION ALL SELECT 'Taco de carnitas de pollo al carbón' r,'Hoja de laurel' i,0.1 q
 UNION ALL SELECT 'Taco de carnitas de pollo al carbón' r,'Tomillo' i,0.1 q
 UNION ALL SELECT 'Taco de carnitas de pollo al carbón' r,'Pimienta negra' i,0.1 q
 UNION ALL SELECT 'Taco de carnitas de pollo al carbón' r,'Tortilla azul' i,1.0 q
 UNION ALL SELECT 'Taco de mole amarillo con pollo y elote' r,'Chile chilhuacle amarillo' i,4.0 q
 UNION ALL SELECT 'Taco de mole amarillo con pollo y elote' r,'Chile guajillo' i,2.0 q
 UNION ALL SELECT 'Taco de mole amarillo con pollo y elote' r,'Tomate verde' i,10.0 q
 UNION ALL SELECT 'Taco de mole amarillo con pollo y elote' r,'Cebolla' i,5.0 q
 UNION ALL SELECT 'Taco de mole amarillo con pollo y elote' r,'Ajo' i,0.8 q
 UNION ALL SELECT 'Taco de mole amarillo con pollo y elote' r,'Masa de maíz' i,2.0 q
 UNION ALL SELECT 'Taco de mole amarillo con pollo y elote' r,'Pepita' i,3.0 q
 UNION ALL SELECT 'Taco de mole amarillo con pollo y elote' r,'Comino' i,0.1 q
 UNION ALL SELECT 'Taco de mole amarillo con pollo y elote' r,'Clavo' i,0.01 q
 UNION ALL SELECT 'Taco de mole amarillo con pollo y elote' r,'Pimienta negra' i,0.03 q
 UNION ALL SELECT 'Taco de mole amarillo con pollo y elote' r,'Fondo de pollo' i,50.0 q
 UNION ALL SELECT 'Taco de mole amarillo con pollo y elote' r,'Muslo de pollo' i,50.0 q
 UNION ALL SELECT 'Taco de mole amarillo con pollo y elote' r,'Elote' i,15.0 q
 UNION ALL SELECT 'Taco de mole amarillo con pollo y elote' r,'Calabaza italiana' i,15.0 q
 UNION ALL SELECT 'Taco de mole amarillo con pollo y elote' r,'Aguacate' i,0.2 q
 UNION ALL SELECT 'Taco de mole amarillo con pollo y elote' r,'Tortilla azul' i,1.0 q
 UNION ALL SELECT 'Frijoles puercos contemporáneos' r,'Frijol bayo cocido' i,125.0 q
 UNION ALL SELECT 'Frijoles puercos contemporáneos' r,'Chorizo' i,25.0 q
 UNION ALL SELECT 'Frijoles puercos contemporáneos' r,'Queso fresco' i,25.0 q
 UNION ALL SELECT 'Frijoles puercos contemporáneos' r,'Cebolla' i,12.5 q
 UNION ALL SELECT 'Frijoles puercos contemporáneos' r,'Chile jalapeño' i,0.25 q
 UNION ALL SELECT 'Frijoles puercos contemporáneos' r,'Manteca de cerdo' i,7.5 q
 UNION ALL SELECT 'Frijoles charros' r,'Frijol pinto cocido' i,125.0 q
 UNION ALL SELECT 'Frijoles charros' r,'Tocino' i,25.0 q
 UNION ALL SELECT 'Frijoles charros' r,'Chorizo' i,25.0 q
 UNION ALL SELECT 'Frijoles charros' r,'Cebolla' i,20.0 q
 UNION ALL SELECT 'Frijoles charros' r,'Tomate' i,25.0 q
 UNION ALL SELECT 'Frijoles charros' r,'Chile serrano' i,0.25 q
 UNION ALL SELECT 'Frijoles charros' r,'Cerveza' i,12.5 q
 UNION ALL SELECT 'Betabel en tres texturas' r,'Betabel' i,1.0 q
 UNION ALL SELECT 'Betabel en tres texturas' r,'Queso de cabra' i,45.0 q
 UNION ALL SELECT 'Betabel en tres texturas' r,'Naranja sanguina' i,0.75 q
 UNION ALL SELECT 'Betabel en tres texturas' r,'Cacao en polvo' i,6.25 q
 UNION ALL SELECT 'Betabel en tres texturas' r,'Nuez' i,12.5 q
 UNION ALL SELECT 'Betabel en tres texturas' r,'Pan molido' i,10.0 q
 UNION ALL SELECT 'Betabel en tres texturas' r,'Mantequilla' i,5.0 q
 UNION ALL SELECT 'Betabel en tres texturas' r,'Azúcar' i,6.25 q
 UNION ALL SELECT 'Betabel en tres texturas' r,'Vinagre' i,10.0 q
 UNION ALL SELECT 'Betabel en tres texturas' r,'Aceite de oliva' i,15.0 q
 UNION ALL SELECT 'Betabel en tres texturas' r,'Miel' i,5.0 q
 UNION ALL SELECT 'Betabel en tres texturas' r,'Tomillo' i,1.25 q
 UNION ALL SELECT 'Betabel en tres texturas' r,'Sal' i,1.5 q
 UNION ALL SELECT 'Betabel en tres texturas' r,'Pimienta negra' i,0.5 q
 UNION ALL SELECT 'Betabel en tres texturas' r,'Brotes comestibles' i,5.0 q
 UNION ALL SELECT 'Betabel en tres texturas' r,'Agar-agar' i,0.3 q
 UNION ALL SELECT 'Raviol de hongos, yema curada y espuma de parmesano' r,'Harina de trigo' i,50.0 q
 UNION ALL SELECT 'Raviol de hongos, yema curada y espuma de parmesano' r,'Huevo' i,1.5 q
 UNION ALL SELECT 'Raviol de hongos, yema curada y espuma de parmesano' r,'Aceite de oliva' i,2.5 q
 UNION ALL SELECT 'Raviol de hongos, yema curada y espuma de parmesano' r,'Sal' i,25.5 q
 UNION ALL SELECT 'Raviol de hongos, yema curada y espuma de parmesano' r,'Hongos mixtos' i,75.0 q
 UNION ALL SELECT 'Raviol de hongos, yema curada y espuma de parmesano' r,'Chalota' i,10.0 q
 UNION ALL SELECT 'Raviol de hongos, yema curada y espuma de parmesano' r,'Ajo' i,1.0 q
 UNION ALL SELECT 'Raviol de hongos, yema curada y espuma de parmesano' r,'Mantequilla' i,7.5 q
 UNION ALL SELECT 'Raviol de hongos, yema curada y espuma de parmesano' r,'Parmesano' i,25.0 q
 UNION ALL SELECT 'Raviol de hongos, yema curada y espuma de parmesano' r,'Crema para batir' i,37.5 q
 UNION ALL SELECT 'Raviol de hongos, yema curada y espuma de parmesano' r,'Fondo de pollo' i,50.0 q
 UNION ALL SELECT 'Raviol de hongos, yema curada y espuma de parmesano' r,'Tomillo' i,0.75 q
 UNION ALL SELECT 'Raviol de hongos, yema curada y espuma de parmesano' r,'Pimienta negra' i,0.5 q
 UNION ALL SELECT 'Raviol de hongos, yema curada y espuma de parmesano' r,'Azúcar' i,12.5 q
 UNION ALL SELECT 'Raviol de hongos, yema curada y espuma de parmesano' r,'Lecitina de soya' i,0.5 q
 UNION ALL SELECT 'Pato glaseado con mole de cacao' r,'Pechuga de pato' i,1.0 q
 UNION ALL SELECT 'Pato glaseado con mole de cacao' r,'Sal' i,4.5 q
 UNION ALL SELECT 'Pato glaseado con mole de cacao' r,'Pimienta negra' i,0.75 q
 UNION ALL SELECT 'Pato glaseado con mole de cacao' r,'Zanahoria baby' i,2.0 q
 UNION ALL SELECT 'Pato glaseado con mole de cacao' r,'Cebolla cambray' i,2.0 q
 UNION ALL SELECT 'Pato glaseado con mole de cacao' r,'Mantequilla' i,26.25 q
 UNION ALL SELECT 'Pato glaseado con mole de cacao' r,'Miel' i,5.0 q
 UNION ALL SELECT 'Pato glaseado con mole de cacao' r,'Aceite vegetal' i,12.5 q
 UNION ALL SELECT 'Pato glaseado con mole de cacao' r,'Cebolla' i,20.0 q
 UNION ALL SELECT 'Pato glaseado con mole de cacao' r,'Ajo' i,2.0 q
 UNION ALL SELECT 'Pato glaseado con mole de cacao' r,'Tomate' i,37.5 q
 UNION ALL SELECT 'Pato glaseado con mole de cacao' r,'Chile ancho' i,5.0 q
 UNION ALL SELECT 'Pato glaseado con mole de cacao' r,'Chile pasilla' i,1.25 q
 UNION ALL SELECT 'Pato glaseado con mole de cacao' r,'Almendra' i,7.5 q
 UNION ALL SELECT 'Pato glaseado con mole de cacao' r,'Cacahuate' i,7.5 q
 UNION ALL SELECT 'Pato glaseado con mole de cacao' r,'Ajonjolí' i,5.0 q
 UNION ALL SELECT 'Pato glaseado con mole de cacao' r,'Pasas' i,6.25 q
 UNION ALL SELECT 'Pato glaseado con mole de cacao' r,'Tortilla de maíz' i,0.25 q
 UNION ALL SELECT 'Pato glaseado con mole de cacao' r,'Chocolate oscuro' i,10.0 q
 UNION ALL SELECT 'Pato glaseado con mole de cacao' r,'Cacao en polvo' i,3.75 q
 UNION ALL SELECT 'Pato glaseado con mole de cacao' r,'Canela' i,0.25 q
 UNION ALL SELECT 'Pato glaseado con mole de cacao' r,'Clavo' i,0.05 q
 UNION ALL SELECT 'Pato glaseado con mole de cacao' r,'Comino' i,0.25 q
 UNION ALL SELECT 'Pato glaseado con mole de cacao' r,'Fondo de pollo' i,125.0 q
 UNION ALL SELECT 'Pato glaseado con mole de cacao' r,'Coliflor' i,125.0 q
 UNION ALL SELECT 'Pato glaseado con mole de cacao' r,'Crema para batir' i,20.0 q
 UNION ALL SELECT 'Pato glaseado con mole de cacao' r,'Leche' i,12.5 q
 UNION ALL SELECT 'Pato glaseado con mole de cacao' r,'Pimienta blanca' i,0.25 q
 UNION ALL SELECT 'Pato glaseado con mole de cacao' r,'Harina de maíz azul' i,10.0 q
 UNION ALL SELECT 'Pato glaseado con mole de cacao' r,'Harina de trigo' i,5.0 q
 UNION ALL SELECT 'Pato glaseado con mole de cacao' r,'Huevo' i,0.25 q
 UNION ALL SELECT 'Entremet de chocolate, elote dulce y mandarina' r,'Chocolate oscuro' i,37.5 q
 UNION ALL SELECT 'Entremet de chocolate, elote dulce y mandarina' r,'Crema para batir' i,112.5 q
 UNION ALL SELECT 'Entremet de chocolate, elote dulce y mandarina' r,'Gelatina sin sabor' i,3.25 q
 UNION ALL SELECT 'Entremet de chocolate, elote dulce y mandarina' r,'Azúcar' i,25.0 q
 UNION ALL SELECT 'Entremet de chocolate, elote dulce y mandarina' r,'Huevo' i,1.0 q
 UNION ALL SELECT 'Entremet de chocolate, elote dulce y mandarina' r,'Harina de trigo' i,8.75 q
 UNION ALL SELECT 'Entremet de chocolate, elote dulce y mandarina' r,'Cacao en polvo' i,3.75 q
 UNION ALL SELECT 'Entremet de chocolate, elote dulce y mandarina' r,'Mantequilla' i,5.0 q
 UNION ALL SELECT 'Entremet de chocolate, elote dulce y mandarina' r,'Elote' i,37.5 q
 UNION ALL SELECT 'Entremet de chocolate, elote dulce y mandarina' r,'Leche' i,45.0 q
 UNION ALL SELECT 'Entremet de chocolate, elote dulce y mandarina' r,'Mandarina' i,1.25 q
 UNION ALL SELECT 'Entremet de chocolate, elote dulce y mandarina' r,'Chocolate blanco' i,25.0 q
 UNION ALL SELECT 'Entremet de chocolate, elote dulce y mandarina' r,'Glucosa' i,7.5 q
 UNION ALL SELECT 'Entremet de chocolate, elote dulce y mandarina' r,'Aceite vegetal' i,2.5 q
 UNION ALL SELECT 'Jamaica, frutos rojos, romero y humo' r,'Flor de jamaica' i,7.5 q
 UNION ALL SELECT 'Jamaica, frutos rojos, romero y humo' r,'Frutos rojos' i,37.5 q
 UNION ALL SELECT 'Jamaica, frutos rojos, romero y humo' r,'Limón amarillo' i,0.5 q
 UNION ALL SELECT 'Jamaica, frutos rojos, romero y humo' r,'Romero fresco' i,0.5 q
 UNION ALL SELECT 'Jamaica, frutos rojos, romero y humo' r,'Azúcar' i,16.25 q
 UNION ALL SELECT 'Jamaica, frutos rojos, romero y humo' r,'Agua mineral' i,100.0 q
 UNION ALL SELECT 'Jamaica, frutos rojos, romero y humo' r,'Hielo' i,75.0 q
 UNION ALL SELECT 'Jamaica, frutos rojos, romero y humo' r,'Lecitina de soya' i,0.5 q
) t JOIN recipes r ON r.name=t.r JOIN ingredients i ON i.name=t.i;

-- El menú degustación suma los ingredientes de sus 5 platillos
INSERT INTO recipe_ingredients (recipe_id,ingredient_id,qty)
SELECT (SELECT id FROM recipes WHERE name='Menú degustación (5 tiempos)'),ri.ingredient_id,SUM(ri.qty)
FROM recipe_ingredients ri JOIN recipes r ON r.id=ri.recipe_id WHERE r.name IN ('Betabel en tres texturas','Raviol de hongos, yema curada y espuma de parmesano','Pato glaseado con mole de cacao','Entremet de chocolate, elote dulce y mandarina','Jamaica, frutos rojos, romero y humo') GROUP BY ri.ingredient_id;

SELECT category, COUNT(*) AS platillos FROM recipes GROUP BY category;