--  Procedimientos para la Gestión de Parques, Áreas y Especies
-- 1. Registrar un nuevo parque

delimiter //
create procedure registrar_parque(in nombre_parque varchar(100), in fecha_declaracion date)
begin
    insert into parque (nombre, fecha_declaracion) values (nombre_parque, fecha_declaracion);
end //
delimiter ;

-- 2. Actualizar datos de un parque

delimiter //
create procedure actualizar_parque(in parque_id int, in nuevo_nombre varchar(100), in nueva_fecha date)
begin
    update parque set nombre = nuevo_nombre, fecha_declaracion = nueva_fecha where id = parque_id;
end //
delimiter ;

-- 3. Registrar una nueva área en un parque

delimiter //
create procedure registrar_area(in id_parque int, in nombre_area varchar(100), in extension int)
begin
    declare area_id int;
    insert into area (nombre) values (nombre_area);
    set area_id = last_insert_id();
    insert into parque_area (id_parque, id_area, extension) values (id_parque, area_id, extension);
end //
delimiter ;

-- 4. Registrar una nueva especie en un área

delimiter //
create procedure registrar_especie(in nombre_cientifico varchar(100), in nombre_vulgar varchar(100), in tipo enum('vegetal', 'animal', 'mineral'))
begin
    insert into especie (nombre_cientifico, nombre_vulgar, tipo) values (nombre_cientifico, nombre_vulgar, tipo);
end //
delimiter ;


-- 5. Asignar una especie a un área específica

delimiter //
create procedure asignar_especie_area(in id_especie int, in id_area int, in cantidad int)
begin
    insert into especie_area (id_especie, id_area, cantidad) values (id_especie, id_area, cantidad);
end //
delimiter ;

-- Procedimientos para la Gestión de Visitantes y Alojamientos

-- 6. Registrar un nuevo visitante
delimiter //
create procedure registrar_visitante(in cedula varchar(20), in nombre varchar(255), in direccion varchar(255), in profesion varchar(100))
begin
    insert into visitantes (cedula, nombre, direccion, profesion) values (cedula, nombre, direccion, profesion);
end //
delimiter ;

-- 7. Registrar la entrada de un visitante
delimiter //
create procedure registrar_entrada_visitante(in id_empleado int, in id_visitante int, in fecha date)
begin
    insert into registro_visitante (id_empleado, id_visitante, fecha) values (id_empleado, id_visitante, fecha);
end //
delimiter ;

-- 8. Asignar un visitante a un alojamiento
delimiter //
create procedure asignar_alojamiento(in id_visitante int, in id_alojamiento int, in fecha date)
begin
    insert into visitante_alojamiento (id_visitante, id_alojamiento, fecha) values (id_visitante, id_alojamiento, fecha);
end //
delimiter ;

-- 9. Contar visitantes en un parque en un rango de fechas
delimiter //
create procedure contar_visitantes_parque(in id_parque int, in fecha_inicio date, in fecha_fin date)
begin
    select count(distinct rv.id_visitante) as total_visitantes
    from registro_visitante rv
    join empleado e on rv.id_empleado = e.id
    join parque_area pa on e.id = pa.id_area
    where pa.id_parque = id_parque and rv.fecha between fecha_inicio and fecha_fin;
end //
delimiter ;

-- 10. Obtener los alojamientos ocupados en una fecha específica
delimiter //
create procedure alojamientos_ocupados(in fecha_consulta date)
begin
    select id_alojamiento, count(id_visitante) as total_visitantes
    from visitante_alojamiento
    where fecha = fecha_consulta
    group by id_alojamiento;
end //
delimiter ;

-- Procedimientos para Asignación de Personal y Registro de Actividades

-- 11. Registrar un nuevo empleado
delimiter //
create procedure registrar_empleado(in cedula varchar(50), in nombre varchar(100), in direccion varchar(100), in celular varchar(20), in sueldo decimal(10,2), in tipo enum('001', '002', '003', '004'))
begin
    insert into empleado (cedula, nombre, direccion, celular, sueldo, tipo) values (cedula, nombre, direccion, celular, sueldo, tipo);
end //
delimiter ;

-- 12. Asignar un empleado a un área de conservación
delimiter //
create procedure asignar_empleado_area(in id_empleado int, in id_area int, in especialidad varchar(255))
begin
    insert into conservacion_area (id_empleado, id_area, especialidad) values (id_empleado, id_area, especialidad);
end //
delimiter ;


-- 13. Registrar la asignación de un vehículo a un empleado
delimiter //
create procedure asignar_vehiculo(in tipo varchar(50), in marca varchar(50), in id_empleado int)
begin
    insert into vehiculo (tipo, marca, id_empleado) values (tipo, marca, id_empleado);
end //
delimiter ;

-- 14. Obtener la cantidad de empleados asignados a cada parque
delimiter //
create procedure empleados_por_parque()
begin
    select p.nombre as parque, count(distinct ca.id_empleado) as total_empleados
    from parque p
    join parque_area pa on p.id = pa.id_parque
    join conservacion_area ca on pa.id_area = ca.id_area
    group by p.nombre;
end //
delimiter ;

-- 15. Listar empleados por especialidad
delimiter //
create procedure listar_empleados_por_especialidad(in especialidad varchar(255))
begin
    select e.id, e.nombre, e.sueldo, c.especialidad
    from empleado e
    join conservacion_area c on e.id = c.id_empleado
    where c.especialidad = especialidad;
end //
delimiter ;

-- Procedimientos para la Gestión de Presupuestos y Proyectos de Investigación

-- 16. Registrar un nuevo proyecto de investigación
delimiter //
create procedure registrar_proyecto(in nombre varchar(255), in descripcion text, in presupuesto decimal(15,2), in fecha_inicio date, in fecha_fin date)
begin
    insert into proyecto_investigacion (nombre, descripcion, presupuesto, fecha_inicio, fecha_fin) 
    values (nombre, descripcion, presupuesto, fecha_inicio, fecha_fin);
end //
delimiter ;

-- 17. Asignar un investigador a un proyecto
delimiter //
create procedure asignar_investigador_proyecto(in id_proyecto int, in id_empleado int)
begin
    insert into investigador_proyecto (id_proyecto, id_empleado) values (id_proyecto, id_empleado);
end //
delimiter ;

-- 18. Obtener el presupuesto total de proyectos por año
delimiter //
create procedure presupuesto_proyectos_por_anio(in anio int)
begin
    select year(fecha_inicio) as año, sum(presupuesto) as total_presupuesto
    from proyecto_investigacion
    where year(fecha_inicio) = anio
    group by año;
end //
delimiter ;

-- 19. Contar proyectos activos
delimiter //
create procedure contar_proyectos_activos()
begin
    select count(*) as proyectos_activos
    from proyecto_investigacion
    where fecha_fin > curdate();
end //
delimiter ;


-- 20. Obtener proyectos con más de tres especies estudiadas
delimiter //
create procedure proyectos_con_mas_especies()
begin
    select id_proyecto, count(distinct id_especie) as total_especies
    from proyecto_especie
    group by id_proyecto
    having total_especies > 3;
end //
delimiter ;


