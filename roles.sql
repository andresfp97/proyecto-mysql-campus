-- 1. rol administrador: acceso total
create role 'administrador';
grant all privileges on parque_natural.* to 'administrador';

-- 2. rol gestor de parques: gestión de parques, áreas y especies
create role 'gestor_parques';
grant select, insert, update, delete on parque to 'gestor_parques';
grant select, insert, update, delete on departamento_parque to 'gestor_parques';
grant select, insert, update, delete on area to 'gestor_parques';
grant select, insert, update, delete on parque_area to 'gestor_parques';
grant select, insert, update, delete on especie to 'gestor_parques';
grant select, insert, update, delete on especie_area to 'gestor_parques';

-- 3. rol investigador: acceso a datos de proyectos y especies
create role 'investigador';
grant select on proyecto_investigacion to 'investigador';
grant select on proyecto_especie to 'investigador';
grant select on investigador_proyecto to 'investigador';
grant select on especie to 'investigador';
grant select on especie_area to 'investigador';

-- 4. rol auditor: acceso a reportes financieros
create role 'auditor';
grant select on reporte_financiero to 'auditor';

-- 5. rol encargado de visitantes: gestión de visitantes y alojamientos
create role 'encargado_visitantes';
grant select, insert, update, delete on visitantes to 'encargado_visitantes';
grant select, insert, update, delete on registro_visitante to 'encargado_visitantes';
grant select, insert, update, delete on alojamiento to 'encargado_visitantes';
grant select, insert, update, delete on visitante_alojamiento to 'encargado_visitantes';
