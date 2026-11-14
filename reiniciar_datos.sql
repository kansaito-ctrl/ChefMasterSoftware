-- ChefMaster: deja el sistema COMO NUEVO (sin pedidos ni movimientos y con el inventario en su existencia base).
-- NO borra la carta. Lo usa el botón "Restaurar datos". Requiere la columna base_quantity (inventario_base.sql).
DELETE FROM movements;
DELETE FROM order_items;
DELETE FROM orders;
ALTER TABLE orders AUTO_INCREMENT = 1001;
UPDATE ingredients SET quantity = base_quantity WHERE base_quantity IS NOT NULL;