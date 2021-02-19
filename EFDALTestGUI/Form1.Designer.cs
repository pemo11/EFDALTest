
namespace EFDALTestGUI
{
    partial class fmMain
    {
        /// <summary>
        /// Erforderliche Designervariable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Verwendete Ressourcen bereinigen.
        /// </summary>
        /// <param name="disposing">True, wenn verwaltete Ressourcen gelöscht werden sollen; andernfalls False.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Vom Windows Form-Designer generierter Code

        /// <summary>
        /// Erforderliche Methode für die Designerunterstützung.
        /// Der Inhalt der Methode darf nicht mit dem Code-Editor geändert werden.
        /// </summary>
        private void InitializeComponent()
        {
            this.tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel();
            this.progressBar1 = new System.Windows.Forms.ProgressBar();
            this.panel1 = new System.Windows.Forms.Panel();
            this.bnTestAuswahl = new System.Windows.Forms.Button();
            this.bnDataDicErstellen = new System.Windows.Forms.Button();
            this.btnEditConfig = new System.Windows.Forms.Button();
            this.btnTestStart = new System.Windows.Forms.Button();
            this.panel2 = new System.Windows.Forms.Panel();
            this.rbbDataRow = new System.Windows.Forms.RadioButton();
            this.rbbDataReader = new System.Windows.Forms.RadioButton();
            this.libStatus = new System.Windows.Forms.ListBox();
            this.tableLayoutPanel2 = new System.Windows.Forms.TableLayoutPanel();
            this.txtCurrentConfigPath = new System.Windows.Forms.TextBox();
            this.txtCurrentDataDicPath = new System.Windows.Forms.TextBox();
            this.tableLayoutPanel1.SuspendLayout();
            this.panel1.SuspendLayout();
            this.panel2.SuspendLayout();
            this.tableLayoutPanel2.SuspendLayout();
            this.SuspendLayout();
            // 
            // tableLayoutPanel1
            // 
            this.tableLayoutPanel1.ColumnCount = 1;
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel1.Controls.Add(this.progressBar1, 0, 3);
            this.tableLayoutPanel1.Controls.Add(this.panel1, 0, 0);
            this.tableLayoutPanel1.Controls.Add(this.panel2, 0, 2);
            this.tableLayoutPanel1.Controls.Add(this.libStatus, 0, 4);
            this.tableLayoutPanel1.Controls.Add(this.tableLayoutPanel2, 0, 1);
            this.tableLayoutPanel1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tableLayoutPanel1.Location = new System.Drawing.Point(0, 0);
            this.tableLayoutPanel1.Name = "tableLayoutPanel1";
            this.tableLayoutPanel1.RowCount = 5;
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 15.61424F));
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 5.946314F));
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 10.22896F));
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 5.617702F));
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 62.59278F));
            this.tableLayoutPanel1.Size = new System.Drawing.Size(841, 573);
            this.tableLayoutPanel1.TabIndex = 0;
            // 
            // progressBar1
            // 
            this.progressBar1.BackColor = System.Drawing.Color.White;
            this.progressBar1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.progressBar1.Location = new System.Drawing.Point(3, 184);
            this.progressBar1.Name = "progressBar1";
            this.progressBar1.Size = new System.Drawing.Size(835, 26);
            this.progressBar1.TabIndex = 2;
            // 
            // panel1
            // 
            this.panel1.BackColor = System.Drawing.Color.Silver;
            this.panel1.Controls.Add(this.bnTestAuswahl);
            this.panel1.Controls.Add(this.bnDataDicErstellen);
            this.panel1.Controls.Add(this.btnEditConfig);
            this.panel1.Controls.Add(this.btnTestStart);
            this.panel1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.panel1.Location = new System.Drawing.Point(3, 3);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(835, 83);
            this.panel1.TabIndex = 0;
            // 
            // bnTestAuswahl
            // 
            this.bnTestAuswahl.Location = new System.Drawing.Point(430, 20);
            this.bnTestAuswahl.Name = "bnTestAuswahl";
            this.bnTestAuswahl.Size = new System.Drawing.Size(155, 40);
            this.bnTestAuswahl.TabIndex = 4;
            this.bnTestAuswahl.Text = "&Testauswahl (3)";
            this.bnTestAuswahl.UseVisualStyleBackColor = true;
            this.bnTestAuswahl.Click += new System.EventHandler(this.bnTestAuswahl_Click);
            // 
            // bnDataDicErstellen
            // 
            this.bnDataDicErstellen.Location = new System.Drawing.Point(248, 20);
            this.bnDataDicErstellen.Name = "bnDataDicErstellen";
            this.bnDataDicErstellen.Size = new System.Drawing.Size(155, 40);
            this.bnDataDicErstellen.TabIndex = 3;
            this.bnDataDicErstellen.Text = "&DataDics erstellen (2)";
            this.bnDataDicErstellen.UseVisualStyleBackColor = true;
            this.bnDataDicErstellen.Click += new System.EventHandler(this.bnDataDicErstellen_Click);
            // 
            // btnEditConfig
            // 
            this.btnEditConfig.Location = new System.Drawing.Point(23, 20);
            this.btnEditConfig.Name = "btnEditConfig";
            this.btnEditConfig.Size = new System.Drawing.Size(155, 40);
            this.btnEditConfig.TabIndex = 2;
            this.btnEditConfig.Text = "&Config-Auswahl (1)";
            this.btnEditConfig.UseVisualStyleBackColor = true;
            this.btnEditConfig.Click += new System.EventHandler(this.btnEditConfig_Click);
            // 
            // btnTestStart
            // 
            this.btnTestStart.Location = new System.Drawing.Point(621, 20);
            this.btnTestStart.Name = "btnTestStart";
            this.btnTestStart.Size = new System.Drawing.Size(155, 40);
            this.btnTestStart.TabIndex = 1;
            this.btnTestStart.Text = "&Test-Start (4)";
            this.btnTestStart.UseVisualStyleBackColor = true;
            this.btnTestStart.Click += new System.EventHandler(this.btnTestStart_Click);
            // 
            // panel2
            // 
            this.panel2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(192)))), ((int)(((byte)(255)))), ((int)(((byte)(255)))));
            this.panel2.Controls.Add(this.rbbDataRow);
            this.panel2.Controls.Add(this.rbbDataReader);
            this.panel2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.panel2.Location = new System.Drawing.Point(3, 126);
            this.panel2.Name = "panel2";
            this.panel2.Size = new System.Drawing.Size(835, 52);
            this.panel2.TabIndex = 3;
            // 
            // rbbDataRow
            // 
            this.rbbDataRow.AutoSize = true;
            this.rbbDataRow.Location = new System.Drawing.Point(231, 15);
            this.rbbDataRow.Name = "rbbDataRow";
            this.rbbDataRow.Size = new System.Drawing.Size(172, 24);
            this.rbbDataRow.TabIndex = 1;
            this.rbbDataRow.TabStop = true;
            this.rbbDataRow.Text = "DataRow-Konvertierung";
            this.rbbDataRow.UseVisualStyleBackColor = true;
            // 
            // rbbDataReader
            // 
            this.rbbDataReader.AutoSize = true;
            this.rbbDataReader.Location = new System.Drawing.Point(9, 15);
            this.rbbDataReader.Name = "rbbDataReader";
            this.rbbDataReader.Size = new System.Drawing.Size(189, 24);
            this.rbbDataReader.TabIndex = 0;
            this.rbbDataReader.TabStop = true;
            this.rbbDataReader.Text = "DataReader-Konvertierung";
            this.rbbDataReader.UseVisualStyleBackColor = true;
            // 
            // libStatus
            // 
            this.libStatus.Dock = System.Windows.Forms.DockStyle.Fill;
            this.libStatus.Font = new System.Drawing.Font("Arial Narrow", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.libStatus.FormattingEnabled = true;
            this.libStatus.ItemHeight = 16;
            this.libStatus.Location = new System.Drawing.Point(3, 216);
            this.libStatus.Name = "libStatus";
            this.libStatus.Size = new System.Drawing.Size(835, 354);
            this.libStatus.TabIndex = 4;
            // 
            // tableLayoutPanel2
            // 
            this.tableLayoutPanel2.ColumnCount = 2;
            this.tableLayoutPanel2.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel2.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel2.Controls.Add(this.txtCurrentConfigPath, 0, 0);
            this.tableLayoutPanel2.Controls.Add(this.txtCurrentDataDicPath, 1, 0);
            this.tableLayoutPanel2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tableLayoutPanel2.Location = new System.Drawing.Point(3, 92);
            this.tableLayoutPanel2.Name = "tableLayoutPanel2";
            this.tableLayoutPanel2.RowCount = 1;
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 20F));
            this.tableLayoutPanel2.Size = new System.Drawing.Size(835, 28);
            this.tableLayoutPanel2.TabIndex = 5;
            // 
            // txtCurrentConfigPath
            // 
            this.txtCurrentConfigPath.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(255)))), ((int)(((byte)(192)))));
            this.txtCurrentConfigPath.Dock = System.Windows.Forms.DockStyle.Fill;
            this.txtCurrentConfigPath.Location = new System.Drawing.Point(3, 3);
            this.txtCurrentConfigPath.Name = "txtCurrentConfigPath";
            this.txtCurrentConfigPath.ReadOnly = true;
            this.txtCurrentConfigPath.Size = new System.Drawing.Size(411, 25);
            this.txtCurrentConfigPath.TabIndex = 8;
            // 
            // txtCurrentDataDicPath
            // 
            this.txtCurrentDataDicPath.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(192)))), ((int)(((byte)(255)))), ((int)(((byte)(192)))));
            this.txtCurrentDataDicPath.Dock = System.Windows.Forms.DockStyle.Fill;
            this.txtCurrentDataDicPath.Location = new System.Drawing.Point(420, 3);
            this.txtCurrentDataDicPath.Name = "txtCurrentDataDicPath";
            this.txtCurrentDataDicPath.ReadOnly = true;
            this.txtCurrentDataDicPath.Size = new System.Drawing.Size(412, 25);
            this.txtCurrentDataDicPath.TabIndex = 9;
            // 
            // fmMain
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 20F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(224)))), ((int)(((byte)(192)))));
            this.ClientSize = new System.Drawing.Size(841, 573);
            this.Controls.Add(this.tableLayoutPanel1);
            this.Font = new System.Drawing.Font("Arial Narrow", 11.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.Margin = new System.Windows.Forms.Padding(4, 5, 4, 5);
            this.Name = "fmMain";
            this.Text = "EF-DAL-Test";
            this.tableLayoutPanel1.ResumeLayout(false);
            this.panel1.ResumeLayout(false);
            this.panel2.ResumeLayout(false);
            this.panel2.PerformLayout();
            this.tableLayoutPanel2.ResumeLayout(false);
            this.tableLayoutPanel2.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel1;
        private System.Windows.Forms.ProgressBar progressBar1;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.Button btnEditConfig;
        private System.Windows.Forms.Button btnTestStart;
        private System.Windows.Forms.Panel panel2;
        private System.Windows.Forms.ListBox libStatus;
        private System.Windows.Forms.RadioButton rbbDataRow;
        private System.Windows.Forms.RadioButton rbbDataReader;
        private System.Windows.Forms.Button bnTestAuswahl;
        private System.Windows.Forms.Button bnDataDicErstellen;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel2;
        private System.Windows.Forms.TextBox txtCurrentConfigPath;
        private System.Windows.Forms.TextBox txtCurrentDataDicPath;
    }
}

