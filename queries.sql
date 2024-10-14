-- Alle Kunden anzeigen
SELECT * FROM Kunden;

--Alle Produkte anzeigen
SELECT * FROM Produkte;

--Alle Bestellungen anzeigen
SELECT * FROM Bestellungen;

--Kunden aus Deutschland anzeigen
SELECT * FROM Kunden WHERE Land = 'Deutschland';

--Produkte mit einem Preis ¸ber 500Ä
SELECT * FROM Produkte WHERE Preis > 500;

--Bestellungen vom 01.10 anzeigen
SELECT * FROM Bestellungen WHERE Bestelldatum = TO_DATE('2024-10-01', 'YYYY-MM-DD');

--Anzahl der Kunden ermitteln
SELECT COUNT(*) AS Anzahl_Kunden FROM Kunden;

--Durchschnittspreis der Produkte
SELECT AVG(Preis) AS Durchschnittspreis FROM Produkte;

--Gesamtanzahl der Bestellungen pro Kunde ermitteln
SELECT KundenID, COUNT(*) AS Anzahl_Bestellungen
FROM Bestellungen
GROUP BY KundenID;

--Alle Bestellungen mit Kundendaten anzeigen
SELECT B.BestellID, K.Name AS Kundenname, B.Produkt, B.Bestelldatum, B.Menge
FROM Bestellungen B
JOIN Kunden K ON B.KundenID = K.KundenID;

--Alle Bestellungen mit Kundendaten anzeigen
SELECT P.Produktname, B.BestellID, B.Bestelldatum, B.Menge
FROM Produkte P
LEFT JOIN Bestellungen B ON P.Produktname = B.Produkt;

--Kunden mit den meisten Bestellungen ermitteln
SELECT K.Name, COUNT(B.BestellID) AS Anzahl_Bestellungen
FROM Kunden K
LEFT JOIN Bestellungen B ON K.KundenID = B.KundenID
GROUP BY K.Name
ORDER BY Anzahl_Bestellungen DESC
FETCH FIRST 1 ROW ONLY;  -- Der Kunde mit den meisten Bestellungen

--Umsatz pro Produkt berechnen
SELECT B.Produkt, SUM(B.Menge) AS Gesamtanzahl, SUM(B.Menge * P.Preis) AS Gesamtumsatz
FROM Bestellungen B
JOIN Produkte P ON B.Produkt = P.Produktname
GROUP BY B.Produkt;

--Kunden die mehr als der Durchschnitt ausgeben
SELECT K.Name, SUM(B.Menge * P.Preis) AS Gesamtausgaben
FROM Kunden K
JOIN Bestellungen B ON K.KundenID = B.KundenID
JOIN Produkte P ON B.Produkt = P.Produktname
GROUP BY K.Name
HAVING SUM(B.Menge * P.Preis) > (
    SELECT AVG(Menge * Preis)
    FROM Bestellungen B2
    JOIN Produkte P2 ON B2.Produkt = P2.Produktname
);

--Umsatz, nach Stadt der Kunden
SELECT K.Stadt, SUM(B.Menge * P.Preis) AS Gesamtumsatz
FROM Kunden K
JOIN Bestellungen B ON K.KundenID = B.KundenID
JOIN Produkte P ON B.Produkt = P.Produktname
GROUP BY K.Stadt
ORDER BY Gesamtumsatz DESC;

--Durchschnittliche Bestellmenge pro Produkt
SELECT B.Produkt, AVG(B.Menge) AS Durchschnittsmenge
FROM Bestellungen B
GROUP BY B.Produkt
HAVING AVG(B.Menge) > 1; -- Nur Produkte mit einer Durchschnittsbestellmenge ¸ber 1

--Rang der Kunden basierend auf ihren Ausgaben
SELECT K.Name, SUM(B.Menge * P.Preis) AS Gesamtausgaben,
       RANK() OVER (ORDER BY SUM(B.Menge * P.Preis) DESC) AS Rang
FROM Kunden K
JOIN Bestellungen B ON K.KundenID = B.KundenID
JOIN Produkte P ON B.Produkt = P.Produktname
GROUP BY K.Name;

--Bestellungen mit einer Statusmeldung basierend aus Menge
SELECT B.BestellID, K.Name AS Kundenname, B.Produkt, B.Menge,
       CASE 
           WHEN B.Menge > 5 THEN 'Groﬂe Bestellung'
           WHEN B.Menge BETWEEN 2 AND 5 THEN 'Mittlere Bestellung'
           ELSE 'Kleine Bestellung'
       END AS Bestellstatus
FROM Bestellungen B
JOIN Kunden K ON B.KundenID = K.KundenID;

--Kunden und deren letzte Bestellung
SELECT K.Name, B.Produkt, B.Bestelldatum
FROM Kunden K
JOIN (
    SELECT KundenID, Produkt, Bestelldatum,
           ROW_NUMBER() OVER (PARTITION BY KundenID ORDER BY Bestelldatum DESC) AS RN
    FROM Bestellungen
) B ON K.KundenID = B.KundenID
WHERE B.RN = 1; -- Nur die letzte Bestellung pro Kunde

--Umsatz pro Kunde und Produkt kombiniert
SELECT K.Name AS Kundenname, P.Produktname, SUM(B.Menge) AS Gesamtmenge, SUM(B.Menge * P.Preis) AS Gesamtumsatz
FROM Bestellungen B
JOIN Kunden K ON B.KundenID = K.KundenID
JOIN Produkte P ON B.Produkt = P.Produktname
GROUP BY K.Name, P.Produktname
ORDER BY K.Name, Gesamtumsatz DESC;









