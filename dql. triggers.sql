-- Tabla para inventario de especies (resumen de especie_area)

-- Triggers para Inventario de Especies (tabla especie_area)


CREATE TABLE IF NOT EXISTS inventario_especies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_especie INT,
    id_area INT,
    total INT,
    last_update DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 1. AFTER INSERT en especie_area
delimiter //
create trigger trg_especie_area_after_insert
after insert on especie_area
for each row
begin
    insert into inventario_especies(id_especie, id_area, total, last_update)
    values (new.id_especie, new.id_area, new.cantidad, now());
end //
delimiter ;

-- 2. AFTER UPDATE en especie_area

 delimiter //
create trigger trg_especie_area_after_update
after update on especie_area
for each row
begin
    update inventario_especies
    set total = new.cantidad, last_update = now()
    where id_especie = new.id_especie and id_area = new.id_area;
end //
delimiter ;

-- 3 AFTER DELETE en especie_area

delimiter //
create trigger trg_especie_area_after_delete
after delete on especie_area
for each row
begin
    delete from inventario_especies
    where id_especie = old.id_especie and id_area = old.id_area;
end //
delimiter ;

-- Triggers para Movimientos y Cambios Salariales en Empleado (tabla empleado)

-- Tabla para log de movimientos y cambios salariales de empleados

CREATE TABLE IF NOT EXISTS log_movimientos_empleado (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_empleado INT,
    accion VARCHAR(50),
    campo_modificado VARCHAR(50),
    valor_anterior DECIMAL(10,2),
    valor_nuevo DECIMAL(10,2),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. AFTER INSERT en empleado

delimiter //
create trigger trg_empleado_after_insert
after insert on empleado
for each row
begin
    -- Se registra la creación del empleado con su sueldo inicial
    insert into log_movimientos_empleado(id_empleado, accion, campo_modificado, valor_anterior, valor_nuevo)
    values (new.id, 'INSERT', 'sueldo', 0, new.sueldo);
end //
delimiter ;

-- 5. AFTER UPDATE en empleado (sólo si cambia el sueldo)

delimiter //
create trigger trg_empleado_after_update
after update on empleado
for each row
begin
    if new.sueldo <> old.sueldo then
        insert into log_movimientos_empleado(id_empleado, accion, campo_modificado, valor_anterior, valor_nuevo)
        values (new.id, 'UPDATE', 'sueldo', old.sueldo, new.sueldo);
    end if;
end //
delimiter ;

-- 6. AFTER DELETE en empleado

delimiter //
create trigger trg_empleado_after_delete
after delete on empleado
for each row
begin
    insert into log_movimientos_empleado(id_empleado, accion, campo_modificado, valor_anterior, valor_nuevo)
    values (old.id, 'DELETE', 'sueldo', old.sueldo, 0);
end //
delimiter ;

-- Triggers para Registro de Cambios en parque_area

-- Tabla para log de cambios en parque_area
CREATE TABLE IF NOT EXISTS log_parque_area (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_parque INT,
    id_area INT,
    accion VARCHAR(20),
    extension INT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. AFTER INSERT en parque_area

delimiter //
create trigger trg_parque_area_after_insert
after insert on parque_area
for each row
begin
    insert into log_parque_area(id_parque, id_area, accion, extension)
    values (new.id_parque, new.id_area, 'INSERT', new.extension);
end //
delimiter ;

-- 8. AFTER UPDATE en parque_area

delimiter //
create trigger trg_parque_area_after_update
after update on parque_area
for each row
begin
    insert into log_parque_area(id_parque, id_area, accion, extension)
    values (new.id_parque, new.id_area, 'UPDATE', new.extension);
end //
delimiter ;

-- 9. AFTER DELETE en parque_area

delimiter //
create trigger trg_parque_area_after_delete
after delete on parque_area
for each row
begin
    insert into log_parque_area(id_parque, id_area, accion, extension)
    values (old.id_parque, old.id_area, 'DELETE', old.extension);
end //
delimiter ;

--  Triggers para Registro en registro_visitante

-- Tabla para log de registro_visitante
CREATE TABLE IF NOT EXISTS log_registro_visitante (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_empleado INT,
    id_visitante INT,
    accion VARCHAR(20),
    fecha_registro DATE,
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 10. AFTER INSERT en registro_visitante

delimiter //
create trigger trg_registro_visitante_after_insert
after insert on registro_visitante
for each row
begin
    insert into log_registro_visitante(id_empleado, id_visitante, accion, fecha_registro)
    values (new.id_empleado, new.id_visitante, 'INSERT', new.fecha);
end //
delimiter ;

-- 11. AFTER UPDATE en registro_visitante

delimiter //
create trigger trg_registro_visitante_after_update
after update on registro_visitante
for each row
begin
    insert into log_registro_visitante(id_empleado, id_visitante, accion, fecha_registro)
    values (new.id_empleado, new.id_visitante, 'UPDATE', new.fecha);
end //
delimiter ;

-- 12. AFTER DELETE en registro_visitante

delimiter //
create trigger trg_registro_visitante_after_delete
after delete on registro_visitante
for each row
begin
    insert into log_registro_visitante(id_empleado, id_visitante, accion, fecha_registro)
    values (old.id_empleado, old.id_visitante, 'DELETE', old.fecha);
end //
delimiter ;

-- Triggers para Registro en visitante_alojamiento

-- Tabla para log de visitante_alojamiento

CREATE TABLE IF NOT EXISTS log_visitante_alojamiento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_visitante INT,
    id_alojamiento INT,
    accion VARCHAR(20),
    fecha DATE,
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 13. AFTER INSERT en visitante_alojamiento

delimiter //
create trigger trg_visitante_alojamiento_after_insert
after insert on visitante_alojamiento
for each row
begin
    insert into log_visitante_alojamiento(id_visitante, id_alojamiento, accion, fecha)
    values (new.id_visitante, new.id_alojamiento, 'INSERT', new.fecha);
end //
delimiter ;

-- 14. AFTER UPDATE en visitante_alojamiento

delimiter //
create trigger trg_visitante_alojamiento_after_update
after update on visitante_alojamiento
for each row
begin
    insert into log_visitante_alojamiento(id_visitante, id_alojamiento, accion, fecha)
    values (new.id_visitante, new.id_alojamiento, 'UPDATE', new.fecha);
end //
delimiter ;

-- 15. AFTER DELETE en visitante_alojamiento

delimiter //
create trigger trg_visitante_alojamiento_after_delete
after delete on visitante_alojamiento
for each row
begin
    insert into log_visitante_alojamiento(id_visitante, id_alojamiento, accion, fecha)
    values (old.id_visitante, old.id_alojamiento, 'DELETE', old.fecha);
end //
delimiter ;


--  Triggers para Registro en investigador_proyecto
-- Tabla para log de investigador_proyecto

CREATE TABLE IF NOT EXISTS log_investigador_proyecto (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_proyecto INT,
    id_empleado INT,
    accion VARCHAR(20),
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 16 AFTER INSERT en investigador_proyecto

delimiter //
create trigger trg_investigador_proyecto_after_insert
after insert on investigador_proyecto
for each row
begin
    insert into log_investigador_proyecto(id_proyecto, id_empleado, accion)
    values (new.id_proyecto, new.id_empleado, 'INSERT');
end //
delimiter ;

-- 17. AFTER UPDATE en investigador_proyecto

delimiter //
create trigger trg_investigador_proyecto_after_update
after update on investigador_proyecto
for each row
begin
    insert into log_investigador_proyecto(id_proyecto, id_empleado, accion)
    values (new.id_proyecto, new.id_empleado, 'UPDATE');
end //
delimiter ;

-- 18. AFTER DELETE en investigador_proyecto

delimiter //
create trigger trg_investigador_proyecto_after_delete
after delete on investigador_proyecto
for each row
begin
    insert into log_investigador_proyecto(id_proyecto, id_empleado, accion)
    values (old.id_proyecto, old.id_empleado, 'DELETE');
end //
delimiter ;

-- Triggers para Registro en vehiculo
-- Tabla para log de vehiculo
CREATE TABLE IF NOT EXISTS log_vehiculo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_empleado INT,
    id_vehiculo INT,
    accion VARCHAR(20),
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- 19 AFTER INSERT en vehiculo

delimiter //
create trigger trg_vehiculo_after_insert
after insert on vehiculo
for each row
begin
    insert into log_vehiculo(id_empleado, id_vehiculo, accion)
    values (new.id_empleado, new.id, 'INSERT');
end //
delimiter ;

-- 20  AFTER UPDATE en vehiculo

delimiter //
create trigger trg_vehiculo_after_update
after update on vehiculo
for each row
begin
    insert into log_vehiculo(id_empleado, id_vehiculo, accion)
    values (new.id_empleado, new.id, 'UPDATE');
end //
delimiter ;


