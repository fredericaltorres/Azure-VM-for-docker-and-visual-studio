
function Write-Host-Color([string]$message, $color = "Cyan") {

    Write-Host $message -ForegroundColor $color
}

function JsonParse([string]$json) {

    [array]$jsonContent = $json | ConvertFrom-Json
    return ,$jsonContent
}

# Execute the block of code 60 times and wait 6 seconds in between each try
# If the block fail 60 time we will have to wait 6 minutes
# We have a 6 minutes time out by default
function Retry([string]$message, [ScriptBlock] $block, [int]$wait = 6, [int]$maxTry = 60) { 

    $try = 0

    while($true) {

        Write-Host "[$try]$message" -ForegroundColor Cyan

        try {

            $ok = & $block
            if($ok) {

                Write-Host "[PASSED]$message" -ForegroundColor Green
                return $true
            }
            Start-Sleep -s $wait
            $try += 1
            if($try -eq $maxTry) {

                Write-Error "[FAILED]Timeout: $message"
                break # Fail time out
            }
        }
        catch {            

            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Write-Error $ErrorMessage
            break
        }
    }
    return $false
}


function urlMustReturnHtml($url) {

    $homePage = (Invoke-RestMethod -Uri $url).ToLowerInvariant()
    if($homePage.Contains("<html")) {
        Write-Host-Color "Url:$url returned html" Green
    }
    else {
        $m = "Url:$url does not return html" 
        Write-Error $m
        throw $m
    }
}

Export-ModuleMember -Function urlMustReturnHtml
Export-ModuleMember -Function Retry
Export-ModuleMember -Function JsonParse
Export-ModuleMember -Function Write-Host-Color
