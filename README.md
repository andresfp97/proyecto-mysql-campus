# Proyecto: Parque Natural 🌳

## 1. Descripción del Proyecto 🚀
Este proyecto consiste en el diseño e implementación de una base de datos para la gestión de un **Parque Natural**. Se abarca la administración de entidades como parques, departamentos, áreas, especies, empleados, visitantes, alojamientos, vehículos y proyectos de investigación.  
El objetivo principal es centralizar y organizar la información relacionada con la administración de los parques naturales, el control de visitantes, la conservación de áreas y especies, y la gestión del personal y sus funciones.

## 2. Requisitos del Sistema 💻
- **Motor de base de datos:** MySQL (versión 8.0 o superior).
- **Herramienta cliente:** DBeaver (última versión disponible).
- **Sistema Operativo:** Compatible con Windows, Linux y macOS.

## 3. Instalación y Configuración 🔧

1. **Instalar MySQL**  
   Asegurarse de tener MySQL 8.0 (o superior) instalado y corriendo en la máquina local.

2. **Instalar DBeaver**  
   Descargar e instalar la versión más reciente de DBeaver.

3. **Clonar o descargar los archivos del proyecto**  
   - `ddl.sql`  
   - `dml.sql`  
   - `dql_select.sql`  
   - `dql_procedimientos.sql`  
   - `dql_funciones.sql`  
   - `dql_triggers.sql`  
   - `dql_eventos.sql`  
   - `roles.sql`  
   - `diagrama.jpg` (opcional)

4. **Crear la base de datos y las tablas (DDL)**  
   Conectarse a MySQL desde DBeaver y ejecutar `ddl.sql` para crear la base de datos `parque_natural` y sus tablas.

5. **Cargar los datos iniciales (DML)**  
   Ejecutar `dml.sql` para insertar los datos base (departamentos, parques, áreas, empleados, visitantes, etc.).

6. **Ejecutar las consultas (DQL)**  
   Abrir `dql_select.sql` y ejecutar las sentencias para visualizar los resultados.

7. **Procedimientos, Funciones, Triggers y Eventos**  
   Ejecutar en el siguiente orden:
   - `dql_procedimientos.sql`
   - `dql_funciones.sql`
   - `dql_triggers.sql`
   - `dql_eventos.sql`

8. **Creación de roles y asignación de permisos**  
   Ejecutar `roles.sql` para crear los roles de usuario y asignar los permisos correspondientes.

## 4. Estructura de la Base de Datos 🗂️
La base de datos `parque_natural` incluye las siguientes tablas principales:

- **entidad_responsable**
- **departamento**
- **parque**
- **departamento_parque**
- **area**
- **parque_area**
- **empleado**
- **conservacion_area**
- **vehiculo**
- **visitantes**
- **registro_visitante**
- **alojamiento**
- **visitante_alojamiento**
- **especie**
- **especie_area**
- **proyecto_investigacion**
- **proyecto_especie**
- **investigador_proyecto**

## 5. Procedimientos, Funciones, Triggers y Eventos ⚙️
Se han creado procedimientos y funciones para distintas operaciones.  
Se han definido 20 triggers para automatizar acciones.  
Se han creado 20 eventos semanales para generar reportes y realizar limpieza de registros.

## 6. Roles de Usuario y Permisos 🔐
- **administrador**  
  Acceso total.

- **gestor_parques**  
  Gestión de parques, áreas y especies.

- **investigador**  
  Acceso a datos de proyectos y especies (solo lectura).

- **auditor**  
  Acceso a reportes financieros (solo lectura).

- **encargado_visitantes**  
  Gestión de visitantes y alojamientos.

## 7. Contribuciones 🤝
Proyecto desarrollado por **Andrés Portilla**.  


## 8. Licencia y Contacto 📄
**Licencia:** El proyecto puede utilizarse con fines académicos o de aprendizaje.  
**Contacto:** [123andresportilla@gmail.com](mailto:123andresportilla@gmail.com)
