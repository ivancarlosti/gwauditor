# Audit Report Script

param (
    [string]$clientName,
    [string]$GAMpath,
    [string]$gamsettings,
	[string]$datetime,
    [string]$destinationpath
)

[console]::OutputEncoding = [System.Text.Encoding]::UTF8

cls

Write-Host "### SCRIPT TO COLLECT GOOGLE WORKSPACE DATA, PLEASE FOLLOW INSTRUCTIONS ###"
Write-Host
Write-Host "GAM project selected: $clientName"
Write-Host "GAM application path: $GAMpath"
Write-Host "Project path: $gamsettings"
Write-Host "Date and time: $datetime"
Write-Host "Destination path: $destinationpath"
Write-Host
function pause{ $null = Read-Host 'Press ENTER key to proceed' }
Write-Host

if (Get-Module -ListAvailable -Name ImportExcel) {
    Write-Host "Module ImportExcel found, no additional installation required"
	Write-Host
} 
else {
    Write-Host "Module ImportExcel do not exist, please run 'Install-Module -Name ImportExcel' as administrator"
	pause
	exit
}

# delete files used on this project on $GAMpath
del $GAMpath\*.csv
del $GAMpath\*.xlsx
del $GAMpath\*.bmp
del $GAMpath\*.ps1
del $GAMpath\*.zip

# copy script to $GAMpath
Copy-Item $MyInvocation.MyCommand.Name $GAMpath

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
    $adminAddress = Read-Host "Please enter the admin account"

    # Check if the input is empty
    if ([string]::IsNullOrWhiteSpace($adminAddress)) {
        continue
    }

    # Check if the admin address exists
    if (Check-AdminAddress -adminAddress $adminAddress) {
        break
    } else {
        Write-Host "The admin account $adminAddress does not exist, or we have an ERROR. Please check credentials and try again, if correct, run >>>gam oauth delete && gam oauth create<<< and come back."
		pause
    }
}


function Check-AdminAuth {
    param (
        [string]$adminAddress
    )

    # Run GAM command to check if the admin address has auth
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
        Write-Host "The admin account $adminAddress does not have proper authorization, run >>>gam user $adminAddress check serviceaccount<<< and come back."
		pause
    }
}


function Check-PoliciesAuth {
    # Run GAM command to check policies
    $output = gam info policies user_takeout_status 2>&1

    # Check the output for the word "insufficient"
    if ($output -match "insufficient") {
        return $false
    } else {
        return $true
    }
}

while ($true) {
    # Check policies authorization
    if (Check-PoliciesAuth) {
        break
    } else {
        Write-Host "The project does not have proper policies authorization, run >>>gam oauth delete && gam oauth create<<< and come back."
		pause
    }
}


#Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
Import-Module -Name ImportExcel

Write-Host
Write-Host "## collect users information ##"
gam redirect csv "$GAMpath\users-report-$datetime.csv" print users fields primaryEmail creationTime id isAdmin isDelegatedAdmin isEnforcedIn2Sv isEnrolledIn2Sv lastLoginTime name suspended aliases
Write-Host
Write-Host "## collect groups information ##"
gam redirect csv "$GAMpath\groups-report-$datetime.csv" print groups fields email id name adminCreated members manager owners aliases
Write-Host
Write-Host "## collect shared drives information ##"
gam redirect csv "$GAMpath\teamdriveacls-report-$datetime.csv" print teamdriveacls oneitemperrow
Write-Host
Write-Host "## collect mailbox delegation information ##"
gam all users print delegates shownames > "$GAMpath\delegates-report-$datetime.csv"
Write-Host
Write-Host "## collect youtube channels information ##"
gam all users_ns_susp print youtubechannels fields id snippet statistics > "$GAMpath\youtube-report-$datetime.csv"
Write-Host
Write-Host "## collect analytics information ##"
gam all users_ns_susp print analyticaccountsummaries > "$GAMpath\analytics-report-$datetime.csv"
Write-Host
Write-Host "## collect policies information ##"
gam redirect csv "$GAMpath\domains-report-$datetime.csv" print domains
Write-Host
Write-Host "## collect policies information ##"
gam redirect csv "$GAMpath\policies-report-$datetime.csv" print policies

Write-Host
Write-Host "## add users report to Excel file ##"
Import-Csv $GAMpath\users-report-$datetime.csv -Delimiter ',' | Export-Excel -Path $GAMpath\audit-$clientName-$datetime.xlsx -WorksheetName users -AutoSize -TableName $sheet.Name -TableStyle Light1
Write-Host
Write-Host "## add groups report to Excel file ##"
Import-Csv $GAMpath\groups-report-$datetime.csv -Delimiter ',' | Export-Excel -Path $GAMpath\audit-$clientName-$datetime.xlsx -WorksheetName groups -AutoSize -TableName $sheet.Name -TableStyle Light1
Write-Host
Write-Host "## add shared drives report to Excel file ##"
Import-Csv $GAMpath\teamdriveacls-report-$datetime.csv -Delimiter ',' | Export-Excel -Path $GAMpath\audit-$clientName-$datetime.xlsx -WorksheetName teamdriveacls -AutoSize -TableName $sheet.Name -TableStyle Light1
Write-Host
Write-Host "## add delegates report to Excel file ##"
Import-Csv $GAMpath\delegates-report-$datetime.csv -Delimiter ',' | Export-Excel -Path $GAMpath\audit-$clientName-$datetime.xlsx -WorksheetName delegates -AutoSize -TableName $sheet.Name -TableStyle Light1
Write-Host
Write-Host "## add youtube report to Excel file ##"
Import-Csv $GAMpath\youtube-report-$datetime.csv -Delimiter ',' | Export-Excel -Path $GAMpath\audit-$clientName-$datetime.xlsx -WorksheetName youtube -AutoSize -TableName $sheet.Name -TableStyle Light1
Write-Host
Write-Host "## add analytics report to Excel file ##"
Import-Csv $GAMpath\analytics-report-$datetime.csv -Delimiter ',' | Export-Excel -Path $GAMpath\audit-$clientName-$datetime.xlsx -WorksheetName analytics -AutoSize -TableName $sheet.Name -TableStyle Light1
Write-Host
Write-Host "## add domains report to Excel file ##"
Import-Csv $GAMpath\domains-report-$datetime.csv -Delimiter ',' | Export-Excel -Path $GAMpath\audit-$clientName-$datetime.xlsx -WorksheetName domains -AutoSize -TableName $sheet.Name -TableStyle Light1
Write-Host
Write-Host "## add policies report to Excel file ##"
Import-Csv $GAMpath\policies-report-$datetime.csv -Delimiter ',' | Export-Excel -Path $GAMpath\audit-$clientName-$datetime.xlsx -WorksheetName policies -AutoSize -TableName $sheet.Name -TableStyle Light1

cls
Write-Host "### SCRIPT TO COLLECT GOOGLE WORKSPACE DATA COMPLETED ###"

# gather MD5 hash of .xlsx file for audit purposes
$hash =  ((certutil -hashfile $GAMpath\audit-$clientName-$datetime.xlsx MD5).split([Environment]::NewLine))[1]
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
Compress-Archive "$GAMpath\*.xlsx" -DestinationPath "$destinationpath\audit-$clientName-$datetime.zip"
Compress-Archive -Path "$GAMpath\*.bmp" -Update -DestinationPath "$destinationpath\audit-$clientName-$datetime.zip"
Compress-Archive -Path "$GAMpath\*.ps1" -Update -DestinationPath "$destinationpath\audit-$clientName-$datetime.zip"

Write-Host "Audit [audit-$clientName-$datetime.zip] file location:"$destinationpath
Write-Host

del $GAMpath\*.csv
del $GAMpath\*.xlsx
del $GAMpath\*.bmp
del $GAMpath\*.ps1
del $GAMpath\*.zip

pause
exit
