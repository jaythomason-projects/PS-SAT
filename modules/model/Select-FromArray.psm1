function script:Select-FromArray {
    param(
        [Parameter(Mandatory=$true)]
        [System.Array]$Array,

        [Parameter(Mandatory=$false)]
        [string]$Title
    )

    $selection = $Array | Out-GridView -Title $Title -PassThru

    return $selection
}