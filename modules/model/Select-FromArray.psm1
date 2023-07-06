function script:Select-FromArray {
    param(
        [Parameter(Mandatory=$true)]
        [System.Array]$Array,
        [string]$Title
    )

    $selection = $Array | Out-GridView -Title $Title -PassThru

    return $selection
}