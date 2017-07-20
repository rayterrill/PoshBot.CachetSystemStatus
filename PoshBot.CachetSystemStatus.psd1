@{
# Point to your module psm1 file...
RootModule = '.\PoshBot.CachetSystemStatus.psm1'

# Be sure to specify a version
ModuleVersion = '0.0.1'

Description = 'PoshBot module for getting System Status from Cachet'
Author = 'Ray Terrill'
CompanyName = 'Port of Portland'
Copyright = '(c) 2017 Ray Terrill. All rights reserved.'
PowerShellVersion = '5.0.0'

# Generate your own GUID
GUID = '522ca401-d205-4042-9361-5f716658b004'

# We require poshbot...
RequiredModules = @('PoshBot')

# Ideally, define these!
FunctionsToExport = '*'

PrivateData = @{
    # These are permissions we'll expose in our poshbot module
    Permissions = @(
        @{
            Name = 'write'
            Description = 'Run comands that update Cachet'
        }
    )
} # End of PrivateData hashtable
}