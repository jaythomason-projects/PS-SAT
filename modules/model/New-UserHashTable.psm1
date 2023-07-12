function script:New-UserHashTable {
    param(
        [Parameter(Mandatory=$false)]
        [array]$UserFilter,

        [Parameter(Mandatory=$true)]
        [array]$Properties
    )
    
    $hashTable = @{}

    # Check if the UserFilter parameter was supplied
    if ($UserFilter) {
        $users = foreach ($user in $UserFilter) {
            Get-ADUser -Identity $user.SamAccountName -Properties $Properties -ErrorAction SilentlyContinue
        }
    } else {
        $users = Get-ADUser -Filter * -Properties $Properties
    }

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
