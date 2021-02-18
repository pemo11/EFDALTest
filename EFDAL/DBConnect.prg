// ================================================================================================
// File: DbConnect.prg
// Angelegt 09/02/21
// ================================================================================================

Using System
Using System.Collections.Generic
Using System.Data
Using System.Data.Common
Using System.Configuration
Using System.Diagnostics
Using System.Linq

Using Devart.Data.PostgreSql
Using Oracle.ManagedDataAccess.Client

Begin Namespace EFDAL
    Global EFDbConnection As IDbConnection   // Globale Verbindung
    Global EFDbProvidername As String        // Aktueller Providername
    Global EFDbConnectionstring As String    // Verbindungszeichenfolge
    Global EFDbConfigname As String          // Aktueller Konfigurationsname, z.B. ef
    Global SQLLogging As Logic
    Global lFirstConnection := True as logic
    
	/// <summary>
    /// Fasst alle Db-Funktionalitäten zusammen
    /// </summary>
	Public Partial Static Class DbFunctions
        Public Static EFDbFactory As DBProviderFactory
        Private Static DbConfig As Configuration
        Private Static infoMessage As String
        Private Static DbConfigPfad := "DBConfig.config" As String
        // Nur für Tests
        Public Static EFConnectionString := "" As String
        
        /// <summary>
        /// hier Beschreibung eingeben 
        /// </summary>
        Static Constructor() As Void
            // Vorbelegung der Variablen EFDbConfigname
            EFDbConfigname := "ef"
            // Nur für Tests, damit ConString abrufbar ist
            EFConnectionString := GetConnectionstring(EfDbConfigName)
            // Nicht erforderlich, da bereits geladen...
            // Local ds = ConfigurationManager.GetSection("system.data") as DataSet
            // ds:Tables[0]:Rows:Add("dotConnect for PostgreSQL",;
            //  "Devart dotConnect for PostgreSQL",;
            //  "Devart.Data.PostgreSql",;
            //  "Devart.Data.PostgreSql.PgSqlProviderFactory, Devart.Data.PostgreSql, Version=7.11.1190.0, Culture=neutral, PublicKeyToken=09af7300eec23701")
            Return
        
	    /// <summary>
        /// Holt den Providernamen aus der Config-Datei
        /// </summary>
        Static Method GetProvidername(Section As String) As String
            Foreach Setting As ConnectionStringSettings in DbConfig:ConnectionStrings:ConnectionStrings
                if Setting:Name == Section
                    EFDbProvidername := Setting:ProviderName
                    Return Setting:ProviderName
                EndIf
            Next
        Return ""
        
	    /// <summary>
        /// Holt den Connectionstring aus der Config-Datei
        /// </summary>
        Static Method GetConnectionstring(Sektion As String) As String
            if DbConfig == Null
                var ConfigMap := ExeConfigurationFileMap{} 
                ConfigMap:ExeConfigFilename := DbConfigPfad
                DbConfig := ConfigurationManager:OpenMappedExeConfiguration(ConfigMap, ConfigurationUserLevel:None)
            endif
            Foreach Setting As ConnectionStringSettings in DbConfig:ConnectionStrings:ConnectionStrings
                if Setting:Name == Sektion
                    EFDbConnectionstring := Setting:Connectionstring
                    Return Setting:Connectionstring
                EndIf
            Next
        Return ""
        
	    /// <summary>
        /// Explizites Öffnen der globalen Verbindung
        /// </summary>
        Static Method OpenEFDbConnection() As Logic
            If EFDbConnection != Null .And. EFDbConnection:State == ConnectionState:Closed
                EFDbConnection:Open()
                // SQL-Logging?
                if SQLLogging
                    infoMessage := i"*** OpenEfDbConnection: Datenbankverbindung mit {EfDbConnectionString} wurde geöffnet. ***"
                    LogHelper.LogInfo(infoMessage)
                endif
                Return True
            Else
                Return False
            Endif

        /// <summary>
        /// Explizites Schließen der globalen Verbindung
        /// </summary>
        Static Method CloseEFDbConnection() As Logic
            If EFDbConnection != Null .And. EFDbConnection:State == ConnectionState:Open
                EFDbConnection:Close()
                // SQL-Logging?
                if SQLLogging
                    infoMessage := i"*** CloseEFDbConnection: Datenbankverbindung wurde geschlossen. ***"
                    LogHelper.LogInfo(infoMessage)
                endif
                Return True
            Else
                Return False
            Endif

        /// <summary>
        /// Anlegen der globalen Verbindung - Verbindung wird aber nicht geöffnet
        /// </summary>
        Static Method NewEFDbConnection() As Logic
            Local RetVal As Logic
            if EFDbConnection != Null .And. EFDbConnection:State == ConnectionState.Open
                Return True
            endif
            try
                var ConfigMap := ExeConfigurationFileMap{} 
                ConfigMap:ExeConfigFilename := DbConfigPfad
                // Variable DbConfig wird aktuell nicht verwendet
                DbConfig := ConfigurationManager:OpenMappedExeConfiguration(ConfigMap, ConfigurationUserLevel:None)
                // Globale Variablen belegen
                EFDbProvidername := GetProvidername(EFDbConfigname)
                // EFDbConnectionstring := GetConnectionstring(EFDbConfigname)
                EFDbFactory := DbProviderFactories.GetFactory(EFDbProvidername) 
                EFDbConnection := EfDbFactory:CreateConnection()
                EFDbConnectionstring := GetConnectionstring(EFDbConfigname)
                EFDbConnection:Connectionstring := EFDbConnectionstring
                // SQL-Logging?
                if SQLLogging
                    infoMessage := i"*** NewEFDbConnection-> Datenbankverbindung wurde mit ConnectionName={EFDbConfigname},ConnectionString={EFDbConnectionString} und Provider={EFDbProvidername} initialisiert. ***"
                    LogHelper.LogInfo(infoMessage)
                endif
                RetVal := True
            catch ex as Exception
                infoMessage := i"!!! NewEFDbConnection-> Fehler beim Initialisieren der Datenbankverbindung - ConnectionName={EFDbConfigname} ({ex:Message}). !!!"
                LogHelper.LogError(infoMessage, ex)
                RetVal := False
            end try
            Return RetVal

        /// <summary>
        /// Anlegen einer neuen und geöffneten Verbindung
        /// </summary>
        Static Method NewOpenDbConnection() As IDbConnection
            Local DbCon As IDbConnection
            Local Provider := "" As String
            try
                var ConfigMap := ExeConfigurationFileMap{} 
                ConfigMap:ExeConfigFilename := DbConfigPfad
                DbConfig := ConfigurationManager:OpenMappedExeConfiguration(ConfigMap, ConfigurationUserLevel:None)
                Provider := GetProvidername(EFDbConfigname)
                EFDbProvidername := Provider
                var DbFactory := DbProviderFactories.GetFactory(Provider) 
                DbCon := DbFactory:CreateConnection()
                DbCon:ConnectionString := GetConnectionstring(EFDbConfigname)
                // DbCon:Connectionstring := ConString
                DbCon:Open()
                // PM: 28/08/20 - wird nur für das Loging benötigt, spielt ansonsten keine (!) Rolle
                Local conString := DbCon:ConnectionString As String
                // SQL-Logging?
                if SQLLogging
                    infoMessage := i"*** NewOpenDbConnection-> Datenbankverbindung wurde mit ConnectionName={EFDbConfigname},ConnectionString={conString} und Provider={Provider} erzeugt und geöffnet. ***"
                    LogHelper.LogInfo(infoMessage)
                endif
                Return DbCon
            catch ex as Exception
                infoMessage := i"!!! NewOpenDbConnection-> Fehler beim Erzeugen der Datenbankverbindung - ConnectionName={Provider} ({ex:Message}). !!!"
                LogHelper.LogError(infoMessage, ex)
                Return Null
            end try
        
        /// <summary>
        /// Gibt eine offene Verbindung für eine anderen Configuration zurück
        /// Wird u.a. für die Jukos-Db benötigt
        /// </summary>
        Static Method InitConnection(ConnectionName As String) As IDbConnection
            Local DbCon := Null As IDbConnection
            Local ProviderName := "" As String
            Local ConString := "" As String
            Local DbFactory As DbProviderFactory
            try
                var configMap := ExeConfigurationFileMap{} 
                ConfigMap:ExeConfigFilename := DbConfigPfad
                ConfigurationManager:OpenMappedExeConfiguration(ConfigMap, ConfigurationUserLevel:None)
                ProviderName := GetProvidername(ConnectionName)
                ConString := GetConnectionstring(ConnectionName)
                DbFactory := DbProviderFactories.GetFactory(providerName) 
                DbCon := DbFactory:CreateConnection() 
                DbCon:Connectionstring := ConString
                // Datenbank öffnen
                DbCon:Open()
                // SQL-Logging?
                if SQLLogging
                    infoMessage := i"*** InitConnection-> Datenbankverbindung mit ConnectionName={ConnectionName} initialisiert und geöffnet. ***"
                    LogHelper.LogInfo(infoMessage)
                endif
            catch ex as SystemException
                infoMessage := i"!!! InitConnection-> Fehler beim Initialisieren der Datenbankverbindung - ConnectionName={ConnectionName} ({ex:Message}). !!!"
                LogHelper.LogError(infoMessage, ex)
            end try
            Return DbCon

        /// <summary>
        /// Neue Datenbankverbindung anlegen und öffnen
        /// Wird u.a. von DbInsertTable.prg/DbUpdateTable.prg verwendet
        /// </summary>
        Static Method InitConnection() As Void
            // EFDbConfigname ist in der Regel "ef"
            InitConnection(EFDbConfigname)
        Return
            
        /// ===========================================================
        /// Datenbankzugriffsmethoden
        /// ===========================================================

        /// <summary>
        /// Zählt die Anzahl der offenen Verbindungen
        /// Spielt aktuell nur für Postgre eine Rolle
        /// Wird in finalen Version NICHT aufgerufen
        /// </summary>
        Static Method GetConnectionCount() As Int
            Local Count := 0 as Int
            switch EFDbProvidername
                case "Devart.Data.PostgreSql"
                    Count := GetPgConnectionCount()
                case "System.Data.SqlClient"
                    Nop
                case "Oracle.ManagedDataAccess.Client"
                    Count := 1
                otherwise
                    Count := -1
            end switch
            Return Count

        /// <summary>
        /// Führt ein Delete, Insert oder Update über die globale Verbindung durch
        /// </summary>
        Static Method InvokeNonQuery(SqlCommandText As String) As Int
            Local DbRetVal := -1 As Int
            try
                If NewEFDbConnection()
                    OpenEFDbConnection()
                    var sqlCommand := EFDbConnection:CreateCommand()
                    sqlCommand:CommandText := SqlCommandText
                    DbRetVal := sqlCommand:ExecuteNonQuery()
                    // SQL-Logging?
                    if SQLLogging
                        var frame := StackFrame{1, true}
                        Local className := frame:GetMethod():ReflectedType:Name As String
                        Local methodName := frame:GetMethod():Name As String
                        Local callerName := i"{className}.{methodName}" As String
                        infoMessage := i">>>SQL->InvokeNonQuery: ({callerName}) RetVal={DbRetVal} - {SqlCommandText} <<<"
                        LogHelper.LogInfo(infoMessage)
                    endif
                    #ifdef CONCOUNTMODE
                    conCount := GetConnectionCount()
                    infoMessage := i"*** InvokeNonQuery-> Connection Count={conCount}/Result={Result} ({SqlCommandText}) ***"
                    LogHelper.LogInfo(infoMessage)
                    #endif
                else
                    infoMessage := "!!! InvokeNonQuery-> Keine Verbindung über NewEFDbConnection !!!"
                    LogHelper.LogInfo(infoMessage)
                Endif
            catch ex As SystemException
                infoMessage := i"!!! InvokeNonQuery-> Fehler beim Ausführen des SQL-Kommandos {SqlCommandText} - Fehler: " + ex:Message + " !!!"
                LogHelper.LogError(infoMessage, ex)
            end try
        Return DbRetVal

        /// <summary>
        /// Führt ein Delete, Insert oder Update über eine eigene Verbindung durch 
        /// </summary>
        Static Method InvokeNonQuery(SqlCommandText As String, DbCon As IDbConnection) As Int
            Local DbRetVal := -1 As Int
            try
                var sqlCommand := DbCon:CreateCommand()
                sqlCommand:CommandText := SqlCommandText
                DbRetVal := sqlCommand:ExecuteNonQuery()
                // SQL-Logging?
                if SQLLogging
                    var frame := StackFrame{1, true}
                    Local className := frame:GetMethod():ReflectedType:Name As String
                    Local methodName := frame:GetMethod():Name As String
                    Local callerName := i"{className}.{methodName}" As String
                    infoMessage := i">>>SQL->InvokeNonQuery: ({callerName}) RetVal={DbRetVal} - {SqlCommandText} <<<"
                    LogHelper.LogInfo(infoMessage)
                endif
                #ifdef CONCOUNTMODE
                conCount := GetConnectionCount()
                infoMessage := i"*** InvokeNonQuery-> Connection Count={conCount}/Result={Result} ({SqlCommandText}) ***"
                LogHelper.LogInfo(infoMessage)
                #endif
            catch ex As SystemException
                infoMessage := i"!!! InvokeNonQuery-> Fehler beim Ausführen des SQL-Kommandos {SqlCommandText} - Fehler: " + ex:Message + " !!!"
                LogHelper.LogError(infoMessage, ex)
            end try
        Return DbRetVal

        /// <summary>
        /// Gibt eine DataTable über die globale Verbindung zurück
        /// </summary>
        Static Method InvokeSelect(SqlCommandText As String) As DataTable
            Local ta := DataTable{} As DataTable
            Local rowCount As Int
            try
                If NewEFDbConnection()
                    OpenEFDbConnection()
                    var selectCommand := EFDbConnection:CreateCommand()
                    selectCommand:CommandText := SqlCommandText
                    If EFDbProvidername == "Oracle.ManagedDataAccess.Client"
                        ((OracleCommand)selectCommand):InitialLONGFetchSize := -1
                    Endif
                    var adapter := EFDbFactory:CreateDataAdapter()
                    adapter:selectCommand := (DbCommand)selectCommand
                    adapter:fill(ta)
                    rowCount := ta:Rows:Count
                    // SQL-Logging?
                    if SQLLogging
                        var frame := StackFrame{1, true}
                        Local className := frame:GetMethod():ReflectedType:Name As String
                        Local methodName := frame:GetMethod():Name As String
                        Local callerName := i"{className}.{methodName}" As String
                        infoMessage := i">>>SQL->InvokeSelect: ({callerName}) RowCount={rowCount} - {SqlCommandText} <<<"
                        LogHelper.LogInfo(infoMessage)
                    endif
                    #ifdef CONCOUNTMODE
                    conCount := GetConnectionCount()
                    infoMessage := i"*** InvokeSelect-> Connection Count={conCount} ({SqlCommandText}) ***"
                    LogHelper.LogInfo(infoMessage)
                    #endif
                else
                    infoMessage := "!!! InvokeSelect-> Keine Verbindung über NewEFDbConnection !!!"
                    LogHelper.LogInfo(infoMessage)
                Endif
            catch ex As SystemException
                infoMessage := i"!!! InvokeSelect-> Fehler beim Ausführen von {SqlCommandText} (" + ex:Message + ") !!!"
                LogHelper.LogError(infoMessage, ex)
            end try
            Return ta

        
        /// <summary>
        /// Nur ein Namensalias
        /// </summary>
        Static Method InvokeGlobalSelectRow(SqlCommandText As String) As DataRow
            Return InvokeSelectRow(SqlCommandText)
            
        /// <summary>
        /// Gibt eine DataRow über die globale Verbindung zurück
        /// </summary>
        Static Method InvokeSelectRow(SqlCommandText As String) As DataRow
            Local ta := DataTable{} As DataTable
            Local rowCount := 0 As Int
            try
                If NewEFDbConnection()
                    OpenEFDbConnection()
                    var selectCommand := EFDbConnection:CreateCommand()
                    selectCommand:CommandText := SqlCommandText
                    If EFDbProvidername == "Oracle.ManagedDataAccess.Client"
                        ((OracleCommand)selectCommand):InitialLONGFetchSize := -1
                    Endif
                    var adapter := EFDbFactory:CreateDataAdapter()
                    adapter:selectCommand := (DbCommand)selectCommand
                    adapter:fill(ta)
                    rowCount := ta:Rows:Count
                    
                    // SQL-Logging?
                    if SQLLogging
                        var frame := StackFrame{1, true}
                        Local className := frame:GetMethod():ReflectedType:Name As String
                        Local methodName := frame:GetMethod():Name As String
                        Local callerName := i"{className}.{methodName}" As String
                        infoMessage := i">>>SQL->InvokeSelectRow: ({callerName}) RowCount={rowCount} - {SqlCommandText} <<<"
                        LogHelper.LogInfo(infoMessage)
                    endif
                    #ifdef CONCOUNTMODE
                    conCount := GetConnectionCount()
                    infoMessage := i"*** InvokeSelectRow-> Connection Count={conCount}  ({SqlCommandText}) ***"
                    LogHelper.LogInfo(infoMessage)
                    #endif
                else
                    infoMessage := "!!! InvokeSelectRow-> Keine Verbindung über NewEFDbConnection !!!"
                    LogHelper.LogInfo(infoMessage)
                endif
            catch ex As SystemException
                infoMessage := i"!!! InvokeSelectRow-> Fehler beim Ausführen von {SqlCommandText} (" + ex:Message + ") !!!"
                LogHelper.LogError(infoMessage, ex)
            end try
            If ta:Rows:Count > 0
                Return ta:Rows[0]
            Else
                Return Null
            Endif
 
        /// <summary>
        /// Gibt eine DataRow mit über ein vorhandenes Connection-Object zurück
        /// </summary>
        Static Method InvokeSelectRow(SqlCommandText As String, DbCon As IDbConnection) As DataRow
            Local ta := DataTable{} As DataTable
            Local rowCount := 0 As Int
            try
                var selectCommand := DbCon:CreateCommand()
                selectCommand:CommandText := SqlCommandText
                If EFDbProvidername == "Oracle.ManagedDataAccess.Client"
                    ((OracleCommand)selectCommand):InitialLONGFetchSize := -1
                Endif
                var adapter := EFDbFactory:CreateDataAdapter()
                adapter:selectCommand := (DbCommand)selectCommand
                adapter:fill(ta)
                rowCount := ta:Rows:Count
                
                    // SQL-Logging?
                    if SQLLogging
                        var frame := StackFrame{1, true}
                        Local className := frame:GetMethod():ReflectedType:Name As String
                        Local methodName := frame:GetMethod():Name As String
                        Local callerName := i"{className}.{methodName}" As String
                        infoMessage := i">>>SQL->InvokeSelectRow: ({callerName}) RowCount={rowCount} - {SqlCommandText} <<<"
                        LogHelper.LogInfo(infoMessage)
                    endif
                #ifdef CONCOUNTMODE
                conCount := GetConnectionCount()
                infoMessage := i"*** InvokeSelectRow-> Connection Count={conCount}  ({SqlCommandText}) ***"
                LogHelper.LogInfo(infoMessage)
                #endif
            catch ex As SystemException
                infoMessage := i"!!! InvokeSelectRow-> Fehler beim Ausführen von {SqlCommandText} (" + ex:Message + ") !!!"
                LogHelper.LogError(infoMessage, ex)
            end try
            If ta:Rows:Count > 0
                Return ta:Rows[0]
            Else
                Return Null
            Endif
 
        /// <summary>
        /// Holt einen einzelnen Wert als Object-Typ über die globale Verbindung
        /// Wird aktuell nicht verwendet
        /// </summary>
        Static Method InvokeValue(SqlCommandText As String) As Object
            Local queryValue := Null As Object
            try
                // Verbindung anlegen und öffnen falls keine offene Verbindung existiert
                if NewEFDbConnection()
                    OpenEFDbConnection()
                    var sqlCommand := EFDbConnection:CreateCommand()
                    // PM: 04/02/21 - eingefügt, damit Abfrage auch mit Oracle funktioniert
                    If EFDbProvidername == "Oracle.ManagedDataAccess.Client"
                        ((OracleCommand)sqlCommand):InitialLONGFetchSize := -1
                    Endif
                    sqlCommand:CommandText := SqlCommandText
                    queryValue := sqlCommand:ExecuteScalar()
                    // SQL-Logging?
                    if SQLLogging
                        var frame := StackFrame{1, true}
                        Local className := frame:GetMethod():ReflectedType:Name As String
                        Local methodName := frame:GetMethod():Name As String
                        Local callerName := i"{className}.{methodName}" As String
                        infoMessage := i">>>SQL->InvokeValue: ({callerName}) RetVal={queryValue} - {SqlCommandText} <<<"
                        LogHelper.LogInfo(infoMessage)
                    endif
                    #ifdef CONCOUNTMODE
                    conCount := GetConnectionCount()
                    infoMessage := i"*** InvokeValue-> ConnectionCount={conCount} ({SqlCommandText}) ***"
                    LogHelper:LogInfo(infoMessage)
                    #endif
                else
                    infoMessage := "!!! InvokeValue-> Keine Verbindung über NewEFDbConnection !!!"
                    LogHelper:LogInfo(infoMessage)
                endif
            catch ex As SystemException
                infoMessage := i"!!! InvokeValue-> Fehler beim Ausführen von {SqlCommandText} (" + ex:Message + ") !!!"
                LogHelper.LogError(infoMessage, ex)
            end try
        Return queryValue
        
        /// <summary>
        // Nur vorübergehend bis Namen angepasst werden
        /// </summary>
        /// <param name="SqlCommandtext"></param> 
        Static Method InvokeSingleIntValue(SqlCommandtext As String) As Int
            Return InvokeIntValue(SqlCommandtext)

        /// <summary>
        /// hier Beschreibung eingeben 
        /// </summary>
        /// <param name="SqlCommandtext"></param> 
        Static Method InvokeSingleStringValue(SqlCommandtext As String) As String
            Return InvokeStringValue(SqlCommandtext)

       /// <summary>
       /// hier Beschreibung eingeben 
       /// </summary>
       /// <param name="SqlCommandtext"></param> 
       Static Method InvokeSingleDecimalValue(SqlCommandtext As String) As Decimal
            Return InvokeDecimalValue(SqlCommandtext)

        /// <summary>
        /// Holt einen einzelnen Wert als Boolean/Logic-Wert über die globale Verbindung
        /// </summary>
        Static Method InvokeBoolValue(SqlCommandtext As String) As Logic
            Local queryValue := Null As Object
            Local ReturnValue := False As Logic
            try
                // Verbindung anlegen und öffnen falls keine offene Verbindung existiert
                if NewEFDbConnection()
                    OpenEFDbConnection()
                    var sqlCommand := EFDbConnection:CreateCommand()
                    // PM: 04/02/21 - eingefügt, damit Abfrage auch mit Oracle funktioniert
                    If EFDbProvidername == "Oracle.ManagedDataAccess.Client"
                        ((OracleCommand)sqlCommand):InitialLONGFetchSize := -1
                    Endif
                    sqlCommand:CommandText := SqlCommandText
                    queryValue := sqlCommand:ExecuteScalar()
                    // SQL-Logging?
                    if SQLLogging
                        var frame := StackFrame{1, true}
                        Local className := frame:GetMethod():ReflectedType:Name As String
                        Local methodName := frame:GetMethod():Name As String
                        Local callerName := i"{className}.{methodName}" As String
                        infoMessage := i">>>SQL->InvokeBoolValue: ({callerName}) RetVal={queryValue} - {SqlCommandText} <<<"
                        LogHelper.LogInfo(infoMessage)
                    endif
                    #ifdef CONCOUNTMODE
                    conCount := GetConnectionCount()
                    infoMessage := i"*** InvokeBoolValue-> ConnectionCount={conCount} ({SqlCommandText}) ***"
                    LogHelper:LogInfo(infoMessage)
                    #endif
                else
                    infoMessage := "!!! InvokeBoolValue-> Keine Verbindung über NewEFDbConnection !!!"
                    LogHelper:LogInfo(infoMessage)
                endif
                ReturnValue := IIf(queryValue != null .And. queryValue != DBNull.Value, Convert.ToBoolean(queryValue), False)
            catch ex As SystemException
                infoMessage := i"!!! InvokeBoolValue-> Fehler beim Ausführen von {SqlCommandText} (" + ex:Message + ") !!!"
                LogHelper.LogError(infoMessage, ex)
            end try
        Return ReturnValue

        /// <summary>
        /// Holt einen einzelnen Wert als Int-Wert über die globale Verbindung
        /// </summary>
        Static Method InvokeIntValue(SqlCommandtext As String) As Int
            Local queryValue := Null As Object
            Local ReturnValue := 0 As Int
            try
                // Verbindung anlegen und öffnen falls keine offene Verbindung existiert
                if NewEFDbConnection()
                    OpenEFDbConnection()
                    var sqlCommand := EFDbConnection:CreateCommand()
                    // PM: 04/02/21 - eingefügt, damit Abfrage auch mit Oracle funktioniert
                    If EFDbProvidername == "Oracle.ManagedDataAccess.Client"
                        ((OracleCommand)sqlCommand):InitialLONGFetchSize := -1
                    Endif
                    sqlCommand:CommandText := SqlCommandText
                    queryValue := sqlCommand:ExecuteScalar()
                    // SQL-Logging?
                    if SQLLogging
                        var frame := StackFrame{1, true}
                        Local className := frame:GetMethod():ReflectedType:Name As String
                        Local methodName := frame:GetMethod():Name As String
                        Local callerName := i"{className}.{methodName}" As String
                        infoMessage := i">>>SQL->InvokeIntValue: ({callerName}) RetVal={queryValue} - {SqlCommandText} <<<"
                        LogHelper.LogInfo(infoMessage)
                    endif
                    #ifdef CONCOUNTMODE
                    conCount := GetConnectionCount()
                    infoMessage := i"*** InvokeIntValue-> ConnectionCount={conCount} ({SqlCommandText}) ***"
                    LogHelper:LogInfo(infoMessage)
                    #endif
                else
                    infoMessage := "!!! InvokeIntValue-> Keine Verbindung über NewEFDbConnection !!!"
                    LogHelper:LogInfo(infoMessage)
                endif
                ReturnValue := IIf(queryValue != null .And. queryValue != DBNull.Value, Convert.ToInt32(queryValue), 0)
            catch ex As SystemException
                infoMessage := i"!!! InvokeIntValue-> Fehler beim Ausführen von {SqlCommandText} (" + ex:Message + ") !!!"
                LogHelper.LogError(infoMessage, ex)
            end try
        Return ReturnValue

        /// <summary>
        /// Liefert einen einzelnen String-Wert über die globale Verbindung
        /// </summary>
        Static Method InvokeStringValue(SqlCommandText As String) As String
            Local queryValue := Null As Object
            Local ReturnValue := "" As String
            try
                // Verbindung anlegen und öffnen falls keine offene Verbindung existiert
                if NewEFDbConnection()
                    OpenEFDbConnection()
                    var sqlCommand := EFDbConnection:CreateCommand()
                    // PM: 04/02/21 - eingefügt, damit Abfrage auch mit Oracle funktioniert
                    If EFDbProvidername == "Oracle.ManagedDataAccess.Client"
                        ((OracleCommand)sqlCommand):InitialLONGFetchSize := -1
                    Endif
                    sqlCommand:CommandText := SqlCommandText
                    queryValue := sqlCommand:ExecuteScalar()
                    // SQL-Logging?
                    if SQLLogging
                        var frame := StackFrame{1, true}
                        Local className := frame:GetMethod():ReflectedType:Name As String
                        Local methodName := frame:GetMethod():Name As String
                        Local callerName := i"{className}.{methodName}" As String
                        infoMessage := i">>>SQL->InvokeStringValue: ({callerName}) RetVal={queryValue} - {SqlCommandText} <<<"
                       LogHelper.LogInfo(infoMessage)
                    endif
                    #ifdef CONCOUNTMODE
                    conCount := GetConnectionCount()
                    // infoMessage := i"*** InvokeStringValue - Ein String-Wert wurde per {SqlCommandText} abgerufen - Connection Count={conCount} ***"
                    infoMessage := i"*** InvokeStringValue-> ConnectionCount={conCount} ({SqlCommandText}) ***"
                    LogHelper:LogInfo(infoMessage)
                    #endif
                else
                    infoMessage := "!!! InvokeStringValue-> Keine Verbindung über NewEFDbConnection !!!"
                    LogHelper:LogInfo(infoMessage)
                endif
                ReturnValue := IIf(queryValue == null, "", queryValue:ToString())
            catch ex As SystemException
                infoMessage := i"!!! InvokeStringValue-> Fehler beim Ausführen von {SqlCommandText} - Fehler: " + ex:Message + " !!!"
                LogHelper.LogError(infoMessage, ex)
            end try
        Return ReturnValue
        
        /// <summary>
        /// Liefert einen einzelnen Decimal-Wert über die globale Verbindung
        /// </summary>
        Static Method InvokeDecimalValue(SqlCommandText As String) As Decimal
            Local queryValue := Null As Object
            Local ReturnValue := 0 As Decimal
            try
                // Verbindung anlegen und öffnen falls keine offene globale Verbindung existiert
                if NewEFDbConnection()
                    OpenEFDbConnection()
                    var sqlCommand := EFDbConnection:CreateCommand()
                    // PM: 04/02/21 - eingefügt, damit Abfrage auch mit Oracle funktioniert
                    If EFDbProvidername == "Oracle.ManagedDataAccess.Client"
                        ((OracleCommand)sqlCommand):InitialLONGFetchSize := -1
                    Endif
                    sqlCommand:CommandText := SqlCommandText
                    queryValue := sqlCommand:ExecuteScalar()
                    // SQL-Logging?
                    if SQLLogging
                        var frame := StackFrame{1, true}
                        Local className := frame:GetMethod():ReflectedType:Name As String
                        Local methodName := frame:GetMethod():Name As String
                        Local callerName := i"{className}.{methodName}" As String
                        infoMessage := i">>>SQL->InvokeDecimalValue: ({callerName}) RetVal={queryValue} - {SqlCommandText} <<<"
                        LogHelper.LogInfo(infoMessage)
                    endif
                    #ifdef CONCOUNTMODE
                    conCount := GetConnectionCount()
                    // infoMessage := i"*** InvokeDecimalValue - Ein Decimal-Wert wurde per {SqlCommandText} abgerufen - Connection Count={conCount} ***"
                    infoMessage := i"*** InvokeDecimalValue-> ConnectionCount={conCount} ({SqlCommandText}) ***"
                    LogHelper.LogInfo(infoMessage)
                    #endif
                else
                    infoMessage := "!!! InvokeDecimalValue-> Keine Verbindung über NewEFDbConnection !!!"
                    LogHelper.LogInfo(infoMessage)
                endif
                ReturnValue := IIf(queryValue != Null .And. queryValue != DBNull.Value, Convert.ToDecimal(queryValue), 0)
            catch ex As SystemException
                infoMessage := i"!!! InvokeDecimalValue->Fehler bei der Ausführung von {SqlCommandText} " + ex:Message + " !!!"
                LogHelper.LogError(infoMessage, ex)
            end try
        Return ReturnValue
        
        /// <summary>
        /// Liefert einen einzelnen DateTime?-Wert über die globale Verbindung
        /// Auch die Rückgabe Null ist (offenbar) ein DateTime?-Wert
        /// PM: 25/09/20 - eingefügt
        /// </summary>
        Static Method InvokeDateTimeValue(SqlCommandText As String) As DateTime?
            Local queryValue := Null As Object
            // PM: Interessant, dass eine Null-Zuweisung möglich ist
            Local ReturnValue := Null As DateTime?
            try
                // Verbindung anlegen und öffnen falls keine offene globale Verbindung existiert
                if NewEFDbConnection()
                    OpenEFDbConnection()
                    var sqlCommand := EFDbConnection:CreateCommand()
                    // PM: 04/02/21 - eingefügt, damit Abfrage auch mit Oracle funktioniert
                    If EFDbProvidername == "Oracle.ManagedDataAccess.Client"
                        ((OracleCommand)sqlCommand):InitialLONGFetchSize := -1
                    Endif
                    sqlCommand:CommandText := SqlCommandText
                    queryValue := sqlCommand:ExecuteScalar()
                    // SQL-Logging?
                    if SQLLogging
                        var frame := StackFrame{1, true}
                        Local className := frame:GetMethod():ReflectedType:Name As String
                        Local methodName := frame:GetMethod():Name As String
                        Local callerName := i"{className}.{methodName}" As String
                        infoMessage := i">>>SQL->InvokeDateTimeValue: ({callerName}) RetVal={queryValue} - {SqlCommandText} <<<"
                        LogHelper.LogInfo(infoMessage)
                    endif
                    #ifdef CONCOUNTMODE
                    conCount := GetConnectionCount()
                    // infoMessage := i"*** InvokeDecimalValue - Ein Decimal-Wert wurde per {SqlCommandText} abgerufen - Connection Count={conCount} ***"
                    infoMessage := i"*** InvokeDecimalValue-> ConnectionCount={conCount} ({SqlCommandText}) ***"
                    LogHelper.LogInfo(infoMessage)
                    #endif
                else
                    infoMessage := "!!! InvokeDateTimeValue-> Keine Verbindung über NewEFDbConnection !!!"
                    LogHelper.LogInfo(infoMessage)
                endif
                // PM: 28/09/20 - clever - die Konvertierung (DateTime?)Null, damit DateTime und Null zusammenpassen
                ReturnValue := IIf(queryValue != Null .And. queryValue != DBNull.Value, DateTime.Parse(queryValue:ToString()), (DateTime?)Null)
            catch ex As SystemException
                infoMessage := i"!!! InvokeDateTimeValue->Fehler bei der Ausführung von {SqlCommandText} " + ex:Message + " !!!"
                LogHelper.LogError(infoMessage, ex)
            end try
        Return ReturnValue
        
        
        /// <summary>
        /// Gibt einen geöffneten DataReader über eine neue Verbindung zurück
        /// </summary>
        Static Method ExecuteReader(SqlCommandText As String, AutoClose := True As Logic) As DbDataReader
            Local dr := Null As DbDataReader
            Local sqlCommand As IDbCommand
            try
                var DbCon := NewOpenDbConnection()
                sqlCommand := (DbCommand)DbCon:CreateCommand()
                sqlCommand:CommandText := SqlCommandText
                If EFDbProvidername == "Oracle.ManagedDataAccess.Client"
                    ((OracleCommand)sqlCommand):InitialLONGFetchSize := -1
                Endif
                if AutoClose
                    dr := (DbDataReader)sqlCommand:ExecuteReader(CommandBehavior.CloseConnection)
                    // PM: Explizites Close an dieser Stelle nicht möglich, da ansonsten der DataReader
                    // nicht mehr angesprochen werden kann - die Verbindung muss daher offen bleiben
                    // DbCon:Close()
                else
                    dr := (DbDataReader)sqlCommand:ExecuteReader(CommandBehavior.Default)
                endif
                // SQL-Logging?
                if SQLLogging
                    var frame := StackFrame{1, true}
                    Local className := frame:GetMethod():ReflectedType:Name As String
                    Local methodName := frame:GetMethod():Name As String
                    Local callerName := i"{className}.{methodName}" As String
                    infoMessage := i">>>SQL->ExecuteReader: ({callerName}) AutoClose={AutoClose} - {SqlCommandText} <<<"
                    LogHelper.LogInfo(infoMessage)
                endif
                #ifdef CONCOUNTMODE
                conCount := GetConnectionCount()
                infoMessage := i"*** ExecuteReader-> ConnectionCount={conCount} ({SqlCommandText}) ***"
                LogHelper.LogInfo(infoMessage)
                #endif
            catch ex As SystemException
                infoMessage := i"!!! ExecuteReader->Fehler bei der Ausführung von {SqlCommandText} " + ex:Message + " !!!"
                LogHelper.LogError(infoMessage, ex)
            end try
        Return dr

        /// <summary>
        /// Gibt einen geöffneten DataReader über die globale Verbindung zurück
        /// </summary>
        Static Method ExecuteGlobalReader(SqlCommandText As String) As DbDataReader
            Local Dr := Null As DbDataReader
            try
                // Verbindung anlegen und öffnen falls keine offene globale Verbindung existiert
                if NewEFDbConnection()
                    OpenEFDbConnection()
                    var sqlCommand := EFDbConnection:CreateCommand()
                    If EFDbProvidername == "Oracle.ManagedDataAccess.Client"
                        ((OracleCommand)sqlCommand):InitialLONGFetchSize := -1
                    Endif
                    sqlCommand:CommandText := SqlCommandText
                    // Verbindung wird hier nicht geschlossen, wenn der DataReader nicht mehr exitiert
                    Dr := (DbDataReader)sqlCommand:ExecuteReader()
                    // SQL-Logging?
                    if SQLLogging
                        var frame := StackFrame{1, true}
                        Local className := frame:GetMethod():ReflectedType:Name As String
                        Local methodName := frame:GetMethod():Name As String
                        Local callerName := i"{className}.{methodName}" As String
                        infoMessage := i">>>SQL->ExecuteGlobalReader: ({callerName}) - {SqlCommandText} <<<"
                        LogHelper.LogInfo(infoMessage)
                    endif
                    #ifdef CONCOUNTMODE
                    conCount := GetConnectionCount()
                    infoMessage := i"*** ExecuteGlobalReader-> ConnectionCount={conCount} ({SqlCommandText}) ***"
                    LogHelper.LogInfo(infoMessage)
                    #endif
                else
                    infoMessage := "!!! ExecuteGlobalReader> Keine Verbindung über NewEFDbConnection !!!"
                    LogHelper.LogInfo(infoMessage)
                endif
            catch ex As SystemException
                infoMessage := i"!!! ExecuteGlobalReader-> Fehler beim Ausführen des SQL-Kommandos {SqlCommandText} - Fehler: " + ex:Message + " !!!"
                LogHelper.LogError(infoMessage, ex)
            end try
            Return Dr

        /// <summary>
        /// Holt nur einen Wert über die globale Verbindung
        /// PM: 20/08/20 - wird aktuell nicht verwendet
        /// </summary>
        Static Method ExecuteScalar(SqlCommandText As String) As Object
            Local queryValue := -1 As Object
            try
                // Verbindung muss offen sein
                if NewEFDbConnection()
                    OpenEFDbConnection()
                    var sqlCommand := EFDbConnection:CreateCommand()
                    If EFDbProvidername == "Oracle.ManagedDataAccess.Client"
                        ((OracleCommand)sqlCommand):InitialLONGFetchSize := -1
                    Endif
                    sqlCommand:CommandText := SqlCommandText
                    queryValue := (int)sqlCommand:ExecuteScalar()
                    #ifdef CONCOUNTMODE
                    conCount := GetConnectionCount()
                    infoMessage := i"*** ExecuteScalar-> ConnectionCount={conCount} ({SqlCommandText}) ***"
                    LogHelper.LogInfo(infoMessage)
                    #endif
                else
                    infoMessage := "!!! ExecuteScalar> Keine Verbindung über NewEFDbConnection !!!"
                    LogHelper.LogInfo(infoMessage)
                endif
            catch ex As SystemException
                infoMessage := i"!!! ExecuteScalar-> Fehler beim Ausführen des SQL-Kommandos {SqlCommandText} - Fehler: " + ex:Message + " !!!"
                LogHelper.LogError(infoMessage, ex)
            end try
                
            Return queryValue
            
        /// <summary>
        /// Holt einen einzelnen Wert über eine eigene Verbindung
        /// </summary>
        Static Method ExecuteScalar(SqlCommandText As String, DbCon As IDbConnection) As Object
            Local queryValue := -1 As Object
            try
                var sqlCommand := DbCon:CreateCommand()
                sqlCommand:CommandText := SqlCommandText
                If EFDbProvidername == "Oracle.ManagedDataAccess.Client"
                    ((OracleCommand)sqlCommand):InitialLONGFetchSize := -1
                Endif
                queryValue := (int)sqlCommand:ExecuteScalar()
                #ifdef CONCOUNTMODE
                conCount := GetConnectionCount()
                infoMessage := i"*** ExecuteScalar-> ConnectionCount={conCount} ({SqlCommandText}) ***"
                #endif
            catch ex As SystemException
                infoMessage := i"!!! ExecuteScalar->Fehler beim Ausführen des SQL-Kommandos {SqlCommandText} - Fehler: " + ex:Message + " !!!"
                LogHelper.LogError(infoMessage, ex)
            end try
            Return queryValue

        /// <summary>
        /// Gibt an, ob ein Select etwas zurückgibt - verwendet die globale Verbindung
        /// </summary>
        Static Method HasRows(SqlCommandText As String) As Logic
            Local queryValue := False As Logic
            Local ta := DataTable{} As DataTable
            try
                // Verbindung muss offen sein
                if NewEFDbConnection()
                    OpenEFDbConnection()
                    var selectCommand := EFDbConnection:CreateCommand()
                    selectCommand:CommandText := SqlCommandText
                    var adapter := EFDbFactory:CreateDataAdapter()
                    adapter:selectCommand := (DbCommand)selectCommand
                    adapter:fill(ta)
                    // Gibt es einen Record?
                    queryValue := ta:Rows:Count > 0
                    #ifdef CONCOUNTMODE
                    conCount := GetConnectionCount()
                    infoMessage := i"*** HasRows-> ConnectionCount={conCount} ({SqlCommandText}) ***"
                    LogHelper.LogInfo(infoMessage)
                    #endif
               else
                    infoMessage := "!!! HasRows-> Keine Verbindung über NewEFDbConnection !!!"
                    LogHelper.LogInfo(infoMessage)
                endif
            catch ex As SystemException
                infoMessage := i"!!! HasRows-> Fehler beim Ausführen des SQL-Kommandos {SqlCommandText} - Fehler: " + ex:Message + " !!!"
                LogHelper.LogError(infoMessage, ex)
            end try
            Return queryValue
            
 
        /// ===========================================================
        /// Weitere Hilfsfunktionen
        /// ===========================================================
       
        /// <summary>
        /// hier Beschreibung eingeben 
        /// </summary>
        Static Method StammTabelle() As DataRow
            Local sqlText := "Select * From Stamm" As String
        Return DbFunctions.InvokeSelectRow(sqlText) 
        
        /// <summary>
        /// hier Beschreibung eingeben 
        /// </summary>
        Static Method GerichtsTabelle() As DataRow
            Local sqlText := "Select * From GerAdr" As String
            Return DbFunctions.InvokeSelectRow(sqlText) 
            

       /// <summary>
        // Postgre-spezifisch: Alle vorhandenen Pools leeren
       /// </summary>
       Static Method ClearPgPool() As Void
            // PgSqlConnection.ClearAllPools(True)
            Return
        

        /// <summary>
        // Abfrage der offenen Postgre-Connections
        /// </summary>
        Static Method GetPgConnectionCount() As Int
            Local ConCount := 0 As Int
            try
                if EFDbConnection != Null
                    Local pgCommand := EFDbConnection:CreateCommand() As IDbCommand
                    pgCommand:CommandText := "Select Count(*) From pg_stat_activity"
                    Local RetVal := pgCommand:ExecuteScalar() As Object
                    ConCount := Int32:Parse(RetVal:ToString()) 
                Endif
            catch ex As SystemException
                infoMessage := i"!!! GetPgConnectionCount->Fehler beim Abfrufen des Postgre-Connectioncount (" + ex:Message +") !!!"
                LogHelper.LogError(infoMessage, ex)
            end try
            Return ConCount

        /*
        // Abfrage der offenen SQL Server-Connections
        Static Method GetMsSqlConnectionCount(DbName As String, Login As String, UseGlobal:=True As Logic) As Int
            Local ConCount := -1 As Int
            Local sqlCommand As IDbCommand
            Local sqlText As String
            Local RetVal As Object
            if !UseGlobal
                Begin Using var DbCon := NewOpenDbConnection()
                    try
                        sqlCommand := DbCon:CreateCommand()
                        sqlText := "Select Count(dbid) As concount "
                        sqlText += "From sys.sysprocesses Where DB_Name(dbid)='" + DbName + "' and loginame='" + Login + "' "
                        sqlCommand:CommandText := sqlText
                        retVal := sqlCommand:ExecuteScalar()
                        ConCount := Int32:Parse(RetVal:ToString()) 
                    catch ex As SystemException
                        infoMessage := i"!!! GetMsSqlConnectionCount->Fehler beim Abrufen des SQL Server-Connectioncount (" + ex:Message +") !!!"
                        LogHelper.LogError(infoMessage, ex)
                    end try
                End using
            else
                try
                    if EFDbConnection != Null
                        sqlCommand := EFDbConnection:CreateCommand()
                        sqlText := "Select Count(dbid) As concount "
                        sqlText += "From sys.sysprocesses Where DB_Name(dbid)='" + DbName + "' and loginame='" + Login + "' "
                        sqlText += "Group By dbid"
                        sqlCommand:CommandText := sqlText
                        RetVal := sqlCommand:ExecuteScalar() 
                        ConCount := Int32:Parse(RetVal:ToString()) 
                    Endif
                catch ex As SystemException
                    infoMessage := i"!!! GetMsSqlConnectionCount->Fehler beim Abrufen des SQL Server-Connectioncount (" + ex:Message +") !!!"
                    LogHelper.LogError(infoMessage, ex)
                end try
            endif
            Return ConCount
            */

    End Class

End Namespace
