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