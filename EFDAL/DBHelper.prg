// File: DBHelper.prg
// Anlegen eines DataDictionary für eine Datenbank in Gestalt einer XML-Datei

USING System
USING System.Collections.Generic
Using System.Data
Using System.IO
USING System.Text
Using System.Xml.Linq
Using System.Text.RegularExpressions

Using Oracle.ManagedDataAccess.Client
Using System.Data.SqlClient
Using Devart.Data.PostgreSql

BEGIN NAMESPACE EFDAL

	/// <summary>
    /// The DBHelper class
    /// </summary>
	Public Class DBHelper
        Private Static sqlText As String
        Private Static infoMessage As String
            
        Constructor()
            Return
            
        Public Static Method CreateOracleDataDic(ConString As String, UserId As String) As Logic
            Local xNs := XNamespace.Get("eureka-fach") As XNamespace
            Local xDbDoc := XElement{XName.Get("Database", xNs:NamespaceName), XAttribute{XNamespace.Xmlns + "ef", xNs},;
             XAttribute{"constring", ConString}} As XElement
            Local xmlPfad := "" As String
            try
                sqlText := "Select Table_Name From User_tables"
                Local ta := DataTable{} As DataTable
                Local da := OracleDataAdapter{sqlText, ConString} As OracleDataAdapter
                da:Fill(ta)
                ta:DefaultView:Sort := "Table_Name Desc"
                foreach row As DataRow in ta:Rows
                    Local TabName := row["table_name"]:ToString() As String
                    sqlText := i"Select table_name, column_name, data_type, data_precision FROM all_tab_columns where table_name = '{TabName}'"
                    Local ta1 := DataTable{} As DataTable
                    Local da1 := OracleDataAdapter{sqlText, ConString} As OracleDataAdapter
                    da1:Fill(ta1)
                    Local xTab := XElement{XName.Get(TabName)} As XElement
                    try
                        foreach row1 As DataRow in ta1:Rows
                            xTab:Add(XElement{row1["Column_Name"]:ToString(), XAttribute{"Type", row1["Data_Type"]:ToString()},;
                             XAttribute{"Precision", IIf(row1["Data_Precision"] is DBNull, "", row1["Data_Precision"]:ToString())}})
                        next
                    catch ex As SystemException
                        Console.WriteLine("Fehler!!! " + ex:Message)
                    end try
                    xDbDoc:Add(xTab)
                next
            catch ex As SystemException
                infoMessage := i"!!! Fehler beim Abrufen der Oracle-Daten (" + ex:Message + ") !!!"
                LogHelper.LogError(infoMessage, ex)
                Return False
            end try
            
            try
                // Xml-Dateien werden im Temp-Verzeichnis abgelegt
                xmlPfad := Path.Combine(Path.GetTempPath(), UserId + ".xml")
                xDbDoc:Save(xmlPfad)
                infoMessage := i"*** {xmlPfad} wurde gespeichert ***"
                LogHelper.LogInfo(infoMessage)
                Return True
            catch ex As SystemException
                infoMessage := i"!!! Fehler beim Abspeichern von {xmlPfad} (" + ex:Message + ") !!!"
                LogHelper.LogError(infoMessage, ex)
                Return False
            end try
                

        Public Static Method CreateSqlServerDataDic(ConString As String, DbName As String) As Logic
            try
                Local xNs := XNamespace.Get("eureka-fach") As XNamespace
                Local xDbDoc := XElement{XName.Get("Database", xNs:NamespaceName), XAttribute{XNamespace.Xmlns + "ef", xNs},;
                 XAttribute{"constring", ConString}} As XElement
                Local xmlPfad := "" As String
                try
                    sqlText := i"Select Table_Name From {DbName}.INFORMATION_SCHEMA.TABLES Where Table_Type = 'BASE TABLE' Order By TABLE_NAME"
                    Local ta := DataTable{} As DataTable
                    Local da := SqlDataAdapter{sqlText, ConString} As SqlDataAdapter
                    da:Fill(ta)
                    ta:DefaultView:Sort := "Table_Name Desc"
                    foreach row As DataRow in ta:Rows
                        Local TabName := row["table_name"]:ToString() As String
                        sqlText := i"Select * FROM INFORMATION_SCHEMA.COLUMNS Where table_name = '{TabName}'"
                        Local ta1 := DataTable{} As DataTable
                        Local da1 := SqlDataAdapter{sqlText, ConString} As SqlDataAdapter
                        da1:Fill(ta1)
                        Local xTab := XElement{XName.Get(TabName)} As XElement
                        try
                            foreach row1 As DataRow in ta1:Rows
                                xTab:Add(XElement{row1["Column_Name"]:ToString(), XAttribute{"Type", row1["Data_Type"]:ToString()},;
                                 XAttribute{"Precision", IIf(row1["Numeric_Precision"] is DBNull, "", row1["Numeric_Precision"]:ToString())}})
                            next
                        catch ex As SystemException
                            Console.WriteLine("Fehler!!! " + ex:Message)
                        end try
                        xDbDoc:Add(xTab)
                    next
                catch ex As SystemException
                    infoMessage := i"!!! Fehler beim Abrufen der SQL-Server-Daten (" + ex:Message + ") !!!"
                    LogHelper.LogError(infoMessage, ex)
                    Return False
                end try
                try
                    // Xml-Dateien werden im Temp-Verzeichnis abgelegt
                    xmlPfad := Path.Combine(Path.GetTempPath(), DbName + ".xml")
                    xDbDoc:Save(xmlPfad)
                    infoMessage := i"*** {xmlPfad} wurde gespeichert ***"
                    LogHelper.LogInfo(infoMessage)
                    Return True
                catch ex As SystemException
                    infoMessage := i"!!! Fehler beim Abspeichern von {xmlPfad} (" + ex:Message + ") !!!"
                    LogHelper.LogError(infoMessage, ex)
                    Return False
                end try
            catch ex As SystemException
                infoMessage := i"!!! Allgemeiner Fehler in CreateSqlServerDataDic bei ConString={ConString} !!!"
                LogHelper.LogError(infoMessage, ex)
                Return False
            end try


        Public Static Method CreatePostgreDataDic(ConString As String, DbName As String) As Logic
            try
                Local xNs := XNamespace.Get("eureka-fach") As XNamespace
                Local xDbDoc := XElement{XName.Get("Database", xNs:NamespaceName), XAttribute{XNamespace.Xmlns + "ef", xNs},;
                 XAttribute{"constring", ConString}} As XElement
                Local xmlPfad := "" As String
                try
                    sqlText := i"SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE'"
                    Local ta := DataTable{} As DataTable
                    Local da := PgSqlDataAdapter{sqlText, ConString} As PgSqlDataAdapter
                    da:Fill(ta)
                    ta:DefaultView:Sort := "Table_Name Desc"
                    foreach row As DataRow in ta:Rows
                        Local TabName := row["table_name"]:ToString() As String
                        sqlText := i"Select * FROM INFORMATION_SCHEMA.COLUMNS Where table_name = '{TabName}'"
                        Local ta1 := DataTable{} As DataTable
                        Local da1 := PgSqlDataAdapter{sqlText, ConString} As PgSqlDataAdapter
                        da1:Fill(ta1)
                        Local xTab := XElement{XName.Get(TabName)} As XElement
                        try
                            foreach row1 As DataRow in ta1:Rows
                                xTab:Add(XElement{row1["Column_Name"]:ToString(), XAttribute{"Type", row1["Data_Type"]:ToString()},;
                                 XAttribute{"Precision", IIf(row1["Numeric_Precision"] is DBNull, "", row1["Numeric_Precision"]:ToString())}})
                            next
                        catch ex As SystemException
                            Console.WriteLine("Fehler!!! " + ex:Message)
                        end try
                        xDbDoc:Add(xTab)
                    next
                catch ex As SystemException
                    infoMessage := i"!!! Fehler beim Abrufen der Postgre-Server-Daten (" + ex:Message + ") !!!"
                    LogHelper.LogError(infoMessage, ex)
                    Return False
                end try
                try
                    // Xml-Dateien werden im Temp-Verzeichnis abgelegt
                    xmlPfad := Path.Combine(Path.GetTempPath(), DbName + ".xml")
                    xDbDoc:Save(xmlPfad)
                    infoMessage := i"*** {xmlPfad} wurde gespeichert ***"
                    LogHelper.LogInfo(infoMessage)
                    Return True
                catch ex As SystemException
                    infoMessage := i"!!! Fehler beim Abspeichern von {xmlPfad} (" + ex:Message + ") !!!"
                    LogHelper.LogError(infoMessage, ex)
                    Return False
                end try
            catch ex As SystemException
                infoMessage := i"!!! Allgemeiner Fehler in CreateSqlServerDataDic bei ConString={ConString} !!!"
                LogHelper.LogError(infoMessage, ex)
                Return False
            end try

        END CLASS
        
END NAMESPACE // EFDAL