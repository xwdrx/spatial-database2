--5a
-- po uruchomieniu procesu SSIS pojawil sie komunikat o dodaniu 6 wierszy oraz o pomyslnym zakonczeniu procesu
-- "Insert Destination" wrote 6 rows.
--  finished: Success.
--------------------------------
--5b

-- po wykonaniu update -> set LastName = 'Nowak' i 2 update -> set TITLE = 'Senior Design Engineer' a nastepnie po uruchomieniu procesu SSIS uzyskano informacje o tym, ze dodano jeden wiersz
--  "Insert Destination" wrote 1 rows.
--  finished: Success.
------------------------------------
--5c

--po wywolaniu updete -> set FIRSTNAME = 'Ryszard' i po odpaleniu procesu SSIS pojawil sie komunikat o bledzie:

--Error: 0xC020803C at cw6, Slowly Changing Dimension [107]: If the FailOnFixedAttributeChange property is set to TRUE, the transformation will fail when a fixed attribute change is detected. To send rows to the Fixed Attribute output, set the FailOnFixedAttributeChange property to FALSE.
--Error: 0xC0047022 at cw6, SSIS.Pipeline: SSIS Error Code DTS_E_PROCESSINPUTFAILED.  The ProcessInput method on component "Slowly Changing Dimension" (107) failed with error code 0xC020803C while processing input "Slowly Changing Dimension Input" (118). The identified component returned an error from the ProcessInput method. The error is specific to the component, but the error is fatal and will cause the Data Flow task to stop running.  There may be error messages posted before this with more information about the failure.
--Information: 0x40043008 at cw6, SSIS.Pipeline: Post Execute phase is beginning.
--Information: 0x4004300B at cw6, SSIS.Pipeline: "Insert Destination" wrote 0 rows. -> nie doszlo do zadnej zmiany w tabelli
--Information: 0x40043009 at cw6, SSIS.Pipeline: Cleanup phase is beginning.

------------------------------------------------------------------------------------

--6

--  5b LastName to SCD type 1 -> nie spowodowalo to zmian w tabeli, zaktualizowano itniejacy rekord
--  5b Title to SCD type 2 -> zmiana title spowodowała dodanie nowego rekordu, a poprzedni rekord został edytowany poprzed dodanie nowej daty do pola endDate
--  5c FirstName to SCD type 0 -> nie doszlo do zmian, bo sa niedozwolone

------------------------------------------------------------------------------------
--  7

-- przy zadaniu 5c pojawil sie komunikat: If the FailOnFixedAttributeChange property is set to TRUE, the transformation will fail when a fixed attribute change is detected. To send rows to the Fixed Attribute output, set the FailOnFixedAttributeChange property to FALSE.
-- oznacza to, ze ustawiajac FailOnFixedAttributeChange = TRUE zapewnono integralnosc danych dla atrybutow, uniemozliwiajac ich modyfikacje. Probujac zmienic FirstName proces zakonczyl sie bledem, poniewaz bylo to traktowane jako naruszenie zasad, nie mozna zmieniać atrybutow bez naruszenia integralności danych.
