CREATE TABLE FormaPago(
	FormaPagoId INT NOT NULL CONSTRAINT PK_FormaPago PRIMARY KEY,
	Nombre VARCHAR(20)
	);

CREATE TABLE Pago(
	PagoId INT NOT NULL CONSTRAINT PK_Pago PRIMARY KEY,
	ClienteId INT NOT NULL CONSTRAINT FK_Cliente_Pago FOREIGN KEY REFERENCES Clientes(ClienteId),
	FormaPagoId INT NOT NULL CONSTRAINT FK_FormaPago_Pago FOREIGN KEY REFERENCES FormaPago(FormaPagoId),
	Fecha DATETIME NOT NULL,
	Total FLOAT NOT NULL,
	EstadoId INT NOT NULL CONSTRAINT FK_Estado_Pago FOREIGN KEY REFERENCES Estados(EstadoId)
	);

CREATE TABLE PagoDetalle(
	CodigoPago INT NOT NULL CONSTRAINT FK_Pagos_Detalle FOREIGN KEY REFERENCES Pago(PagoId),
	CodigoFactura INT NOT NULL CONSTRAINT FK_Factura_Cliente FOREIGN KEY REFERENCES Facturas(FacturaId),
	MontoPagado FLOAT NOT NULL,
	PRIMARY KEY(CodigoPago, CodigoFactura) 
	);

	INSERT INTO FormaPago VALUES(1, 'Efectivo');
	INSERT INTO FormaPago VALUES(2, 'Tarjeta');
	INSERT INTO FormaPago VALUES(3, 'Cheque');

	INSERT INTO Pago VALUES(1, 1, 1, GETDATE(), 100.00, 1); 
	INSERT INTO PagoDetalle VALUES(1,1,100.00);
	SELECT * FROM Pago;
	SELECT * FROM PagoDetalle;
	SELECT * , Cantidad * PrecioVenta FROM FacturasDetalle WHERE FacturaId = 1

--Vistas actualizables 
/*
	Cualquier modificacion, incluidas las instrucciones UPDATE, INSERT y DELETE debe hacer referencia a las columnas de una unica tabla base. 
*/

UPDATE vw_Clientes_Activos
SET Nombre = 'Cliente1 Actualizado'
WHERE Nombre = 'Cliente1';

UPDATE vw_Clientes_Activos
SET Sexo = 'Masculino'
WHERE Nombre = 'Cliente1 Actualizado'

ALTER VIEW vw_Clientes_Activos
AS
	SELECT a.ClienteId, a.Nombre, b.Nombres, CASE WHEN a.Sexo = 'm' THEN 'Masculino'
									 WHEN a.Sexo = 'f' THEN 'Femenino'
									 ELSE 'Indefinido' END AS Sexo FROM dbo.Clientes a INNER JOIN dbo.Estados b
	ON a.EstadoId = b.EstadoId WHERE a.EstadoId = 1 

SELECT * FROM vw_Clientes_Activos

UPDATE Clientes
SET Nombre = 'Cliente' + CONVERT(VARCHAR(10),ClienteId)
Select * from Clientes

--Interpreta el nulo como un valor 
SET ANSI_NULLS OFF
DECLARE @table1 TABLE 
(
id INT NULL
)

INSERT @table1 WHEER;

--Permite que se pueda o no redondear la cantidad de decimales que tiene cada una
SET NUMERIC_ROUNDABORT OFF 

DECLARE @r DECIMAL(5,2)
DECLARE @n1 DECIMAL(5,2) = 1.2453
DECLARE @n2 DECIMAL(5,2) = 1.2252

SET @r = @n1 + @n2
SELECT @r

--Para indexar una vista, verificar si la vista es determinisitica
SELECT * FROM sys.views WHERE NAME = 'vw_Clientes_Activos';

select * from vw_Clientes_Activos

SELECT object_id, NAME, COLUMNPROPERTY(OBJECT_ID, NAME, 'isDeterministic') IsDeterministic
FROM sys.columns
WHERE object_id = 2037582297;

--Solo las vistas que tengan todos sus campos deterministicos pueden ser indexadas
CREATE UNIQUE CLUSTERED INDEX PK_ClienteId 
	ON dbo.vw_Clientes_Activos (ClienteId);

CREATE NONCLUSTERED INDEX I_Nombre
	ON dbo.vw_Clientes_Activos (Nombre);

--Algunas vistas del sistema. Vistas padres(sys.object) y derivadas(sys.table) 

SELECT * FROM sys.objects;

SELECT * FROM sys.tables;

SELECT * FROM sys.views;

--Vistas particionadas, vistas con particiones
