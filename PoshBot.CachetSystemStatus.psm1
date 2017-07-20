# Slack text width with the formatting we use maxes out ~80 characters...
$Width = 80
$CommandsToExport = @()

function Get-SystemStatusViaSlack {
    <#
    .SYNOPSIS
        Get System Status from Cachet.IO install via Slack
    .EXAMPLE
        !sysstemstatus
    #>
    [PoshBot.BotCommand(
        Aliases = ('systemstatus')
    )]
    [cmdletbinding()]
    param(
      [PoshBot.FromConfig('BaseURL')][parameter(Mandatory)][string]$baseURL,
      [string]$name = $null
    )
    
    $componentURL = "$($baseURL)/components"
    
    if (!$name) {
      $res = Invoke-WebRequest $componentURL -UseBasicParsing
    } else {
      $urlencodeName = [uri]::EscapeDataString($name)
      $url = "$($componentURL)?name=$($urlencodeName)"
      $res = Invoke-WebRequest $url -UseBasicParsing
    }
    
    $data = $res.Content | ConvertFrom-JsonNewtonSoft
    
    if (!$data.data) {
      $o = "No results found"
    } else {
      #Create Table object
      $table = New-Object system.Data.DataTable "System Status"

      #Define Columns
      $col1 = New-Object system.Data.DataColumn System,([string])
      $col2 = New-Object system.Data.DataColumn Status,([string])
    
      #Add the Columns
      $table.columns.add($col1)
      $table.columns.add($col2)
    
      foreach ($d in $data.data) {
         #Create a row
         $row = $table.NewRow()

         #Write-Host "$($d.name) - $($d.status_name)"
         #Enter data in the row
         $row.System = $d.name
         $row.Status = $d.status_name
       
         #Add the row to the table
         $table.Rows.Add($row)
      }
    
      $o = $table | Format-Table -AutoSize -Wrap | Out-String -Width $Width
    }

    New-PoshBotCardResponse -Type Normal -Text $o
}
$CommandsToExport += 'Get-SystemStatusViaSlack'

function Update-SystemStatusViaSlack {
    <#
    .SYNOPSIS
        Update System Status at Cachet.IO install via Slack
    .EXAMPLE
        !updatesysstemstatus
    #>
    [PoshBot.BotCommand(
        Aliases = ('updatesystemstatus'),
        Permissions = 'write'
    )]
    [cmdletbinding()]
    param(
      [PoshBot.FromConfig('BaseURL')][parameter(Mandatory)][string]$baseURL,
      [PoshBot.FromConfig('CachetToken')][parameter(Mandatory)][string]$cachetToken,
      [parameter(Mandatory)][string]$name,
      [parameter(Mandatory)][string]$status
    )
    
    $componentURL = "$($baseURL)/components"
    
    $urlencodeName = [uri]::EscapeDataString($name)
    $url = "$($componentURL)?name=$($urlencodeName)"
    $res = Invoke-WebRequest $url -UseBasicParsing
    
    $data = $res.Content | ConvertFrom-JsonNewtonSoft
    
    if (!$data.data) {
      $o = "Could not find the service requested. Please try again."
      return;
    } else {
      $appID = $data.data.id
    } 
    
    if ($status -eq 'Operational') {
      $statusID = 1;
    } elseif ($status -eq 'Performance Issues') {
      $statusID = 2;
    } elseif ($status -eq 'Partial Outage') {
      $statusID = 3;
    } elseif ($status -eq 'Major Outage') {
      $statusID = 4;
    } else {
      New-PoshbotCardResponse -Type Normal -Text "Status should be one of: Operational, Performance Issues, Partial Outage, or Major Outage"
      Return;
    }
    
    $headers = @{}
    $headers.Add("X-Cachet-Token",$cachetToken)
    
    $statusJSON = '{ "status" : ' + $statusID + ' }'
    $res = Invoke-WebRequest "$($componentURL)/$($appID)" -UseBasicParsing -ContentType "application/json" -Method PUT -Body $statusJSON -Headers $headers

    if ($res.StatusCode -eq '200') {
      $o = "New Status Recorded"
    } else {
      $o = "Problem updating status. Please try again."
    }

    New-PoshBotCardResponse -Type Normal -Text $o
}
$CommandsToExport += 'Update-SystemStatusViaSlack'

Export-ModuleMember -Function $CommandsToExport