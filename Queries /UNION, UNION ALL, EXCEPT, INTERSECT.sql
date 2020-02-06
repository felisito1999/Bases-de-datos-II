

Declare @Tabla1 Table
(
Letra char(1)
)

Declare @Tabla2 Table
(
Letra char(1)
)

INSERT INTO @Tabla1 values ('A'), ('B'), ('C')
INSERT INTO @Tabla2 values ('D'), ('B'), ('E')

Select Letra from @Tabla1
UNION ALL
Select Letra from @Tabla2

Select Letra from @Tabla1
UNION 
Select Letra from @Tabla2

Select Letra from @Tabla1
INTERSECT
Select Letra from @Tabla2

Select Letra from @Tabla1
EXCEPT
Select Letra from @Tabla2

SELECT Letra FROM @Tabla1
INTERSECT 
SELECT Letra FROM @Tabla2
