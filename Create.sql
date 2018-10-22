--C: cliente - E: empleado
create domain DOM_GR08_rolvalido
as char(1) not null 
check( (value like 'C') or (value like 'E') );

create domain DOM_GR08_fechavalida
as timestamp null 
check ( extract(year from value) > '1916' );

--El formato de DOM_GR08_pisovalido es: X Y
--donde X corresponde al piso
--e Y corresponde al depto
create domain DOM_GR08_pisovalido
as text null
check( value ~ '^(\d+) (\w+)$');

-- 0 : FACTURA
-- 1 : RECIBO
-- 2 : REMITO
create domain DOM_GR08_tcompvalido
as integer not null
check(value = 0 or value = 1 or value = 2);

create sequence seq_factura 
start with 1 
increment by 1
maxvalue 99999
minvalue 1;

create sequence seq_remito
start with 1 
increment by 1
maxvalue 99999
minvalue 1; 

create sequence seq_recibo
start with 1 
increment by 1
maxvalue 99999
minvalue 1;

-- tables
--Table: GR08_PERSONA
CREATE TABLE GR08_PERSONA (
    id_persona int  NOT NULL,
    tipodoc char(1)  NOT NULL,
    nrodoc int  NOT NULL,
    nombre varchar(40)  NOT NULL,
    apellido varchar(40)  NOT NULL,
    fecha_nacimiento DOM_GR08_fechavalida  NOT NULL,
    fecha_baja DOM_GR08_fechavalida  NULL,
    contraseña varchar(40)  NOT NULL,
    activo boolean  NOT NULL,
    telefono_caracteristica numeric(3,0)  NOT NULL,
    telefono_numero varchar(20)  NOT NULL,
    telefono_tipo char(1)  NOT NULL,
    mail varchar(120)  NOT NULL,
    calle varchar(50)  NOT NULL,
    numero int  NOT NULL,
    piso_departamento DOM_GR08_pisovalido  NULL,
    rol DOM_GR08_rolvalido  NOT NULL,
    cod_ciudad int  NOT NULL,
    nombre_usuario varchar(30)  NOT NULL,
    CONSTRAINT PK_GR08_persona PRIMARY KEY (id_persona)
);
-- Table: GR08_COMPROBANTE
CREATE TABLE GR08_COMPROBANTE (
    id_tcomp DOM_GR08_tcompvalido  NOT NULL,
    id_comp bigint  NOT NULL,
    fecha timestamp  NULL,
    comentario varchar(2048)  NOT NULL,
    estado varchar(20)  NULL,
    fecha_vencimiento timestamp  NULL,
    importe decimal(18,5)  NOT NULL,
    tipo_comprobante char(1)  NOT NULL,
    CONSTRAINT PK_GR08_comprobante PRIMARY KEY (id_tcomp,id_comp)
);

-- Table : GR08_LINEA_COMPROBANTE
CREATE TABLE GR08_LINEA_COMPROBANTE (
    nro_linea int  NOT NULL,
    descripcion varchar(80)  NOT NULL,
    cantidad int  NOT NULL,
    importe numeric(18,5)  NOT NULL,
    id_tcomp DOM_GR08_tcompvalido  NOT NULL,
    id_comp bigint  NOT NULL,
    CONSTRAINT PK_GR08_lineacomp PRIMARY KEY (nro_linea,id_tcomp,id_comp)
);

-- Table: GR08_EQUIPO
CREATE TABLE GR08_EQUIPO (
    id_equipo int  NOT NULL,
    nombre varchar(80)  NOT NULL,
    MAC varchar(20)  NULL,
    IP varchar(20)  NULL,
    AP varchar(20)  NULL,
    id_servicio int  NOT NULL,
    id_direccion int  NOT NULL,
    id_persona int  NOT NULL,
    marca varchar(30)  NOT NULL,
    modelo varchar(30)  NOT NULL,
    modo_conexion varchar(30)  NOT NULL,
    asignacion_ip varchar(30)  NOT NULL,
    CONSTRAINT PK_GR08_EQUIPO PRIMARY KEY (id_equipo,id_direccion)
);
-- Table: GR08_COMPROBANTE_CONL
CREATE TABLE GR08_COMPROBANTE_CONL (
    id_tcomp DOM_GR08_tcompvalido  NOT NULL,
    id_comp bigint  NOT NULL,
    id_persona int  NOT NULL,
    CONSTRAINT PK_GR08_COMPROBANTE_CONL PRIMARY KEY (id_tcomp,id_comp)
);

-- Table: GR08_COMPROBANTE_SINL
CREATE TABLE GR08_COMPROBANTE_SINL (
    id_turno int  NOT NULL,
    id_tcomp DOM_GR08_tcompvalido  NOT NULL,
    id_comp bigint  NOT NULL,
    CONSTRAINT PK_GR08_COMPROBANTE_SINL PRIMARY KEY (id_tcomp,id_comp)
);

-- Table: GR08_COMPROBANTE_SINL_TURNO
CREATE TABLE GR08_COMPROBANTE_SINL_TURNO (
    id_persona int  NOT NULL,
    id_tcomp DOM_GR08_tcompvalido  NOT NULL,
    id_comp bigint  NOT NULL,
    id_turno int  NOT NULL,
    CONSTRAINT PK_GR08_COMPROBANTE_SINL_TURNO PRIMARY KEY (id_persona,id_tcomp,id_comp,id_turno)
);

-- Table: GR08_DIRECCION
CREATE TABLE GR08_DIRECCION (
    id_direccion int  NOT NULL,
    calle varchar(50)  NOT NULL,
    numero int  NOT NULL,
    piso int  NULL,
    depto varchar(50)  NULL,
    tipo varchar(20)  NOT NULL,
    cod_barrio int  NOT NULL,
    cod_ciudad int  NOT NULL,
    CONSTRAINT PK_GR08_DIRECCION PRIMARY KEY (id_direccion)
);

-- Table: GR08_EMPLEADO
CREATE TABLE GR08_EMPLEADO (
    id_persona int  NOT NULL,
    fecha_alta date  NOT NULL,
    CONSTRAINT PK_GR08_EMPLEADO PRIMARY KEY (id_persona)
);
-- Table: GR08_CLIENTE
CREATE TABLE GR08_CLIENTE (
    id_persona int  NOT NULL,
    saldo numeric(18,5)  NOT NULL,
    cuit int  NOT NULL,
    id_direccion_facturacion int  NOT NULL,
    CONSTRAINT PK_GR08_CLIENTE PRIMARY KEY (id_persona)
);

-- Table: GR08_SERVICIO
CREATE TABLE GR08_SERVICIO (
    id_servicio int  NOT NULL,
    nombre varchar(80)  NOT NULL,
    periodico boolean  NOT NULL,
    costo numeric(18,3)  NOT NULL,
    inicio_intervalo int  NULL,
    tipo_intervalo varchar(20)  NULL,
    activo boolean  NOT NULL,
    categoria_servicio char(1)  NOT NULL,
    fin_intervalo int  NULL,
    CONSTRAINT CHECK_0 CHECK (( tipo_intervalo in ( 'semana' , 'quincena' , 'mes' , 'bimestre' ) )) NOT DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT PK_GR08_servicio PRIMARY KEY (id_servicio)
);

-- Table: GR08_TIPO_COMPROBANTE
CREATE TABLE GR08_TIPO_COMPROBANTE (
    id_tcomp DOM_GR08_tcompvalido  NOT NULL,
    nombre varchar(30)  NOT NULL,
    CONSTRAINT PK_GR08_tipo_comprobante PRIMARY KEY (id_tcomp)
);

-- Table: GR08_TURNO
CREATE TABLE GR08_TURNO (
    id_turno int  NOT NULL,
    desde timestamp  NOT NULL,
    hasta timestamp  NULL,
    dinero_inicio numeric(18,3)  NOT NULL,
    dinero_fin numeric(18,3)  NULL,
    id_persona int  NOT NULL,
    cod_lugar int  NOT NULL,
    CONSTRAINT PK_GR08_TURNO PRIMARY KEY (id_turno)
);

-- foreign keys
-- Reference: CLIENTE_DIRECCION (table: GR08_CLIENTE)
ALTER TABLE GR08_CLIENTE ADD CONSTRAINT FK_GR08_CLIENTE_DIRECCION
    FOREIGN KEY (id_direccion_facturacion)
    REFERENCES GR08_DIRECCION (id_direccion)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: COMPROBANTE_SINL_TURNO_CLIENTE (table: GR08_COMPROBANTE_SINL_TURNO)
ALTER TABLE GR08_COMPROBANTE_SINL_TURNO ADD CONSTRAINT FK_GR08_COMPROBANTE_SINL_TURNO_CLIENTE
    FOREIGN KEY (id_persona)
    REFERENCES GR08_CLIENTE (id_persona)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: COMPROBANTE_SINL_TURNO_COMPROBANTE (table: GR08_COMPROBANTE_SINL_TURNO)
ALTER TABLE GR08_COMPROBANTE_SINL_TURNO ADD CONSTRAINT FK_GR08_COMPROBANTE_SINL_TURNO_COMPROBANTE
    FOREIGN KEY (id_tcomp, id_comp)
    REFERENCES GR08_COMPROBANTE (id_tcomp, id_comp)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: COMPROBANTE_SINL_TURNO_TURNO (table: GR08_COMPROBANTE_SINL_TURNO)
ALTER TABLE GR08_COMPROBANTE_SINL_TURNO ADD CONSTRAINT FK_GR08_COMPROBANTE_SINL_TURNO_TURNO
    FOREIGN KEY (id_turno)
    REFERENCES GR08_TURNO (id_turno)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_CLIENTE_COMPROBANTE_CONL (table: GR08_COMPROBANTE_CONL)
ALTER TABLE GR08_COMPROBANTE_CONL ADD CONSTRAINT FK_GR08_CLIENTE_COMPROBANTE_CONL
    FOREIGN KEY (id_persona)
    REFERENCES GR08_CLIENTE (id_persona)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_CLIENTE_EQUIPO (table: GR08_EQUIPO)
ALTER TABLE GR08_EQUIPO ADD CONSTRAINT FK_GR08_CLIENTE_EQUIPO
    FOREIGN KEY (id_persona)
    REFERENCES GR08_CLIENTE (id_persona)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_COMPROBANTE_COMPROBANTE_SINL (table: GR08_COMPROBANTE_SINL)
ALTER TABLE GR08_COMPROBANTE_SINL ADD CONSTRAINT FK_GR08_COMPROBANTE_COMPROBANTE_SINL
    FOREIGN KEY (id_tcomp, id_comp)
    REFERENCES GR08_COMPROBANTE (id_tcomp, id_comp)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_COMPROBANTE_CONL_COMPROBANTE (table: GR08_COMPROBANTE_CONL)
ALTER TABLE GR08_COMPROBANTE_CONL ADD CONSTRAINT FK_GR08_COMPROBANTE_CONL_COMPROBANTE
    FOREIGN KEY (id_tcomp, id_comp)
    REFERENCES GR08_COMPROBANTE (id_tcomp, id_comp)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_COMPROBANTE_CONL_LINEA_COMPROBANTE (table: GR08_LINEA_COMPROBANTE)
ALTER TABLE GR08_LINEA_COMPROBANTE ADD CONSTRAINT FK_GR08_COMPROBANTE_CONL_LINEA_COMPROBANTE
    FOREIGN KEY (id_tcomp, id_comp)
    REFERENCES GR08_COMPROBANTE_CONL (id_tcomp, id_comp)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_DIRECCION_EQUIPO (table: GR08_EQUIPO)
ALTER TABLE GR08_EQUIPO ADD CONSTRAINT FK_GR08_DIRECCION_EQUIPO
    FOREIGN KEY (id_direccion)
    REFERENCES GR08_DIRECCION (id_direccion)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_EMPLEADO_TURNO (table: GR08_TURNO)
ALTER TABLE GR08_TURNO ADD CONSTRAINT FK_GR08_EMPLEADO_TURNO
    FOREIGN KEY (id_persona)
    REFERENCES GR08_EMPLEADO (id_persona)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_PERSONA_CLIENTE (table: GR08_CLIENTE)
ALTER TABLE GR08_CLIENTE ADD CONSTRAINT FK_GR08_PERSONA_CLIENTE
    FOREIGN KEY (id_persona)
    REFERENCES GR08_PERSONA (id_persona)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_PERSONA_EMPLEADO (table: GR08_EMPLEADO)
ALTER TABLE GR08_EMPLEADO ADD CONSTRAINT FK_GR08_PERSONA_EMPLEADO
    FOREIGN KEY (id_persona)
    REFERENCES GR08_PERSONA (id_persona)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_SERVICIO_EQUIPO (table: GR08_EQUIPO)
ALTER TABLE GR08_EQUIPO ADD CONSTRAINT FK_GR08_SERVICIO_EQUIPO
    FOREIGN KEY (id_servicio)
    REFERENCES GR08_SERVICIO (id_servicio)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_TIPO_COMPROBANTE_COMPROBANTE (table: GR08_COMPROBANTE)
ALTER TABLE GR08_COMPROBANTE ADD CONSTRAINT FK_GR08_TIPO_COMPROBANTE_COMPROBANTE
    FOREIGN KEY (id_tcomp)
    REFERENCES GR08_TIPO_COMPROBANTE (id_tcomp)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_TURNO_COMPROBANTE_SINL (table: GR08_COMPROBANTE_SINL)
ALTER TABLE GR08_COMPROBANTE_SINL ADD CONSTRAINT FK_GR08_TURNO_COMPROBANTE_SINL
    FOREIGN KEY (id_turno)
    REFERENCES GR08_TURNO (id_turno)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

insert into GR08_TIPO_COMPROBANTE 
values (0, 'Factura'), (1, 'Recibo'), (2, 'Remito');