$exchange_front_end = '@@YOUREXCHANGESERVER@@'
$db_output = '@@YOURSQLNAME@@'
$db_tablename1 = "@@[database_you_make].[dbo].[table_you_make_table1]@@"
$db_tablename2 = "@@[database_you_make].[dbo].[table_you_make_table2]@@"
$db_catalog = '@@YOUR_DB_NAME@@'
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$exchange_front_end/PowerShell/ -Authentication Kerberos
import-pssession $session

$dbstatus = Get-MailboxDatabaseCopyStatus *\*|select name, status, contentindexstate, copyqueuelength, replayqueuelength, ActiveDatabaseCopy
$mounted = $null
$highcopyqueue = $null
$highreplayqueue = $null
$copystatus = $null
$cistatus = $null
$Active_Dags = Get-MailboxDatabaseCopyStatus *\*|select ActiveDatabaseCopy | sort ActiveDatabaseCopy | Get-Unique -AsString
   
Invoke-Sqlcmd -ServerInstance $db_output -Database Tech_ReaderBoard  -Query "truncate table $db_tablename1;truncate table $db_tablename2;"
$sqlConnectionString = "Data Source=$db_output;Initial Catalog=$db_catalog;Integrated Security=SSPI;"
$conn = New-Object System.Data.SqlClient.SqlConnection
$conn.ConnectionString = $sqlConnectionString
$conn.open()
foreach ($server in $Active_Dags){
    $counter = ($dbstatus | where{$_.activedatabaseCopy -eq $server.ActiveDatabaseCopy}).count
    Invoke-Sqlcmd -ServerInstance $db_output -Database Tech_ReaderBoard -Query "insert into $db_tablename1 values ('$(($server.ActiveDatabaseCopy).ToUpper())','$counter')"
    }
foreach ($dbstat in $dbstatus) {

    $sqlcmd = New-Object System.Data.SqlClient.SqlCommand("USP_Insert_Exchange_DB_Health", $conn)
    $SqlCmd.CommandType = [System.Data.CommandType]'StoredProcedure'
    $sqlcmd.Parameters.Add("@Name", $dbstat.name) | Out-Null
    $sqlcmd.Parameters.Add("@status", $dbstat.status) | Out-Null
    $sqlcmd.Parameters.Add("@contentindexstate", $dbstat.contentindexstate) | Out-Null
    $sqlcmd.Parameters.Add("@copyqueuelength", $dbstat.copyqueuelength) | Out-Null
    $sqlcmd.Parameters.Add("@replayqueuelength", $dbstat.replayqueuelength) | Out-Null
    $sqlcmd.Parameters.Add("@ActiveDatabaseCopy", $dbstat.ActiveDatabaseCopy) | Out-Null
    $sqlCmdResult = $sqlcmd.executenonquery()
}
Get-PSSession | where{ $_.configurationName -Like 'Microsoft.Exchange'} |Remove-PSSession