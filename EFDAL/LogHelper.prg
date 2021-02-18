// ============================================================================
// File: LogHelper.prg
// ============================================================================

Using System
Using NLog

Begin Namespace EFDAL

	Static Class LogHelper
        Static Private logMan As Logger
    
        Static Constructor()
            logMan := LogManager.GetCurrentClassLogger()
            Return
 
        /// <summary>
        /// hier Beschreibung eingeben 
        /// </summary>
        /// <param name="Message"></param> 
        Static Method LogInfo(Message As String) As Void
            logMan:Info(Message)
            Return
            
        /// <summary>
        /// hier Beschreibung eingeben 
        /// </summary>
        /// <param name="Message"></param> 
        /// <param name="Error"></param> 
        Static Method LogError(Message As String, Error As Exception) As Void
            logMan:Error(Error, Message)
            Return
            
        /// <summary>
        /// hier Beschreibung eingeben 
        /// </summary>
        /// <param name="Message"></param> 
        Static Method LogSpezial(Message as String) As Void
            Local logMan := LogManager.GetLogger("Spezial") As Logger
            logMan:Info(Message)
            Return
            
        /// <summary>
        /// hier Beschreibung eingeben 
        /// </summary>
        /// <param name="SqlText"></param> 
        /// <param name="RetVal"></param> 
        /// <param name="Location"></param> 
        Static Method LogSQL(SqlText As String, RetVal As Int, Location As String) As Void
            Local ClassName := Location:Split(c".")[1] As String
            Local msg := i"+++ {ClassName}: RetVal={RetVal} für {SqlText} +++" as string
            LogMan:Info(msg)
            Return
            
	End Class

End Namespace