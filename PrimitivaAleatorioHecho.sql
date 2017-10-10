CREATE DATABASE Primitiva

--DROP DATABASE Primitiva
--ROLLBACK

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
	ID BIGINT NOT NULL,
	FechaSorteo DATETIME NOT NULL,
	Reintegro TINYINT NULL,


	CONSTRAINT PK_Boletos PRIMARY KEY (ID),
	CONSTRAINT FK_Boletos_Sorteos FOREIGN KEY (FechaSorteo) REFERENCES Sorteos (Fecha) ON UPDATE CASCADE ON DELETE CASCADE

)

GO

CREATE TABLE Apuestas
(
	ID BIGINT NOT NULL,
	ID_Boleto BIGINT NOT NULL,
	Tipo BIT NOT NULL,
	Estado BIT NOT NULL DEFAULT 0, -- 1 Completa, 0 no.

	CONSTRAINT PK_Apuestas PRIMARY KEY (ID),
	CONSTRAINT FK_Apuestas_Boletos FOREIGN KEY (ID_Boleto) REFERENCES Boletos (ID) ON UPDATE CASCADE ON DELETE CASCADE
)

GO

CREATE TABLE Numeros
(
	Valor TINYINT NOT NULL,
	IDApuesta BIGINT NOT NULL,

	CONSTRAINT CK_1y49Numeros CHECK (Valor BETWEEN 1 AND 49),
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

CREATE TABLE Premios
(
	FechaSorteo DATETIME NOT NULL,
	
	CONSTRAINT PK_Premios PRIMARY KEY (FechaSorteo),
	CONSTRAINT FK_Premios_Sorteos FOREIGN KEY (FechaSorteo) REFERENCES Sorteos (Fecha) ON UPDATE CASCADE ON DELETE CASCADE

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

		IF (CURRENT_TIMESTAMP > @FechaAux OR (DATEDIFF (MINUTE, CURRENT_TIMESTAMP, @FechaAux) <= 60))
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

/*
CREATE FUNCTION ComprobarDisponibilidad (@FechaSorteo DATETIME)
RETURNS BIT AS

	BEGIN
		DECLARE @Resultado BIT
		SET @Resultado = 0

		IF EXISTS (SELECT *
					FROM Sorteos
					WHERE Fecha = @FechaSorteo) --AND DATEDIFF (MINUTE, @FechaSorteo, CURRENT_TIMESTAMP) > 60)

					BEGIN
						SET @Resultado = 1
					END

		RETURN @Resultado
	END

GO
*/

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
			DECLARE @IDBoleto BIGINT
			SET @IDBoleto = (SELECT MAX (ID) + 1
							FROM Boletos)

			DECLARE @IDApuesta BIGINT
			SET @IDApuesta = (SELECT MAX (ID) + 1
								FROM Apuestas)

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

					UPDATE Apuestas
					SET Estado = 1
					WHERE ID = @IDApuesta
				COMMIT TRANSACTION
	END

GO

--De momento genera bien los 6 numeros sin repetirse pero no los introduce bien en la tabla numeros

--LO DE ABAJO ESTA SOLUCIONADO, SE SUPONE QUE EL PROCEDURE YA VA PERFECTO

--!!!!!!!!!!!!!COÑO LA TABLA TEMPORAL DE NUMEROS NO SE BORRA, PRIMERO SE METEN 6, DESPUES 12, 
--!!!!!!!!!!!!!DESPUES 18 ETCETCETC HAY QUE BORRARLA DESPUES DE CADA INSERT EN APUESTA
--!!ª!!!!!!ª·ª"qwahser&·w%&j$%"jk&i·%%&j%%tykstjaerjyhkaWKRHASERKETYKEWR
CREATE PROCEDURE GrabaSencillaAleatoria (@fechaSorteo DATETIME, @numeroApuestas TINYINT)
AS
	BEGIN
		DECLARE @IDBoleto BIGINT
		SET @IDBoleto = (SELECT MAX (ID) + 1
							FROM Boletos)

		DECLARE @IDApuesta BIGINT
		--SET @IDApuesta = NEWID () -- Usabamos el mismo id de apuesta para todas ellas
		IF (@numeroApuestas < 9 AND @numeroApuestas > 0)
		BEGIN
			INSERT INTO Boletos (ID, FechaSorteo, Reintegro)
			VALUES
			(@IDBoleto, @FechaSorteo, RAND () * 10)

			DECLARE @iteraciones INT
			SET @iteraciones=0;
			
			DECLARE @tablaNumeros TABLE(
			Numero TINYINT
			)

			DECLARE @iteraciones2 TINYINT
			DECLARE @numeroRandom TINYINT
			WHILE(@numeroApuestas>@iteraciones)
			BEGIN
				SET @IDApuesta = (SELECT MAX (ID) + 1
									FROM Apuestas) -- Generamos un nuevo id de apuesta cada para cada apuesta
				INSERT INTO Apuestas (ID, ID_Boleto, Tipo)
				VALUES
				(@IDApuesta, @IDBoleto, 0) --Apuesta simple

				SET @iteraciones2 = 0
				

				WHILE(@iteraciones2<6)
				BEGIN
					SET @numeroRandom = RAND () * (49) + 1
					IF (@numeroRandom not in (SELECT * FROM @tablaNumeros))
					BEGIN
						INSERT INTO @tablaNumeros(Numero)
						VALUES
						(@numeroRandom)
						SET @iteraciones2+=1
					END
				END
				--SELECT * FROM @tablaNumeros

				INSERT INTO Numeros (Valor, IDApuesta)
				SELECT Numero,@IDApuesta from @tablaNumeros 
				--(SELECT Numero, @IDApuesta FROM @tablaNumeros) La variable tabla tablaNumeros no tiene IDApuesta
				DELETE @tablaNumeros
				SET @iteraciones = @iteraciones+1;

				UPDATE Apuestas
				SET Estado = 1
				WHERE ID = @IDApuesta
			END
		END
		ELSE
		BEGIN
			Print 'NEIN'
		END
	END


	GO


CREATE PROCEDURE GrabaMuchasSencillas (@fechaSorteo DATETIME, @numeroBoletos INT)
AS
	BEGIN
		DECLARE @iteraciones INT
		SET @iteraciones=0
		WHILE(@numeroBoletos>@iteraciones)
		BEGIN
			EXECUTE GrabaSencillaAleatoria @fechaSorteo, 1
			SET @iteraciones=@iteraciones+1
		END
END

	GO

CREATE PROCEDURE GrabaMultiple
	@FechaSorteo DATETIME,
	@Num_1 TINYINT,
	@Num_2 TINYINT,
	@Num_3 TINYINT,
	@Num_4 TINYINT,
	@Num_5 TINYINT,
	@Num_6 TINYINT = NULL,
	@Num_7 TINYINT = NULL,
	@Num_8 TINYINT = NULL,
	@Num_9 TINYINT = NULL,
	@Num_10 TINYINT = NULL,
	@Num_11 TINYINT = NULL
AS
	BEGIN
		BEGIN TRANSACTION
		
		DECLARE @IDBoleto BIGINT = (SELECT MAX (ID) + 1
									FROM Boletos)
		DECLARE @IDApuesta BIGINT = (SELECT MAX (ID) + 1
									FROM Apuestas)
				INSERT INTO Boletos (ID, FechaSorteo, Reintegro)
					VALUES
					(@IDBoleto, @FechaSorteo, RAND () * 10)

				INSERT INTO Apuestas (ID, ID_Boleto, Tipo)
					VALUES
					(@IDApuesta, @IDBoleto, 1)
		
				--PROPUESTA1 por JavierGlez revisada y aprobada por Aquarius man, en espera de que el carry Goumes de luz verde. 
				-- .
				-- .
				-- .
				-- .
				-- .
				-- .
				-- El carry Goumes da luz verde, pero con una pequeña modificación.
				-- Fran jugó lee sin support.
				INSERT INTO Numeros (IDApuesta,	Valor)
					VALUES
					(@IDApuesta, @Num_1),
					(@IDApuesta, @Num_2),
					(@IDApuesta, @Num_3),
					(@IDApuesta, @Num_4),
					(@IDApuesta, @Num_5)
				IF @Num_6!=NULL
				BEGIN
					INSERT INTO Numeros (IDApuesta, Valor)
						VALUES
						(@IDApuesta, @Num_6)
				END
				IF @Num_7!=NULL
				BEGIN
					INSERT INTO Numeros (IDApuesta, Valor)
						VALUES
						(@IDApuesta, @Num_7)
				END
				IF @Num_8!=NULL
				BEGIN
					INSERT INTO Numeros (IDApuesta, Valor)
						VALUES
						(@IDApuesta, @Num_8)
				END
				IF @Num_9!=NULL
				BEGIN
					INSERT INTO Numeros (IDApuesta, Valor)
						VALUES
						(@IDApuesta, @Num_9)
				END
				IF @Num_10!=NULL
				BEGIN
					INSERT INTO Numeros (IDApuesta, Valor)
						VALUES
						(@IDApuesta, @Num_10)
				END
				IF @Num_11!=NULL
				BEGIN
					INSERT INTO Numeros (IDApuesta, Valor)
						VALUES
						(@IDApuesta, @Num_11)
				END
				--FIN PROPUESTA1

				-- Ayyyy esas cabezas...
				UPDATE Apuestas
				SET Estado = 1
				WHERE ID = @IDApuesta

				COMMIT TRANSACTION
			END

GO

-- Empieza la tralla del martes tarde
-- Si después de modificar una apuesta a estado cerrada no tiene 6 numeros, hacer rollback y dejar el estado a en proceso.

CREATE TRIGGER numeroApuestaSencilla ON Apuestas
AFTER UPDATE AS
BEGIN
	DECLARE @numero INT

	IF EXISTS(SELECT * FROM inserted WHERE Tipo = 0)
	BEGIN
		SELECT @numero = COUNT (N.Valor)
		FROM inserted as A
		INNER JOIN
		Numeros AS N
		ON A.ID = N.IDApuesta
		WHERE Tipo = 0

		IF (@numero != 6)
		BEGIN
			ROLLBACK
			/*UPDATE Apuestas
			SET Estado = 0
			WHERE ID = (SELECT ID FROM inserted)*/
		END
	END

END

GO

--Lo mismo pero para multiple
CREATE TRIGGER numeroApuestaMultiple ON Apuestas
AFTER UPDATE AS
BEGIN
	DECLARE @numero INT

	IF EXISTS(SELECT * FROM inserted WHERE Tipo = 1)
	BEGIN
		SELECT @numero = COUNT (N.Valor)
		FROM inserted as A
		INNER JOIN
		Numeros AS N
		ON A.ID = N.IDApuesta
		WHERE Tipo = 1

		IF (@numero < 5 OR @numero = 6 OR @numero > 11)
		BEGIN
			ROLLBACK
			/*UPDATE Apuestas
			SET Estado = 0
			WHERE ID = (SELECT ID FROM inserted)*/
		END
	END

	/*ELSE
	BEGIN
		ROLLBACK	
	END*/   -- Invertimos el IF
END

GO

CREATE TRIGGER NumeroApuestasPorBoleto ON Apuestas
AFTER INSERT AS
BEGIN
	DECLARE @IDBoleto BIGINT
	SELECT @IDBoleto = ID_Boleto FROM inserted

	IF ((SELECT COUNT (ID)
			FROM Apuestas
			WHERE ID_Boleto = @IDBoleto AND Tipo = 1) > 1)
			BEGIN
				ROLLBACK
			END

END

GO



-- COMIENZO PRUEBAS
BEGIN TRANSACTION

INSERT INTO Sorteos(Fecha,Reintegro,Complementario)
VALUES
('10-10-2017 15:34:09', 4, 5)

EXECUTE GrabaSencilla '5-10-2017 13:34:09', 1, 5, 34, 32, 12 ,24 --Probando numeros válidos. Funciona flama

EXECUTE GrabaSencilla '5-10-2017 13:34:09', 1, 5, 34, 34, 12 ,24 --Probando numeros repetidos. Funciona flama

EXECUTE GrabaSencilla '5-10-2017 13:34:09', 1, 5, 0, 32, 12 ,24 -- Probando numeros no admitidos

EXECUTE GrabaSencilla '5-12-2017 13:34:09', 1, 5, 0, 32, 12 ,24 -- Probando Sorteo erroneo

EXECUTE GrabaSencillaAleatoria '5-10-2017 15:34:09', 5 --Probando caso correcto

EXECUTE GrabaSencillaAleatoria '5-10-2017 15:34:09', 9 --Probando caso incorrecto

EXECUTE GrabaSencillaAleatoria '5-10-2017 15:34:09', 0 --Probando caso incorrecto
BEGIN TRANSACTION

INSERT INTO Boletos (ID, FechaSorteo, Reintegro)
VALUES (1, '10-10-2017 15:34:09', 4)

INSERT INTO Apuestas (ID, ID_Boleto, Tipo)
VALUES (1, 1, 0)

INSERT INTO Numeros (IDApuesta, Valor)
VALUES
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(1, 5),
(1, 6)

UPDATE Apuestas
SET Estado = 1
WHERE ID = 1

GO

EXECUTE GrabaMuchasSencillas '10-10-2017 15:34:09', 10000 -- Probando caso correcto


SELECT * 
FROM Boletos

SELECT *
FROM Sorteos

SELECT * 
FROM Apuestas

SELECT *
FROM Numeros

ROLLBACK

COMMIT TRANSACTION

 -- FIN PRUEBAS

BEGIN TRANSACTION

INSERT INTO Sorteos(Fecha,Reintegro,Complementario)
VALUES
('18-06-2015 13:34:09', 4, 5)
EXECUTE GrabaSencillaAleatoria '18-06-2015 13:34:09',8
--DELETE from Sorteos where Fecha='18-06-2015 13:34:09'
--DELETE from Numeros
select * from Sorteos
select * from boletos
select * from Apuestas
select * from Numeros

COMMIT TRANSACTION

GO

BEGIN TRANSACTION

--CREAR TRIGGER PARA REINTEGRO AL GENERAR BOLETO -- YA NO


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

rollback