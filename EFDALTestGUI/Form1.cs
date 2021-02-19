// File: Form1.cs

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Text.RegularExpressions;
using System.Xml.Linq;
using System.Windows.Forms;

using EFDAL;

namespace EFDALTestGUI
{
    public partial class fmMain : Form
    {
        private string infoMessage;
        private string currentTestPath;
        private string currentConfigPath;
        private string currentConstring;
        private List<DbTable> taDaten;

        public fmMain()
        {
            InitializeComponent();
            this.rbbDataReader.Checked = true;
            string appVersion = Assembly.GetExecutingAssembly().GetName().Version.ToString();
            this.Text += $" ({appVersion})";
            lblCurrentConfigPath.Text = "Keine Config-Datei";
            lblCurrentDataDicPath.Text = "Keine DataDic-Datei";
        }

        private void btnEditConfig_Click(object sender, EventArgs e)
        {
            using (OpenFileDialog ofd = new OpenFileDialog())
            {
                ofd.InitialDirectory = Environment.CurrentDirectory;
                ofd.Filter = "Config-Dateien (*.txt)|*.txt|Alle Dateien|*.*";
                if (ofd.ShowDialog() == DialogResult.OK)
                {
                    currentConfigPath = ofd.FileName;
                    lblCurrentConfigPath.Text = currentConfigPath;
                    try
                    {
                        ProcessStartInfo pInfo = new ProcessStartInfo("Notepad", currentConfigPath);
                        Process.Start(pInfo);
                    }
                    catch (SystemException ex)
                    {
                        MessageBox.Show($"Fehler - {currentConfigPath} kann nicht angezeigt werden.", ex.Message);
                    }
                }
            }

        }

        private void LogMessage(string logMessage)
        {
            libStatus.Items.Add(logMessage);
            libStatus.SelectedIndex = libStatus.Items.Count - 1;
        }

        private void btnTestStart_Click(object sender, EventArgs e)
        {
            try
            {
                // Gibt es eine Config-Datei?
                if (this.currentConfigPath == null || !File.Exists(this.currentConfigPath))
                {
                    MessageBox.Show("Bitte zuerst ein Config-Datei auswählen", "Hinweis");
                    return;
                }
                // Gibt es eine Test-Datei?
                if (this.currentTestPath == null || !File.Exists(this.currentTestPath))
                {
                    MessageBox.Show("Bitte zuerst ein DataDic (Xml-Datei) auswählen", "Hinweis");
                    return;
                }
                XElement xDoc = XElement.Load(this.currentTestPath);
                taDaten = new List<DbTable>();
                this.currentConstring = xDoc.Attribute(XName.Get("constring")).Value;
                foreach (XElement xTab in xDoc.Elements())
                {
                    DbTable ta = new DbTable { TabName = xTab.Name.LocalName };
                    // ALle Felder durchgehen
                    foreach (XElement xField in xTab.Elements())
                    {
                        ta.Fields.Add(new DbField
                        {
                            FieldName = xField.Name.LocalName,
                            DataType = xField.Attribute("Type").Value,
                            Precision = xField.Attribute("Precision").Value == "" ? 0 : Int32.Parse(xField.Attribute("Precision").Value)
                        });
                    }
                    taDaten.Add(ta);
                }
                // Jetzt Test durchführen
                if (rbbDataReader.Checked)
                {
                    infoMessage = $"*** Starte DALReader-Test1 für {currentConstring} ***";
                    LogMessage(infoMessage);
                    bool result = DataReaderTest.DALReaderTest1(taDaten, currentConstring);
                    if (result)
                    {
                        infoMessage = "*** DALReader-Test1 erfolgreich absolviert ***";
                    }
                    else
                    {
                        infoMessage = "!!! DALReader-Test1 - es traten Fehler auf (alle Details in der Log-Datei) !!!";
                    }
                    LogMessage(infoMessage);
                }
                else
                {
                    infoMessage = $"*** Starte DataRow-Test1 für  {currentConstring} ***";
                    LogMessage(infoMessage);
                    bool result = DataRowTest.DataRowTest1(taDaten, currentConstring);
                    if (result)
                    {
                        infoMessage = "*** DataRow-Test1 erfolgreich absolviert ***";
                    }
                    else
                    {
                        infoMessage = "!!! DataRow-Test1 - es traten Fehler auf (alle Details in der Log-Datei) !!!";
                    }
                    LogMessage(infoMessage);

                }
            }
            catch (SystemException ex)
            {
                infoMessage = $"!!! Allgemeiner Fehler in btnTestStart_Click ({ex:Mesage}) !!!";
                LogHelper.LogError(infoMessage, ex);
            }
        }

        private void bnDataDicErstellen_Click(object sender, EventArgs e)
        {
            // Config-Datei auswerten
            string configName = "";
            string dbName = "";
            int configCount = 0;
            double dauerSec = 0;
            DateTime startZeit = DateTime.Now;
            Dictionary<string, List<string>> dicConfig = new Dictionary<string, List<string>>();
            using (StreamReader sr = new StreamReader(currentConfigPath))
            {
                while (!sr.EndOfStream)
                {
                    string line = sr.ReadLine();
                    // Ist es eine config-Zeile?
                    if (Regex.IsMatch(line, @"\[(\w+)\]"))
                    {
                        configName = Regex.Match(line, @"\[(\w+)\]").Groups[1].Value;
                        if (!dicConfig.ContainsKey(configName))
                        {
                            dicConfig.Add(configName, new List<string>());
                        }
                    }
                    else if (line.StartsWith("Data Source"))
                    {
                        dicConfig[configName].Add(line);
                        configCount++;
                    }
                }
            }
            infoMessage = $"{configCount} Konfigurationen eingelesen.";
            libStatus.Items.Add(infoMessage);
            // Alle Konfigurationen durchgehen
            foreach (string config in dicConfig.Keys)
            {
                switch (config)
                {
                    case "Oracle":
                        infoMessage = $"*** Verarbeite Konfiguration {config} ***";
                        libStatus.Items.Add(infoMessage);
                        progressBar1.Maximum = dicConfig[config].Count;
                        foreach (string conString in dicConfig[config])
                        {
                            progressBar1.Value++;
                            Application.DoEvents();
                            infoMessage = $"*** Erstelle Xml-DataDictionary für {conString} ***";
                            LogMessage(infoMessage);
                            dbName = Regex.Match(conString, @"User Id=([\w_]+)").Groups[1].Value;
                            if (EFDAL.DBHelper.CreateOracleDataDic(conString, dbName))
                            {
                                infoMessage = $"*** Xml-DataDictionary wurde erstellt ***";
                                LogMessage(infoMessage);
                            }
                            else
                            {
                                infoMessage = $"!!! Xml-DataDictionary konnte nicht erstellt werden !!!";
                                LogMessage(infoMessage);
                            }
                        }
                        progressBar1.Value = 0;
                        break;
                    case "SqlServer":
                        infoMessage = $"*** Verarbeite Konfiguration {config} ***";
                        libStatus.Items.Add(infoMessage);
                        progressBar1.Maximum = dicConfig[config].Count;
                        foreach (string conString in dicConfig[config])
                        {
                            progressBar1.Value++;
                            Application.DoEvents();
                            infoMessage = $"*** Erstelle Xml-DataDictionary für {conString} ***";
                            LogMessage(infoMessage);
                            dbName = Regex.Match(conString, @"Initial Catalog\s*=\s*(\w+)").Groups[1].Value;
                            if (EFDAL.DBHelper.CreateSqlServerDataDic(conString, dbName))
                            {
                                infoMessage = $"*** Xml-DataDictionary wurde erstellt ***";
                                LogMessage(infoMessage);
                            }
                            else
                            {
                                infoMessage = $"!!! Xml-DataDictionary konnte nicht erstellt werden !!!";
                                LogMessage(infoMessage);
                            }
                        }
                        progressBar1.Value = 0;
                        break;
                    case "Postgre":
                        infoMessage = $"*** Verarbeite Konfiguration {config} ***";
                        libStatus.Items.Add(infoMessage);
                        progressBar1.Maximum = dicConfig[config].Count;
                        foreach (string conString in dicConfig[config])
                        {
                            progressBar1.Value++;
                            Application.DoEvents();
                            infoMessage = $"*** Erstelle Xml-DataDictionary für {conString} ***";
                            LogMessage(infoMessage);
                            dbName = Regex.Match(conString, @"Database\s*=\s*(\w+)").Groups[1].Value;
                            if (EFDAL.DBHelper.CreateSqlServerDataDic(conString, dbName))
                            {
                                infoMessage = $"*** Xml-DataDictionary wurde erstellt ***";
                                LogMessage(infoMessage);
                            }
                            else
                            {
                                infoMessage = $"!!! Xml-DataDictionary konnte nicht erstellt werden !!!";
                                LogMessage(infoMessage);
                            }
                        }
                        progressBar1.Value = 0;
                        break;

                    default:
                        infoMessage = $"!!! Unbekannte Konfiguration {config} !!!";
                        LogMessage(infoMessage);
                        break;
                }
            }
            dauerSec = (DateTime.Now - startZeit).TotalSeconds;
            MessageBox.Show($"Auftrag ausgeführt in {dauerSec:n2}s", "EFDALTest");
        }

        private void bnTestAuswahl_Click(object sender, EventArgs e)
        {
            using (OpenFileDialog ofd = new OpenFileDialog())
            {
                ofd.InitialDirectory = Path.GetTempPath();
                ofd.Filter = "DataDic-Dateien (*.xml)|*.xml|Alle Dateien|*.*";
                if (ofd.ShowDialog() == DialogResult.OK)
                {
                    currentTestPath = ofd.FileName;
                    lblCurrentDataDicPath.Text = currentTestPath;
                }
            }
        }
    }
}
