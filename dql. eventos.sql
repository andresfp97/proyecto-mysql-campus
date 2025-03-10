-- 1. reporte semanal de visitantes y alojamientos

delimiter //
create event evt_reporte_visitantes_alojamientos
on schedule every 1 week
starts '2025-03-10 00:00:00'
do
begin
    insert into reporte_visitantes_alojamientos(fecha, total_visitantes, total_alojamientos)
    select curdate(), 
           (select count(*) from visitantes),
           (select count(*) from alojamiento);
end //
delimiter ;

-- 2. actualización semanal del inventario de especies

delimiter //
create event evt_actualizar_inventario_especies
on schedule every 1 week
starts '2025-03-10 01:00:00'
do
begin
    truncate table inventario_especies;
    insert into inventario_especies(id_especie, id_area, total, last_update)
    select id_especie, id_area, cantidad, now()
    from especie_area;
end //
delimiter ;

-- 3. limpieza de log de movimientos de empleados

delimiter //
create event evt_limpiar_log_movimientos_empleado
on schedule every 1 week
starts '2025-03-10 02:00:00'
do
begin
    delete from log_movimientos_empleado
    where fecha < date_sub(now(), interval 1 month);
end //
delimiter ;

-- 4. limpieza de log de parque_area

delimiter //
create event evt_limpiar_log_parque_area
on schedule every 1 week
starts '2025-03-10 03:00:00'
do
begin
    delete from log_parque_area
    where fecha < date_sub(now(), interval 1 month);
end //
delimiter ;

-- 5. limpieza de log de registro_visitante

delimiter //
create event evt_limpiar_log_registro_visitante
on schedule every 1 week
starts '2025-03-10 04:00:00'
do
begin
    delete from log_registro_visitante
    where log_time < date_sub(now(), interval 1 month);
end //
delimiter ;

-- 6. limpieza de log de visitante_alojamiento

delimiter //
create event evt_limpiar_log_visitante_alojamiento
on schedule every 1 week
starts '2025-03-10 05:00:00'
do
begin
    delete from log_visitante_alojamiento
    where log_time < date_sub(now(), interval 1 month);
end //
delimiter ;

-- 7. limpieza de log de investigador_proyecto

delimiter //
create event evt_limpiar_log_investigador_proyecto
on schedule every 1 week
starts '2025-03-10 06:00:00'
do
begin
    delete from log_investigador_proyecto
    where log_time < date_sub(now(), interval 1 month);
end //
delimiter ;

-- 8. limpieza de log de vehiculo

delimiter //
create event evt_limpiar_log_vehiculo
on schedule every 1 week
starts '2025-03-10 07:00:00'
do
begin
    delete from log_vehiculo
    where log_time < date_sub(now(), interval 1 month);
end //
delimiter ;

-- 9. reporte semanal de logs de movimientos de empleados

delimiter //
create event evt_reporte_log_movimientos
on schedule every 1 week
starts '2025-03-10 08:00:00'
do
begin
    insert into reporte_log_movimientos(fecha, total_registros)
    select curdate(), count(*) from log_movimientos_empleado;
end //
delimiter ;

-- 10. reporte semanal de logs de parque_area

delimiter //
create event evt_reporte_log_parque_area
on schedule every 1 week
starts '2025-03-10 09:00:00'
do
begin
    insert into reporte_log_parque_area(fecha, total_registros)
    select curdate(), count(*) from log_parque_area;
end //
delimiter ;

-- 11. reporte semanal de logs de registro_visitante

delimiter //
create event evt_reporte_log_registro_visitante
on schedule every 1 week
starts '2025-03-10 10:00:00'
do
begin
    insert into reporte_log_registro_visitante(fecha, total_registros)
    select curdate(), count(*) from log_registro_visitante;
end //
delimiter ;

-- 12. reporte semanal de logs de visitante_alojamiento
delimiter //
create event evt_reporte_log_visitante_alojamiento
on schedule every 1 week
starts '2025-03-10 11:00:00'
do
begin
    insert into reporte_log_visitante_alojamiento(fecha, total_registros)
    select curdate(), count(*) from log_visitante_alojamiento;
end //
delimiter ;

-- 13. reporte semanal de logs de investigador_proyecto

delimiter //
create event evt_reporte_log_investigador_proyecto
on schedule every 1 week
starts '2025-03-10 12:00:00'
do
begin
    insert into reporte_log_investigador_proyecto(fecha, total_registros)
    select curdate(), count(*) from log_investigador_proyecto;
end //
delimiter ;

-- 14. reporte semanal de logs de vehiculo

delimiter //
create event evt_reporte_log_vehiculo
on schedule every 1 week
starts '2025-03-10 13:00:00'
do
begin
    insert into reporte_log_vehiculo(fecha, total_registros)
    select curdate(), count(*) from log_vehiculo;
end //
delimiter ;

-- 15. reporte semanal de empleados por tipo

delimiter //
create event evt_reporte_empleados_por_tipo
on schedule every 1 week
starts '2025-03-10 14:00:00'
do
begin
    insert into reporte_empleados_por_tipo(fecha, tipo, total)
    select curdate(), tipo, count(*) from empleado group by tipo;
end //
delimiter ;

-- 16. reporte semanal de vehículos por empleado

delimiter //
create event evt_reporte_vehiculos_por_empleado
on schedule every 1 week
starts '2025-03-10 15:00:00'
do
begin
    insert into reporte_vehiculos_por_empleado(fecha, id_empleado, total)
    select curdate(), id_empleado, count(*) from vehiculo group by id_empleado;
end //
delimiter ;

-- 17. reporte semanal de proyectos activos

delimiter //
create event evt_reporte_proyectos_activos
on schedule every 1 week
starts '2025-03-10 16:00:00'
do
begin
    insert into reporte_proyectos_activos(fecha, total_activos)
    select curdate(), count(*) 
    from proyecto_investigacion
    where curdate() between fecha_inicio and fecha_fin;
end //
delimiter ;

-- 18. reporte semanal de visitas (registro de visitante en la última semana)

delimiter //
create event evt_reporte_visitas_semana
on schedule every 1 week
starts '2025-03-10 17:00:00'
do
begin
    insert into reporte_visitas_semana(fecha, total_visitas)
    select curdate(), count(*) 
    from registro_visitante
    where fecha between date_sub(curdate(), interval 7 day) and curdate();
end //
delimiter ;

-- 19. reporte semanal de ocupación de alojamientos

delimiter //
create event evt_reporte_ocupacion_alojamientos
on schedule every 1 week
starts '2025-03-10 18:00:00'
do
begin
    insert into reporte_ocupacion_alojamientos(fecha, id_alojamiento, total_visitas)
    select curdate(), id_alojamiento, count(*)
    from visitante_alojamiento
    group by id_alojamiento;
end //
delimiter ;

-- 20. reporte semanal consolidado

delimiter //
create event evt_reporte_consolidado_semanal
on schedule every 1 week
starts '2025-03-10 19:00:00'
do
begin
    insert into reporte_consolidado_semanal(fecha, total_visitantes, total_alojamientos, total_empleados, total_proyectos)
    select curdate(),
           (select count(*) from visitantes),
           (select count(*) from alojamiento),
           (select count(*) from empleado),
           (select count(*) from proyecto_investigacion where curdate() between fecha_inicio and fecha_fin);
end //
delimiter ;
