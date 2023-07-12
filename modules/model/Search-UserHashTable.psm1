function script:Search-UserHashTable {
    param(
        [Parameter(Mandatory=$true)]
        [array]$Properties,

        [ValidateNotNullOrEmpty()]
        [string]$String,

        [ValidateNotNullOrEmpty()]
        [object]$HashTable,

        [Parameter(Mandatory=$false)]
        [switch]$FilterSearch
    )

    $results = @()

    # Iterate over each user in the database
    foreach ($key in $hashTable.Keys) {
        # If FilterSearch switch is enabled, perform a 'like' search
        if ($FilterSearch) {
            foreach ($attr in $Properties) {
                if ($HashTable[$key].$attr -like "*$String*") {
                    $results += $HashTable[$key]
                    # Exit the loop after finding the first match
                    break
                }
            }
        }
        # If FilterSearch switch is not enabled, perform an 'exact' search 
        else {
            foreach ($attr in $Properties) {
                if ($HashTable[$key].$attr -eq $String) {
                    $results += $HashTable[$key]
                    # Exit the loop after finding the first match
                    break
                }
            }
        }
    }

    # If more than one user is found, select from results
    if (($results).Count -gt 1) {
        $resultsHashTable = New-UserHashTable -UserFilter $results -Properties @(
            "SamAccountName",
            "DisplayName",
            "EmployeeID",
            "Company",
            "Title"
        )

        $selectedUser = Select-FromArray -Array $resultsHashTable.Values -Title "Select a User"
    } else {
        $selectedUser = $results
    }
    
    return $selectedUser
}