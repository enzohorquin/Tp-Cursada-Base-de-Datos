-----SENTENCIAS DISPARADORAS PARA LOS TRIGGERS 
--a) Insercion 
--INSERT INTO GR08_VISTA_EMPLEADO (id_persona,tipodoc,nrodoc,nombre,apellido,fecha_nacimiento,fecha_baja,contraseña,activo,telefono_caracteristica,telefono_numero,telefono_tipo,mail,calle,numero,piso_departamento,rol,cod_ciudad,nombre_usuario,fecha_alta) 
--values (3,'D',38828881,'Nicolas','Horquin','1995-05-30',null,'123456',true,0223,5778506,'c','enzohorquin@gmail.com','Arenales',257,null,'Z',1,'nicohorquin','2000-12-12');
-- 
--update
--update GR08_PERSONA set rol = 'X' where id_persona=1;
--
--
--b)
--INSERT INTO GR08_VISTA_EMPLEADO (id_persona,tipodoc,nrodoc,nombre,apellido,fecha_nacimiento,fecha_baja,contraseña,activo,telefono_caracteristica,telefono_numero,telefono_tipo,mail,calle,numero,piso_departamento,rol,cod_ciudad,nombre_usuario,fecha_alta) 
--values (3,'D',38828881,'Nicolas','Horquin','1915-05-30',null,'123456',true,0223,5778506,'c','enzohorquin@gmail.com','Arenales',257,null,'E',1,'nicohorquin','2000-12-12');
--
--update GR08_VISTA_EMPLEADO set fecha_nacimiento='1915-12-30' where id_persona=1;
--
--c)
--INSERT INTO GR08_VISTA_EMPLEADO (id_persona,tipodoc,nrodoc,nombre,apellido,fecha_nacimiento,fecha_baja,contraseña,activo,telefono_caracteristica,telefono_numero,telefono_tipo,mail,calle,numero,piso_departamento,rol,cod_ciudad,nombre_usuario,fecha_alta) 
--values (3,'D',38828881,'Nicolas','Horquin','1995-05-30','2016-05-30','123456',true,0223,5778506,'c','enzohorquin@gmail.com','Arenales',257,null,'E',1,'nicohorquin','2000-12-12');
--
--update GR08_PERSONA set activo = true where id_persona=3;
--
--d) Se inserta una persona con fecha de baja y activo en falso 
--
--INSERT INTO GR08_VISTA_EMPLEADO (id_persona,tipodoc,nrodoc,nombre,apellido,fecha_nacimiento,fecha_baja,contraseña,activo,telefono_caracteristica,telefono_numero,telefono_tipo,mail,calle,numero,piso_departamento,rol,cod_ciudad,nombre_usuario,fecha_alta) 
--values (3,'D',38828881,'Nicolas','Horquin','1995-05-30','2016-05-30','123456',false,0223,5778506,'c','enzohorquin@gmail.com','Arenales',257,null,'E',1,'nicohorquin','2000-12-12');
-- 
--
--update GR08_PERSONA set nombre = 'Pepe' where id_persona=3 ;
--
--
--e)
--INSERT INTO GR08_COMPROBANTE(id_tcomp,id_comp,fecha,comentario,estado,fecha_vencimiento,importe,tipo_comprobante) values (0,1,current_timestamp,'Factura','Sin pagar','2016-11-21',0,'F');
--INSERT INTO GR08_COMPROBANTE_CONL(id_tcomp,id_comp,id_persona) values (0,1,1); 
--INSERT INTO GR08_LINEA_COMPROBANTE values (1,'linea 1',10,100,0,1);
--INSERT INTO GR08_LINEA_COMPROBANTE values (2,'linea 2',10,100,0,1);
--INSERT INTO GR08_LINEA_COMPROBANTE values (3,'linea 3',10,100,0,1);
--insert into GR08_LINEA_COMPROBANTE values (4, 'linea 4', 10, 100, 0, 1);
--insert into GR08_LINEA_COMPROBANTE values (5, 'linea 5', 10, 100, 0, 1);
--insert into GR08_LINEA_COMPROBANTE values (6, 'linea 6', 10, 100, 0, 1);
--insert into GR08_LINEA_COMPROBANTE values (7, 'linea 7', 10, 100, 0, 1);
--insert into GR08_LINEA_COMPROBANTE values (8, 'linea 8', 10, 100, 0, 1);
--insert into GR08_LINEA_COMPROBANTE values (9, 'linea 9', 10, 100, 0, 1);
--insert into GR08_LINEA_COMPROBANTE values (10, 'linea 10', 10, 100, 0, 1);
--insert into GR08_LINEA_COMPROBANTE values (11, 'Linea 11', 10, 100, 0, 1);
--
--
--f) Usando las sentencias del inciso e)
--
-- update GR08_COMPROBANTE set importe = 0 where id_comp = 1 and id_tcomp = 0; 
--
--
--
--
--
--
--
--
--
--
--
--
--
alter table GR08_PERSONA 
add constraint GR08_chk_activo_fecha_baja 
check ( 
	(activo = false and fecha_baja is not null) or 
	(activo = true and fecha_baja is null) 
);

create or replace function TRFN_GR08_chk_rol_cliente()
returns trigger as $$ 
begin 

	if (select rol from GR08_PERSONA where id_persona = new.id_persona) = 'C' then
		return new; 
	else
		raise exception 'La persona insertada no es un cliente'; 
	end if; 

end; $$ language plpgsql;

create or replace function TRFN_GR08_chk_rol_empleado()
returns trigger as $$ 
begin 

    if (select rol from GR08_PERSONA where id_persona = new.id_persona) = 'E' then
        return new; 
    else
        raise exception 'La persona insertada no es un empleado'; 
    end if; 

end; $$ language plpgsql;

create or replace function TRFN_GR08_chk_saldo_correcto()
returns trigger as $$ 
begin
	if new.saldo <> 0 then 
		raise exception 'No puede insertarse un cliente que tenga saldo diferente a 0'; 
	else
		return NEW; 
	end if; 
end; $$ language plpgsql;

create or replace function TRFN_GR08_chk_deny_update_saldo()
returns trigger as $$
declare
	aux_facturas integer;
	aux_recibos integer;
begin
	select sum(lc.importe) into aux_facturas
	from GR08_COMPROBANTE c join GR08_LINEA_COMPROBANTE lc
	on (c.id_tcomp = lc.id_tcomp and c.id_comp = lc.id_comp);

	select sum(c.importe) into aux_recibos
	from GR08_COMPROBANTE c join GR08_COMPROBANTE_CONL cl on (c.id_comp = cl.id_comp and c.id_tcomp = cl.id_tcomp)
	where c.id_tcomp = 1 and cl.id_persona = new.id_persona;

	if aux_facturas is null then	
		raise notice 'Entra al primer if';	
		select 0 into aux_facturas;
	end if;

	if aux_recibos is null then
		raise notice 'Entra al segundo if';
		select 0 into aux_recibos;
	end if;

	raise notice 'Saldo en facturas: %', aux_facturas;
	raise notice 'Saldo en recibos: %', aux_recibos;
	raise notice 'Saldo nuevo: %', new.saldo;

	if new.saldo <> (aux_facturas - aux_recibos) then
		raise exception 'No se puede modificar el saldo directamente';
	else
		return new;
	end if;
	
end; $$ language plpgsql;

create or replace function FN_GR08_modificar_saldo_cliente(numeric, integer, bigint)
--FUNCION LLAMADA POR FUNCIONES DE GR08_COMPROBANTE(recibo) 
--Y POR FUNCIONES DE GR08_LINEA_COMPROBANTE(factura)
returns void as $$
declare
	id_cliente integer;
begin
	--FUNCION QUE ACTUALIZA EL SALDO DEL CLIENTE
	--SI TIENE QUE RESTAR, EL PRIMER PARAMETRO LLEGA NEGATIVO
	--SI TIENE QUE SUMAR, EL PRIMER PARAMETRO LLEGA POSITIVO
	    
	--$1 se refiere a la modificacion del saldo
	--$2 se refiere al tipo de comprobante
	--$3 se refiere al identificador del comprobante
		      
	--OBTENGO EL CLIENTE AL CUAL LE VOY A ACTUALIZAR EL SALDO
	--SEGUN EL TIPO DE COMPROBANTE
    
	if $2 = 0 then 
		select id_persona into id_cliente
		from GR08_COMPROBANTE_CONL
		where id_tcomp = $2 and id_comp = $3;
	elsif $2 = 1 then 		
		select id_persona into id_cliente
		from GR08_COMPROBANTE_SINL_TURNO
		where id_tcomp = $2 and id_comp = $3; 
	end if;
	
  	update GR08_CLIENTE set saldo = saldo + $1 where id_persona = id_cliente;
    
end; $$ language plpgsql;

create or replace function TRFN_GR08_insert_recibo()
returns trigger as $$
declare
	aux_importe integer;
begin
	if new.id_tcomp = 1 then   
		select importe into aux_importe
		from GR08_COMPROBANTE
		where id_tcomp = new.id_tcomp and id_comp = new.id_comp;
		
		execute fn_GR08_modificar_saldo_cliente(aux_importe * (-1), new.id_tcomp, new.id_comp);
	end if;
    
	return new;
end; $$ language plpgsql;

create or replace function TRFN_GR08_delete_recibo()
returns trigger as $$
declare
	aux_importe numeric(18,5);
begin
	--ESTA BORRANDO DE COMPROBANTE_SINL_TURNO
	if old.id_tcomp = 1 then

		select importe into aux_importe
		from GR08_COMPROBANTE
		where id_tcomp = old.id_tcomp and id_comp = old.id_comp;

 		execute fn_GR08_modificar_saldo_cliente(aux_importe, old.id_tcomp, old.id_comp);
		
		delete from GR08_COMPROBANTE_SINL_TURNO
		where id_tcomp = old.id_tcomp and id_comp = old.id_comp;

		delete from GR08_COMPROBANTE 
		where id_tcomp = old.id_tcomp and id_comp = old.id_comp;

	end if;

	return old;
end; $$ language plpgsql;

-- Table: GR08_LINEA_COMPROBANTE
create or replace function TRFN_GR08_chequear_lineas()
returns trigger as $$
declare
	cant_comp integer;
begin
	select count(id_comp) into cant_comp
	from GR08_LINEA_COMPROBANTE
	where id_comp = NEW.id_comp;

	    
	if cant_comp = 10 then
		raise exception 'Superado el máximo de líneas en el comprobante';
	end if;
	    
	return new;
end; $$ language plpgsql;


create or replace function TRFN_GR08_chequear_insert_lc()
returns trigger as $$
begin 
	--FUNCION QUE ACTUALIZA EL IMPORTE DEL COMPROBANTE AL CUAL
	--SE REFIERE LA PRESENTE LINEA
	    
	--ACLARACION: "new.importe" se refiere al nuevo importe de LINEA_COMPROBANTE
	 
	--ME ASEGURO DE NO TRABAJAR DESPUES CON UN REMITO
	if new.id_tcomp = 2 then
		return new;
	end if;
	
	--ACTUALIZO EL IMPORTE EN LA TABLA GR08_COMPROBANTE
	update GR08_COMPROBANTE set importe = importe + new.importe
	where id_tcomp = new.id_tcomp and id_comp = new.id_comp;
	    
	--LLAMO A LA FUNCION QUE CONTROLA EL SALDO DEL CLIENTE
	execute fn_GR08_modificar_saldo_cliente(new.importe::numeric, new.id_tcomp::integer, new.id_comp::bigint);
	    
	return new;
end; $$ language plpgsql;

create or replace function TRFN_GR08_chequear_update_lc()
returns trigger as $$
declare
	aux_importe numeric(18,5);
begin
	--ME ASEGURO DE NO TRABAJAR DESPUES CON UN REMITO
	if old.id_tcomp = 2 then
		return new;
	end if;

	if old.nro_linea <> new.nro_linea or old.id_tcomp <> new.id_tcomp or old.id_comp <> new.id_comp then
		raise exception 'No se puede cambiar la PK de una linea, solo el importe';
	end if;
	
	aux_importe = (old.importe - new.importe) * (-1);

	--ACTUALIZO EL IMPORTE EN LA TABLA GR08_COMPROBANTE
	update GR08_COMPROBANTE set importe = importe + aux_importe
	where id_tcomp = old.id_tcomp and id_comp = old.id_comp;

	--LLAMO A LA FUNCION QUE CONTROLA EL SALDO DEL CLIENTE
	execute fn_GR08_modificar_saldo_cliente(aux_importe, new.id_tcomp, new.id_comp);
	
	return new;
end; $$ language plpgsql;

create or replace function TRFN_GR08_chequear_delete_lc()
returns trigger as $$
begin
	--ME ASEGURO DE NO TRABAJAR DESPUES CON UN REMITO
	if old.id_tcomp = 2 then
		return old;
	end if;

	--ACTUALIZO EL IMPORTE EN LA TABLA GR08_COMPROBANTE
	update GR08_COMPROBANTE set importe = importe - old.importe
	where id_tcomp = old.id_tcomp and id_comp = old.id_comp;

	--LLAMO A LA FUNCION QUE CONTROLA EL SALDO DEL CLIENTE
	execute fn_GR08_modificar_saldo_cliente(old.importe * (-1), old.id_tcomp, old.id_comp);
    
	return old;    
end; $$ language plpgsql;;

create or replace function TRFN_GR08_chk_update_estado_cliente()
returns trigger as $$
begin
    if old.activo = false and new.activo = false then
        raise exception 'No se puede modificar una persona dado de baja';
    else
        return new;
    end if;
end; $$ language plpgsql;

-- SERVICIO 2 
create or replace function PR_GR08_generar_facturas()
returns void as $$ 
declare 
	fila record ; 
	fila2 record;
	id_compr bigint;
begin 

	for fila in ( select * from GR08_CLIENTE c join GR08_EQUIPO e on ( c.id_persona = e.id_persona) join GR08_SERVICIO s on ( e.id_servicio = s.id_servicio) ) 
	loop
		if fila.periodico = true and fila.activo = true then 
		      id_compr = nextval('seq_factura');
		      insert into GR08_COMPROBANTE values (0, id_compr, current_timestamp, ' ', null, null, 0, 'F') ; 
		      insert into GR08_COMPROBANTE_CONL values (0, id_compr, fila.id_persona); 
			  insert into GR08_LINEA_COMPROBANTE values (1, 'La factura es de una sola linea', 1, fila.costo, 0, id_compr ); 
		end if; 
	end loop ; 

	for fila2 in ( select c.id_persona, comp.id_comp , lc.importe, comp.fecha 
		      from GR08_CLIENTE c join GR08_COMPROBANTE_CONL cl on ( c.id_persona = cl.id_persona ) join GR08_COMPROBANTE comp on ( comp.id_comp =  cl.id_comp and comp.id_tcomp = cl.id_tcomp) join GR08_LINEA_COMPROBANTE lc on (lc.id_comp = comp.id_comp and lc.id_tcomp = comp.id_tcomp)
		      where cl.id_tcomp = 2 and extract(month from date_trunc('day', now() - interval '1 month')) = extract(month from comp.fecha) and extract(year from date_trunc('day', now() - interval '1 month')) = extract(year from comp.fecha) )
	loop 
		id_compr = nextval('seq_factura');   
		
		insert into GR08_COMPROBANTE values (0, id_compr, current_timestamp, ' ', null, null, 0, 'F'); 
		insert into GR08_COMPROBANTE_CONL values (0, id_compr, fila2.id_persona); 		 
		insert into GR08_LINEA_COMPROBANTE values (1, 'La factura es de una sola linea', 1, fila2.importe, 0, id_compr); 
	end loop;

end; $$ language plpgsql;
--FIN SERVICIO 2

--INICIO SERVICIO 3 
-- PARA CLIENTES
create or replace function TRFN_GR08_insercion_persona_cliente()
returns trigger as $$      
begin
	insert into GR08_PERSONA (id_persona, tipodoc, nrodoc, nombre, apellido, fecha_nacimiento, fecha_baja, contraseña, activo, telefono_caracteristica, telefono_numero, telefono_tipo, mail, calle, numero, piso_departamento, rol, cod_ciudad, nombre_usuario) 
	values (new.id_persona, new.tipodoc, new.nrodoc, new.nombre, new.apellido, new.fecha_nacimiento, new.fecha_baja, new.contraseña, new.activo, new.telefono_caracteristica, new.telefono_numero, new.telefono_tipo, new.mail, new.calle, new.numero, new.piso_departamento, new.rol, new.cod_ciudad, new.nombre_usuario); 

	insert into GR08_CLIENTE (id_persona, saldo, cuit, id_direccion_facturacion) 
	values (new.id_persona, 0, new.cuit, new.id_direccion_facturacion); 

	return new;               
end; $$ language plpgsql; 

-- PARA EMPLEADOS
create or replace function TRFN_GR08_insercion_persona_empleado()
returns trigger as $$
begin
	insert into GR08_PERSONA (id_persona, tipodoc, nrodoc, nombre, apellido, fecha_nacimiento, fecha_baja, contraseña, activo, telefono_caracteristica, telefono_numero, telefono_tipo, mail, calle, numero, piso_departamento, rol, cod_ciudad, nombre_usuario) 
	values (new.id_persona, new.tipodoc, new.nrodoc, new.nombre, new.apellido, new.fecha_nacimiento, new.fecha_baja, new.contraseña, new.activo, new.telefono_caracteristica, new.telefono_numero, new.telefono_tipo, new.mail, new.calle, new.numero, new.piso_departamento, new.rol, new.cod_ciudad, new.nombre_usuario); 
	insert into GR08_EMPLEADO(id_persona, fecha_alta) values (new.id_persona, new.fecha_alta); 

	return new;
end; $$ language plpgsql;  

-- Funcion que chequea el update de un importe en COMPROBANTE
create or replace function TRFN_GR08_COMPROBANTE_chk_suma_importes_linea()
returns trigger as $$ 
declare 
	suma_importe numeric(18,5);
begin 

	if new.id_tcomp = 1 then
		execute fn_GR08_modificar_saldo_cliente(old.importe - new.importe, new.id_tcomp, new.id_comp); 
		return new; 
	end if; 

	select sum(importe) into suma_importe 
	from GR08_LINEA_COMPROBANTE 
	where id_comp = new.id_comp and id_tcomp = new.id_tcomp;

	if suma_importe = null then
		select 0 into suma_importe;
	end if;

	if suma_importe <> new.importe then 
		raise exception 'La suma de las lineas no puede ser distinto al nuevo importe' ;
	end if; 

	return new; 
end; $$ language plpgsql;

create or replace function TRFN_GR08_actualizacion_persona_cliente()
returns trigger as $$ 
begin 
	update GR08_PERSONA 
	set tipodoc = new.tipodoc, nrodoc = new.nrodoc, nombre = new.nombre, apellido = new.apellido, 
		fecha_nacimiento = new.fecha_nacimiento, fecha_baja = new.fecha_baja, contraseña = new.contraseña, 
		activo = new.activo, telefono_caracteristica = new.telefono_caracteristica, telefono_numero = new.telefono_numero, 
		telefono_tipo = new.telefono_tipo, mail = new.mail, calle = new.calle, numero = new.numero, 
		piso_departamento = new.piso_departamento, cod_ciudad = new.cod_ciudad, nombre_usuario = new.nombre_usuario 
	where id_persona = old.id_persona;

	update GR08_CLIENTE
	set saldo=new.saldo, cuit=new.cuit 
	where id_persona= old.id_persona;  

	return new;
end ; $$ language plpgsql; 

create or replace function TRFN_GR08_actualizacion_persona_empleado()
returns trigger as $$ 
begin 
	update GR08_PERSONA 
	set tipodoc = new.tipodoc, nrodoc = new.nrodoc, nombre = new.nombre, apellido = new.apellido, 
		fecha_nacimiento = new.fecha_nacimiento, fecha_baja = new.fecha_baja, contraseña = new.contraseña, 
		activo = new.activo, telefono_caracteristica = new.telefono_caracteristica, telefono_numero = new.telefono_numero, 
		telefono_tipo = new.telefono_tipo, mail = new.mail, calle = new.calle, numero = new.numero, 
		piso_departamento = new.piso_departamento, cod_ciudad = new.cod_ciudad, nombre_usuario = new.nombre_usuario 
	where id_persona = old.id_persona ; 
	
	update GR08_EMPLEADO 
	set fecha_alta=new.fecha_alta  
	where id_persona = old.id_persona;
	
	return new;
end ; $$ language plpgsql; 

--D. DEFINICION DE VISTAS

--D.1
create view GR08_VISTA_COMPROBANTES_CL
as (select p.*, c.saldo, c.cuit, c.id_direccion_facturacion, comp.*, lc.nro_linea, lc.descripcion, lc.cantidad, lc.importe as "Importe de linea", null as "id_turno"
	from GR08_PERSONA p  natural join GR08_CLIENTE c 
		 					     join GR08_COMPROBANTE_CONL cl on (c.id_persona = cl.id_persona)  
		 					 	 join GR08_COMPROBANTE comp on ( cl.id_tcomp = comp.id_tcomp and cl.id_comp = comp.id_comp)
		 					  	 join GR08_LINEA_COMPROBANTE lc on ( lc.id_tcomp = comp.id_tcomp and lc.id_comp = comp.id_comp)
	union
	select p.*, c.saldo, c.cuit, c.id_direccion_facturacion, comp.*, null, null, null, null, cslt.id_turno
	from GR08_PERSONA p natural join GR08_CLIENTE C 
						natural join GR08_COMPROBANTE_SINL_TURNO cslt
						natural join GR08_COMPROBANTE comp
	);

--D.2              
create view GR08_VISTA_CLIENTES
as select *
from GR08_CLIENTE natural join GR08_PERSONA;

create view GR08_VISTA_EMPLEADO
as select *
from GR08_EMPLEADO natural join GR08_PERSONA;

--D.3
create view GR08_VISTA_DEUDORES
as select * 
from GR08_PERSONA 
where id_persona in ( select id_persona from GR08_CLIENTE where saldo > 0 ); 

create trigger TR_GR08_chk_rol_cliente 
before insert or update on GR08_CLIENTE
for each row 
execute procedure TRFN_GR08_chk_rol_cliente();

create trigger TR_GR08_chk_rol_empleado
before insert or update on GR08_EMPLEADO
for each row 
execute procedure TRFN_GR08_chk_rol_empleado();

create trigger TR_GR08_chk_saldo_correcto
before insert on GR08_CLIENTE
for each row 
execute procedure TRFN_GR08_chk_saldo_correcto();

create trigger TR_GR08_chk_deny_update_saldo
after update on GR08_CLIENTE
for each row
execute procedure TRFN_GR08_chk_deny_update_saldo();

create trigger TR_GR08_insert_recibo
after insert on GR08_COMPROBANTE_SINL_TURNO
for each row
execute procedure TRFN_GR08_insert_recibo();

create trigger TR_GR08_LINEA_COMPROBANTE_chk_cant_linea_comp
before insert on GR08_LINEA_COMPROBANTE
for each row
execute procedure TRFN_GR08_chequear_lineas();

create trigger TR_GR08_LINEA_COMPROBANTE_chk_insert_linea
after insert on GR08_LINEA_COMPROBANTE
for each row
execute procedure TRFN_GR08_chequear_insert_lc();

create trigger TR_GR08_LINEA_COMPROBANTE_chk_update_linea
after update of importe on GR08_LINEA_COMPROBANTE
for each row
execute procedure TRFN_GR08_chequear_update_lc();

create trigger TR_GR08_LINEA_COMPROBANTE_chk_delete_linea
after delete on GR08_LINEA_COMPROBANTE
for each row
execute procedure TRFN_GR08_chequear_delete_lc();

create trigger TR_GR08_PERSONA_chk_update_estado_cliente
before update on GR08_PERSONA
for each row
execute procedure TRFN_GR08_chk_update_estado_cliente();

create trigger TR_GR08_VISTA_CLIENTE_PERSONA
instead of insert on GR08_VISTA_CLIENTES
for each row 
execute procedure TRFN_GR08_insercion_persona_cliente();

create trigger TR_GR08_PERSONA_EMPLEADO_insercion_persona_empleado
instead of insert on GR08_VISTA_EMPLEADO
for each row 
execute procedure TRFN_GR08_insercion_persona_empleado(); 

create trigger TR_GR08_COMPROBANTE_chk_suma_importes_linea 
after update of importe on GR08_COMPROBANTE
for each row 
execute procedure TRFN_GR08_COMPROBANTE_chk_suma_importes_linea();

create trigger TR_GR08_COMPROBANTE_SINL_delete_recibo
after delete on GR08_COMPROBANTE_SINL
for each row
execute procedure TRFN_GR08_delete_recibo();

create trigger TR_GR08_PERSONA_CLIENTE_actualizacion_persona_cliente
instead of update on GR08_VISTA_CLIENTES
for each row 
execute procedure TRFN_GR08_actualizacion_persona_cliente(); 

create trigger TR_GR08_actualizacion_persona_empleado
instead of update on GR08_VISTA_EMPLEADO
for each row 
execute procedure TRFN_GR08_actualizacion_persona_empleado();
