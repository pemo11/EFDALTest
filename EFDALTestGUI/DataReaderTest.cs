// File: DataReaderTest.cs

using System;
using System.Collections.Generic;
using System.Linq;

using EFDAL;

namespace EFDALTestGUI
{
    public static class DataReaderTest
    {
        private static string infoMessage;
        private static string sqlText;

        public static bool DALReaderTest1(List<DbTable> taDaten, String conString)
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
            // Postgre-Datentypen
            dicType.Add("timestamp", "datetime");
            dicType.Add("numeric", "decimal");
            dicType.Add("character varying", "string");
            dicType.Add("integer", "int32");
            dicType.Add("bigint", "int64");
            dicType.Add("timestamp without time zone", "datetime");
            dicType.Add("character", "string");
            dicType.Add("bytea", "byte[]");

            infoMessage = $"*** Test DALReaderTest1 mit ConString={conString} beginnt ***";
            LogHelper.LogInfo(infoMessage);
            foreach (DbTable tb in taDaten)
            {
                sqlText = "Select * From " + tb.TabName;
                try
                {
                    i++;
                    using (var dr = DbFunctions.ExecuteReader(sqlText, true))
                    {
                        if (dr != null)
                        {
                            infoMessage = $"*** ({i}) DataReader-Abruf für {tb.TabName} war erfolgreich ***";
                            LogHelper.LogInfo(infoMessage);
                            if (dr.Read())
                            {
                                // Jetzt alle Felder durchgehen
                                foreach (DbField Field in tb.Fields)
                                {
                                    var fieldVal = DbFunctions.GetReaderValue(dr, Field.FieldName);
                                    // Diese Abfrage liefert immer ein _usual
                                    // string fieldType = fieldVal.GetType().Name;
                                    string fieldType = dr[Field.FieldName].GetType().Name.ToLower();
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
                        else
                        {
                            ret = false;
                        }
                    }
                }
                catch (SystemException ex)
                {
                    infoMessage = $"!!!  ({i}) Fehler beim DataReader-Abruf für {tb.TabName} ({ex.Message}) !!!";
                    LogHelper.LogInfo(infoMessage);
                    ret = false;
                }

            }
            infoMessage = $"*** Test DALReaderTest1 wurde für {taDaten.Count} Tabellen abgeschlossen ***";
            LogHelper.LogInfo(infoMessage);
            return true;

        }
    }
}
