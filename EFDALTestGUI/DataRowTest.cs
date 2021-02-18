// File: DataRowTest.cs

using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;

using EFDAL;

namespace EFDALTestGUI
{
    public static class DataRowTest
    {
        private static string infoMessage;
        private static string sqlText;

        public static bool DataRowTest1(List<DbTable> taDaten, string conString)
        {
            bool ret = true;
            int i = 0;
            Dictionary<string, string> dicType = new Dictionary<string, string>();
            dicType.Add("varchar", "string");
            dicType.Add("int32", "int");
            dicType.Add("int", "int32");
            dicType.Add("char", "string");
            dicType.Add("text", "string");
            dicType.Add("bit", "boolean");
            // Eingefügt für Postgre
            dicType.Add("character varying", "string");
            dicType.Add("character", "string");
            dicType.Add("integer", "int32");
            dicType.Add("numeric", "decimal");
            dicType.Add("bigint", "int64");
            dicType.Add("timestamp without time zone", "datetime");
            dicType.Add("bytea", "byte[]");

            infoMessage = $"*** Test DataRowTest1 mit ConString={conString} beginnt ***";
            LogHelper.LogInfo(infoMessage);
            foreach (DbTable tb in taDaten)
            {
                sqlText = "Select * From " + tb.TabName;
                try
                {
                    i++;
                    DataRow row = DbFunctions.InvokeSelectRow(sqlText);
                    if (row != null)
                    {
                        infoMessage = $"*** ({i}) DataRow-Abruf für {tb.TabName} war erfolgreich ***";
                        LogHelper.LogInfo(infoMessage);
                        // Jetzt alle Felder durchgehen
                        foreach (DbField Field in tb.Fields)
                        {
                            var fieldVal = DbFunctions.GetRowValue(row, Field.FieldName);
                            string fieldType = row[Field.FieldName].GetType().Name.ToLower();
                            string fieldAliasType = dicType.ContainsKey(Field.DataType) ? dicType[Field.DataType] : "";
                            if (fieldType != "dbnull" && fieldType != Field.DataType && fieldType != fieldAliasType)
                            {
                                ret = false;
                            }
                        }
                        if (ret)
                        {
                            infoMessage = $"*** Alle Felder für {tb.TabName} fehlerfrei konvertiert ***";
                            LogHelper.LogInfo(infoMessage);
                        }
                    }
                    else
                    {
                        infoMessage = $"*** ({i}) Keine Datensätze bei {tb.TabName} ***";
                        LogHelper.LogInfo(infoMessage);
                    }
                }
                catch (SystemException ex)
                {
                    infoMessage = $"!!! ({i}) Fehler beim DataRow-Abruf für {tb.TabName} ({ex.Message}) !!!";
                    LogHelper.LogInfo(infoMessage);
                    ret = false;
                }

            }
            infoMessage = $"*** Test DataRowTest1 wurde für {taDaten.Count} Tabellen abeschlossen ***";
            LogHelper.LogInfo(infoMessage);
            return true;
        }

    }
}
