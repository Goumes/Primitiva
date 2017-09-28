CREATE DATABASE Primitiva

--DROP DATABASE Primitiva

GO

USE Primitiva

GO

CREATE TABLE Sorteos
(
	Fecha DATETIME NOT NULL,
	Reintegro TINYINT NOT NULL,
	Complementario TINYINT NOT NULL,

	CONSTRAINT PK_Sorteos PRIMARY KEY (Fecha)
)

GO

CREATE TABLE Boletos
(
	ID UNIQUEIDENTIFIER NOT NULL,
	FechaSorteo DATETIME NOT NULL,
	Reintegro TINYINT NULL,


	CONSTRAINT PK_Boletos PRIMARY KEY (ID),
	CONSTRAINT FK_Boletos_Sorteos FOREIGN KEY (FechaSorteo) REFERENCES Sorteos (Fecha) ON UPDATE CASCADE ON DELETE CASCADE

)

GO

CREATE TABLE Apuestas
(
	ID UNIQUEIDENTIFIER NOT NULL,
	ID_Boleto UNIQUEIDENTIFIER NOT NULL,
	Tipo BIT NOT NULL,

	CONSTRAINT PK_Apuestas PRIMARY KEY (ID),
	CONSTRAINT FK_Apuestas_Boletos FOREIGN KEY (ID_Boleto) REFERENCES Boletos (ID) ON UPDATE CASCADE ON DELETE CASCADE
)

GO

CREATE TABLE Numeros
(
	Valor TINYINT NOT NULL,
	IDApuesta UNIQUEIDENTIFIER NOT NULL,

	CONSTRAINT PK_Numeros PRIMARY KEY (Valor, IDApuesta),
	CONSTRAINT FK_Numeros_Apuestas FOREIGN KEY (IDApuesta) REFERENCES Apuestas (ID) ON UPDATE CASCADE ON DELETE CASCADE
)

GO

CREATE TABLE NumerosSorteo
(
	Valor TINYINT NOT NULL,
	FechaSorteo DATETIME NOT NULL,

	CONSTRAINT PK_NumerosSorteo PRIMARY KEY (Valor, FechaSorteo),
	CONSTRAINT FK_Numeros_Sorteo FOREIGN KEY (FechaSorteo) REFERENCES Sorteos (Fecha) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT CK_1y49Sorteo CHECK (Valor BETWEEN 1 AND 49)
)

GO

CREATE TRIGGER HoraRestante ON Boletos
AFTER INSERT AS
BEGIN

	DECLARE @FechaAux DATETIME

	IF EXISTS (SELECT * FROM inserted)
	BEGIN
		SELECT @FechaAux = FechaSorteo 
		FROM inserted

		IF ((DATEDIFF (HOUR, @FechaAux, CURRENT_TIMESTAMP) < 1))
		BEGIN
			ROLLBACK
		END
	END
END

GO

CREATE TRIGGER NoModificar ON Numeros
AFTER UPDATE AS
BEGIN
	IF EXISTS (SELECT * FROM inserted)
	BEGIN
		ROLLBACK
	END
END

GO


CREATE TRIGGER ApuestaSencilla6 ON Numeros
AFTER INSERT AS
BEGIN
	IF EXISTS (SELECT * FROM inserted)
	BEGIN
		IF EXISTS (SELECT * 
					FROM inserted AS I
					INNER JOIN
					Apuestas AS A
					ON I.IDApuesta = A.ID
					WHERE Tipo = 0) -- Si la apuesta es simple.
		BEGIN

		IF EXISTS(SELECT COUNT (Valor)
					FROM Numeros AS N
					INNER JOIN
					Apuestas AS A
					ON N.IDApuesta = A.ID
					HAVING COUNT (Valor) = 6) --Si la apuesta ya tiene seis números y se inserta otro
			BEGIN
				ROLLBACK
			END
		END
	END
END

GO

CREATE FUNCTION ComprobarDisponibilidad (@FechaSorteo DATETIME)
RETURNS BIT AS

	BEGIN
		DECLARE @Resultado BIT
		SET @Resultado = 0

		IF EXISTS (SELECT *
					FROM Sorteos
					WHERE Fecha = @FechaSorteo AND DATEDIFF (MINUTE, @FechaSorteo, CURRENT_TIMESTAMP) > 60)

					BEGIN
						SET @Resultado = 1
					END

		RETURN @Resultado
	END

GO


CREATE PROCEDURE GrabaSencilla
	@FechaSorteo DATETIME,
	@Num_1 TINYINT, 
	@Num_2 TINYINT,
	@Num_3 TINYINT,
	@Num_4 TINYINT,
	@Num_5 TINYINT,
	@Num_6 TINYINT
AS
	BEGIN
			DECLARE @IDBoleto UNIQUEIDENTIFIER
			SET @IDBoleto = NEWID ()

			DECLARE @IDApuesta UNIQUEIDENTIFIER
			SET @IDApuesta = NEWID ()

		BEGIN TRANSACTION

			INSERT INTO Boletos (ID, FechaSorteo, Reintegro)
			VALUES
			(@IDBoleto, @FechaSorteo, RAND () * 10)

			INSERT INTO Apuestas (ID, ID_Boleto, Tipo)
			VALUES
			(@IDApuesta, @IDBoleto, 0) --Apuesta simple

			INSERT INTO Numeros (Valor, IDApuesta)
			VALUES
			(@Num_1, @IDApuesta),
			(@Num_2, @IDApuesta),
			(@Num_3, @IDApuesta),
			(@Num_4, @IDApuesta),
			(@Num_5, @IDApuesta),
			(@Num_6, @IDApuesta)
		COMMIT TRANSACTION
	END

BEGIN TRANSACTION

--CREAR TRIGGER PARA REINTEGRO AL GENERAR BOLETO


INSERT INTO Sorteos (Fecha, Reintegro, Complementario)
VALUES
('18-06-2012 13:34:09', 4, 2)


INSERT INTO NumerosSorteo (Valor, FechaSorteo)
VALUES
(45, '18-06-2012 13:34:09'),
(3, '18-06-2012 13:34:09'),
(14, '18-06-2012 13:34:09'),
(43, '18-06-2012 13:34:09'),
(12, '18-06-2012 13:34:09'),
(35, '18-06-2012 13:34:09')


--DECLARE @ID UNIQUEIDENTIFIER = NEWID ()

INSERT INTO Boletos (ID, FechaSorteo)
VALUES 
(NEWID (), '18-06-2012 13:34:09')

COMMIT TRANSACTION

ROLLBACK

SELECT *
	FROM Sorteos AS S
	INNER JOIN
	Boletos AS B
	ON S.Fecha = B.FechaSorteo
	INNER JOIN
	NumerosSorteo AS NS
	ON S.Fecha = NS.FechaSorteo

	SELECT * FROM Boletos

GO

CREATE PROCEDURE GrabaMuchasSencillas (@fechaSorteo DATETIME, @numeroBoletos INT)
AS
	BEGIN
		DECLARE @iteraciones INT
		SET @iteraciones=1
		WHILE(@numeroBoletos<@iteraciones)
		BEGIN
			EXECUTE GrabaSencilla @fechaSorteo, 2,3,1,5,7,34
			SET @iteraciones=@iteraciones+1
		END
	END