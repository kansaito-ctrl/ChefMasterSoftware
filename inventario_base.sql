   USE chefmaster;
   ALTER TABLE ingredients ADD COLUMN base_quantity DECIMAL(10,2) NULL;
   UPDATE ingredients SET base_quantity = quantity;
   SELECT name, quantity, base_quantity FROM ingredients ORDER BY name LIMIT 5;