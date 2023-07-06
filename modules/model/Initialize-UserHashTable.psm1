function script:Initialize-UserHashTable {
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