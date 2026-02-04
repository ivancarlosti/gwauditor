## Main script

# set variables
$GAMpath = "C:\GAM7"
$gamsettings = "$env:USERPROFILE\.gam"
$destinationpath = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path

# collect project folders on $gamsettings
$directories = Get-ChildItem -Path $gamsettings -Directory -Exclude "gamcache" | Select-Object -ExpandProperty Name
$datetime = get-date -f yyyy-MM-dd-HH-mm-ss

function Show-Menu {
    cls
    Write-Host "GAM project selected: $clientName"
    Write-Host ""
    Write-Host "Please choose an option:`n1. Generate audit report`n2. Archive mailbox messages to group`n3. List, add or remove mailbox delegation`n4. Change GAM project`n5. Exit script"
    return (Read-Host -Prompt "Enter your choice")
}

function Select-GAMProject {
    cls
    # Refresh project list every time in case of changes
    $directories = Get-ChildItem -Path $gamsettings -Directory -Exclude "gamcache" | Select-Object -ExpandProperty Name

    Write-Host "Projects available:"
    for ($i = 0; $i -lt $directories.Count; $i++) {
        Write-Host "$($i + 1). $($directories[$i])"
    }
    Write-Host

    $selectedProject = $null
    while (-not $selectedProject) {
        $selection = Read-Host "Please enter project number"

		[int]$parsedSelection = 0
		if ([int]::TryParse($selection, [ref]$parsedSelection) -and 
			$parsedSelection -ge 1 -and 
			$parsedSelection -le $directories.Count) {
			
			$chosenProject = $directories[$parsedSelection - 1]

			if ((& "$GAMpath\gam.exe" select $chosenProject 2>&1) -match "ERROR") {
				Write-Host "Selected project '$chosenProject' is invalid. Please try again."
			} else {
				$selectedProject = $chosenProject
			}
		} else {
			Write-Host "Invalid selection. Please enter a number between 1 and $($directories.Count)."
		}

    }

    Write-Host "GAM project selected: $selectedProject"
    & "$GAMpath\gam.exe" select $selectedProject save
    $global:clientName = $selectedProject  # Set globally
    Write-Host "DEBUG: clientName is set to $clientName"
}


function Run-AuditReportScript {
    Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File .\_script_AuditReport.ps1 -clientName $clientName -GAMpath $GAMpath -gamsettings $gamsettings -datetime $datetime -destinationpath $destinationpath" -Wait
}
function Run-ArchiveMailboxMessagesScript {
    Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File .\_script_ArchiveMailboxMessages.ps1 -clientName $clientName -GAMpath $GAMpath -gamsettings $gamsettings -datetime $datetime" -Wait
}
function Run-MailboxDelegationScript {
    Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File .\_script_MailboxDelegation.ps1 -clientName $clientName -GAMpath $GAMpath -gamsettings $gamsettings -datetime $datetime" -Wait
}

while ($true) {
    if (-not $clientName) {
        Select-GAMProject
        Write-Host "DEBUG: After Select-GAMProject, clientName is $clientName"
    }

    $option = Show-Menu

    try {
        switch ($option) {
            '1' {
                # Call Google Workspace Auditor script to generate audit report
                Run-AuditReportScript -clientName $clientName -GAMpath $GAMpath -gamsettings $gamsettings -datetime $datetime -destinationpath $destinationpath
            }
            '2' {
                # Call script to archive mailbox messages to group
                Run-ArchiveMailboxMessagesScript -clientName $clientName -GAMpath $GAMpath -gamsettings $gamsettings -datetime $datetime
            }
            '3' {
                # Call script to list, add, or remove mailbox delegation
                Run-MailboxDelegationScript -clientName $clientName -GAMpath $GAMpath -gamsettings $gamsettings -datetime $datetime
            }
            '4' {
                # Change GAM project
                Select-GAMProject
            }
            '5' {
                Write-Output "Exiting script."
                break
            }
            default {
                Write-Output "Invalid option selected."
            }
        }
    }
    catch {
        Write-Host "An error occurred: $_"
    }

    if ($option -eq '5') {
        break
    }
}
