--  Funciones para Superficie y Distribución de Parques

-- 1. Función para calcular la superficie total de parques por departamento
delimiter //
create function superficie_parques_por_departamento(departamento_id int) 
returns int deterministic
begin
    declare total_superficie int;
    select sum(pa.extension) into total_superficie
    from parque_area pa
    join departamento_parque dp on pa.id_parque = dp.id_parque
    where dp.id_departamento = departamento_id;
    return ifnull(total_superficie, 0);
end //
delimiter ;


-- 2. Función para obtener el número de parques en un departamento
delimiter //
create function cantidad_parques_por_departamento(departamento_id int) 
returns int deterministic
begin
    declare total_parques int;
    select count(distinct dp.id_parque) into total_parques
    from departamento_parque dp
    where dp.id_departamento = departamento_id;
    return total_parques;
end //
delimiter ;

-- 3. Función para calcular el promedio de superficie por parque

delimiter //
create function promedio_superficie_parques() 
returns decimal(10,2) deterministic
begin
    declare promedio decimal(10,2);
    select avg(pa.extension) into promedio
    from parque_area pa;
    return ifnull(promedio, 0);
end //
delimiter ;

-- 4. Función para obtener el parque con la mayor superficie

delimiter //
create function parque_mayor_superficie() 
returns varchar(100) deterministic
begin
    declare nombre_parque varchar(100);
    select p.nombre into nombre_parque
    from parque p
    join parque_area pa on p.id = pa.id_parque
    group by p.id, p.nombre
    order by sum(pa.extension) desc
    limit 1;
    return nombre_parque;
end //
delimiter ;

-- Funciones para Inventarios y Estadísticas de Especies

-- 5. Función para contar la cantidad de especies en un área

delimiter //
create function especies_en_area(area_id int) 
returns int deterministic
begin
    declare total_especies int;
    select count(distinct id_especie) into total_especies
    from especie_area
    where id_area = area_id;
    return total_especies;
end //
delimiter ;


-- 6. Función para calcular la cantidad total de especies por tipo en un parque

delimiter //
create function especies_por_tipo_parque(parque_id int, especie_tipo enum('vegetal', 'animal', 'mineral')) 
returns int deterministic
begin
    declare total int;
    select count(distinct ea.id_especie) into total
    from parque_area pa
    join especie_area ea on pa.id_area = ea.id_area
    join especie e on ea.id_especie = e.id
    where pa.id_parque = parque_id and e.tipo = especie_tipo;
    return total;
end //
delimiter ;


-- 7. Función para calcular la cantidad total de individuos de una especie en todas las áreas

delimiter //
create function cantidad_individuos_especie(especie_id int) 
returns int deterministic
begin
    declare total_individuos int;
    select sum(cantidad) into total_individuos
    from especie_area
    where id_especie = especie_id;
    return ifnull(total_individuos, 0);
end //
delimiter ;

-- 8. Función para calcular el porcentaje de especies animales en un parque
delimiter //
create function porcentaje_especies_animales_parque(parque_id int) 
returns decimal(5,2) deterministic
begin
    declare total_especies int;
    declare total_animales int;
    declare porcentaje decimal(5,2);

    select count(distinct ea.id_especie) into total_especies
    from parque_area pa
    join especie_area ea on pa.id_area = ea.id_area
    where pa.id_parque = parque_id;

    select count(distinct ea.id_especie) into total_animales
    from parque_area pa
    join especie_area ea on pa.id_area = ea.id_area
    join especie e on ea.id_especie = e.id
    where pa.id_parque = parque_id and e.tipo = 'animal';

    if total_especies > 0 then
        set porcentaje = (total_animales * 100.0) / total_especies;
    else
        set porcentaje = 0;
    end if;

    return porcentaje;
end //
delimiter ;


-- 9. Función para contar las especies estudiadas en un proyecto

delimiter //
create function especies_en_proyecto(proyecto_id int) 
returns int deterministic
begin
    declare total int;
    select count(distinct id_especie) into total
    from proyecto_especie
    where id_proyecto = proyecto_id;
    return total;
end //
delimiter ;

-- Funciones para Cálculo de Costos Operativos de Proyectos

-- 10. Función para calcular el costo total de un proyecto de investigación

delimiter //
create function costo_total_proyecto(proyecto_id int) 
returns decimal(15,2) deterministic
begin
    declare costo_total decimal(15,2);
    select presupuesto into costo_total
    from proyecto_investigacion
    where id = proyecto_id;
    return ifnull(costo_total, 0);
end //
delimiter ;

-- 11 . Función para calcular el costo promedio de los proyectos en un año específico

delimiter //
create function costo_promedio_proyectos(anio int) 
returns decimal(15,2) deterministic
begin
    declare promedio decimal(15,2);
    select avg(presupuesto) into promedio
    from proyecto_investigacion
    where year(fecha_inicio) = anio;
    return ifnull(promedio, 0);
end //
delimiter ;

-- 12. Función para calcular el presupuesto total invertido en proyectos de investigación por parque

delimiter //
create function presupuesto_proyectos_parque(parque_id int) 
returns decimal(15,2) deterministic
begin
    declare total_presupuesto decimal(15,2);
    select sum(pi.presupuesto) into total_presupuesto
    from proyecto_investigacion pi
    join proyecto_especie pe on pi.id = pe.id_proyecto
    join especie_area ea on pe.id_especie = ea.id_especie
    join parque_area pa on ea.id_area = pa.id_area
    where pa.id_parque = parque_id;
    return ifnull(total_presupuesto, 0);
end //
delimiter ;

-- 13. Función para obtener el año con mayor inversión en proyectos

delimiter //
create function anio_mayor_inversion() 
returns int deterministic
begin
    declare anio_max int;
    select year(fecha_inicio) into anio_max
    from proyecto_investigacion
    group by year(fecha_inicio)
    order by sum(presupuesto) desc
    limit 1;
    return anio_max;
end //
delimiter ;


-- 14. Función para calcular el costo promedio por investigador en un proyecto

delimiter //
create function costo_por_investigador(proyecto_id int) 
returns decimal(15,2) deterministic
begin
    declare total_presupuesto decimal(15,2);
    declare total_investigadores int;
    declare costo_unitario decimal(15,2);

    select presupuesto into total_presupuesto
    from proyecto_investigacion
    where id = proyecto_id;

    select count(distinct id_empleado) into total_investigadores
    from investigador_proyecto
    where id_proyecto = proyecto_id;

    if total_investigadores > 0 then
        set costo_unitario = total_presupuesto / total_investigadores;
    else
        set costo_unitario = 0;
    end if;

    return costo_unitario;
end //
delimiter ; 

-- Funciones para Estadísticas de Visitantes y Alojamiento

-- 15. Función para contar la cantidad de visitantes registrados en un parque en un rango de fechas

delimiter //
create function visitantes_por_parque_rango(parque_id int, fecha_inicio date, fecha_fin date) 
returns int deterministic
begin
    declare total_visitantes int;
    select count(distinct rv.id_visitante) into total_visitantes
    from registro_visitante rv
    join empleado e on rv.id_empleado = e.id
    join parque_area pa on e.id = pa.id_area
    where pa.id_parque = parque_id and rv.fecha between fecha_inicio and fecha_fin;
    return total_visitantes;
end //
delimiter ;

-- 16. Función para calcular la tasa de ocupación de un alojamiento

delimiter //
create function tasa_ocupacion_alojamiento(alojamiento_id int) 
returns decimal(5,2) deterministic
begin
    declare ocupacion decimal(5,2);
    declare capacidad_total int;
    declare visitantes_actuales int;
    
    select capacidad into capacidad_total from alojamiento where id = alojamiento_id;
    select count(id_visitante) into visitantes_actuales from visitante_alojamiento where id_alojamiento = alojamiento_id;
    
    if capacidad_total > 0 then
        set ocupacion = (visitantes_actuales * 100.0) / capacidad_total;
    else
        set ocupacion = 0;
    end if;
    
    return ocupacion;
end //
delimiter ;

-- 17. Función para contar la cantidad de visitantes únicos en un año

delimiter //
create function visitantes_en_anio(anio int) 
returns int deterministic
begin
    declare total int;
    select count(distinct id_visitante) into total
    from registro_visitante
    where year(fecha) = anio;
    return total;
end //
delimiter ;


-- 18. Función para calcular el porcentaje de ocupación total de alojamientos en un parque
delimiter //
create function ocupacion_total_parque(parque_id int) 
returns decimal(5,2) deterministic
begin
    declare total_capacidad int;
    declare ocupacion_actual int;
    declare porcentaje decimal(5,2);

    select sum(capacidad) into total_capacidad
    from alojamiento
    where id_parque = parque_id;

    select count(distinct id_visitante) into ocupacion_actual
    from visitante_alojamiento va
    join alojamiento a on va.id_alojamiento = a.id
    where a.id_parque = parque_id;

    if total_capacidad > 0 then
        set porcentaje = (ocupacion_actual * 100.0) / total_capacidad;
    else
        set porcentaje = 0;
    end if;

    return porcentaje;
end //
delimiter ;

-- Funciones Extras 
-- 19. Función para obtener el alojamiento más ocupado en un parque
delimiter //
create function alojamiento_mas_ocupado(parque_id int) 
returns varchar(100) deterministic
begin
    declare nombre_alojamiento varchar(100);
    select a.categoria into nombre_alojamiento
    from alojamiento a
    join visitante_alojamiento va on a.id = va.id_alojamiento
    where a.id_parque = parque_id
    group by a.id, a.categoria
    order by count(va.id_visitante) desc
    limit 1;
    return nombre_alojamiento;
end //
delimiter ;


-- 20. Función para calcular la cantidad de investigadores en proyectos de un parque
delimiter //
create function investigadores_en_parque(parque_id int) 
returns int deterministic
begin
    declare total int;
    select count(distinct ip.id_empleado) into total
    from investigador_proyecto ip
    join proyecto_especie pe on ip.id_proyecto = pe.id_proyecto
    join especie_area ea on pe.id_especie = ea.id_especie
    join parque_area pa on ea.id_area = pa.id_area
    where pa.id_parque = parque_id;
    return total;
end //
delimiter ;









