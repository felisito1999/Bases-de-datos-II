--Integridad de dominio
DECLARE @Ejemplo TABLE 
(
Id TINYINT
)

INSERT INTO @Ejemplo VALUES(250)

SELECT * FROM @Ejemplo

--Integridad de la entidad (Cada tabla debe tener un clave primaria

--Integridad referencial  (Hace referencia a los foreign key)

--Los tres tipos de integridad ayudan a mantener la base de datos integra

--Restrinciones 

--UNIQUE
--Es buena practica hacer las validaciones a nivel de base de datos y a nivel de cliente. 

--CHECK 
--Hacer validaciones 

--1
CREATE TABLE Categoria(
	Codigo INT NOT NULL CONSTRAINT PK_Categoria PRIMARY KEY, 
	Nombre VARCHAR(30));

CREATE TABLE Categoriza(
	Codigo_producto INT NOT NULL CONSTRAINT FK_Productos_Categoriza FOREIGN KEY REFERENCES Productos(ProductoId),
	Codigo_Categoria INT NOT NULL CONSTRAINT FK_Categoria_Categoriza FOREIGN KEY REFERENCES Categoria(Codigo),
	CONSTRAINT PK_Categoriza PRIMARY KEY(Codigo_producto, Codigo_Categoria)); 
--2

ALTER TABLE Clientes ADD Cedula VARCHAR(13);

ALTER TABLE Clientes ADD UNIQUE (Cedula);

SELECT *, SUBSTRING(CONCAT('0000000000000', ClienteId), LEN(ClienteId) + 1, 13) Cedula FROM Clientes;

SELECT * FROM Clientes
--Update a todas las filas de la tabla. 
UPDATE Clientes
SET Cedula = SUBSTRING(CONCAT('0000000000000', ClienteId), LEN(ClienteId) + 1, 13);
SELECT * FROM Clientes

INSERT INTO Clientes(ClienteId, Nombre, Sexo, EstadoId,Cedula) VALUES 
(1051,'Cliente 1049', 'M', 1, '0000000001049');

--Distinct (Eliminar filas duplicadas)
SELECT a.ClienteId, b.Nombre FROM Facturas a INNER JOIN Clientes b ON a.ClienteId = b.ClienteId
WHERE YEAR(Fecha) = 2015 AND MONTH(Fecha) = 1
ORDER BY a.ClienteId;
--Con el distinct 
SELECT DISTINCT a.ClienteId, b.Nombre FROM Facturas a INNER JOIN Clientes b ON a.ClienteId = b.ClienteId
WHERE YEAR(Fecha) = 2015 AND MONTH(Fecha) = 1
ORDER BY a.ClienteId;

--GROUP BY (SUM, AVG, MIN, MAX, COUNT) Lo que no este en esta funcion de agregacion, debe ser especificado por el group by

SELECT a.ClienteId, b.Nombre, COUNT(*) total 
FROM Facturas a INNER JOIN Clientes b ON a.ClienteId = b.ClienteId
WHERE YEAR(Fecha) = 2015 AND MONTH(Fecha) = 1
GROUP BY a.ClienteId, b.Nombre
ORDER BY a.ClienteId;

--Forma mas eficiente, en la que el group by no tiene que trabajar con un string que ralentiza la operacion
SELECT a.ClienteId, MAX(b.Nombre) Nombre, COUNT(*) total 
FROM Facturas a INNER JOIN Clientes b ON a.ClienteId = b.ClienteId
WHERE YEAR(Fecha) = 2015 AND MONTH(Fecha) = 1
GROUP BY a.ClienteId
ORDER BY a.ClienteId;

--La consulta con un HAVING para especificar los que hayan hecho entre 15 y 50 facturas. 
SELECT a.ClienteId, b.Nombre, COUNT(*) total 
FROM Facturas a INNER JOIN Clientes b ON a.ClienteId = b.ClienteId
WHERE YEAR(Fecha) = 2015 AND MONTH(Fecha) = 1
GROUP BY a.ClienteId, b.Nombre
HAVING COUNT(*) BETWEEN 15 AND 50	
ORDER BY a.ClienteId;

--UNION y UNION ALL

DECLARE @Tabla1 TABLE 
(
	Letra CHAR(1)
)

DECLARE @Tabla2 TABLE 
(
	Letra CHAR(1)
)

INSERT INTO @Tabla1 VALUES ('A'), ('B'), ('C')
INSERT INTO @Tabla2 VALUES ('D'), ('B'), ('E')

SELECT Letra FROM @Tabla1
UNION 
SELECT Letra FROM @Tabla2

SELECT Letra FROM @Tabla1
UNION ALL
SELECT Letra FROM @Tabla2

SELECT Letra FROM @Tabla1
EXCEPT
SELECT Letra FROM @Tabla2

SELECT Letra FROM @Tabla1
INTERSECT 
SELECT Letra FROM @Tabla2
--Consultas

SELECT * FROM FacturasDetalle
--1
SELECT a.FacturaId, a.Fecha, b.Nombre, SUM(c.PrecioVenta * c.Cantidad) AS Total, d.Nombres FROM Facturas a INNER JOIN Clientes b
ON a.ClienteId = b.ClienteId INNER JOIN FacturasDetalle c 
ON a.FacturaId = c.FacturaId INNER JOIN Estados d
ON a.EstadoId = d.EstadoId
WHERE a.Fecha BETWEEN '2016-01-30' AND '2016-02-20'	
GROUP BY a.FacturaId, a.Fecha, b.Nombre, d.Nombres

--2 
SELECT TOP 10 a.ClienteId, a.Nombre, SUM(c.PrecioVenta * c.Cantidad) AS TotalComprado FROM Clientes a INNER JOIN Facturas b 
ON a.ClienteId = b.ClienteId INNER JOIN FacturasDetalle c 
ON b.FacturaId = c.FacturaId
GROUP BY a.ClienteId, a.Nombre
ORDER BY TotalComprado DESC

--3
SELECT DISTINCT a.ProductoId, a.Nombre, b.PrecioVenta FROM Productos a INNER JOIN FacturasDetalle b 
ON a.ProductoId = b.ProductoId 

--4 

SELECT ClienteId, Nombre FROM Clientes a 
WHERE a.ClienteId NOT IN (SELECT ClienteId FROM Facturas WHERE Fecha BETWEEN '2016-01-30' AND '2016-03-30');

--5

SELECT a.ProductoId, a.Nombre, COUNT(b.FacturaId) AS CantidadFacturas, SUM(b.Cantidad * b.PrecioVenta) TotalVendido FROM Productos a INNER JOIN FacturasDetalle b 
ON a.ProductoId = b.ProductoId 
GROUP BY a.ProductoId, a.Nombre;

--Vistas 
--Es una tabla virtual 
/*

* Standard views 
With Schemabinding, prevenir que cuando se haga un cambio con la estructura de la tabla que esta relacionada con la vista, envie un alerta 
No fallen las vistas inesperadamente

* With Encryption
Esta oculta la definicion de la vista. 
No recomendado, muy dificil de mantener, hay otros mecanismos para prevenir el acceso a las definiciones de las mismas.

-No se puede usar order by, al menos, que se utilice un TOP 
-Puede haber mas de una consulta, pero deben ser unidas con UNION, o UNION ALL.
-No se recomienda utilizar el '*' en las consultas de la vista. 


*/
CREATE VIEW  vw_Clientes 
WITH SCHEMABINDING 
AS 
	SELECT ClienteId, Nombre, Sexo 
	FROM dbo.Clientes;

--Cuando se hace con SCHEMABINDING se necesita aplicar el esquema de la tabla necesariamente, de lo contrario, dara un error a la hora de crearla. 
	
SELECT * FROM vw_Clientes;

SELECT * FROM sys.views

--Muestra un texto con la definicion de la vista.
SELECT name, OBJECT_DEFINITION(OBJECT_ID) AS Estructura 
FROM sys.views

--Rename table from query

sp_RENAME 'Clientes.Nombre', 'Nombres' , 'Nombre'

--Creacion de vistas

--1
CREATE VIEW vw_Clientes_Activos 
WITH SCHEMABINDING
AS 
	SELECT a.ClienteId, a.Nombre, b.Nombres AS Estado, CASE WHEN a.Sexo = 'm' THEN 'Masculino'
									 WHEN a.Sexo = 'f' THEN 'Femenino'
									 ELSE 'Indefinido' END AS Sexo FROM dbo.Clientes a INNER JOIN dbo.Estados b
	ON a.EstadoId = b.EstadoId WHERE a.EstadoId = 1; 

CREATE UNIQUE CLUSTERED INDEX PK_ClienteId 
	ON dbo.vw_Clientes_Activos (ClienteId);

CREATE NONCLUSTERED INDEX I_Nombre
	ON dbo.vw_Clientes_Activos (Nombre);
--2 
CREATE VIEW vw_Facturas
WITH SCHEMABINDING 
AS
	SELECT a.FacturaId, b.ClienteId, b.Nombre, YEAR(a.Fecha) AS Anio, 
	CASE WHEN MONTH(a.Fecha) = 1 THEN 'Enero'
		 WHEN MONTH(a.Fecha) = 2 THEN 'Febrero'
		 WHEN MONTH(a.Fecha) = 3 THEN 'Marzo'
		 WHEN MONTH(a.Fecha) = 4 THEN 'Abril'
		 WHEN MONTH(a.Fecha) = 5 THEN 'Mayo'
		 WHEN MONTH(a.Fecha) = 6 THEN 'Junio'
		 WHEN MONTH(a.Fecha) = 7 THEN 'Julio'
		 WHEN MONTH(a.Fecha) = 8 THEN 'Agosto'
		 WHEN MONTH(a.Fecha) = 9 THEN 'Septiembre'
		 WHEN MONTH(a.Fecha) = 10 THEN 'Octubre'
		 WHEN MONTH(a.Fecha) = 11 THEN 'Noviembre'
		 WHEN MONTH(a.Fecha) = 12 THEN 'Diciembre'
		 END AS Mes
	,a.Fecha, d.Total, c.Nombres AS Estado FROM dbo.Facturas a INNER JOIN dbo.Clientes b 
	ON a.ClienteId = b.ClienteId INNER JOIN dbo.Estados c 
	ON a.EstadoId = c.EstadoId INNER JOIN (SELECT FacturaId,SUM(Cantidad * PrecioVenta) AS Total FROM dbo.FacturasDetalle GROUP BY FacturaId) d
	ON a.FacturaId = d.FacturaId 
	
--Case when 

DECLARE @n int 
SET @n = 3 

SELECT CASE 
	WHEN @n = 1 THEN 'UNO'
	WHEN @n = 2 THEN 'DOS'
	ELSE 'NO SE'
	END;

--3 

CREATE VIEW vwTop10Producto1
WITH SCHEMABINDING
AS
	SELECT TOP 10 a.ClienteId, a.Nombre, COUNT(C.ProductoId),C.TotalCompra FROM dbo.Clientes a INNER JOIN Facturas b
	ON a.ClienteId = b.ClienteId INNER JOIN 
	(SELECT ProductoId, SUM(PrecioVenta * Cantidad) AS TotalCompra FROM FacturasDetalle WHERE ProductoId = 1
	GROUP BY ProductoId)c
	ON b.FacturaId = c.FacturaId

CREATE VIEW vwTop10Producto1
WITH SCHEMABINDING
AS
	SELECT TOP 10 a.ClienteId, a.Nombre, COUNT(c.ProductoId) AS Cantidad, SUM(c.Cantidad * c.PrecioVenta) AS TotalVendido FROM dbo.Clientes a INNER JOIN dbo.Facturas b
	ON a.ClienteId = b.ClienteId INNER JOIN dbo.FacturasDetalle c
	ON b.FacturaId = c.FacturaId WHERE c.ProductoId = 1  GROUP BY a.ClienteId, a.Nombre ORDER BY TotalVendido DESC


--None
CREATE VIEW vw_Clientes_Productos 
WITH SCHEMABINDING
AS 
	SELECT Nombre, Tipo = 2 FROM dbo.Productos

	UNION ALL

	SELECT Nombre, Tipo = 1 FROM dbo.Clientes

	

--Clases de las funciones, y creacion de funciones

--1
CREATE FUNCTION dbo.TotalVendido
(@Cantidad FLOAT, 
@Precio FLOAT
)
RETURNS FLOAT
WITH SCHEMABINDING
AS 
BEGIN 
	DECLARE @TotalVendido FLOAT
	SET @TotalVendido = @Cantidad * @Precio
RETURN @TotalVendido
END;

SELECT * ,dbo.TotalVendido(Cantidad, PrecioVenta) AS Total FROM FacturasDetalle;

--2
CREATE FUNCTION dbo.TotalVendidoFactura
(
@IdFactura INT
)
RETURNS FLOAT
AS 
BEGIN
DECLARE @TotalVendido FLOAT

SET @TotalVendido = (SELECT SUM(Cantidad * PrecioVenta) FROM FacturasDetalle WHERE FacturaId = @IdFactura)
RETURN @TotalVendido
END


SELECT  *, dbo.TotalVendidoFactura(FacturaId) AS Total FROM FacturasDetalle WHERE FacturaId = 1;

SELECT FacturaId, COUNT(DetalleId) AS CantidadDetalle FROM FacturasDetalle 
GROUP BY FacturaId HAVING COUNT(DetalleId) > 1
ORDER BY FacturaId ASC 

--3
CREATE FUNCTION dbo.Trimestre
(
@FacturaId INT
)
RETURNS TABLE
AS 
RETURN 
	SELECT *,(CASE WHEN Month(Fecha) = 1 THEN 'Primer trimestre'
			 WHEN Month(Fecha) = 2 THEN 'Primer trimestre'
			 WHEN Month(Fecha) = 3 THEN 'Primer trimestre'
			 WHEN Month(Fecha) = 4 THEN 'Segundo trimestre'
			 WHEN Month(Fecha) = 5 THEN 'Segundo trimestre'
			 WHEN Month(Fecha) = 6 THEN 'Segundo trimestre'
			 WHEN Month(Fecha) = 7 THEN 'Tercer trimestre'
			 WHEN Month(Fecha) = 8 THEN 'Tercer trimestre'
			 WHEN Month(Fecha) = 9 THEN 'Tercer trimestre'
			 WHEN Month(Fecha) = 10 THEN 'Cuarto trimestre'
			 WHEN Month(Fecha) = 11 THEN 'Cuarto trimestre'
			 WHEN Month(Fecha) = 12 THEN 'Cuarto trimestre' 
			 END) AS Trimestre FROM Facturas;

--4 
--DROP FUNCTION dbo.FacturasCalculosTipos;
CREATE FUNCTION dbo.FacturasCalculosTipos
(
@FechaInicial DATETIME,
@FechaFinal DATETIME,
@IdProducto INT,
@TipoOperacion INT
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @Total FLOAT;

	IF (@TipoOperacion = 1)
	BEGIN
		SET @Total = (SELECT SUM(Cantidad) AS Total FROM FacturasDetalle a INNER JOIN Facturas b ON a.FacturaId = b.FacturaId
		WHERE a.ProductoId = @IdProducto AND b.Fecha BETWEEN @FechaInicial AND @FechaFinal GROUP BY a.ProductoId);
	END
	ELSE 
		IF (@TipoOperacion = 2)
		BEGIN
			SET @Total = (SELECT SUM(Cantidad * PrecioVenta) AS Total FROM FacturasDetalle a INNER JOIN Facturas b ON 
			a.FacturaId = b.FacturaId
			WHERE a.ProductoId = @IdProducto AND b.Fecha BETWEEN @FechaInicial AND @FechaFinal GROUP BY a.ProductoId);
		END
	RETURN @Total;
END; 

SELECT  dbo.FacturasCalculosTipos('1-09-2016','3-06-2017',1,2);

--5
--DROP FUNCTION dbo.Clientes
CREATE FUNCTION dbo.ClientesEstado
(
@Estado INT
)
RETURNS TABLE 
AS 
RETURN
	SELECT a.clienteId, a.Nombre, a.Cedula, Sexo, b.Nombres FROM Clientes a INNER JOIN
		Estados b ON a.EstadoId = b.EstadoId WHERE a.EstadoId = @Estado OR a.EstadoId IS NULL;
	--IF (@Estado = 1)
	--BEGIN
	--	SELECT a.clienteId, a.Nombre, a.Cedula, Sexo, b.Nombres FROM Clientes a INNER JOIN
	--			Estados b ON a.EstadoId = b.EstadoId WHERE a.EstadoId = @Estado;
	--END
	--ELSE 
	--	IF (@Estado IS NULL)
	--	BEGIN
	--		SELECT clienteId, Nombre, a.Cedula, Sexo, b.Nombres FROM Clientes a INNER JOIN
	--			Estados b ON a.EstadoId = b.EstadoId
	--	END

	DECLARE @EstadoId INT = NULL

	SELECT COUNT(*) total FROM Clientes 
	WHERE CASE WHEN @EstadoId IS NULL 
	THEN ISNULL(@EstadoId,0)  ELSE EstadoId
	END = ISNULL(@EstadoId,0)
	
SELECT * FROM dbo.ClientesEstado(1);

--6 
--DROP FUNCTION dbo.facturasPendientes
CREATE FUNCTION dbo.facturasPendientes
(
@ClienteId INT
)
RETURNS TABLE 
AS 
RETURN
SELECT a.FacturaId, a.Fecha, SUM(b.Cantidad * b.PrecioVenta) AS TotalFacturado, c.MontoPagado AS MontoPagado 
FROM Facturas a INNER JOIN FacturasDetalle b 
ON a.FacturaId = b.FacturaId 
LEFT JOIN (SELECT CodigoFactura, SUM(MontoPagado) AS MontoPagado FROM PagoDetalle GROUP BY CodigoFactura) c
ON a.FacturaId = c.CodigoFactura 
WHERE a.ClienteId = @ClienteId 
GROUP BY a.FacturaId, a.Fecha, MontoPagado
HAVING (SUM(b.Cantidad * b.PrecioVenta) - ISNULL(c.MontoPagado,0)) > 0;

SELECT * FROM dbo.facturasPendientes(1);

--Solo para las facturas que tienen pagos
DECLARE @ClienteId INT = 1;

SELECT a.FacturaId, a.Fecha, SUM(b.Cantidad * b.PrecioVenta) AS TotalFacturado, c.MontoPagado AS MontoPagado 
FROM Facturas a INNER JOIN FacturasDetalle b 
ON a.FacturaId = b.FacturaId 
INNER JOIN (SELECT CodigoFactura, SUM(MontoPagado) AS MontoPagado FROM PagoDetalle GROUP BY CodigoFactura) c
ON a.FacturaId = c.CodigoFactura 
WHERE a.ClienteId = @ClienteId 
GROUP BY a.FacturaId, a.Fecha, MontoPagado 
HAVING (SUM(b.Cantidad * b.PrecioVenta) - ISNULL(c.MontoPagado,0)) > 0;

--Para que salgan las facturas que no tienen pagos registrados
DECLARE @ClienteId INT = 1;

SELECT a.ClienteId, a.FacturaId, a.Fecha, SUM(b.Cantidad * b.PrecioVenta) AS TotalFacturado, c.MontoPagado AS MontoPagado 
FROM Facturas a INNER JOIN FacturasDetalle b 
ON a.FacturaId = b.FacturaId 
LEFT JOIN (SELECT CodigoFactura, SUM(MontoPagado) AS MontoPagado FROM PagoDetalle GROUP BY CodigoFactura) c
ON a.FacturaId = c.CodigoFactura 
WHERE a.ClienteId = @ClienteId 
GROUP BY a.FacturaId, a.Fecha, MontoPagado, a.ClienteId 
HAVING (SUM(b.Cantidad * b.PrecioVenta) - ISNULL(c.MontoPagado,0)) > 0 ORDER BY a.FacturaId ASC;

--Practica de funciones del sistema
--1
CREATE FUNCTION dbo.productos_Ventas
(
@Mes INT,
@Anio INT
)
RETURNS TABLE 
AS 
RETURN 
	SELECT a.ProductoId, a.Nombre, SUM(b.Cantidad) CantidadTotal, MIN(b.Cantidad) CantidadMinima, 
	MAX(b.Cantidad) CantidadMaxima, AVG(b.Cantidad) CantidadPromedio, COUNT(b.Cantidad) CantidadVeces FROM Productos a INNER JOIN
	FacturasDetalle b ON a.ProductoId = b.ProductoId INNER JOIN Facturas c 
	ON b.FacturaId = c.FacturaId WHERE MONTH(c.Fecha) = @Mes AND YEAR(c.Fecha) = @Anio GROUP BY a.ProductoId, a.Nombre;


--Practica funciones multistatements
--1 
CREATE FUNCTION dbo.Cuotas
(
@FechaInicio DATE,
@MontoAPagar FLOAT,
@NumeroCuotas FLOAT,
@Frecuencia INT
)
RETURNS @CuotasTable TABLE
		(
			Fecha DATE NOT NULL,
			NumeroCuota INT NOT NULL,
			Monto FLOAT NOT NULL
		)
AS 
	BEGIN

		DECLARE @Cuota INT = 1;
		DECLARE @FechaCuota DATE = @FechaInicio;
		
		WHILE @Cuota <= @NumeroCuotas
		BEGIN
		IF (@Cuota = 1)
			BEGIN
				INSERT INTO @CuotasTable VALUES (@FechaInicio, @Cuota, (@MontoAPagar / @NumeroCuotas));
			END
		
		ELSE 
			IF (@Cuota > 1)
				BEGIN
					SET @FechaCuota = DATEADD(DAY, @Frecuencia, @FechaCuota);
					INSERT INTO @CuotasTable VALUES (@FechaCuota, @Cuota, (@MontoAPagar / @NumeroCuotas));
				END
		SET @Cuota += 1;
		END

	RETURN 
	END
--DROP FUNCTION dbo.Cuotas;
SELECT * FROM dbo.Cuotas('12-3-2019', 45000, 5, 20);

--2 

--Creacion de trigger 

CREATE TRIGGER tgTablasVirtuales
on Clientes 
AFTER INSERT, UPDATE, DELETE 
AS 
BEGIN 
	SELECT * FROM inserted
	SELECT * FROM deleted
END

INSERT INTO Clientes VALUES (312312, 'Cliente312312', 'M', 1, 000102312322);
DELETE FROM Clientes WHERE ClienteId = 312312;
UPDATE Clientes SET Nombre = 'Felix Junior Perez Peguero', Sexo = 'M' WHERE ClienteId = 1

SELECT * FROM Clientes 

--Encontrar los triggers 

SELECT b.name Tabla, * FROM sys.triggers a INNER JOIN sys.tables b 
ON a.parent_id = b.object_id


--Creacion de trigger 

CREATE TRIGGER tgTablasVirtuales
on Clientes 
AFTER INSERT, UPDATE, DELETE 
AS 
BEGIN 
	SELECT * FROM inserted
	SELECT * FROM deleted
END

INSERT INTO Clientes VALUES (312312, 'Cliente312312', 'M', 1, 000102312322);
DELETE FROM Clientes WHERE ClienteId = 312312;
UPDATE Clientes SET Nombre = 'Felix Junior Perez Peguero', Sexo = 'M' WHERE ClienteId = 1

SELECT * FROM Clientes 

--Encontrar los triggers 

SELECT b.name Tabla, * FROM sys.triggers a INNER JOIN sys.tables b 
ON a.parent_id = b.object_id

--Triggers
CREATE TRIGGER tg_ClientesCedula
ON Clientes 
AFTER UPDATE
AS
BEGIN 

if update(cedula) 
begin
	
	INSERT INTO HistorialdeCambios

	SELECT 'Clientes', a.ClienteId, 'Cedula', b.Cedula, a.Cedula, SYSTEM_USER, GETDATE() FROM inserted a Inner join deleted b ON a.ClienteId = b.ClienteId

end

END

UPDATE Clientes SET Cedula = '123456789' WHERE ClienteId = 1
Select * from HistorialdeCambios


-- t
CREATE TRIGGER tg_FacturasEstados 
ON Facturas 
AFTER UPDATE 
AS 
BEGIN 

	IF UPDATE(Fecha)
	BEGIN 
	INSERT INTO HistorialdeCambios

	SELECT 'Facturas', a.FacturaId, 'Fecha', b.Fecha, a.Fecha, SYSTEM_USER, GETDATE() FROM inserted a INNER JOIN deleted b 
	ON a.FacturaId = b.FacturaId

	END

	IF UPDATE(EstadoId)
	BEGIN
	INSERT INTO HistorialdeCambios

	SELECT 'Facturas', a.FacturaId, 'Estado', b.EstadoId, a.EstadoId, SYSTEM_USER, GETDATE() FROM inserted a INNER JOIN deleted b
	ON a.FacturaId = b.FacturaId

	END
END

UPDATE Facturas SET EstadoId = 2 WHERE FacturaId = 3

UPDATE Facturas SET Fecha = '2019-08-23' WHERE FacturaId = 3 

--Trigger Detalle facturas 
CREATE TRIGGER tg_DetalleFacturaInstead
ON FacturasDetalle 
INSTEAD OF INSERT 
AS 
BEGIN
	IF (SELECT ProductoId FROM inserted) NOT IN (SELECT ProductoId FROM Productos)
	BEGIN
		RAISERROR('Se ha detectado una amenaza',16,1);
	END
	ELSE 
	BEGIN
	INSERT INTO FacturasDetalle 
	SELECT * FROM inserted
	END
END


--ROW_COUNT
SELECT *, ROW_NUMBER() OVER (PARTITION BY Sexo ORDER BY ClienteId) Id 
FROM Clientes; 

--Funciones de clasificacion 

SELECT a.*,
ROW_NUMBER() OVER (ORDER BY Total DESC) AS RowNumber,
RANK() OVER (ORDER BY Total DESC) AS rRank,
DENSE_RANK() OVER (ORDER BY Total DESC) AS DenseRank,
NTILE(4) OVER (ORDER BY Total DESC) AS aNTILE
FROM 
(SELECT a.ClienteId, c.Nombre, SUM(Total) Total
FROM Facturas a INNER JOIN Clientes c ON a.ClienteId = c.ClienteId
INNER JOIN (SELECT  FacturaId, SUM(Cantidad * PrecioVenta) Total
FROM FacturasDetalle GROUP BY FacturaId) b ON a.FacturaId = b.FacturaId
GROUP BY a.ClienteId, c.Nombre)a
--ssss