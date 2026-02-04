# Mailbox Delegation Script

param (
    [string]$clientName,
    [string]$GAMpath,
    [string]$gamsettings,
	[string]$datetime
)

[console]::OutputEncoding = [System.Text.Encoding]::UTF8

cls

Write-Host "### SCRIPT TO MANAGE MAILBOX DELEGATION, PLEASE FOLLOW INSTRUCTIONS ###"
Write-Host
Write-Host "GAM project selected: $clientName"
Write-Host "GAM application path: $GAMpath"
Write-Host "Project path: $gamsettings"
Write-Host "Date and time: $datetime"
Write-Host
function pause{ $null = Read-Host 'Press ENTER key to end script' }
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
    $adminAddress = Read-Host "Please enter the admin account"

    # Check if the input is empty
    if ([string]::IsNullOrWhiteSpace($adminAddress)) {
        continue
    }

    # Check if the admin address exists
    if (Check-AdminAddress -adminAddress $adminAddress) {
        break
    } else {
        Write-Host "The admin account $adminAddress does not exist, or we have an ERROR. Please check credentials and try again."
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
        Write-Host "The admin account $adminAddress does not have proper authorization, we will run the command again to let you authorize it:"
        gam user $adminAddress check serviceaccount
    }
}

# Function to check policy settings
function Check-PolicySettings {
    param (
        [string]$filter
    )

    # Run the GAM command and capture the output
    $output = $(gam print policies filter "$filter" 2>&1)

    # Check if the output contains the specified messages
    if ($output -match "False,True,ADMIN" -or $output -match "False,False,ADMIN" -or $output -match "Got 0 Policies" -or $output -match "insufficient") {
        Write-Host "WARNING: You can proceed but policies unreachable or mailbox delegation disabled."
        Write-Host "Users may not be able to access the delegated mailbox."
        Write-Host "Please check it in https://admin.google.com/ac/apps/gmail/usersettings"
        Write-Host
        return $false
    } else {
        Write-Host "Mailbox delegation is enabled, you are good to go."
        Write-Host
        return $true
    }
}

# Define the filter
$filter = "setting.type.matches('.*gmail.mail_delegation')"

# Check policy settings
$policyCheck = Check-PolicySettings -filter $filter

# Function to check if a mailbox address exists
function Check-EmailAddress {
    param (
        [string]$sourceAddress
    )

    # Run GAM command to check if the mailbox address exists
    $output = gam info user $sourceAddress 2>&1

    # Check the output for errors
    if ($output -match "Does not exist" -or $output -match "Show Info Failed" -or $output -match "ERROR") {
        return $false
    } else {
        return $true
    }
}

while ($true) {
    # Prompt for the mailbox address
    $sourceAddress = Read-Host "Please enter the mailbox address"

    # Check if the input is empty
    if ([string]::IsNullOrWhiteSpace($sourceAddress)) {
        continue
    }

    # Check if the mailbox address exists
    if (Check-EmailAddress -sourceAddress $sourceAddress) {
        break
    } else {
        Write-Host "The mailbox $sourceAddress does not exist, it's a group, or we have an ERROR. Please check credentials and try again."
    }
}

# Function to list delegates
function List-Delegates {
    param (
        [string]$sourceAddress
    )
    gam user $sourceAddress show delegates
}

# Function to add delegates
function Add-Delegates {
    param (
        [string]$sourceAddress
    )
    $delegatedAddress = Read-Host "Please enter the mailbox or group to enable access to $sourceAddress's mailbox"
    gam user $sourceAddress add delegates $delegatedAddress
}

# Function to remove delegates
function Remove-Delegates {
    param (
        [string]$sourceAddress
    )
    $delegatedAddress = Read-Host "Please enter the mailbox or group to remove access to $sourceAddress's mailbox"
    gam user $sourceAddress del delegates $delegatedAddress
}

# Menu options
while ($true) {
    Write-Host
    Write-Host "Select an option:"
    Write-Host "1. List Delegates"
    Write-Host "2. Add Delegates"
    Write-Host "3. Remove Delegates"
    Write-Host "4. Exit"
    Write-Host

    $choice = Read-Host "Enter your choice"

    switch ($choice) {
        1 {
            List-Delegates -sourceAddress $sourceAddress
        }
        2 {
            Add-Delegates -sourceAddress $sourceAddress
        }
        3 {
            Remove-Delegates -sourceAddress $sourceAddress
        }
        4 {
            Write-Host
            Write-Host "### SCRIPT TO MANAGE MAILBOX DELEGATION COMPLETED ###"

            $currentdate = Get-Date
            $culture = [System.Globalization.CultureInfo]::GetCultureInfo("en-US")
            $currentdate = $currentdate.ToString("dddd, dd MMMM yyyy HH:mm:ss", $culture)

            # show info after running the script
            Write-Host
            Write-Host Project used by GAM: $clientName
            Write-Host Actual date and time: $currentdate
            Write-Host

            pause
            break
        }
        default {
            Write-Host "Invalid option, please try again."
        }
    }

    if ($choice -eq '4') {
        break
    }
}
