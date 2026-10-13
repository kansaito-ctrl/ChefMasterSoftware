USE chefmaster;

ALTER TABLE recipes ADD COLUMN image_url VARCHAR(255) NULL;

UPDATE recipes SET image_url='/img/taco-res-glaseada.jpg' WHERE name='Taco de res glaseada de chile morita';
UPDATE recipes SET image_url='/img/taco-birria.jpg' WHERE name='Taco de birria de res al carbón';
UPDATE recipes SET image_url='/img/taco-asada.jpg' WHERE name='Taco de asada con adobo de guajillo y achiote';
UPDATE recipes SET image_url='/img/taco-pastor.jpg' WHERE name='Taco de pastor de res';
UPDATE recipes SET image_url='/img/taco-calabaza-elote.jpg' WHERE name='Taco de calabaza y elote';
UPDATE recipes SET image_url='/img/taco-carnitas-pollo.jpg' WHERE name='Taco de carnitas de pollo al carbón';
UPDATE recipes SET image_url='/img/taco-mole-amarillo.jpg' WHERE name='Taco de mole amarillo con pollo y elote';
UPDATE recipes SET image_url='/img/frijoles-puercos.jpg' WHERE name='Frijoles puercos contemporáneos';
UPDATE recipes SET image_url='/img/frijoles-charros.jpg' WHERE name='Frijoles charros';
UPDATE recipes SET image_url='/img/betabel.jpg' WHERE name='Betabel en tres texturas';
UPDATE recipes SET image_url='/img/raviol-hongos.jpg' WHERE name='Raviol de hongos, yema curada y espuma de parmesano';
UPDATE recipes SET image_url='/img/pato-mole-cacao.jpg' WHERE name='Pato glaseado con mole de cacao';
UPDATE recipes SET image_url='/img/entremet.jpg' WHERE name='Entremet de chocolate, elote dulce y mandarina';
UPDATE recipes SET image_url='/img/jamaica.jpg' WHERE name='Jamaica, frutos rojos, romero y humo';

SELECT name, image_url FROM recipes WHERE image_url IS NOT NULL;
