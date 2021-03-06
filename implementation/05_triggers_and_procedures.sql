CREATE OR REPLACE TRIGGER UPDATE_UTENTI
AFTER UPDATE ON UTENTI
FOR EACH ROW
BEGIN
    UPDATE AUTISTI SET UTENTE = :NEW.ID WHERE UTENTE = :OLD.ID;
    UPDATE PASSEGGERI SET UTENTE = :NEW.ID WHERE UTENTE = :OLD.ID;
    UPDATE VIAGGI SET AUTISTA = :NEW.ID WHERE AUTISTA = :OLD.ID;
    UPDATE PRENOTAZIONI SET PASSEGGERO = :NEW.ID WHERE PASSEGGERO = :OLD.ID;
    UPDATE RECENSIONI SET RECENSENTE = :NEW.ID WHERE RECENSENTE = :OLD.ID;
    UPDATE RECENSIONI SET RECENSITO = :NEW.ID WHERE RECENSITO = :OLD.ID;
END;

CREATE OR REPLACE TRIGGER UPDATE_VIAGGI
AFTER UPDATE ON VIAGGI
FOR EACH ROW
BEGIN
    UPDATE RECENSIONI SET VIAGGIO = :NEW.CODICE WHERE VIAGGIO = :OLD.CODICE;
    UPDATE TAPPE SET VIAGGIO = :NEW.CODICE WHERE VIAGGIO = :OLD.CODICE;
END;

CREATE OR REPLACE TRIGGER UPDATE_AUTO
AFTER UPDATE ON AUTO
FOR EACH ROW
BEGIN
    UPDATE AUTISTI SET AUTO = :NEW.TARGA WHERE AUTO = :OLD.TARGA;
END;

CREATE OR REPLACE TRIGGER UPDATE_POSTI_DISPONIBILI
AFTER UPDATE ON PRENOTAZIONI
FOR EACH ROW
BEGIN
    UPDATE VIAGGI SET POSTI_DISPONIBILI = POSTI_DISPONIBILI - 1 WHERE CODICE = :OLD.VIAGGIO;
END;

CREATE OR REPLACE TRIGGER UPDATE_STATO_VIAGGIO
BEFORE UPDATE ON VIAGGI
FOR EACH ROW
BEGIN
    DECLARE
        ERRORE EXCEPTION;
        NUM INTEGER;
    BEGIN
        SELECT V.POSTI_DISPONIBILI INTO NUM
        FROM VIAGGI V WHERE V.CODICE = :OLD.CODICE;
        IF (NUM = 0)
        THEN RAISE ERRORE;
        END IF;
    EXCEPTION
        WHEN ERRORE 
        THEN RAISE_APPLICATION_ERROR ( -2002 , 'Posti disponibili esauriti');
    END;
END;

CREATE OR REPLACE PROCEDURE INSERT_AUTO (
    inTARGA IN AUTO.TARGA%TYPE, 
    inMODELLO IN AUTO.MODELLO%TYPE,
    inCOLORE IN AUTO.COLORE%TYPE, 
    inSCADENZA IN AUTO.SCADENZA_ASSICURAZIONE%TYPE
)
AS
BEGIN
    BEGIN
        INSERT INTO AUTO(TARGA, MODELLO, COLORE, SCADENZA_ASSICURAZIONE)
        VALUES (inTARGA, inMODELLO, inCOLORE, inSCADENZA);
        COMMIT;
    END;
END INSERT_AUTO;

CREATE OR REPLACE PROCEDURE INSERT_RECENSIONE (
    inCODICE IN RECENSIONI.CODICE%TYPE, 
    inVOTO IN RECENSIONI.VOTO%TYPE,
    inGIUDIZIO IN RECENSIONI.GIUDIZIO%TYPE, 
    inRECENSENTE IN RECENSIONI.RECENSENTE%TYPE,
    inRECENSITO IN RECENSIONI.RECENSITO%TYPE,
    inVIAGGIO IN RECENSIONI.VIAGGIO%TYPE
)
AS
BEGIN
    BEGIN
        INSERT INTO RECENSIONI(CODICE, VOTO, GIUDIZIO, RECENSENTE, RECENSITO, VIAGGIO)
        VALUES (inCODICE, inVOTO, inGIUDIZIO, inRECENSENTE, inRECENSITO, inVIAGGIO);
        COMMIT;
    END;
END INSERT_RECENSIONE;    