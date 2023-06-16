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
        [array]$Attributes,
        [ValidateNotNullOrEmpty()]
        [string]$SearchText,
        [Parameter()]
        [switch]$FilterSearch
    )

    $hashTable = $global:userHashTable
    $results = @()

    # Iterate over each user in the database
    foreach ($user in $hashTable.Keys) {
        # If FilterSearch switch is enabled, perform a 'like' search
        if ($FilterSearch) {
            foreach ($attr in $Attributes) {
                if ($hashTable[$user].$attr -like "*$SearchText*") {
                    $results += $hashTable[$user]
                    # Exit the loop after finding the first match
                    break
                }
            }
        }
        # If FilterSearch switch is not enabled, perform an 'exact' search 
        else {
            foreach ($attr in $Attributes) {
                if ($hashTable[$user].$attr -eq $SearchText) {
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
    # TODO: Create function
}

function Get-UserProperties {
    # TODO: Create function
}

