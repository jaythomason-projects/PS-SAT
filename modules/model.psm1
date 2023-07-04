function script:Get-UserHashTable {
    param(
        [Parameter(Mandatory=$true)]
        [array]$Properties
    )
    
    $hashTable = @{}

    # Get all users and specified properties
    $users = Get-ADUser -Filter * -Properties $Properties

    foreach ($user in $users) {
        $userProperties = New-Object PSObject
        
        # Loop through each property to add it to the userProperties object
        foreach ($property in $properties) {
            $userProperties | Add-Member -NotePropertyName $property -NotePropertyValue $user.$property
        }
        
        # Use the SamAccountName as the key to store the userProperties object in the hashtable
        $hashTable[$user.SamAccountName] = $userProperties
    }

    return $hashTable
}

function script:Search-UserHashTable {
    param(
        [Parameter(Mandatory=$true)]
        [array]$Properties,
        [ValidateNotNullOrEmpty()]
        [string]$String,
        [Parameter()]
        [switch]$FilterSearch
    )

    $hashTable = $global:userHashTable
    $results = @()
    $user = $null

    # Iterate over each user in the database
    foreach ($key in $hashTable.Keys) {
        # If FilterSearch switch is enabled, perform a 'like' search
        if ($FilterSearch) {
            foreach ($attr in $Properties) {
                if ($hashTable[$key].$attr -like "*$String*") {
                    $results += $hashTable[$key]
                    # Exit the loop after finding the first match
                    break
                }
            }
        }
        # If FilterSearch switch is not enabled, perform an 'exact' search 
        else {
            foreach ($attr in $Properties) {
                if ($hashTable[$key].$attr -eq $String) {
                    $results += $hashTable[$key]
                    # Exit the loop after finding the first match
                    break
                }
            }
        }
    }

    # If more than one user is found, select from results
    if (($results).Count -gt 1) {
        $results = Select-FromArray -Array $results -Title "Select a User"
    }
    
    return $results
}

function script:Get-User {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Arguments
    )

    $user = Search-UserHashTable @Arguments

    if ($user) {
        # Get user AD object and standard properties
        $selectedUser = Get-ADUser -Identity $user.SamAccountName -Properties *

        # Get user custom properties
        $selectedUser = Get-UserCustomProperties -User $selectedUser

        Write-Log "Selected new user: $selectedUser" -LineBreak
    } else {
        [System.Windows.MessageBox]::Show("No users were found with the details provided. Please verify the information and try again.","No Users Found") | Out-Null
        return
    }

    return $selectedUser
}

function script:Get-UserCustomProperties {
    param (
        [Parameter(Mandatory=$true)]
        [object]$User
    )

    # Define custom user properties
    $customProperties = @{
        'PasswordLastSet' = {
            $date = $User.PasswordLastSet

            # format date and return result
            $formattedDate = $date.ToString("dd-MM-yyyy HH:mm:ss")
            return $formattedDate
        }
    }

    # Add custom properties to the user object
    foreach ($key in $customProperties.Keys) {
        $value = & $customProperties[$key] $User
        $user | Add-Member -MemberType NoteProperty -Name $key -Value $value -Force
    }

    return $User
}

function script:Select-FromArray {
    param(
        [Parameter(Mandatory=$true)]
        [System.Array]$Array,
        [string]$Title
    )

    $selection = $Array | Out-GridView -Title $Title -PassThru

    return $selection
}

function script:Write-Log {
    Param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [switch]$LineBreak
    )

    # Get the current date and time
    $currentDateTime = Get-Date -Format "dd-MM-yyyy HH:mm:ss"

    # Add a line break if the -LineBreak switch is present
    If ($LineBreak) {
        $global:uiElements['LogTextBox'].AppendText("-------------------------`n")
    }

    # Format the log message with the current date and time
    $formattedMessage = "$CurrentDateTime - $Message"

    # Append the message to the 'Log' textbox
    $global:uiElements['LogTextBox'].AppendText("$formattedMessage`n")
}
