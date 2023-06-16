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

    # Iterate over each user in the database
    foreach ($user in $hashTable.Keys) {
        # If FilterSearch switch is enabled, perform a 'like' search
        if ($FilterSearch) {
            foreach ($attr in $Properties) {
                if ($hashTable[$user].$attr -like "*$String*") {
                    $results += $hashTable[$user]
                    # Exit the loop after finding the first match
                    break
                }
            }
        }
        # If FilterSearch switch is not enabled, perform an 'exact' search 
        else {
            foreach ($attr in $Properties) {
                if ($hashTable[$user].$attr -eq $String) {
                    $results += $hashTable[$user]
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

function script:Select-FromArray {
    param(
        [Parameter(Mandatory=$true)]
        [System.Array]$Array,
        [string]$Title
    )

    $selection = $Array | Out-GridView -Title $Title -PassThru

    return $selection
}


function Get-User {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Arguments
    )

    $user = Search-UserHashTable @Arguments

    if ($user) {
        # Get user AD object
        $selectedUser = Get-ADUser -Identity $user.SamAccountName

        # TODO: Move this to view -
        # Update 'Selected User:' text
        $global:uiElements['SelectedUserText'].Text = $selectedUser.SamAccountName

         # TODO: Get user properites

         # TODO: Add log entry
    } else {
        [System.Windows.MessageBox]::Show("No users were found with the details provided. Please verify the information and try again.","No Users Found")
        return
    }

    return $selectedUser
}

function Get-UserProperties {
    # TODO: Create function
}

