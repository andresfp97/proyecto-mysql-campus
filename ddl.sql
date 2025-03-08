create database parque_natural;
use parque_natural;

create table entidad_responsable (
    id int primary key auto_increment,
    nombre varchar(100) not null
);

create table departamento (
    id int primary key auto_increment,
    nombre varchar(100) not null,
    id_entidad_responsable int not null,
    foreign key (id_entidad_responsable) references entidad_responsable(id) on delete cascade
);


create table parque (
    id int primary key auto_increment,
    nombre varchar(100) not null,
    fecha_declaracion date not null
);


create table departamento_parque (
    id_departamento int not null,
    id_parque int not null,
    primary key (id_departamento, id_parque),
    foreign key (id_departamento) references departamento(id) on delete cascade,
    foreign key (id_parque) references parque(id) on delete cascade
);

create table area (
    id int primary key,
    nombre varchar(100) not null
  );

create table parque_area (
    id_parque int,
    id_area int,
    extension int,
    primary key (id_parque, id_area),
    foreign key (id_parque) references parque(id),
    foreign key (id_area) references area(id)
);

create table empleado (
    id integer primary key,
    cedula varchar(50) unique not null,
    nombre varchar(100) not null,
    direccion varchar(100) not null,
    celular varchar(20),
    sueldo decimal(10,2) not null,
    tipo enum('001', '002', '003', '004') not null
);

create table conservacion_area (
    id_empleado int,
    id_area int,
    especialidad varchar(255),
    primary key (id_empleado, id_area),
    foreign key (id_empleado) references empleado(id),
    foreign key (id_area) references area(id)
);

create table vehiculo (
    id int primary key auto_increment,
    tipo varchar(50) not null,
    marca varchar(50) not null,
    id_empleado int,
    foreign key (id_empleado) references empleado(id)
);

create table visitantes (
    id int primary key auto_increment,
    cedula varchar(20) unique not null,
    nombre varchar(255) not null,
    direccion varchar(255),
    profesion varchar(100)
);

create table registro_visitante (
    id int primary key auto_increment,
    id_empleado int,
    id_visitante int,
    fecha date,
    foreign key (id_empleado) references empleado(id),
    foreign key (id_visitante) references visitantes(id)
);

create table alojamiento (
    id int primary key auto_increment,
    id_parque int,
    capacidad int not null,
    categoria varchar(50) not null,
    foreign key (id_parque) references parque(id)
);

create table visitante_alojamiento (
    id_visitante int,
    id_alojamiento int,
    fecha date,
    primary key (id_visitante, id_alojamiento, fecha),
    foreign key (id_visitante) references visitantes(id),
    foreign key (id_alojamiento) references alojamiento(id)
);

create table especie (
    id integer primary key,
    nombre_cientifico varchar(100) not null,
    nombre_vulgar varchar(100) not null,
    tipo enum('vegetal', 'animal', 'mineral') not null
);

create table especie_area (
    id_especie integer not null,
    id_area integer not null,
    cantidad integer not null,
    primary key (id_especie, id_area),
    foreign key (id_especie) references especie(id) on delete cascade,
    foreign key (id_area) references area(id) on delete cascade
);

create table proyecto_investigacion (
    id int primary key auto_increment,
    nombre varchar(255) not null,
    descripcion text,
    presupuesto decimal(15,2),
    fecha_inicio date,
    fecha_fin date
);

create table proyecto_especie (
    id_proyecto int,
    id_especie int,
    primary key (id_proyecto, id_especie),
    foreign key (id_proyecto) references proyecto_investigacion(id),
    foreign key (id_especie) references especie(id)
);

create table investigador_proyecto (
    id_proyecto int,
    id_empleado int,
    primary key (id_proyecto, id_empleado),
    foreign key (id_proyecto) references proyecto_investigacion(id),
    foreign key (id_empleado) references empleado(id)
);
