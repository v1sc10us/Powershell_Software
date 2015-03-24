function Get-PatchSchedule([switch]$month, [switch]$year) {

    if($year -eq $TRUE -and !$month){

    $CalendarType = new-object system.globalization.datetimeformatinfo
    $gregor = $CalendarType.MonthNames
    [datetime]$Today=[datetime]::NOW
    $yearRequested=Read-Host "Year?"
    $yearRequested = $yearRequested.ToString()
    }
    if($month -and !$year){
        $gregor = Read-Host "What Month do you want the schedule for (FORMAT full name ie March or the numeric equivilant)?"
        [datetime]$Today=[datetime]::NOW
        $yearRequested=$Today.Year.ToString()
        }
    if($month -eq $TRUE -and $year -eq $TRUE){
        $gregor = Read-Host "Month?"
        $yearRequested = Read-Host "Year?"
        }
    elseif(!$month -and !$year){
        [datetime]$Today=[datetime]::NOW
        $yearRequested=$Today.Year.ToString()
        $gregor = $Today.Month.ToString()
        }
    foreach($monthes in $gregor){
        if($monthes -ne ""){
        $FindNthDay=2
        $WeekDay='Tuesday'
        [datetime]$StrtMonth=$monthes+'/1/'+$yearRequested
        while ($StrtMonth.DayofWeek -ine $WeekDay) { $StrtMonth=$StrtMonth.AddDays(1) }
        $MS_release = $StrtMonth.AddDays(7*($FindNthDay-1)).AddHours(10)
        #
        $Test_Server = $MS_release.AddHours(10)
        $P002_01_ITL_AUTOREBOOT = $MS_release.adddays(4).AddHours(14)
        $P002_02_ITL_MANEX = $MS_release.adddays(4).AddHours(14)
        $P003_01_DOM_SPL1 = $MS_release.AddDays(11).AddHours(13)
        $P003_02_CITRIX = $MS_release.AddDays(11).AddHours(13)
        $P003_03_BRANCH = $MS_release.AddDays(11).AddHours(13).AddMinutes(30)
        $P004_01_DOM_SPL2 = $MS_release.AddDays(18).AddHours(13)
        $P004_02_SQL_PROD = $MS_release.AddDays(18).AddHours(14)
        $P004_03_APP = $MS_release.AddDays(18).AddHours(15)
        $P004_04_INFRA = $MS_release.AddDays(18).AddHours(16)
        $P004_05_QRM = $MS_release.AddDays(18).AddHours(17)
        $P004_06_SHAREP = $MS_release.AddDays(18).AddHours(17).AddMinutes(30)
        $P004_07_EXCH_AUTO = $MS_release.AddDays(18).AddHours(18)
        $P004_08_EXCH_MAN = $MS_release.AddDays(18).AddHours(18).AddMinutes(30)
        $P004_09_MISC = $MS_release.AddDays(18).AddHours(19)
        $P004_10_OPS = $MS_release.AddDays(18).AddHours(19)
        Write-host "$month`n___________`n"
        write "`nP001 TEST SERVERS`n"
        $Test_Server
        write "`nP002 BR SITE`n"
        $P002_01_ITL_AUTOREBOOT
        $P002_02_ITL_MANEX
        write "`nP003 Citrix/Branches`n"
        $P003_01_DOM_SPL1
        $P003_02_CITRIX
        $P003_03_BRANCH
        write "`nP004 Mainsite`n"
        $P004_01_DOM_SPL2
        $P004_02_SQL_PROD
        $P004_03_APP
        $P004_04_INFRA
        $P004_05_QRM
        $P004_06_SHAREP
        $P004_07_EXCH_AUTO
        $P004_08_EXCH_MAN
        $P004_09_MISC
        $P004_10_OPS
        write "`n--------`n"
        
        
        
        }
    }    
}    
