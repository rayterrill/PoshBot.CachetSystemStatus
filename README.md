# PoshBot.CachetSystemStatus #

Allows for reading and writing component statuses to a Cachet.io install

### Installation ###

1. Install the module into your PoshBot\Plugins directory
2. Update your PoshBot configuration to include the base URL to your Cachet install using the PluginConfiguration section:
```
  PluginConfiguration = @{
    'PoshBot.CachetSystemStatus' = @{
      BaseURL = 'https://mystatusurl.mydomain.com/api/v1'
      CachetToken = 'MY_CACHET_TOKEN'
    }
  }
```
3. Install the module into your PoshBot instance
```
!install-plugin poshbot.cachetsystemstatus
```
4. Assign permissions to write back to the Cachet system (for example, to a PoshBot sysadmins group)
```
!Add-RolePermission sysadmins poshbot.cachetsystemstatus:write
```