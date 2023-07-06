function script:Get-UserCustomProps {
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
