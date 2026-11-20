USE chefmaster;

UPDATE recipes SET image_url='/img/hummus.jpg' WHERE name='Hummus';
UPDATE recipes SET image_url='/img/sigara-boregi.jpg' WHERE name='Sigara Böreği';
UPDATE recipes SET image_url='/img/adana-kebap.jpg' WHERE name='Adana Kebap';
UPDATE recipes SET image_url='/img/simit.jpg' WHERE name='Simit';
UPDATE recipes SET image_url='/img/baklava.jpg' WHERE name='Baklava';
UPDATE recipes SET image_url='/img/cafe-turco.jpg' WHERE name='Café turco';
UPDATE recipes SET image_url='/img/carpaccio-betabel.jpg' WHERE name='Carpaccio de betabel rostizado con queso de cabra';
UPDATE recipes SET image_url='/img/crema-esparragos.jpg' WHERE name='Crema de espárragos verdes';
UPDATE recipes SET image_url='/img/filete-vino-tinto.jpg' WHERE name='Filete de res con salsa de vino tinto';
UPDATE recipes SET image_url='/img/papa-fondant.jpg' WHERE name='Papa fondant y zanahorias baby glaseadas';
UPDATE recipes SET image_url='/img/entremet-tres-leches.jpg' WHERE name='Entremet de chocolate tres leches';
UPDATE recipes SET image_url='/img/alcachofa-confitada.jpg' WHERE name='Alcachofa confitada con emulsión de papa';
UPDATE recipes SET image_url='/img/consome-jitomate.jpg' WHERE name='Consomé de jitomate rostizado';
UPDATE recipes SET image_url='/img/suprema-pollo.jpg' WHERE name='Suprema de pollo al limón amarillo y tomillo';
UPDATE recipes SET image_url='/img/risotto-azafran.jpg' WHERE name='Risotto de azafrán y espárragos';
UPDATE recipes SET image_url='/img/tartaleta-limon.jpg' WHERE name='Tartaleta de limón amarillo y merengue italiano';
UPDATE recipes SET image_url='/img/tartar-jitomate.jpg' WHERE name='Tartar de jitomate heirloom con aguachile verde';
UPDATE recipes SET image_url='/img/crema-elote.jpg' WHERE name='Crema de elote tatemado';
UPDATE recipes SET image_url='/img/magret-mole.jpg' WHERE name='Magret de pato con mole negro';
UPDATE recipes SET image_url='/img/pure-camote.jpg' WHERE name='Puré de camote y vegetales baby glaseados';
UPDATE recipes SET image_url='/img/cremoso-guayaba.jpg' WHERE name='Cremoso de guayaba, mousse de vainilla y gel de jamaica';
UPDATE recipes SET image_url='/img/raviol-ricotta.jpg' WHERE name='Raviol de ricotta y espinaca con salvia';
UPDATE recipes SET image_url='/img/veloute-hongos.jpg' WHERE name='Velouté de hongos con aceite de trufa';
UPDATE recipes SET image_url='/img/short-rib.jpg' WHERE name='Short rib de res a baja temperatura';
UPDATE recipes SET image_url='/img/pure-coliflor.jpg' WHERE name='Puré de coliflor y vegetales de temporada';
UPDATE recipes SET image_url='/img/entremet-frutos-rojos.jpg' WHERE name='Entremet de frutos rojos y vainilla';

UPDATE recipes SET image_url='/img/filete-vino-tinto.jpg' WHERE name='Menú 1 completo (5 tiempos)';
UPDATE recipes SET image_url='/img/suprema-pollo.jpg' WHERE name='Menú 2 completo (5 tiempos)';
UPDATE recipes SET image_url='/img/magret-mole.jpg' WHERE name='Menú 3 completo (5 tiempos)';
UPDATE recipes SET image_url='/img/short-rib.jpg' WHERE name='Menú 4 completo (5 tiempos)';

SELECT COUNT(*) AS platillos_con_foto FROM recipes WHERE image_url IS NOT NULL AND active=1;