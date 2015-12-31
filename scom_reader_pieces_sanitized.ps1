$scom_server = '@@your_scom_server@@'
$db_output = '@@your_database_server@@'
$db_tablename1 = "@@[database_you_make].[dbo].[table_you_make_table1]@@"
$db_tablename2 = "@@[database_you_make].[dbo].[table_you_make_table2]@@"
$db_catalog = '@@YOUR_DB_NAME@@'
$scom = New-PSSession -ComputerName $scom_server
Import-PSSession $scom -Module operationsManager

$scom_crits = Get-SCOMAlert -Severity 2 -ResolutionState 0 | sort TimeRaised -Descending
$scom_Warns = Get-SCOMAlert -Severity 1 -ResolutionState 0 | sort TimeRaised -Descending

Get-PSSession | where {$_.ComputerName -eq "$scom_server"} | Remove-PSSession
$show_me_crits = @()
$take_warning = @()

$sqlConnectionString = "Data Source=$db_output;Initial Catalog=$db_catalog;Integrated Security=SSPI;"
$conn = New-Object System.Data.SqlClient.SqlConnection
$conn.ConnectionString = $sqlConnectionString
$conn.open()

foreach($sc in $scom_crits[0..4]) 
{
        $line = New-Object PSObject
        $line | Add-Member -MemberType NoteProperty -Name 'Name' -Value "$($sc.name)"
        $line | Add-Member -MemberType NoteProperty -Name 'Type' -Value "Critical"
        $line | Add-Member -MemberType NoteProperty -Name 'Description' -Value "$($sc.Description)"
        $line | Add-Member -MemberType NoteProperty -Name 'MonitoringObjectDisplayName' -Value "$($sc.MonitoringObjectDisplayName)"
        $line | Add-Member -MemberType NoteProperty -Name 'TimeRaised' -Value "$($sc.TimeRaised)"
        $show_me_crits += $line
}

foreach($sw in $scom_Warns[0..4])
{
        $line = New-Object PSObject
        $line | Add-Member -MemberType NoteProperty -Name 'Name' -Value "$($sw.name)"
        $line | Add-Member -MemberType NoteProperty -Name 'Type' -Value "Warning"
        $line | Add-Member -MemberType NoteProperty -Name 'Description' -Value "$($sw.Description)"
        $line | Add-Member -MemberType NoteProperty -Name 'MonitoringObjectDisplayName' -Value "$($sw.MonitoringObjectDisplayName)"
        $line | Add-Member -MemberType NoteProperty -Name 'TimeRaised' -Value "$($sw.TimeRaised)"
        $take_warning += $line

}
Invoke-Sqlcmd -ServerInstance $db_output -Database Tech_ReaderBoard -Query "truncate table $db_tablename1; truncate table $db_tablename2; insert into $db_tablename1 (SCOMWarningCount, SCOMCritCount) values($($scom_Warns.count),$($scom_crits.count));"
foreach($warn in $take_warning)
{

    $sqlcmd = New-Object System.Data.SqlClient.SqlCommand("USP_Insert_SCOM_Top_5", $conn)
    $SqlCmd.CommandType = [System.Data.CommandType]'StoredProcedure'
    $sqlcmd.Parameters.Add("@Name", $warn.name) | Out-Null
    $sqlcmd.Parameters.Add("@Description", $warn.Description) | Out-Null
    $sqlcmd.Parameters.Add("@MonitoringObjectDisplayName", $warn.MonitoringObjectDisplayName) | Out-Null
    $sqlcmd.Parameters.Add("@TimeRaised", $warn.TimeRaised) | Out-Null
    $sqlcmd.Parameters.Add("@type", $warn.type) | Out-Null

    $sqlCmdResult = $sqlcmd.executenonquery()

}
foreach($crit in $show_me_crits)
{
    $sqlcmd = New-Object System.Data.SqlClient.SqlCommand("USP_Insert_SCOM_Top_5", $conn)
    $SqlCmd.CommandType = [System.Data.CommandType]'StoredProcedure'
    $sqlcmd.Parameters.Add("@Name", $crit.name) | Out-Null
    $sqlcmd.Parameters.Add("@Description", $crit.Description) | Out-Null
    $sqlcmd.Parameters.Add("@MonitoringObjectDisplayName", $crit.MonitoringObjectDisplayName) | Out-Null
    $sqlcmd.Parameters.Add("@TimeRaised", $crit.TimeRaised) | Out-Null
    $sqlcmd.Parameters.Add("@type", $crit.type) | Out-Null

    $sqlCmdResult = $sqlcmd.executenonquery()
}

