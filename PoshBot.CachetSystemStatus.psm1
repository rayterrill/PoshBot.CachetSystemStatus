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

Export-ModuleMember -Function $CommandsToExport