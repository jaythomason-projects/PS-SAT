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