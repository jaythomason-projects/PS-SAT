function script:Get-SelectedUser {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Arguments
    )

    $user = Search-UserHashTable @Arguments

    if ($user) {
        # Get user AD object and standard properties
        $selectedUser = Get-ADUser -Identity $user.SamAccountName -Properties *

        # Get user custom properties
        $selectedUser = Get-UserCustomProps -User $selectedUser

        Write-Log "Selected new user: $selectedUser" -LineBreak
    } else {
        [System.Windows.MessageBox]::Show("No users were found with the details provided. Please verify the information and try again.","No Users Found") | Out-Null
        return
    }

    return $selectedUser
}