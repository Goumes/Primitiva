CREATE DATABASE Primitiva

--use master DROP DATABASE Primitiva
--ROLLBACK

GO

USE Primitiva

GO

CREATE TABLE Sorteos
(
	Fecha DATETIME NOT NULL,
	Reintegro TINYINT NOT NULL,
	Complementario TINYINT NULL,

	CONSTRAINT PK_Sorteos PRIMARY KEY (Fecha)
)

GO

CREATE TABLE Boletos
(
	ID BIGINT NOT NULL,
	FechaSorteo DATETIME NOT NULL,
	Reintegro BIT NULL,
	Premio MONEY DEFAULT 0 NOT NULL,


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
	Premio MONEY NULL,

	CONSTRAINT PK_Apuestas PRIMARY KEY (ID),
	CONSTRAINT FK_Apuestas_Boletos FOREIGN KEY (ID_Boleto) REFERENCES Boletos (ID) ON UPDATE CASCADE ON DELETE CASCADE
)

GO

CREATE TABLE Numeros
(
	Valor TINYINT NOT NULL,
	IDApuesta BIGINT NOT NULL,

	CONSTRAINT CK_1y49Numeros CHECK (Valor BETWEEN 1 AND 49),
	CONSTRAINT PK_Numeros PRIMARY KEY (IDApuesta, Valor),
	CONSTRAINT FK_Numeros_Apuestas FOREIGN KEY (IDApuesta) REFERENCES Apuestas (ID) ON UPDATE CASCADE ON DELETE CASCADE
)

GO

CREATE TABLE NumerosSorteo
(
	Valor TINYINT NOT NULL,
	FechaSorteo DATETIME NOT NULL,

	CONSTRAINT PK_NumerosSorteo PRIMARY KEY (FechaSorteo, Valor),
	CONSTRAINT FK_Numeros_Sorteo FOREIGN KEY (FechaSorteo) REFERENCES Sorteos (Fecha) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT CK_1y49Sorteo CHECK (Valor BETWEEN 1 AND 49)
)

GO

CREATE TABLE Premios
(
	FechaSorteo DATETIME NOT NULL,
	Categoria1 MONEY NOT NULL,
	Categoria2 MONEY NOT NULL,
	Categoria3 MONEY NOT NULL,
	Categoria4 MONEY NOT NULL,
	Categoria5 MONEY NOT NULL,
	CategoriaE MONEY NOT NULL,
	Reintegro MONEY NULL

	
	CONSTRAINT PK_Premios PRIMARY KEY (FechaSorteo),
	CONSTRAINT FK_Premios_Sorteos FOREIGN KEY (FechaSorteo) REFERENCES Sorteos (Fecha) ON UPDATE CASCADE ON DELETE CASCADE

)

GO

CREATE TABLE Aciertos
(
	Pronostico TINYINT NOT NULL,
	NumerosAcertados VARCHAR (10) NOT NULL,
	--FechaSorteo DATETIME NOT NULL,
	Categoria1 TINYINT NULL,
	Categoria2 TINYINT NULL,
	Categoria3 TINYINT NULL,
	Categoria4 TINYINT NULL,
	Categoria5 TINYINT NULL,
	CategoriaE TINYINT NULL,
	Reintegro BIT NOT NULL DEFAULT 0,
	Complementario BIT NOT NULL DEFAULT 0,

	CONSTRAINT PK_Aciertos PRIMARY KEY (Pronostico, NumerosAcertados, Reintegro, Complementario)--,
	--CONSTRAINT FK_Aciertos_Sorteos FOREIGN KEY (FechaSorteo) REFERENCES Sorteos (Fecha) ON UPDATE CASCADE ON DELETE NO ACTION
) 

GO
/*
Resumen: Restriccion a la entrada de un boleto fuera de tiempo
Precondiciones: Insert de boleto creado
Entrada: El insert de boleto
Salida: En caso correcto inserta el boleto, en caso incorrecto hace rollback
Postcondiciones: El boleto queda insertado o no
*/
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

INSERT INTO Aciertos (Pronostico, NumerosAcertados, Categoria1,Categoria2,Categoria3, Categoria4, Categoria5, CategoriaE)
VALUES
(5, '2', NULL, NULL, NULL, NULL, 4, NULL),

(5, '3', NULL, NULL, NULL, 3, 41, NULL),
(7, '3', NULL, NULL, NULL, NULL, 4, NULL),
(8, '3', NULL, NULL, NULL, NULL, 10, NULL),
(9, '3', NULL, NULL, NULL, NULL, 20, NULL),
(10, '3', NULL, NULL, NULL, NULL, 35, NULL),
(11, '3', NULL, NULL, NULL, NULL, 56, NULL),

(5, '4', NULL, NULL, 2, 42, NULL, NULL),
(7, '4', NULL, NULL, NULL, 3, 4, NULL),
(8, '4', NULL, NULL, NULL, 6, 16, NULL),
(9, '4', NULL, NULL, NULL, 10, 40, NULL),
(10, '4', NULL, NULL, NULL, 15, 80, NULL),
(11, '4', NULL, NULL, NULL, 21, 140, NULL),



(5, '5', 1, 1, 42, NULL, NULL, NULL),
(7, '5', NULL, NULL, 2, 5, NULL, NULL),
(8, '5', NULL, NULL, 3, 15, 10, NULL),
(9, '5', NULL, NULL, 4, 30, 40, NULL),
(10, '5', NULL, NULL, 5, 50, 100, NULL),
(11, '5', NULL, NULL, 6, 75, 200, NULL),



(7, '6', 1, NULL, 6, NULL, NULL, NULL),
(8, '6', 1, NULL, 12, 15, NULL, NULL),
(9, '6', 1, NULL, 18, 45, 20, NULL),
(10, '6', 1, NULL, 24, 90, 80, NULL),
(11, '6', 1, NULL, 30, 150, 200, NULL)


INSERT INTO Aciertos (Pronostico, NumerosAcertados, Categoria1,Categoria2,Categoria3, Categoria4, Categoria5, CategoriaE, Reintegro, Complementario)
VALUES

(5, '4', NULL, 2, NULL, 42, NULL, NULL, 0, 1), --C

(5, '5', 1, 1, 42, NULL, NULL, 1, 1, 0), --R

(7, '5', NULL, 1, 1, 5, NULL, NULL, 0, 1), --C
(8, '5', NULL, 1, 2, 15, 10, NULL, 0, 1), --C
(9, '5', NULL, 1, 3, 30, 40, NULL, 0, 1), --C
(10, '5', NULL, 1, 4, 50, 100, NULL, 0, 1), --C
(11, '5', NULL, 1, 5, 75, 200, NULL, 0 ,1), --C

(7, '6', 1, 6, NULL, NULL, NULL, NULL, 0, 1), -- C
(8, '6', 1, 6, 6, 15, NULL, NULL, 0, 1), -- C
(9, '6', 1, 6, 12, 45, 20, NULL, 0, 1), -- C
(10, '6', 1, 6, 18, 90, 80, NULL, 0, 1), -- C
(11, '6', 1, 6, 24, 150, 200, NULL, 0, 1), -- C

(7, '6', 1, NULL, 6, NULL, NULL, 1, 1, 0), -- R
(8, '6', 1, NULL, 12, 15, NULL, 1, 1, 0), -- R
(9, '6', 1, NULL, 18, 45, 20, 1, 1, 0), -- R
(10, '6', 1, NULL, 24, 90, 80, 1, 1, 0), -- R
(11, '6', 1, NULL, 30, 150, 200, 1, 1, 0), -- R

(7, '6', 1, 6, NULL, NULL, NULL, 1, 1, 1), -- RC
(8, '6', 1, 6, 6, 15, NULL, 1, 1, 1), -- RC
(9, '6', 1, 6, 12, 45, 20, 1, 1, 1), -- RC
(10, '6', 1, 6, 18, 90, 80, 1, 1, 1), -- RC
(11, '6', 1, 6, 24, 150, 200, 1, 1, 1) -- RC
GO

/*
Resumen: No permite modificar los numeros de una apuesta
Precondiciones: Que haya numeros
Entrada: Actualizacion de tabla Numeros
Salida: Rollback
Postcondiciones: No se actualiza la tabla Numeros
*/
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
Resumen: Crea un boleto y graba en el una apuesta sencilla
Precondiciones: Nada
Entrada: La fecha del sorteo y los 6 numeros de la apuesta
Salida: El boleto y la apuesta creada
Postcondiciones: Boleto creado correctamente si no hay un error en los numeros
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

/*
Resumen: Graba una apuesta sencilla generada aleatoriamente en un boleto
Precondiciones: Nada
Entrada: Fecha del sorteo y la cantidad de apuestas que quieres crear (se genera un boleto por cada apuesta)
Salida: Todos los boletos con las apuestas generadas aleatoriamente
Postcondiciones: Todas las apuestas quedan grabadas en la base de datos
*/
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
					SET @numeroRandom = FLOOR (RAND () * (49) + 1)
					IF (@numeroRandom not in (SELECT * FROM @tablaNumeros))
					BEGIN
						INSERT INTO @tablaNumeros(Numero)
						VALUES
						(@numeroRandom)
						SET @iteraciones2+=1
					END
				END
				
				
				INSERT INTO Numeros (IDApuesta, Valor)
				SELECT @IDApuesta, Numero from @tablaNumeros 

				DELETE @tablaNumeros
				
				
				SET @iteraciones = @iteraciones+1;

				UPDATE Apuestas
				SET Estado = 1
				WHERE ID = @IDApuesta

			END
		END
		ELSE
		BEGIN
			Print 'NEIN' -- Poner un RaiseError y esas cosas
		END
	END


GO


/*
Resumen: Genera los numeros del sorteo y el complementario y los inserta en sus correspondientes tablas
Precondiciones: Nada
Entrada: Fecha del sorteo
Salida: Los numeros del sorteo y el complementario
Postcondiciones: Los numeros y el complementario quedan grabados en la base de datos
*/
CREATE PROCEDURE GeneraNumerosSorteo (@fechaSorteo DATETIME) 
AS
	BEGIN			
		DECLARE @tablaNumeros TABLE(
		Numero TINYINT
		)

		DECLARE @iteraciones2 TINYINT
		SET @iteraciones2 = 0
		DECLARE @numeroRandom TINYINT
		DECLARE @complementario TINYINT

		WHILE(@iteraciones2<7)
		BEGIN
			
			SET @numeroRandom = RAND () * (49) + 1
			IF (@numeroRandom not in (SELECT * FROM @tablaNumeros))
				BEGIN
				IF (@iteraciones2<6)
				BEGIN
					INSERT INTO @tablaNumeros(Numero)
					VALUES
					(@numeroRandom)
					SET @iteraciones2+=1
				END
				ELSE
				BEGIN
					SET @complementario = @numeroRandom
					SET @iteraciones2+=1
				END
			END
		END
				
				
		INSERT INTO NumerosSorteo(FechaSorteo, Valor)
		SELECT @fechaSorteo, Numero from @tablaNumeros 

		UPDATE Sorteos
		SET Complementario = @complementario
		WHERE Fecha = @fechaSorteo

		DELETE @tablaNumeros
	END


GO

/*
Resumen: Graba un numero indeterminado de apuestas aleatorias, una por boleto
Precondiciones: El procedimiento GrabaSencillaAleatoria debe estar implementado
Entrada: fecha del sorteo, cantidad de apuestas
Salida: numero de boletos y apuestas introducidas
Postcondiciones: Las apuestas quedan grabadas en la base de datos
*/

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

/*
Resumen: Graba una apuesta multiple, de 5 a 11 numeros, en un nuevo boleto
Precondiciones: Nada
Entrada: fecha sorteo, numeros de la apuesta (5-11)
Salida: boleto generado
Postcondiciones: La apuesta multiple queda grabada en la base de datos
*/
CREATE PROCEDURE GrabaMultiple
	@FechaSorteo DATETIME,
	@Num_1 TINYINT,
	@Num_2 TINYINT,
	@Num_3 TINYINT,
	@Num_4 TINYINT,
	@Num_5 TINYINT,
	@Num_6 TINYINT  = NULL,
	@Num_7 TINYINT  = NULL,
	@Num_8 TINYINT  = NULL,
	@Num_9 TINYINT  = NULL,
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
					(@IDBoleto, @FechaSorteo,FLOOR (RAND () * 10))

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
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!! ESTO ESTA MAL, solo mete apuestas de 5 !!!!!!!!!!! -> Ya va no problem
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				INSERT INTO Numeros (IDApuesta,	Valor)
					VALUES
					(@IDApuesta, @Num_1),
					(@IDApuesta, @Num_2),
					(@IDApuesta, @Num_3),
					(@IDApuesta, @Num_4),
					(@IDApuesta, @Num_5)
				IF @Num_6 IS NOT NULL
				BEGIN
					INSERT INTO Numeros (IDApuesta, Valor)
						VALUES
						(@IDApuesta, @Num_6)
				END
				IF @Num_7 IS NOT NULL
				BEGIN
					INSERT INTO Numeros (IDApuesta, Valor)
						VALUES
						(@IDApuesta, @Num_7)
				END
				IF @Num_8 IS NOT NULL
				BEGIN
					INSERT INTO Numeros (IDApuesta, Valor)
						VALUES
						(@IDApuesta, @Num_8)
				END
				IF @Num_9 IS NOT NULL
				BEGIN
					INSERT INTO Numeros (IDApuesta, Valor)
						VALUES
						(@IDApuesta, @Num_9)
				END
				IF @Num_10 IS NOT NULL
				BEGIN
					INSERT INTO Numeros (IDApuesta, Valor)
						VALUES
						(@IDApuesta, @Num_10)
				END
				IF @Num_11 IS NOT NULL
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

/*
Resumen: Comprueba que la apuesta sencilla tenga 6 numeros
Precondiciones: Se inserta una apuesta simple en el sistema
Postcondiciones: Si tiene mas o menos de 6 numeros, hace rollback
*/
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
/*
Resumen: Comprueba que las apuestas múltiples tengan entre 5 y 11 números, pero no 6
Precondiciones: Se inserta una apuesta multiple en el sistema
Postcondiciones: Si la cantidad de números de la apuesta es erróneo, hace rollback
*/

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

/*
Resumen: Comprueba que en un boleto solo haya una apuesta múltiple
Precondiciones: Se inserta un boleto en el sistema
Postcondiciones: Si el boleto contiene más de una apuesta múltiple, hace rollback
*/
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

-- PROCEDIMIENTOS DE RECOLECCION DE APUESTAS
/*
Resumen: Cuenta cuántas apuestas sencillas hay en un sorteo
Precondiciones: El sorteo existe
Entrada: fecha del sorteo
Salida: cantidad de apuestas sencillas en el sorteo
Postcondiciones: Devuelve la cantidad de apuestas sencillas en el sorteo
*/
CREATE FUNCTION RecoleccionApuestasSencillas (@fechaSorteo DATETIME)
RETURNS INT	AS
		BEGIN
			DECLARE @totalSencillas INT
			SET @totalSencillas=0

			SET @totalSencillas = (SELECT COUNT (*)
								FROM Apuestas
								WHERE Tipo = 0 AND Estado = 1)
			RETURN @totalSencillas
		END
	GO

/*
Resumen: Cuenta cuántas apuestas múltiples hay en un sorteo
Precondiciones: El sorteo existe
Entrada: fecha del sorteo
Salida: cantidad de apuestas múltiples en el sorteo
Postcondiciones: Devuelve la cantidad de apuestas múltiples en el sorteo
*/
CREATE FUNCTION RecoleccionApuestasMultiples (@fechaSorteo DATETIME)
RETURNS INT	AS
		BEGIN 
			DECLARE @totalMultiples INT
			SET @totalMultiples=0
			DECLARE @numerosApuesta INT
			SET @numerosApuesta=0
			DECLARE @IDApuesta INT 
			SET @IDApuesta =0 

			BEGIN

				SET @numerosApuesta = (SELECT COUNT (*)
									FROM Apuestas AS A
									WHERE Tipo = 1 AND Estado = 1 AND (SELECT COUNT (*)
																		FROM Numeros AS N WHERE A.ID=N.IDApuesta)=5
									)

				SET @totalMultiples += @numerosApuesta * 44

				SET @numerosApuesta = (SELECT COUNT (*)
									FROM Apuestas AS A
									WHERE Tipo = 1 AND Estado = 1 AND (SELECT COUNT (*)
																		FROM Numeros AS N WHERE A.ID=N.IDApuesta)=7
									)
				SET @totalMultiples += @numerosApuesta * 7


				SET @numerosApuesta = (SELECT COUNT (*)
									FROM Apuestas AS A
									WHERE Tipo = 1 AND Estado = 1 AND (SELECT COUNT (*)
																		FROM Numeros AS N WHERE A.ID=N.IDApuesta)=8
									)
				SET @totalMultiples += @numerosApuesta * 28


				SET @numerosApuesta = (SELECT COUNT (*)
									FROM Apuestas AS A
									WHERE Tipo = 1 AND Estado = 1 AND (SELECT COUNT (*)
																		FROM Numeros AS N WHERE A.ID=N.IDApuesta)=9
									)
				SET @totalMultiples += @numerosApuesta * 84


				SET @numerosApuesta = (SELECT COUNT (*)
									FROM Apuestas AS A
									WHERE Tipo = 1 AND Estado = 1 AND (SELECT COUNT (*)
																		FROM Numeros AS N WHERE A.ID=N.IDApuesta)=10
									)
				SET @totalMultiples += @numerosApuesta * 210


				SET @numerosApuesta = (SELECT COUNT (*)
									FROM Apuestas AS A
									WHERE Tipo = 1 AND Estado = 1 AND (SELECT COUNT (*)
																		FROM Numeros AS N WHERE A.ID=N.IDApuesta)=11
									)
				SET @totalMultiples += @numerosApuesta * 462


			END
			RETURN @totalMultiples
				
		END

	GO

/*
Resumen: Calcula los fondos totales destinados a cada categoria del sorteo
Precondiciones: El sorteo existe
Entrada: fecha del sorteo
Salida: Premio para cada categoría
Postcondiciones: Inserta en la tabla premios el total destinado a cada categoría
*/
CREATE PROCEDURE PremioPorCategoria (@fechaSorteo DATETIME)
AS
	BEGIN
		DECLARE @TotalRecaudado INT
		SET @TotalRecaudado = (SELECT dbo.RecoleccionApuestasMultiples ('27-10-2018 15:34:09')) + (SELECT dbo.RecoleccionApuestasSencillas ('27-10-2018 15:34:09'))
	
		SET @TotalRecaudado = @TotalRecaudado*45/100

		INSERT INTO Premios (FechaSorteo, Categoria1, Categoria2, Categoria3, Categoria4, Categoria5, CategoriaE)
		VALUES
		(@fechaSorteo, @TotalRecaudado * 0.4, @TotalRecaudado * 0.06, @TotalRecaudado * 0.13, @TotalRecaudado * 0.21, 8, @TotalRecaudado * 0.2)
	END

	GO


	--HACER SELECT PARA COMPROBAR NUMEROS ACERTADOS (CON UN "IN") -----HACIECHO

	--HACER SELECT PARA COMPROBAR REINTEGRO

	-- HACER SELECT PARA COMPROBAR COMPLEMENTARIO

/*
Resumen: Comprueba los ganadores en cada categoría del sorteo
Precondiciones: El sorteo existe
Entrada: fecha del sorteo
Salida: Los ganadores en cada categoría
Postcondiciones: Devuelve los ganadores que hay por categoría
*/
CREATE FUNCTION Ganadores (@fechaSorteo DATETIME)
RETURNS @tabla TABLE  (IDApuesta INT, numerosAcertados INT, complementario BIT, reintegro BIT)
AS
	BEGIN
	
		DECLARE @resultado INT = 0
		DECLARE @numerosAcertados INT = 0

		--IF(CURRENT_TIMESTAMP > @fechaSorteo OR (DATEDIFF (MINUTE, CURRENT_TIMESTAMP, @fechaSorteo) <= 60))
		--BEGIN

			DECLARE @IDApuesta BIGINT
			DECLARE @numeroNoAcertado TINYINT
			DECLARE @complementario BIT = 0
			DECLARE @reintegro BIT = 0

			DECLARE cursorApuestas CURSOR
			FOR
			SELECT A.ID
			FROM Apuestas AS A
			INNER JOIN
			Boletos AS B
			ON A.ID_Boleto = B.ID
			WHERE B.FechaSorteo = @fechaSorteo AND Tipo = 0

			OPEN cursorApuestas
			FETCH NEXT FROM cursorApuestas INTO @IDApuesta

			WHILE @@FETCH_STATUS = 0
			BEGIN

			SET @complementario = 0
			SET @numerosAcertados = 0
			SET @reintegro = 0

			IF EXISTS (
				SELECT Valor
				FROM Numeros AS N
				INNER JOIN
				Apuestas AS A
				ON N.IDApuesta = A.ID
				WHERE IDApuesta = @IDApuesta AND Valor IN (SELECT Valor
															FROM NumerosSorteo
															WHERE FechaSorteo = @fechaSorteo))

				BEGIN

					IF ((SELECT COUNT (Valor)
						FROM Numeros
						WHERE IDApuesta = @IDApuesta AND Valor IN  (SELECT Valor
																	FROM NumerosSorteo
																	WHERE FechaSorteo = @fechaSorteo)) > 2)
					BEGIN
						SELECT @numerosAcertados = COUNT (Valor)
						FROM Numeros
						WHERE IDApuesta = @IDApuesta AND Valor IN  (SELECT Valor
																	FROM NumerosSorteo
																	WHERE FechaSorteo = @fechaSorteo)
						
						IF(@numerosAcertados=5)
							BEGIN
								SET @numeroNoAcertado = (SELECT Valor
								FROM Numeros
								WHERE IDApuesta = @IDApuesta AND Valor NOT IN (SELECT Valor
																			FROM NumerosSorteo
																			WHERE FechaSorteo = @fechaSorteo))
								IF(@numeroNoAcertado = (SELECT complementario 
														FROM Sorteos 
														WHERE Fecha=@fechaSorteo))
									BEGIN
										SET @complementario = 1
									END
							END

						IF (@numerosAcertados = 6)
						BEGIN
							SELECT @reintegro = B.Reintegro
								FROM Boletos AS B
								INNER JOIN
								Apuestas AS A
								ON B.ID = A.ID_Boleto
								WHERE A.ID = @IDApuesta
						END

					INSERT INTO @tabla (IDApuesta, numerosAcertados, complementario, reintegro)
					 VALUES (@IDApuesta, @numerosAcertados, @complementario, @reintegro)
						
					END
				 END

								
				FETCH NEXT FROM cursorApuestas INTO @IDApuesta
			END

		--END

		RETURN
	END

	GO

CREATE FUNCTION cantidadPremios (@FechaSorteo DATETIME)
RETURNS @Tabla TABLE (Categoria CHAR, Dinero MONEY, Acertantes INT) 
AS
	BEGIN
	DECLARE @multipleCat5 INT
	DECLARE @multipleCat4 INT
	DECLARE @multipleCat3 INT
	DECLARE @multipleCat2 INT
	DECLARE @multipleCat1 INT
	DECLARE @multipleCatE INT
	SET @multipleCat5= (SELECT SUM(Categoria5) FROM dbo.ganadoresMultiples(@FechaSorteo))
	SET @multipleCat4= (SELECT SUM(Categoria4) FROM dbo.ganadoresMultiples(@FechaSorteo))
	SET @multipleCat3= (SELECT SUM(Categoria3) FROM dbo.ganadoresMultiples(@FechaSorteo))
	SET @multipleCat2= (SELECT SUM(Categoria2) FROM dbo.ganadoresMultiples(@FechaSorteo))
	SET @multipleCat1= (SELECT SUM(Categoria1) FROM dbo.ganadoresMultiples(@FechaSorteo))
	SET @multipleCatE= (SELECT SUM(CategoriaE) FROM dbo.ganadoresMultiples(@FechaSorteo))


	/*
		DECLARE @Tabla TABLE (IDApuesta BIGINT, numeroAciertos INT)

		INSERT INTO @Tabla (IDApuesta, numeroAciertos)
		(SELECT IDApuesta, numerosAcertados FROM dbo.Ganadores (@FechaSorteo))
	*/

	IF  ((((SELECT COUNT (IDApuesta)
			FROM dbo.Ganadores (@FechaSorteo)
			WHERE numerosAcertados = 6) > 0)
			OR
			((SELECT Categoria1 FROM dbo.ganadoresMultiples(@FechaSorteo)) IS NOT NULL))
			OR
			((SELECT CategoriaE FROM dbo.ganadoresMultiples(@FechaSorteo)) IS NOT NULL)) -- ANY
	BEGIN
		IF ((((SELECT Reintegro
			FROM dbo.Ganadores (@FechaSorteo)) = 0)
			OR
			(SELECT Categoria1 FROM dbo.ganadoresMultiples(@FechaSorteo)) IS NOT NULL)
			)

		BEGIN
			INSERT INTO @Tabla (Categoria, Dinero, Acertantes)

			(SELECT '1', (SELECT Categoria1 FROM Premios)/((COUNT (IDApuesta))+@multipleCat1), (COUNT (IDApuesta)+@multipleCat1)
				FROM dbo.Ganadores (@FechaSorteo)
					WHERE numerosAcertados = 6)
		END
		ELSE
		BEGIN

			INSERT INTO @Tabla (Categoria, Dinero, Acertantes)

			(SELECT 'E', (SELECT CategoriaE FROM Premios)/((COUNT (IDApuesta))+@multipleCatE), (COUNT (IDApuesta)+@multipleCatE)
				FROM dbo.Ganadores (@FechaSorteo)
					WHERE numerosAcertados = 6 AND reintegro = 1)
		END

	END

	IF ((((SELECT COUNT (IDApuesta)
			FROM dbo.Ganadores (@FechaSorteo)
			WHERE numerosAcertados = 5 AND complementario = 1) > 0)
			OR
			(SELECT Categoria2 FROM dbo.ganadoresMultiples(@FechaSorteo)) IS NOT NULL))
	BEGIN
	

	INSERT INTO @Tabla (Categoria, Dinero, Acertantes)

	(SELECT '2', (SELECT Categoria2 FROM Premios)/((COUNT (IDApuesta))+@multipleCat2), (COUNT (IDApuesta)+@multipleCat2)
		FROM dbo.Ganadores (@FechaSorteo)
		 WHERE numerosAcertados = 5 AND complementario = 1)-- + C AMO A VE SI ESTO VA ASI DE LOCURA

	END


	IF ((((SELECT COUNT (IDApuesta)
			FROM dbo.Ganadores (@FechaSorteo)
			WHERE numerosAcertados = 5 AND complementario = 0) > 0)
			OR
			(SELECT Categoria3 FROM dbo.ganadoresMultiples(@FechaSorteo)) IS NOT NULL))
			
	BEGIN
	

	INSERT INTO @Tabla (Categoria, Dinero, Acertantes)

	(SELECT '3', (SELECT Categoria3 FROM Premios)/((COUNT (IDApuesta))+@multipleCat3), ((COUNT (IDApuesta))+@multipleCat3)
		FROM dbo.Ganadores (@FechaSorteo)
		 WHERE numerosAcertados = 5)


	END

	IF ((((SELECT COUNT (IDApuesta)
			FROM dbo.Ganadores (@FechaSorteo)
			WHERE numerosAcertados = 4) > 0)
			OR
			(SELECT Categoria4 FROM dbo.ganadoresMultiples(@FechaSorteo)) IS NOT NULL))
	BEGIN
	
	INSERT INTO @Tabla (Categoria, Dinero, Acertantes)

	(SELECT '4', (SELECT Categoria4 FROM Premios)/((COUNT (IDApuesta))+@multipleCat4), ((COUNT (IDApuesta)) + @multipleCat4)
		FROM dbo.Ganadores (@FechaSorteo)
		 WHERE numerosAcertados = 4)

	END

	IF ((SELECT COUNT (IDApuesta)
			FROM dbo.Ganadores (@FechaSorteo)
			WHERE numerosAcertados = 3) > 0)
	BEGIN
	

	INSERT INTO @Tabla (Categoria, Dinero, Acertantes)

	(SELECT '5', '8', (COUNT (IDApuesta)+@multipleCat5)
		FROM dbo.Ganadores (@FechaSorteo)
		 WHERE numerosAcertados = 3)

	END
	
-- Terminar de asignar los premios dependiendo de la categoria para las apuestas multiples. El resto se hace automáticamente.
-- OK, aqui va
	UPDATE @Tabla SET Acertantes= Acertantes+ @multipleCat1 WHERE Categoria=1

		RETURN
		
	END

	GO

	CREATE PROCEDURE calcularReintegro (@fechaSorteo DATETIME)
	AS
	BEGIN
		DECLARE @reintegro BIT

		DECLARE @numeroApuestas INT = 0
		DECLARE @idBoleto INT
		DECLARE cursorBoletos CURSOR
		FOR
		SELECT B.ID
			FROM Boletos AS B
			INNER JOIN
			Apuestas AS A
			ON B.ID = A.ID_Boleto
			WHERE FechaSorteo = @fechaSorteo AND A.Estado = 1

		OPEN cursorBoletos
		FETCH NEXT FROM cursorBoletos INTO @idBoleto

		WHILE @@FETCH_STATUS = 0
		BEGIN


		IF EXISTS((SELECT Reintegro
						FROM Boletos
						WHERE Reintegro = (SELECT Reintegro
											FROM Sorteos
											WHERE Fecha = @fechaSorteo) AND ID = @idBoleto))
			BEGIN
				UPDATE Boletos
				SET Reintegro = 1
				WHERE ID = @idBoleto

				SET @reintegro = 1

				SELECT @numeroApuestas = COUNT (A.ID)
					FROM Boletos AS B
					INNER JOIN
					Apuestas AS A
					ON B.ID = A.ID_Boleto
					WHERE B.ID = @idBoleto

			END

			IF (@reintegro = 1 AND (SELECT Premio FROM Boletos WHERE ID = @idBoleto) = 0) --Esto se hace primero, después se suma el resto.
			BEGIN
				UPDATE Boletos
				SET Premio = @numeroApuestas
			END

			FETCH NEXT FROM cursorBoletos INTO @idBoleto
			END
		END
	GO

	-- Ahora tenemos que crear un procedimiento que nos meta en premios de cada apuesta lo que ha ganado. Después sumar
	-- en el premio del boleto, todos los premios de sus apuestas al reintegro metido anteriormente.

	CREATE PROCEDURE asignarPremioApuesta (@fechaSorteo DATETIME)
	AS
	BEGIN
		DECLARE @numeroAcertados INT
		DECLARE @complementario BIT
		DECLARE @idApuesta INT
		DECLARE @Premio1 MONEY
		DECLARE @Premio2 MONEY
		DECLARE @Premio3 MONEY
		DECLARE @Premio4 MONEY
		DECLARE @Premio5 MONEY
		DECLARE @PremioE MONEY

		SELECT @Premio1 = Dinero
		FROM dbo.cantidadPremios (@fechaSorteo)
		WHERE Categoria = 1

		SELECT @Premio2 = Dinero
		FROM dbo.cantidadPremios (@fechaSorteo)
		WHERE Categoria = 2

		SELECT @Premio3 = Dinero
		FROM dbo.cantidadPremios (@fechaSorteo)
		WHERE Categoria = 3

		SELECT @Premio4 = Dinero
		FROM dbo.cantidadPremios (@fechaSorteo)
		WHERE Categoria = 4

		SELECT @Premio5 = Dinero
		FROM dbo.cantidadPremios (@fechaSorteo)
		WHERE Categoria = 5

		DECLARE cursorApuestas CURSOR
		FOR
		SELECT IDApuesta
		FROM dbo.Ganadores (@fechaSorteo)

		OPEN cursorApuestas
		FETCH NEXT FROM cursorApuestas INTO @idApuesta

		WHILE @@FETCH_STATUS = 0
		BEGIN
		
			SELECT @numeroAcertados = numerosAcertados, @complementario = complementario
			FROM dbo.Ganadores (@fechaSorteo)
			WHERE IDApuesta = @idApuesta

			IF (@numeroAcertados = 3)
			BEGIN
				UPDATE Apuestas
				SET Premio = @Premio5
				WHERE ID = @idApuesta
			END

			ELSE IF (@numeroAcertados = 4)
			BEGIN
				UPDATE Apuestas
				SET Premio = @Premio4
				WHERE ID = @idApuesta
			END

			ELSE IF (@numeroAcertados = 5 AND @complementario = 0)
			BEGIN
				UPDATE Apuestas
				SET Premio = @Premio3
				WHERE ID = @idApuesta
			END

			ELSE IF (@numeroAcertados = 5 AND @complementario = 1)
			BEGIN
				UPDATE Apuestas
				SET Premio = @Premio2
				WHERE ID = @idApuesta
			END

			ELSE IF (@numeroAcertados = 6)
			BEGIN
				IF ((SELECT B.Reintegro
							FROM Boletos AS B
							INNER JOIN
							Apuestas AS A
							ON B.ID = A.ID_Boleto) = 0)
				BEGIN
					UPDATE Apuestas
					SET Premio = @Premio1
					WHERE ID = @idApuesta
				END

				ELSE
				BEGIN
					UPDATE Apuestas
					SET Premio = @PremioE
					WHERE ID = @idApuesta
				END
				
			END

			

			FETCH NEXT FROM cursorApuestas INTO @idApuesta
		END
	END

	--METER EN GANADORES LA CANTIDAD DE APUESTAS SIMPLES QUE HAY EN MULTIPLES Y REPARTIR LOS PREMIOS DE LAS MULTIPLES Y YA TERMINAMOS TO LA MIERDA xdd
	GO

	CREATE FUNCTION ganadoresMultiples (@fechaSorteo DATETIME)
	RETURNS @tablaCategorias TABLE (IDApuesta INT, Categoria1 INT, Categoria2 INT, Categoria3 INT, Categoria4 INT, Categoria5 INT, CategoriaE INT) 
	AS
	BEGIN
		DECLARE @IDApuesta BIGINT
		DECLARE @numeroAcertados TINYINT
		DECLARE @complementario BIT = 0
		DECLARE @reintegro BIT = 0
		DECLARE @pronostico INT
		DECLARE cursorApuestas CURSOR
		FOR
		SELECT A.ID
		FROM Apuestas AS A
		INNER JOIN
		Boletos AS B
		ON A.ID_Boleto = B.ID
		WHERE B.FechaSorteo = @fechaSorteo AND Tipo = 1

		OPEN cursorApuestas
		FETCH NEXT FROM cursorApuestas INTO @IDApuesta

		WHILE @@FETCH_STATUS = 0
		BEGIN

			SELECT @Pronostico = COUNT (Valor)
				FROM Numeros AS N
				INNER JOIN
				Apuestas AS A
				ON N.IDApuesta = A.ID
				WHERE IDApuesta = @IDApuesta

			SELECT @numeroAcertados = COUNT (Valor)
						FROM Numeros
						WHERE IDApuesta = @IDApuesta AND Valor IN  (SELECT Valor
																	FROM NumerosSorteo
																	WHERE FechaSorteo = @fechaSorteo)
			INSERT INTO @tablaCategorias (IDApuesta, Categoria1, Categoria2, Categoria3, Categoria4, Categoria5, CategoriaE)
			SELECT @IDApuesta, Categoria1, Categoria2, Categoria3, Categoria4, Categoria5, CategoriaE
			FROM Aciertos
			WHERE Pronostico = @pronostico AND NumerosAcertados = @numeroAcertados


			FETCH NEXT FROM cursorApuestas INTO @IDApuesta

			--HAY QUE CERRAR LOS CURSORES
		END

		CLOSE cursorApuestas
		DEALLOCATE cursorApuestas

		RETURN

	END

	GO



	GO


-- COMIENZO PRUEBAS
BEGIN TRANSACTION

EXECUTE GrabaSencilla '5-10-2017 13:34:09', 1, 5, 34, 32, 12 ,24 --Probando numeros válidos. Funciona flama

EXECUTE GrabaSencilla '5-10-2017 13:34:09', 1, 5, 34, 34, 12 ,24 --Probando numeros repetidos. Funciona flama

EXECUTE GrabaSencilla '5-10-2017 13:34:09', 1, 5, 0, 32, 12 ,24 -- Probando numeros no admitidos

EXECUTE GrabaSencilla '5-12-2017 13:34:09', 1, 5, 0, 32, 12 ,24 -- Probando Sorteo erroneo

EXECUTE GrabaSencillaAleatoria '5-10-2017 15:34:09', 5 --Probando caso correcto

EXECUTE GrabaSencillaAleatoria '5-10-2017 15:34:09', 9 --Probando caso incorrecto

EXECUTE GrabaSencillaAleatoria '5-10-2017 15:34:09', 0 --Probando caso incorrecto

BEGIN TRANSACTION

--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|||||||||||||||||||||||||||||||||||||PRUEBAS EN ORDEN|||||||||||||||||||||||||||||||||||||||||||||
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

INSERT INTO Sorteos(Fecha,Reintegro,Complementario)
VALUES
('27-10-2018 15:34:09', 4, 5)

EXECUTE GeneraNumerosSorteo '27-10-2018 15:34:09'

INSERT INTO Boletos (ID, FechaSorteo, Reintegro)
VALUES (1, '27-10-2018 15:34:09', 4)

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

GO
EXECUTE GrabaMuchasSencillas '27-10-2018 15:34:09', 10000 

EXECUTE GrabaMultiple '27-10-2018 15:34:09',11,15,21,4,5,41,9

EXECUTE PremioPorCategoria '27-10-2018 15:34:09'

EXECUTE RecoleccionApuestasMultiples '27-10-2018 15:34:09'

SELECT *
FROM dbo.cantidadPremios ('27-10-2018 15:34:09')

SELECT *
FROM dbo.Ganadores ('27-10-2018 15:34:09')
ORDER BY numerosAcertados

EXECUTE asignarPremioApuesta '27-10-2018 15:34:09'

--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|||||||||||||||||||||||||||||||||||||FIN PRUEBAS EN ORDEN|||||||||||||||||||||||||||||||||||||||||
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

/* PRUEBAS RECOLECCION DE RECAUDACION MANILLA*/


SELECT * FROM dbo.ganadoresMultiples ('27-10-2018 15:34:09') -- GANADORES MULPTIPLES FUNCIONA

INSERT INTO Boletos (ID, FechaSorteo, Reintegro)
VALUES (100000, '27-10-2018 15:34:09', 4)

INSERT INTO Apuestas (ID, ID_Boleto, Tipo)
VALUES (100000, 100000, 1)

INSERT INTO Numeros (IDApuesta, Valor)
VALUES
(100000, 3),
(100000, 5),
(100000, 8),
(100000, 10),
(100000, 39),
(100000, 48)

UPDATE Apuestas
SET Estado = 1

/*FIN PRUEBAS RECOLECCION */



SELECT * 
FROM Boletos

SELECT *
FROM Sorteos

SELECT * 
FROM Apuestas

SELECT *
FROM Numeros
ORDER BY IDApuesta

SELECT *
FROM Aciertos

SELECT *
FROM NumerosSorteo

ROLLBACK

COMMIT TRANSACTION




SELECT *
FROM Apuestas
ORDER BY Premio


 -- FIN PRUEBAS

BEGIN TRANSACTION

INSERT INTO Sorteos (Fecha, Reintegro, Complementario)
VALUES
('18-06-2015 13:34:09', 4, 5)
EXECUTE GrabaSencillaAleatoria '18-06-2015 13:34:09',8
--DELETE from Sorteos where Fecha='18-06-2015 13:34:09'


/*
DELETE from NumerosSorteo
DELETE from Numeros
DELETE FROM Apuestas
DELETE FROM Boletos
DELETE FROM Sorteos
*/


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
(45, '26-10-2017 15:34:09'),
(3, '26-10-2017 15:34:09'),
(14, '26-10-2017 15:34:09'),
(43, '26-10-2017 15:34:09'),
(12, '26-10-2017 15:34:09'),
(35, '26-10-2017 15:34:09')


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