[console]::OutputEncoding = [System.Text.Encoding]::UTF8
cls
Write-Host "### SCRIPT TO COLLECT GOOGLE WORKSPACE DATA, PLEASE FOLLOW INSTRUCTIONS ###"
Write-Host

function pause{ $null = Read-Host 'Press ENTER key to close the window' }

if (Get-Module -ListAvailable -Name ImportExcel) {
    Write-Host "Module ImportExcel found, no additional installation required"
	Write-Host
} 
else {
    Write-Host "Module ImportExcel do not exist, please run 'Install-Module -Name ImportExcel' as administrator"
	pause
	exit
}

# set variables
$GAMpath = "C:\GAM7"
$gamsettings = "$env:USERPROFILE\.gam"
$destinationpath = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path

# collect project folders on $gamsettings
$directories = Get-ChildItem -Path $gamsettings -Directory -Exclude "gamcache" | Select-Object -ExpandProperty Name
$datetime = get-date -f yyyy-MM-dd-HH-mm

# user should choose the project available on GAM 
Write-Host "Please keep this window active, a print screen command will be send to generate a screenshot of it"
Write-Host "Projects available:" $directories
Write-Host

While ( ($Null -eq $clientName) -or ($clientName -eq '') ) {
    $clientName = Read-Host -Prompt "Please enter project shortname"
}

cls

# delete files used on this project on $GAMpath
del $GAMpath\*.csv
del $GAMpath\*.xlsx
del $GAMpath\*.bmp
del $GAMpath\*.ps1
del $GAMpath\*.zip

# copy script to $GAMpath
Copy-Item $MyInvocation.MyCommand.Name $GAMpath

cd $GAMpath

gam select $clientName save
Write-Host

function Check-AdminAddress {
    param (
        [string]$adminAddress
    )

    # Run GAM command to check if the admin address exists
    $output = gam info user $adminAddress 2>&1

    # Check the output for errors
    if ($output -match "Does not exist" -or $output -match "Show Info Failed" -or $output -match "ERROR" -or $output -match "Super Admin: False") {
        return $false
    } else {
        return $true
    }
}

while ($true) {
    # Prompt for the admin address
    $adminAddress = Read-Host "Please enter the admin mailbox address"

    # Check if the admin address exists
    if (Check-AdminAddress -adminAddress $adminAddress) {
        break
    } else {
        Write-Host "The admin mailbox $adminAddress does not exist, its a group or we have an ERROR. Please check credentials and try again."
    }
}

function Check-AdminAuth {
    param (
        [string]$adminAddress
    )

    # Run GAM command to check if the admin address have auth
    $output = gam user $adminAddress check serviceaccount 2>&1

    # Check the output for errors
    if ($output -match "Some scopes failed") {
        return $false
    } else {
        return $true
    }
}

while ($true) {
    # Check if the admin address exists
    if (Check-AdminAuth -adminAddress $adminAddress) {
        break
    } else {
        Write-Host "The admin mailbox $adminAddress do not have proper authorization, we will run again the command to let you authorize it:"
		gam user $adminAddress check serviceaccount
    }
}

Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
Import-Module -Name ImportExcel

Write-Host
Write-Host "## collect users information ##"
gam redirect csv ./"users-report-$datetime.csv" print users fields primaryEmail creationTime id isAdmin isDelegatedAdmin isEnforcedIn2Sv isEnrolledIn2Sv lastLoginTime name suspended
Write-Host
Write-Host "## collect groups information ##"
gam redirect csv ./"groups-report-$datetime.csv" print groups fields email id name adminCreated members manager owners
Write-Host
Write-Host "## collect shared drives information ##"
gam redirect csv ./"teamdriveacls-report-$datetime.csv" print teamdriveacls oneitemperrow
Write-Host
Write-Host "## collect mailbox delegation information ##"
gam all users print delegates shownames > ./"delegates-report-$datetime.csv"
Write-Host
Write-Host "## collect youtube channels information ##"
gam all users_ns_susp print youtubechannels fields id snippet statistics > ./"youtube-report-$datetime.csv"
Write-Host
Write-Host "## collect analytics information ##"
gam all users_ns_susp print analyticaccountsummaries > ./"analytics-report-$datetime.csv"
Write-Host
Write-Host "## collect policies information ##"
gam redirect csv ./"policies-report-$datetime.csv" print policies

Write-Host
Write-Host "## add users report to Excel file ##"
Import-Csv .\users-report-$datetime.csv -Delimiter ',' | Export-Excel -Path .\audit-$clientName-$datetime.xlsx -WorksheetName users
Write-Host
Write-Host "## add groups report to Excel file ##"
Import-Csv .\groups-report-$datetime.csv -Delimiter ',' | Export-Excel -Path .\audit-$clientName-$datetime.xlsx -WorksheetName groups
Write-Host
Write-Host "## add shared drives report to Excel file ##"
Import-Csv .\teamdriveacls-report-$datetime.csv -Delimiter ',' | Export-Excel -Path .\audit-$clientName-$datetime.xlsx -WorksheetName teamdriveacls
Write-Host
Write-Host "## add delegates report to Excel file ##"
Import-Csv .\delegates-report-$datetime.csv -Delimiter ',' | Export-Excel -Path .\audit-$clientName-$datetime.xlsx -WorksheetName delegates
Write-Host
Write-Host "## add youtube report to Excel file ##"
Import-Csv .\youtube-report-$datetime.csv -Delimiter ',' | Export-Excel -Path .\audit-$clientName-$datetime.xlsx -WorksheetName youtube
Write-Host
Write-Host "## add analytics report to Excel file ##"
Import-Csv .\analytics-report-$datetime.csv -Delimiter ',' | Export-Excel -Path .\audit-$clientName-$datetime.xlsx -WorksheetName analytics
Write-Host
Write-Host "## add policies report to Excel file ##"
Import-Csv .\policies-report-$datetime.csv -Delimiter ',' | Export-Excel -Path .\audit-$clientName-$datetime.xlsx -WorksheetName policies

cls
Write-Host "### SCRIPT TO COLLECT GOOGLE WORKSPACE DATA COMPLETED ###"

# gather MD5 hash of .xlsx file for audit purposes
$hash =  ((certutil -hashfile audit-$clientName-$datetime.xlsx MD5).split([Environment]::NewLine))[1]
$currentdate = Get-Date
$culture = [System.Globalization.CultureInfo]::GetCultureInfo("en-US")
$currentdate = $currentdate.ToString("dddd, dd MMMM yyyy HH:mm:ss", $culture)

# show info after collect report
Write-Host
Write-Host Project used by GAM: $clientName
Write-Host Actual date and time: $currentdate
Write-Host MD5 hash of [audit-$clientName-$datetime.xlsx] file: $hash

# wait to print info on screen for print screen
Start-Sleep -Seconds 2

# print screen program
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# send alt + printscreen to capture the active window
[System.Windows.Forms.SendKeys]::SendWait("%{PRTSC}")

# create a bitmap to store the screenshot
$bitmap = New-Object System.Drawing.Bitmap([System.Windows.Forms.Clipboard]::GetImage())

# save the screenshot
$bitmap.Save("$GAMpath\audit-$clientName-$datetime.bmp")

# add files to .zip file on $GAMpath
Compress-Archive "*.xlsx" -DestinationPath audit-$clientName-$datetime.zip
Compress-Archive -Path "*.bmp" -Update -DestinationPath "audit-$clientName-$datetime.zip"
Compress-Archive -Path "*.ps1" -Update -DestinationPath "audit-$clientName-$datetime.zip"

Move-Item audit-$clientName-$datetime.zip $destinationpath
Write-Host "Audit [audit-$clientName-$datetime.zip] file location:"$destinationpath
Write-Host

del $GAMpath\*.csv
del $GAMpath\*.xlsx
del $GAMpath\*.bmp
del $GAMpath\*.ps1
del $GAMpath\*.zip

pause
exit
