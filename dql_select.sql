-- ESTADO ACTUAL DE PARQUES

-- 1 Obtener la cantidad total de parques registrados por entidad responsable.
 
select er.nombre, count(distinct p.id) as "Cantidad de parques"
from departamento_parque dp  
join parque p  on  p.id = dp.id_parque
join departamento d  on d.id  =dp.id_departamento
join entidad_responsable er on  er.id  = d.id_entidad_responsable
group by er.nombre;

-- 2 Listar los parques que tienen una superficie superior al promedio de todas las áreas registradas.

select p.id, p.nombre, SUM(pa.extension) AS total_extension  
from parque p
join parque_area pa ON p.id = pa.id_parque
group by p.id, p.nombre  
having total_extension > (select AVG(extension) from parque_area);
 
-- 3 Determinar los parques que tienen más de uno departamentos asociados.

select p.nombre, count(dp.id_departamento) as cantidad_departamento, group_concat(d.nombre) as departamentos
from departamento_parque dp 
join parque p on p.id  = dp.id_parque
join departamento d  on d.id  = dp.id_departamento 
group  by p.nombre
having cantidad_departamento > 1;

 -- 4 Mostrar el parque con la mayor extensión total sumando todas sus áreas.

 select p.id, p.nombre, sum(pa.extension) as extension_total
 from parque_area pa
 join parque p on p.id =pa.id_parque
 group by p.id, p.nombre
 order by extension_total desc  limit 1;
 
-- 5 Identificar el departamento con la mayor cantidad de parques registrados.
 
 select d.id, d.nombre, count(distinct dp.id_parque) as cantida_parques
 from departamento_parque dp
 join departamento d on d.id = dp.id_departamento
 group by d.id, d.nombre
 order by cantida_parques desc limit 1;

-- 6 Calcular el porcentaje de parques que pertenecen a cada departamento respecto al total.
 
select d.nombre AS departamento, count(dp.id_parque) as total_parques,
    (count(dp.id_parque) * 100.0 / (select count(*) FROM parque)) as porcentaje
from departamento d
join departamento_parque dp on d.id = dp.id_departamento
group by d.nombre
order by porcentaje desc;

-- 7 Obtener los parques que fueron declarados en la misma fecha que el parque más antiguo registrado.

select p.nombre, p.fecha_declaracion
from parque p 
where p.fecha_declaracion = (select min(fecha_declaracion)  from parque);

-- 8  Mostrar la distribución de parques por departamento con un porcentaje de representación.

select d.nombre, count(distinct dp.id_parque) AS cantidad_parques,
    round((count(distinct dp.id_parque) / (select count(distinct id_parque) from departamento_parque) * 100.0),2) as porcentaje
from departamento_parque dp
join departamento d ON d.id = dp.id_departamento
group by d.nombre;

-- 9 Listar los parques que no tienen áreas asignadas.

select p.id, p.nombre 
from parque p
left join parque_area pa  on pa.id_parque = p.id
where  pa.id_parque is null;

-- 10 Determinar el parque con la mayor cantidad de especies registradas.

select p.nombre,  count( distinct ea.id_especie) as cantidad_especies
from  parque_area pa 
join parque p  on p.id  = pa.id_parque
join area a  on a.id = pa.id_area
join especie_area ea  on ea.id_area  = a.id
group by p.nombre
order by cantidad_especies desc limit 1;


-- INVENTARIOS DE ESPECIES

-- 11 Obtener la cantidad de especies diferentes que hay en cada área y su porcentaje respecto al total de especies.

select  a.nombre as area, 
    count(distinct ea.id_especie) AS total_especies, 
    (count(distinct ea.id_especie) * 100.0 / (select count(distinct id) from especie)) as porcentaje
from area a
left join especie_area ea ON a.id = ea.id_area
group by a.nombre
order by porcentaje desc;

-- 12 Listar las especies que están presentes en más de la mitad de las áreas registradas.

 select ea.id_especie, e.nombre_vulgar, count( distinct ea.id_especie) as  cantidad_especie_area
 from especie_area ea
 join especie e  on e.id = ea.id_especie
 group by ea.id_especie , e.nombre_vulgar
 having cantidad_especie_area >= (select count(*) from area)/2;
 
-- 13 Determinar la cantidad total de especies de cada tipo y su representación porcentual.
 
 select e.tipo, count(distinct e.id ) as cantida_por_tipo, 
 round(
 count(distinct e.id ) / (select  count(*) from especie) * 100.00
 ,2) as porcentaje
 from especie e 
 group by e.tipo;

-- 14 Mostrar la especie más común en cada área.
 
select ea.id_area, a.nombre as nombre_area, e.nombre_vulgar, ea.cantidad
from especie_area ea
join especie e ON ea.id_especie = e.id
join area a ON ea.id_area = a.id
where (ea.id_area, ea.cantidad) IN (
    select id_area, MAX(cantidad)
    from especie_area
    group by id_area
)
order by ea.id_area;

-- 15 Obtener las especies cuya cantidad es inferior al 10% del promedio general.
 
select ea.id_especie, e.nombre_vulgar, ea.cantidad
from especie_area ea
join especie e ON ea.id_especie = e.id
where ea.cantidad < (
    select AVG(ea2.cantidad) * 0.1
    from especie_area ea2
);

-- 16 Identificar las especies que aparecen en más de tres proyectos de investigación.

select pe.id_especie, e.nombre_vulgar, COUNT(pe.id_proyecto) AS total_proyectos
from proyecto_especie pe
join especie e on pe.id_especie = e.id
group by pe.id_especie, e.nombre_vulgar
having count(pe.id_proyecto) > 3;


-- 17 Listar las áreas en las que hay más especies animales que vegetales.

select ea.id_area, a.nombre AS nombre_area
from especie_area ea
join especie e ON ea.id_especie = e.id
join area a ON ea.id_area = a.id
group by ea.id_area, a.nombre
having 
    SUM(case when e.tipo = 'animal' then 1 else 0 end) > 
    SUM(case when e.tipo = 'vegetal' then 1 else 0 end);

-- 18 Determinar qué especie tiene la mayor cantidad total registrada en todas las áreas combinadas.

select ea.id_especie, e.nombre_vulgar, SUM(ea.cantidad) AS total_cantidad
from especie_area ea
join especie e on ea.id_especie = e.id
group by ea.id_especie, e.nombre_vulgar
order by total_cantidad desc
limit 1;

-- 19 Mostrar cuántas especies hay en cada parque y ordenarlas de mayor a menor.

select p.id as id_parque, p.nombre as nombre_parque, count(distinct ea.id_especie) AS total_especies
from parque p
join parque_area pa on p.id = pa.id_parque
join especie_area ea on pa.id_area = ea.id_area
group by p.id, p.nombre
order by total_especies DESC;

-- 20 Listar los parques con mayor biodiversidad, considerando la cantidad de especies distintas presentes en cada parque.

select p.id as id_parque, p.nombre as nombre_parque, COUNT(distinct e.id) AS total_especies_distintas
from parque p
join parque_area pa on p.id = pa.id_parque
join especie_area ea on pa.id_area = ea.id_area
join especie e on ea.id_especie = e.id
group by p.id, p.nombre
order by total_especies_distintas desc;

-- 21 Listar los empleados que trabajan en más de una área y su especialidad.

select e.id, e.nombre, e.tipo, c.especialidad, count(c.id_area) as total_areas
from empleado e
join conservacion_area c ON e.id = c.id_empleado
group by e.id, e.nombre, e.tipo, c.especialidad
having count(c.id_area) > 0
order by total_areas desc;

-- 22 Calcular el salario promedio de cada tipo de empleado y compararlo con el sueldo general promedio.

select e.tipo, 
       round(avg(e.sueldo), 2) as salario_promedio_tipo, 
       (select round(avg(sueldo), 2) from empleado) as salario_promedio_general
from empleado e
group by e.tipo
order by salario_promedio_tipo desc;


-- 23 Identificar qué empleados ganan más que el promedio dentro de su misma especialidad.

select e.id, e.nombre, e.tipo, c.especialidad, e.sueldo
from empleado e
join conservacion_area c on e.id = c.id_empleado
where e.sueldo > (
    select avg(e2.sueldo) 
    from empleado e2
    join conservacion_area c2 on e2.id = c2.id_empleado
    where c2.especialidad = c.especialidad
)
order by c.especialidad, e.sueldo desc;


-- 24 Contar la cantidad de empleados por tipo y calcular su porcentaje de representación.

select e.tipo, 
       count(*) as total_empleados, 
       round((count(*) * 100.0) / (select count(*) from empleado), 2) as porcentaje
from empleado e
group by e.tipo
order by total_empleados desc;

-- 25 Listar los empleados que no tienen un vehículo asignado y trabajan en más de un área.

select e.id, e.nombre, e.tipo, count(ca.id_area) as total_areas
from empleado e
join conservacion_area ca on e.id = ca.id_empleado
left join vehiculo v on e.id = v.id_empleado
where v.id is null
group by e.id, e.nombre, e.tipo
having count(ca.id_area) > 0
order by total_areas desc;


-- 26 respuesta corta Mostrar cuántos empleados trabajan en cada proyecto de investigación.

select ip.id_proyecto, pi.nombre as nombre_proyecto, count(ip.id_empleado) as total_empleados
from investigador_proyecto ip
join proyecto_investigacion pi on ip.id_proyecto = pi.id
group by ip.id_proyecto, pi.nombre
order by total_empleados desc;

-- 27 Determinar el empleado que ha estudiado el mayor número de especies en proyectos.

select ip.id_empleado, e.nombre, count(distinct pe.id_especie) as total_especies_estudiadas
from investigador_proyecto ip
join empleado e on ip.id_empleado = e.id
join proyecto_especie pe on ip.id_proyecto = pe.id_proyecto
group by ip.id_empleado, e.nombre
order by total_especies_estudiadas desc
limit 1;

-- 28 Listar los empleados cuyo sueldo es mayor al 75% del total de empleados.

select e.id, e.nombre, e.sueldo
from empleado e
where e.sueldo > (
    select sueldo 
    from (
        select sueldo, 
               row_number() over (order by sueldo) as fila, 
               count(*) over () as total_empleados
        from empleado
    ) as subquery
    where fila = floor(total_empleados * 0.75)
)
order by e.sueldo desc;

-- 29 Identificar qué tipo de empleados presentan la mayor variabilidad salarial.

select e.tipo, 
       round(stddev(e.sueldo), 2) as desviacion_salarial, 
       round(avg(e.sueldo), 2) as salario_promedio
from empleado e
group by e.tipo
order by desviacion_salarial desc;

-- 30 Calcular el salario total de los empleados que participan en proyectos de investigación.

select round(sum(e.sueldo), 2) as salario_total
from empleado e
where e.id in (
    select distinct ip.id_empleado 
    from investigador_proyecto ip
);

--  ESTADÍSTICAS DE PROYECTOS DE INVESTIGACIÓN

-- 31 Contar la cantidad de proyectos de investigación cuyo presupuesto es mayor al promedio.

select count(*) as total_proyectos
from proyecto_investigacion
where presupuesto > (select avg(presupuesto) from proyecto_investigacion);

-- 32 Identificar los proyectos que tienen más de dos especies estudiadas.

select pi.id, pi.nombre, count(distinct pe.id_especie) as total_especies
from proyecto_investigacion pi
join proyecto_especie pe on pi.id = pe.id_proyecto
group by pi.id, pi.nombre
having count(distinct pe.id_especie) > 2
order by total_especies desc;

-- 33 Listar los proyectos finalizados y calcular su presupuesto ajustado por inflación (5% anual).

select pi.id, pi.nombre, pi.presupuesto, pi.fecha_fin,
       round(pi.presupuesto * power(1.05, year(curdate()) - year(pi.fecha_fin)), 2) as presupuesto_ajustado
from proyecto_investigacion pi
where pi.fecha_fin < curdate()
order by pi.fecha_fin desc;

-- 34 Determinar qué proyectos han involucrado la mayor cantidad de investigadores.

select pi.id, pi.nombre, count(distinct ip.id_empleado) as total_investigadores
from proyecto_investigacion pi
join investigador_proyecto ip on pi.id = ip.id_proyecto
group by pi.id, pi.nombre
order by total_investigadores desc;

-- 35 Calcular el presupuesto total de los proyectos agrupados por su año de inicio.

select year(pi.fecha_inicio) as anio, round(sum(pi.presupuesto), 2) as presupuesto_total
from proyecto_investigacion pi
group by anio
order by anio desc;

-- 36  Encontrar el proyecto con el mayor costo por especie estudiada.

select pi.id, pi.nombre, pi.presupuesto, count(distinct pe.id_especie) as total_especies,
       round(pi.presupuesto / count(distinct pe.id_especie), 2) as costo_por_especie
from proyecto_investigacion pi
join proyecto_especie pe on pi.id = pe.id_proyecto
group by pi.id, pi.nombre, pi.presupuesto
order by costo_por_especie desc
limit 1;

 -- 37 Identificar los proyectos que han investigado especies presentes en más de cinco áreas diferentes.

select pi.id, pi.nombre, count(distinct ea.id_area) as total_areas
from proyecto_investigacion pi
join proyecto_especie pe on pi.id = pe.id_proyecto
join especie_area ea on pe.id_especie = ea.id_especie
group by pi.id, pi.nombre
having total_areas > 5
order by total_areas desc;

-- 38 Listar los investigadores que han participado en más de tres proyectos.

select e.id, e.nombre, count(distinct ip.id_proyecto) as total_proyectos
from investigador_proyecto ip
join empleado e on ip.id_empleado = e.id
group by e.id, e.nombre
having total_proyectos > 3
order by total_proyectos desc;

-- 39 Calcular el porcentaje de proyectos que aún están activos.

select round(
    (select count(*) from proyecto_investigacion where fecha_fin > curdate()) * 100.0 / 
    (select count(*) from proyecto_investigacion), 2
) as porcentaje_activos;

-- 40 Identificar qué investigador ha participado en más proyectos.

select e.id, e.nombre, count(ip.id_proyecto) as total_proyectos
from investigador_proyecto ip
join empleado e on ip.id_empleado = e.id
group by e.id, e.nombre
order by total_proyectos desc
limit 1;

-- GESTIÓN DE VISITANTES Y OCUPACIÓN DE ALOJAMIENTOS

-- 41 Calcular el promedio de visitantes por parque en cada mes del año.

select p.id as id_parque, p.nombre as nombre_parque, 
       month(rv.fecha) as mes, 
       round(avg(count(rv.id_visitante)) over (partition by p.id, month(rv.fecha)), 2) as promedio_visitantes
from registro_visitante rv
join empleado e on rv.id_empleado = e.id
join parque_area pa on e.id = pa.id_area
join parque p on pa.id_parque = p.id
group by p.id, p.nombre, mes
order by p.id, mes;

-- 42 Identificar los visitantes que han visitado más de tres parques diferentes.

select rv.id_visitante, v.nombre, count(distinct pa.id_parque) as total_parques
from registro_visitante rv
join visitantes v on rv.id_visitante = v.id
join empleado e on rv.id_empleado = e.id
join parque_area pa on e.id = pa.id_area
group by rv.id_visitante, v.nombre
having total_parques > 3
order by total_parques desc;

-- 43 Listar los visitantes que han sido registrados por más de un empleado.

select rv.id_visitante, v.nombre, count(distinct rv.id_empleado) as total_empleados
from registro_visitante rv
join visitantes v on rv.id_visitante = v.id
group by rv.id_visitante, v.nombre
having total_empleados > 1
order by total_empleados desc;

-- 44 Mostrar los visitantes que han ocupado alojamientos más de cinco veces en el último año.

select va.id_visitante, v.nombre, count(*) as total_ocupaciones
from visitante_alojamiento va
join visitantes v on va.id_visitante = v.id
where va.fecha >= date_sub(curdate(), interval 1 year)
group by va.id_visitante, v.nombre
having total_ocupaciones > 5
order by total_ocupaciones desc;

-- 45 Calcular la tasa de ocupación promedio de los alojamientos en cada parque.

select a.id_parque, p.nombre as nombre_parque, 
       round(avg((select count(*) from visitante_alojamiento va where va.id_alojamiento = a.id) / a.capacidad) * 100, 2) as tasa_ocupacion
from alojamiento a
join parque p on a.id_parque = p.id
group by a.id_parque, p.nombre
order by tasa_ocupacion desc;

-- 46 Determinar qué porcentaje de visitantes ha ocupado un alojamiento respecto al total de visitantes.

select round(
    (select count(distinct id_visitante) from visitante_alojamiento) * 100.0 / 
    (select count(*) from visitantes), 2
) as porcentaje_ocupacion;

-- 47 Obtener los alojamientos más frecuentados en cada parque.

select a.id, a.categoria, a.id_parque, p.nombre as nombre_parque, count(va.id_visitante) as total_ocupaciones
from alojamiento a
join visitante_alojamiento va on a.id = va.id_alojamiento
join parque p on a.id_parque = p.id
group by a.id, a.categoria, a.id_parque, p.nombre
order by total_ocupaciones desc;

-- 48 Identificar en qué mes del año se registra la mayor cantidad de visitas a los parques.

select month(rv.fecha) as mes, count(rv.id_visitante) as total_visitas
from registro_visitante rv
group by mes
order by total_visitas desc
limit 1;

-- 49 Determinar los visitantes que han visitado parques en cada uno de los últimos tres años.

select rv.id_visitante, v.nombre, count(distinct year(rv.fecha)) as anios_visitados
from registro_visitante rv
join visitantes v on rv.id_visitante = v.id
where year(rv.fecha) >= year(curdate()) - 2
group by rv.id_visitante, v.nombre
having anios_visitados = 3;

-- 50 Contar cuántos visitantes han sido registrados más de una vez en un mismo parque.

select count(*) as total_visitantes_recurrentes
from (
    select rv.id_visitante, pa.id_parque, count(*) as total_visitas
    from registro_visitante rv
    join empleado e on rv.id_empleado = e.id
    join parque_area pa on e.id = pa.id_area
    group by rv.id_visitante, pa.id_parque
    having total_visitas > 1
) as subquery;

--  CONSULTAS COMPLEJAS Y OPTIMIZADAS

-- 51 Determinar qué parque tiene la mayor diversidad de especies en relación con su superficie total.

select p.id, p.nombre, count(distinct ea.id_especie) / sum(pa.extension) as diversidad_por_superficie
from parque p
join parque_area pa on p.id = pa.id_parque
join especie_area ea on pa.id_area = ea.id_area
group by p.id, p.nombre
order by diversidad_por_superficie desc
limit 1;

-- 52 Calcular la extensión promedio de las áreas en cada parque y listar las que están por encima del promedio.

select p.id, p.nombre, avg(pa.extension) as extension_promedio
from parque p
join parque_area pa on p.id = pa.id_parque
group by p.id, p.nombre
having avg(pa.extension) > (select avg(extension) from parque_area)
order by extension_promedio desc;

-- 53 Identificar qué parque tiene la mayor concentración de especies de tipo animal.

select p.id, p.nombre, count(distinct ea.id_especie) as total_especies_animales
from parque p
join parque_area pa on p.id = pa.id_parque
join especie_area ea on pa.id_area = ea.id_area
join especie e on ea.id_especie = e.id
where e.tipo = 'animal'
group by p.id, p.nombre
order by total_especies_animales desc
limit 1;

-- 54 Listar las especies que aparecen en al menos dos áreas y han sido estudiadas en proyectos.

select ea.id_especie, e.nombre_vulgar, count(distinct ea.id_area) as total_areas
from especie_area ea
join especie e on ea.id_especie = e.id
join proyecto_especie pe on ea.id_especie = pe.id_especie
group by ea.id_especie, e.nombre_vulgar
having total_areas >= 2
order by total_areas desc;

-- 55 Calcular el porcentaje de visitantes recurrentes en cada parque.

select pa.id_parque, p.nombre as nombre_parque, 
       round(count(distinct rv.id_visitante) * 100.0 / (select count(distinct id_visitante) from registro_visitante), 2) as porcentaje_recurrentes
from registro_visitante rv
join empleado e on rv.id_empleado = e.id
join parque_area pa on e.id = pa.id_area
join parque p on pa.id_parque = p.id
group by pa.id_parque, p.nombre
order by porcentaje_recurrentes desc;

-- 56 Identificar el parque que ha registrado la mayor cantidad de visitantes únicos en el último año.

select pa.id_parque, p.nombre, count(distinct rv.id_visitante) as total_visitantes_unicos
from registro_visitante rv
join empleado e on rv.id_empleado = e.id
join parque_area pa on e.id = pa.id_area
join parque p on pa.id_parque = p.id
where rv.fecha >= date_sub(curdate(), interval 1 year)
group by pa.id_parque, p.nombre
order by total_visitantes_unicos desc
limit 1;

-- 57 Determinar las especialidades de empleados más comunes en los proyectos de investigación.

select c.especialidad, count(distinct ip.id_empleado) as total_empleados
from investigador_proyecto ip
join conservacion_area c on ip.id_empleado = c.id_empleado
group by c.especialidad
order by total_empleados desc;

-- 58 Contar cuántos vehículos están asignados a empleados por marca y tipo.

select v.marca, v.tipo, count(*) as total_vehiculos
from vehiculo v
group by v.marca, v.tipo
order by total_vehiculos desc;

-- 59 Mostrar la distribución de empleados por tipo de contrato en proyectos de investigación.

select e.tipo, count(distinct ip.id_empleado) as total_empleados
from investigador_proyecto ip
join empleado e on ip.id_empleado = e.id
group by e.tipo
order by total_empleados desc;

-- 60 Identificar los proyectos que han investigado especies en más de tres parques.

select pe.id_proyecto, pi.nombre, count(distinct pa.id_parque) as total_parques
from proyecto_especie pe
join proyecto_investigacion pi on pe.id_proyecto = pi.id
join especie_area ea on pe.id_especie = ea.id_especie
join parque_area pa on ea.id_area = pa.id_area
group by pe.id_proyecto, pi.nombre
having total_parques > 3
order by total_parques desc;

-- 61 Calcular el porcentaje de visitantes que han visitado al menos dos parques en un año.

select round(
    (select count(distinct id_visitante) from (
        select rv.id_visitante, count(distinct pa.id_parque) as total_parques
        from registro_visitante rv
        join empleado e on rv.id_empleado = e.id
        join parque_area pa on e.id = pa.id_area
        where year(rv.fecha) = year(curdate())
        group by rv.id_visitante
        having total_parques >= 2
    ) as subquery) * 100.0 / (select count(distinct id_visitante) from registro_visitante), 2
) as porcentaje_visitantes_multiplos;

-- 62 Identificar el visitante con la mayor cantidad de registros de entrada en parques.

select rv.id_visitante, v.nombre, count(rv.id) as total_registros
from registro_visitante rv
join visitantes v on rv.id_visitante = v.id
group by rv.id_visitante, v.nombre
order by total_registros desc
limit 1;

-- 63 Listar los empleados que han trabajado en más de tres áreas diferentes.

select e.id, e.nombre, count(distinct ca.id_area) as total_areas
from empleado e
join conservacion_area ca on e.id = ca.id_empleado
group by e.id, e.nombre
having total_areas > 3
order by total_areas desc;

-- 64 Determinar qué parque tiene la mayor superficie en relación con su cantidad de especies.

select p.id, p.nombre, sum(pa.extension) / count(distinct ea.id_especie) as superficie_por_especie
from parque p
join parque_area pa on p.id = pa.id_parque
join especie_area ea on pa.id_area = ea.id_area
group by p.id, p.nombre
order by superficie_por_especie desc
limit 1;

-- 65 Identificar el proyecto con el mayor retorno de inversión considerando especies investigadas y presupuesto.

select pi.id, pi.nombre, pi.presupuesto, count(distinct pe.id_especie) as total_especies,
       round(count(distinct pe.id_especie) / pi.presupuesto, 5) as retorno_inversion
from proyecto_investigacion pi
join proyecto_especie pe on pi.id = pe.id_proyecto
group by pi.id, pi.nombre, pi.presupuesto
order by retorno_inversion desc
limit 1;

-- 66 Mostrar los parques con la mayor proporción de empleados por hectárea.

select p.id, p.nombre, count(distinct e.id) / sum(pa.extension) as empleados_por_hectarea
from parque p
join parque_area pa on p.id = pa.id_parque
join conservacion_area ca on pa.id_area = ca.id_area
join empleado e on ca.id_empleado = e.id
group by p.id, p.nombre
order by empleados_por_hectarea desc;

-- 67 Analizar la relación entre la cantidad de investigadores y el éxito de los proyectos.

select pi.id, pi.nombre, count(distinct ip.id_empleado) as total_investigadores, pi.presupuesto
from proyecto_investigacion pi
join investigador_proyecto ip on pi.id = ip.id_proyecto
group by pi.id, pi.nombre, pi.presupuesto
order by total_investigadores desc;

-- 68 Evaluar el impacto de los proyectos en la diversidad de especies en cada parque.

select pa.id_parque, p.nombre, count(distinct pe.id_especie) as especies_estudiadas
from proyecto_especie pe
join especie_area ea on pe.id_especie = ea.id_especie
join parque_area pa on ea.id_area = pa.id_area
join parque p on pa.id_parque = p.id
group by pa.id_parque, p.nombre
order by especies_estudiadas desc;

-- 69 Listar los visitantes que han ocupado la mayoría de los alojamientos disponibles en un parque.

select va.id_visitante, v.nombre, count(distinct va.id_alojamiento) as total_alojamientos
from visitante_alojamiento va
join visitantes v on va.id_visitante = v.id
group by va.id_visitante, v.nombre
order by total_alojamientos desc;

-- 70 Identificar los parques con la mayor actividad de investigación en relación con su tamaño.

select pa.id_parque, p.nombre, count(distinct pi.id) / sum(pa.extension) as proyectos_por_hectarea
from parque_area pa
join parque p on pa.id_parque = p.id
join especie_area ea on pa.id_area = ea.id_area
join proyecto_especie pe on ea.id_especie = pe.id_especie
join proyecto_investigacion pi on pe.id_proyecto = pi.id
group by pa.id_parque, p.nombre
order by proyectos_por_hectarea desc;

-- 71 Calcular el porcentaje de especies en peligro de extinción en cada parque.

select pa.id_parque, p.nombre as nombre_parque,
       round((count(distinct ea.id_especie) * 100.0) / (select count(distinct id_especie) from especie_area), 2) as porcentaje_especies_en_peligro
from parque_area pa
join parque p on pa.id_parque = p.id
join especie_area ea on pa.id_area = ea.id_area
join especie e on ea.id_especie = e.id
where e.tipo = 'animal' and e.nombre_vulgar like '%en peligro%'
group by pa.id_parque, p.nombre
order by porcentaje_especies_en_peligro desc;

-- 72 Determinar qué parque tiene la mayor cantidad de especies vegetales registradas.

select pa.id_parque, p.nombre, count(distinct ea.id_especie) as total_especies_vegetales
from parque_area pa
join parque p on pa.id_parque = p.id
join especie_area ea on pa.id_area = ea.id_area
join especie e on ea.id_especie = e.id
where e.tipo = 'vegetal'
group by pa.id_parque, p.nombre
order by total_especies_vegetales desc
limit 1;

-- 73 Calcular la cantidad total de visitantes por año en cada parque.

select pa.id_parque, p.nombre, year(rv.fecha) as anio, count(distinct rv.id_visitante) as total_visitantes
from registro_visitante rv
join empleado e on rv.id_empleado = e.id
join parque_area pa on e.id = pa.id_area
join parque p on pa.id_parque = p.id
group by pa.id_parque, p.nombre, anio
order by anio desc, total_visitantes desc;

-- 74 Identificar la especie más estudiada en proyectos de investigación.

select e.id, e.nombre_vulgar, count(distinct pe.id_proyecto) as total_proyectos
from proyecto_especie pe
join especie e on pe.id_especie = e.id
group by e.id, e.nombre_vulgar
order by total_proyectos desc
limit 1;

-- 75 Contar la cantidad de alojamientos disponibles en cada parque según su categoría.

select a.id_parque, p.nombre, a.categoria, count(*) as total_alojamientos
from alojamiento a
join parque p on a.id_parque = p.id
group by a.id_parque, p.nombre, a.categoria
order by total_alojamientos desc;

-- 76 Calcular el promedio de empleados por parque en relación con su extensión.

select pa.id_parque, p.nombre, round(count(distinct e.id) / sum(pa.extension), 2) as empleados_por_hectarea
from parque_area pa
join parque p on pa.id_parque = p.id
join conservacion_area ca on pa.id_area = ca.id_area
join empleado e on ca.id_empleado = e.id
group by pa.id_parque, p.nombre
order by empleados_por_hectarea desc;

-- 77 Determinar el proyecto con mayor impacto en especies investigadas.

select pi.id, pi.nombre, count(distinct pe.id_especie) as total_especies_investigadas
from proyecto_investigacion pi
join proyecto_especie pe on pi.id = pe.id_proyecto
group by pi.id, pi.nombre
order by total_especies_investigadas desc
limit 1;

-- 78 Mostrar los investigadores con mayor experiencia en proyectos de conservación.

select e.id, e.nombre, count(distinct ip.id_proyecto) as total_proyectos
from investigador_proyecto ip
join empleado e on ip.id_empleado = e.id
where e.tipo = '001'
group by e.id, e.nombre
order by total_proyectos desc;

-- 79 Identificar el parque con la mayor cantidad de proyectos de investigación.

select pa.id_parque, p.nombre, count(distinct pi.id) as total_proyectos
from parque_area pa
join parque p on pa.id_parque = p.id
join especie_area ea on pa.id_area = ea.id_area
join proyecto_especie pe on ea.id_especie = pe.id_especie
join proyecto_investigacion pi on pe.id_proyecto = pi.id
group by pa.id_parque, p.nombre
order by total_proyectos desc
limit 1;

-- 80 Listar los visitantes que han estado en más de un parque en un solo mes.

select rv.id_visitante, v.nombre, year(rv.fecha) as anio, month(rv.fecha) as mes, count(distinct pa.id_parque) as total_parques
from registro_visitante rv
join visitantes v on rv.id_visitante = v.id
join empleado e on rv.id_empleado = e.id
join parque_area pa on e.id = pa.id_area
group by rv.id_visitante, v.nombre, anio, mes
having total_parques > 1
order by total_parques desc;

-- 81 Calcular la relación entre la cantidad de vehículos y empleados.

select round(
    (select count(*) from vehiculo) * 100.0 / 
    (select count(*) from empleado), 2
) as porcentaje_vehiculos_por_empleado;

-- 82 Determinar qué especies han sido avistadas en todos los parques.

select ea.id_especie, e.nombre_vulgar, count(distinct pa.id_parque) as total_parques
from especie_area ea
join especie e on ea.id_especie = e.id
join parque_area pa on ea.id_area = pa.id_area
group by ea.id_especie, e.nombre_vulgar
having total_parques = (select count(*) from parque)
order by total_parques desc;

-- 83 Contar los visitantes que han realizado más de 10 visitas en un solo año.

select rv.id_visitante, v.nombre, year(rv.fecha) as anio, count(*) as total_visitas
from registro_visitante rv
join visitantes v on rv.id_visitante = v.id
group by rv.id_visitante, v.nombre, anio
having total_visitas > 10
order by total_visitas desc;

-- 84 Determinar la cantidad de empleados en proyectos que han trabajado en más de un área.

select ip.id_empleado, e.nombre, count(distinct ca.id_area) as total_areas
from investigador_proyecto ip
join empleado e on ip.id_empleado = e.id
join conservacion_area ca on e.id = ca.id_empleado
group by ip.id_empleado, e.nombre
having total_areas > 1
order by total_areas desc;

-- 85 Calcular la media de visitantes por día en cada parque.

select pa.id_parque, p.nombre, round(avg(count(rv.id_visitante)) over (partition by pa.id_parque, rv.fecha), 2) as promedio_diario
from registro_visitante rv
join empleado e on rv.id_empleado = e.id
join parque_area pa on e.id = pa.id_area
join parque p on pa.id_parque = p.id
group by pa.id_parque, p.nombre, rv.fecha
order by promedio_diario desc;

-- 86 Determinar qué parque tiene la mayor tasa de visitantes por hectárea.

select pa.id_parque, p.nombre, count(distinct rv.id_visitante) / sum(pa.extension) as visitantes_por_hectarea
from parque_area pa
join parque p on pa.id_parque = p.id
join registro_visitante rv on pa.id_parque = rv.id
group by pa.id_parque, p.nombre
order by visitantes_por_hectarea desc
limit 1;

-- 87 Determinar el impacto de la conservación en la recuperación de especies.

select e.nombre_vulgar, count(distinct pi.id) as total_proyectos, sum(ea.cantidad) as cantidad_total
from proyecto_especie pe
join proyecto_investigacion pi on pe.id_proyecto = pi.id
join especie e on pe.id_especie = e.id
join especie_area ea on e.id = ea.id_especie
group by e.nombre_vulgar
order by total_proyectos desc;

-- 88 Identificar el empleado con la mayor cantidad de registros de visitantes en el último año.

select rv.id_empleado, e.nombre, count(rv.id) as total_registros
from registro_visitante rv
join empleado e on rv.id_empleado = e.id
where rv.fecha >= date_sub(curdate(), interval 1 year)
group by rv.id_empleado, e.nombre
order by total_registros desc
limit 1;

-- 89 Determinar el proyecto con el mayor número de áreas involucradas.

select pi.id, pi.nombre, count(distinct ea.id_area) as total_areas
from proyecto_investigacion pi
join proyecto_especie pe on pi.id = pe.id_proyecto
join especie_area ea on pe.id_especie = ea.id_especie
group by pi.id, pi.nombre
order by total_areas desc
limit 1;

-- 90 Calcular el número de visitantes promedio por tipo de alojamiento en cada parque.

select a.id_parque, p.nombre as nombre_parque, a.categoria,
       round(avg(count(va.id_visitante)) over (partition by a.id_parque, a.categoria), 2) as promedio_visitantes
from visitante_alojamiento va
join alojamiento a on va.id_alojamiento = a.id
join parque p on a.id_parque = p.id
group by a.id_parque, p.nombre, a.categoria
order by promedio_visitantes desc;

-- 91 Identificar qué especie tiene la mayor cantidad de individuos en los parques.

select e.id, e.nombre_vulgar, sum(ea.cantidad) as total_individuos
from especie_area ea
join especie e on ea.id_especie = e.id
group by e.id, e.nombre_vulgar
order by total_individuos desc
limit 1;

-- 92 Calcular el número de visitantes únicos en cada parque en los últimos 6 meses.

select pa.id_parque, p.nombre, count(distinct rv.id_visitante) as total_visitantes
from registro_visitante rv
join empleado e on rv.id_empleado = e.id
join parque_area pa on e.id = pa.id_area
join parque p on pa.id_parque = p.id
where rv.fecha >= date_sub(curdate(), interval 6 month)
group by pa.id_parque, p.nombre
order by total_visitantes desc;

-- 93 Listar los empleados que han trabajado en más de un parque.

select e.id, e.nombre, count(distinct pa.id_parque) as total_parques
from empleado e
join conservacion_area ca on e.id = ca.id_empleado
join parque_area pa on ca.id_area = pa.id_area
group by e.id, e.nombre
having total_parques > 1
order by total_parques desc;

-- 94 Determinar la distribución de visitantes por profesión en los parques.

select v.profesion, count(distinct rv.id_visitante) as total_visitantes
from registro_visitante rv
join visitantes v on rv.id_visitante = v.id
group by v.profesion
order by total_visitantes desc;

-- 95 Contar visitantes por profesión en cada parque

select pa.id_parque, p.nombre as nombre_parque, 
       v.profesion, count(distinct rv.id_visitante) as total_visitantes
from registro_visitante rv
join visitantes v on rv.id_visitante = v.id
join parque_area pa on rv.id_empleado = pa.id_area
join parque p on pa.id_parque = p.id
group by pa.id_parque, p.nombre, v.profesion
order by pa.id_parque, total_visitantes desc;


-- 96  Calcular el número total de visitantes por parque

select pa.id_parque, p.nombre as nombre_parque,
       count(distinct rv.id_visitante) as total_visitantes
from registro_visitante rv
join visitantes v on rv.id_visitante = v.id
join parque_area pa on rv.id_empleado = pa.id_area
join parque p on pa.id_parque = p.id
group by pa.id_parque, p.nombre
order by total_visitantes desc;


-- 97 Listar los visitantes que han realizado visitas en los últimos cinco años consecutivos.

select rv.id_visitante, v.nombre, count(distinct year(rv.fecha)) as total_años
from registro_visitante rv
join visitantes v on rv.id_visitante = v.id
where year(rv.fecha) >= year(curdate()) - 4
group by rv.id_visitante, v.nombre
having total_años = 5
order by total_años desc;

-- 98 Determinar qué parque tiene la mayor cantidad de visitantes en días festivos.

select pa.id_parque, p.nombre, count(distinct rv.id_visitante) as total_visitantes_festivos
from registro_visitante rv
join empleado e on rv.id_empleado = e.id
join parque_area pa on e.id = pa.id_area
join parque p on pa.id_parque = p.id
where dayofweek(rv.fecha) in (1, 7) -- Domingo y sábado
group by pa.id_parque, p.nombre
order by total_visitantes_festivos desc
limit 1;

-- 99  Consulta corregida para evaluar el impacto de los programas educativos en la conservación del parque

select pi.id, pi.nombre, 
       count(distinct pe.id_especie) as especies_beneficiadas,
       round(pi.presupuesto / count(distinct pe.id_especie), 2) as presupuesto_por_especie
from proyecto_investigacion pi
join proyecto_especie pe on pi.id = pe.id_proyecto
where pi.nombre like '%educativo%' -- Filtra solo proyectos educativos
group by pi.id, pi.nombre, pi.presupuesto
order by especies_beneficiadas desc;


-- 100 Identificar qué parque tiene la mayor cantidad de especies endémicas.

select pa.id_parque, p.nombre, count(distinct e.id) as total_especies_endemicas
from parque_area pa
join parque p on pa.id_parque = p.id
join especie_area ea on pa.id_area = ea.id_area
join especie e on ea.id_especie = e.id
where e.nombre_vulgar like '%endémica%'
group by pa.id_parque, p.nombre
order by total_especies_endemicas desc
limit 1;






























