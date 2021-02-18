// File: DBTable.cs

using System;
using System.Collections.Generic;

namespace EFDALTestGUI
{
    public class DbTable
    {
        public string TabName { get; set; }
        public List<DbField> Fields { get; set; }

        public DbTable()
        {
            this.Fields = new List<DbField>();
        }
    }
}
