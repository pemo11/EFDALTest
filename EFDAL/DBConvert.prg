// ================================================================================================
// File: DBConvert.prg
// Angelegt 09/01/21
// ================================================================================================

Using System
Using System.Collections.Generic
Using System.Data
Using System.Data.Common

Using DevArt.Data.PostgreSql
Using Oracle.ManagedDataAccess.Client

Begin Namespace EFDAL
    
    Public Static Partial Class DbFunctions
        Private Static NullDate := Null As Date?
        
        /// ===========================================================
        /// Wertfunktionen für DataReader und DataRow
        /// ===========================================================
 
    
        // Datentyp: Generisch - werden von anderen Konvertierungsfunktionen verwendet
        
        /// <summary>
        /// hier Beschreibung eingeben 
        /// </summary>
        /// <param name="Dr"></param> 
        /// <param name="Feld"></param> 
        Static Method GetReaderValue(Dr As DbDataReader, Feld As String) As Usual Pascal
            Local NullDate := Null As DateTime?
            Local Feldwert := Null As Usual
            // Alle Feldnamen zusammenfassen für Abfrage - Abfrage fehlt noch und evt. auch gar nicht benötigt
            // Local Feldnamen := Enumerable.Range(0, Dr:FieldCount):Select(Dr:GetName):ToList() As Usual
            Local OrdNr := Dr:GetOrdinal(Feld) As Int
            Local Feldtyp := Dr:GetDataTypeName(OrdNr):ToLower() As String
            // Dem providerspezifischen Feldnamen heißt z.B. SqlBoolean anstelle von Boolean
            Local ProviderFeldtyp := Dr:GetProviderSpecificFieldType(OrdNr) As Type
            if !Dr:IsDbNull(OrdNr)
                switch Feldtyp
                    // PM: 11/02/21 - eingefügt
                    case "char"
                        Feldwert := Dr:GetString(OrdNr)
                    case "text"
                        Feldwert := Dr:GetString(OrdNr)
                    case "string"
                        Feldwert := Dr:GetString(OrdNr)
                    case "varchar"
                        Feldwert := Dr:GetString(OrdNr)
                    case "int"
                        Feldwert := Dr:GetInt32(OrdNr)
                    case "int16"
                        Feldwert := Dr:GetInt16(OrdNr)
                    case "int32"
                        Feldwert := Dr:GetInt32(OrdNr)
                    case "int64"
                        Feldwert := Dr:GetInt64(OrdNr)
                    case "datetime"
                        Feldwert := Dr:GetDateTime(OrdNr)
                    case "bit"
                        Feldwert := Dr:GetBoolean(OrdNr)
                    case "boolean"
                        Feldwert := Dr:GetBoolean(OrdNr)
                    case "byte"
                        Feldwert := Dr:GetByte(OrdNr)
                    case "single"
                        // PM: aus single (Oracle) wird ebenfalls Decimal
                        Feldwert := Dr:GetDecimal(OrdNr)
                    case "double"
                        Feldwert := Dr:GetDouble(OrdNr)
                    case "decimal"
                        Feldwert := Dr:GetDecimal(OrdNr)
                    case "bigint"
                        Feldwert := Dr:GetDecimal(OrdNr)
                    // Postgre-Datentypen
                    case "timestamp"
                        Feldwert := Dr:GetDateTime(OrdNr)
                    case "numeric"
                        Feldwert := Dr:GetDecimal(OrdNr)
                    case "bytea"
                        Local byteArray := Byte[]{100}
                        Dr:GetBytes(OrdNr, 0, byteArray,0,100)
                        Feldwert := byteArray
                    otherwise
                        // darf normalerweise nicht vorkommen
                        infoMessage := i"!!! - GetReaderValue - Fehler bei der Datenkonvertierung von Feldtyp={Feldtyp}/Providertyp={ProviderFeldtyp}"
                        LogHelper.LogInfo(infoMessage)
                        Console.WriteLine(infoMessage)
                end switch
            else
                switch Feldtyp
                    case "char"
                    case "string"
                    case "text"
                    case "varchar"
                        Feldwert := ""
                    case "int"
                        Feldwert := (Int32)0
                    case "int16"
                        Feldwert := (Int16)0
                    case "int32"
                        Feldwert := (Int32)0
                    case "int64"
                        Feldwert := (Int64)0
                    case "datetime"
                        Feldwert := nullDate
                    case "bit"
                        Feldwert := False
                    case "boolean"
                        Feldwert := False
                    case "byte"
                        Feldwert := (byte)0
                    case "double"
                        Feldwert := (double)0
                    case "single"
                        // PM: aus single (Oracle) wird ebenfalls Decimal
                        Feldwert := (decimal)0
                    case "decimal"
                        Feldwert := (decimal)0
                    case "bigint"
                        Feldwert := (decimal)0
                    // Postgre-Datentypen
                    case "timestamp"
                        Feldwert := nullDate
                    case "numeric"
                        Feldwert := (decimal)0
                    case "bytea"
                        Feldwert := Byte[]{0}
                    otherwise
                        // darf normalerweise nicht vorkommen
                        infoMessage := i"!!! - GetReaderValue - Fehler bei der Datenkonvertierung von Feldtyp={feldTyp}/Providertyp={ProviderFeldtyp}"
                        LogHelper.LogInfo(infoMessage)
                        Console.WriteLine(infoMessage)
                        feldWert := ""
                end switch
            Endif
        Return Feldwert

        /// <summary>
        /// hier Beschreibung eingeben 
        /// </summary>
        /// <param name="Row"></param> 
        /// <param name="Feld"></param> 
        Static Method GetRowValue(Row As DataRow, Feld As String) As Usual Pascal
            Local NullDateTime := Null As DateTime?
            Local NullDate := Null As Date?
            Local Feldwert := Null As Object
            // Wichtig: Bei Abfrage per GetType() ist der Feldtyp DBNull, wenn der Wert Null ist
            // Local Feldtyp := Row[FeldName]:GetType():Name:ToLower() As String
            Local Feldtyp := Row:Table:Columns[Feld]:DataType:Name:ToLower() As String
            if !Row:IsNull(Feld)
                switch Feldtyp
                    case "string"
                        // Feldwert := (String)Row[Feld]
                        Feldwert := Convert.ToString(Row[Feld])
                    case "int16"
                        // Feldwert := (Int16)Row[Feld]
                        Feldwert := Convert.ToInt16(Row[Feld])
                    case "int32"
                        // Feldwert := (Int32)Row[Feld]
                        Feldwert := Convert.ToInt32(Row[Feld])
                    case "int64"
                        // Feldwert := (Int64)Row[Feld]
                        Feldwert := Convert.ToInt64(Row[Feld])
                    case "datetime"
                        // Feldwert := (DateTime)Row[Feld]
                        Feldwert := Convert.ToDateTime(Row[Feld])
                    case "date"
                        // Feldwert := (DateTime)Row[Feld]
                        Feldwert := Convert.ToDateTime(Row[Feld])
                    case "boolean"
                        // Feldwert := (Boolean)Row[Feld]
                        Feldwert := Convert.ToBoolean(Row[Feld])
                    case "byte"
                        // Feldwert := (Byte)Row[Feld]
                        Feldwert := Convert.ToByte(Row[Feld])
                        // PM: Ein single-Wert wird zu decimal (Oracle)
                    case "single"
                        // Feldwert := (Decimal)Row[Feld]
                        Feldwert := Convert.ToSingle(Row[Feld])
                    case "double"
                        // Feldwert := (Double)Row[Feld]
                        Feldwert := Convert.ToDouble(Row[Feld])
                    case "decimal"
                        // Feldwert := (Decimal)Row[Feld]
                        Feldwert := Convert.ToDecimal(Row[Feld])
                    case "bitarray"
                        Feldwert := Row[Feld]
                    // Eingefügt für Postgre
                    case "byte[]"
                        // ??? nicht sicher, ob das reicht
                        Feldwert := Row[Feld]
                    otherwise
                        // darf normalerweise nicht vorkommen
                        infoMessage := i"!!! - GetRowValue - Fehler bei der Datenkonvertierung von Feldtyp={feldTyp}"
                        LogHelper.LogInfo(infoMessage)
                end switch
            Else
                if Feldtyp == "datetime"
                    Feldwert := nullDateTime
                Elseif Feldtyp == "date"
                    Feldwert := nullDate
                Elseif Feldtyp:StartsWith("int")
                    Feldwert := 0
                    // PM: Ein single-Wert wird zu decimal (Oracle)
                Elseif Feldtyp == "single"
                    Feldwert := (decimal)0
                Elseif Feldtyp == "double"
                    Feldwert := (double)0
                Elseif Feldtyp == "decimal"
                    Feldwert := (decimal)0
                Elseif Feldtyp = "boolean"
                    Feldwert := False
                Else
                    Feldwert := ""
                Endif
            Endif
        Return Feldwert
        
        // Datentyp Bool
        
        /// <summary>
        /// hier Beschreibung eingeben 
        /// </summary>
        /// <param name="Row"></param> 
        /// <param name="Feld"></param> 
        Static Method GetRowBool(Row As DataRow, Feld As String) As Logic 
            Return GetRowValue(Row, Feld)
        
        /// <summary>
        /// hier Beschreibung eingeben 
        /// </summary>
        /// <param name="Dr"></param> 
        /// <param name="Feld"></param> 
        Static Method GetReaderBool(Dr As DbDataReader, Feld As String) As Logic Pascal
            Return GetReaderValue(Dr, Feld)

        /// <summary>
        // Datentyp Float bzw. Double bzw. Real4
        /// </summary>
        /// <param name="Row"></param> 
        /// <param name="Feld"></param> 
        Static Method GetRowFloat(Row As DataRow, Feld As String) As Float Pascal
            Return IIf(Row[Feld] is DBNull, (Float)0, (Float)Row[Feld])
        
        /// <summary>
        /// hier Beschreibung eingeben 
        /// </summary>
        /// <param name="Dr"></param> 
        /// <param name="Feld"></param> 
        Static Method GetReaderFloat(Dr As DbDataReader, Feld As String) As Float Pascal
            // PM: Mit (Float)0 gibt es einen Compilererror, da der Typ für die IIf-Bedingung nicht erkannt werden kann, da
            // Float uund Real4 wechselseit ineinander konvertiert werden können?
            Return IIf(Dr:IsDBNull(Dr:GetOrdinal(Feld)),(Real4)0, Dr:GetFloat(Dr:GetOrdinal(Feld)))
            
        // Datentyp DateTime
        
        /// <summary>
        // Liefert ein DateTime? anstelle eines DateTime
        /// </summary>
        /// <param name="Dr"></param> 
        /// <param name="Feld"></param> 
        Static Method GetReaderDateTime(Dr As DbDataReader, Feld As String) As DateTime? Pascal
            Local OrdNr := Dr:GetOrdinal(Feld) As Int
            Return IIf(Dr:IsDBNull(OrdNr), NullDate, Dr:GetDateTime(OrdNr))
            
        /// <summary>
        /// hier Beschreibung eingeben 
        /// </summary>
        /// <param name="Row"></param> 
        /// <param name="Feld"></param> 
        Static Method GetRowDateTime(Row As DataRow, Feld As String) As DateTime? Pascal
            Return IIf(row[Feld] is DBNull, NullDate,(DateTime)Row[Feld])

        // Datentyp Date
        
        /// <summary>
        // PM: Rückgabe eines Date? würde zu viele Änderungen im Code nach sich ziehen
        /// </summary>
        /// <param name="Dr"></param> 
        /// <param name="Feld"></param> 
        Static Method GetReaderDate(Dr As DbDataReader, Feld As String) As Date Pascal
            Local OrdNr := Dr:GetOrdinal(Feld) As Int
            Return IIf(Dr:IsDBNull(OrdNr), CTod(""), CtoD(Dr:GetDateTime(OrdNr):ToShortDateString()))

        /// <summary>
        /// hier Beschreibung eingeben 
        /// </summary>
        /// <param name="Row"></param> 
        /// <param name="Feld"></param> 
        Static Method GetRowDate(Row As DataRow, Feld As String) As Date Pascal
            Return IIf(row[Feld] is DBNull, CTod(""), CtoD(row[Feld]:ToString()))
            
        // Datentyp Decimal
        
        /// <summary>
        /// hier Beschreibung eingeben 
        /// </summary>
        /// <param name="Row"></param> 
        /// <param name="Feld"></param> 
        Static Method GetRowDecimal(Row As DataRow, Feld As String) As Decimal Pascal
            Local RetVal := GetRowValue(Row, Feld) As Object
            Return Convert.ToDecimal(RetVal)

        /// <summary>
        // PM: 02/09 - Anpassung, da retVal immer dann "" sein kann, wenn der Datentyp von GetReaderValue() nicht erkannt wurde, da
        // der Datentypname noch nicht abgefragt wird
        /// </summary>
        /// <param name="Dr"></param> 
        /// <param name="Feld"></param> 
        Static Method GetReaderDecimal(Dr As DbDataReader, Feld As String) As Decimal Pascal
            Local RetVal := GetReaderValue(Dr, Feld) As Object
            // PM: Diese Abfrage sollte nicht erforderlich sein
            if RetVal:ToString() == ""  
                RetVal := 0
            endif
        Return Convert.ToDecimal(RetVal)

        /// <summary>
         // PM: 03/07/20 - eingefügt, um einen Fehler in EARZumTermin() zu vermeiden
        /// </summary>
        /// <param name="Value"></param> 
        Static Method GetDecimalValue(Value As Object) As Decimal
            Return Convert.ToDecimal(Value)

        /// <summary>
        // Datentyp: String
        /// </summary>
        /// <param name="Dr"></param> 
        /// <param name="Feld"></param> 
        Static Method GetReaderString(Dr As DbDataReader, Feld As String) As String
            Local OrdNr := Dr:GetOrdinal(Feld) As Int
            Return IIf(Dr:IsDBNull(OrdNr), "", Dr:GetString(OrdNr))

        /// <summary>
        /// hier Beschreibung eingeben 
        /// </summary>
        /// <param name="Row"></param> 
        /// <param name="Feld"></param> 
        Static Method GetRowString(Row As DataRow, Feld As String) As String Pascal
            Return IIf(Row[Feld] Is DBNull, "", Row[Feld]:ToString())

        // Datentyp: Int
      
        /// <summary>
        /// hier Beschreibung eingeben 
        /// </summary>
        /// <param name="Row"></param> 
        /// <param name="Feld"></param> 
        Static Method GetRowInt(Row As DataRow, Feld As String) As Int Pascal
            Local RetVal := GetRowValue(Row, Feld) As Object
            Return Convert.ToInt32(RetVal)
            
        /// <summary>
        /// hier Beschreibung eingeben 
        /// </summary>
        /// <param name="Dr"></param> 
        /// <param name="Feld"></param> 
        Static Method GetReaderInt(Dr As DbDataReader, Feld As String) As Usual Pascal
            Local OrdNr := Dr:GetOrdinal(Feld) As Int
            Local Feldtyp := Dr:GetDataTypeName(OrdNr):ToLower() As String
            Local Feldwert := Null As Object
            infoMessage := ""
            switch Feldtyp
                case "int"
                    // FeldWert := GetGenericReaderValue<Int>(Dr, Feldname)
                    Feldwert := GetReaderValue(Dr, Feld)
                    try
                        Feldwert := Convert.ToInt32(Feldwert)
                    catch
                        Feldwert := 0
                        infoMessage := i"!!! GetReaderInt-> Fehler bei int-Konvertierung - Feldname: {Feld}"
                    end try
                case "bigint" // Postgre-Datentyp (z.B. Anzahl)
                    Feldwert := GetReaderValue(Dr, Feld)
                    try
                        Feldwert := Convert.ToInt64(Feldwert)
                    catch
                        Feldwert := 0
                        infoMessage := i"!!! GetReaderInt-> Fehler bei bigint-Konvertierung - Feldname: {Feld}"
                    end try
                case "int16"
                    // feldWert := GetGenericReaderValue<Int>(Dr, Feldname)
                    Feldwert := GetReaderValue(Dr, Feld)
                    try
                        Feldwert := Convert.ToInt16(Feldwert)
                    catch
                        Feldwert :=0
                        infoMessage := i"!!! GetReaderInt-> Fehler bei int16-Konvertierung - Feldname: {Feld}"
                    end try
                case "int32"
                    // feldWert := GetGenericReaderValue<Int>(Dr, Feldname)
                    Feldwert := GetReaderValue(Dr, Feld)
                    try
                        Feldwert := Convert.ToInt32(Feldwert)
                    catch
                        Feldwert := 0
                        infoMessage := i"!!! GetReaderInt-> Fehler bei int32-Konvertierung - Feldname: {Feld}"
                    end try
                case "int64"
                    // feldWert := GetGenericReaderValue<Int64>(Dr, Feldname)
                    Feldwert := GetReaderValue(Dr, Feld)
                    try
                        Feldwert := Convert.ToInt64(Feldwert)
                    catch
                        Feldwert := 0
                        infoMessage := i"!!! GetReaderInt-> Fehler bei int64-Konvertierung - Feldname: {Feld}"
                    end try
                case "decimal"
                    // feldWert := GetGenericReaderValue<Int>(Dr, Feldname)
                    Feldwert := GetReaderValue(Dr, Feld)
                    try
                        Feldwert := Convert.ToInt32(Feldwert)
                    catch
                        Feldwert := 0
                        infoMessage := i"!!! GetReaderInt-> Fehler bei decimal-Konvertierung - Feldname: {Feld}"
                    end try
                    // PM: 19/06/20 - eingefügt, da LfdNr bei Postgre-Dbs vom Typ numeric ist (immer?)
                case "numeric"
                    Feldwert := GetReaderValue(Dr, Feld)
                    try
                        Feldwert := Convert.ToInt32(Feldwert)
                    catch
                        Feldwert := 0
                        infoMessage := i"!!! GetReaderInt-> Fehler bei numeric-Konvertierung - Feldname: {Feld}"
                    end try
                otherwise
                    // Sollte kein Thema sein (PM: 19/06 - leider doch, bei Postgre kann der Feldttyp Numeric sein)
                    infoMessage := i"!!! GetReaderInt-> Unbekannter Feldtyp: {Feldtyp}"
            end switch
            
            if !Empty(infoMessage)
                LogHelper.LogInfo(infoMessage)
            endif
        Return Feldwert
 
    End Class
    
End Namespace
