@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'Pogo.psm1'

    # Version number of this module.
    ModuleVersion = '1.2.8'

    # ID used to uniquely identify this module
    GUID = 'e2a2c734-89a7-40bd-8880-fc04422ac3ca'

    # Author of this module
    Author = 'Dan MacCormac <dan@maccormac.net>'

    # Company or vendor of this module
    CompanyName = 'Dan MacCormac <dan@maccormac.net>'

    # Copyright statement for this module
    Copyright = '© 2024 - 2025 Dan MacCormac <dan@maccormac.net>. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'PowerShell Goto - Sys Admin Utility'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Minimum version of the common language runtime (CLR) required by this module
    CLRVersion = '4.0'

    # Required modules imported by this module
    RequiredModules = @()

    # Required assemblies loaded by this module
    RequiredAssemblies = @()

    # Functions to export from this module
    FunctionsToExport = @('New-SystemMonitor', 'New-NetworkMonitor', 'Get-IPGeoLocation', 'Stop-Computer', 'Restart-Computer', `
    'Suspend-Computer', 'Exit-UserSession', 'Show-ColorList', 'Show-ColorGrid', 'Show-AdvancedSystemProperties', 'Switch-VolumeMute', `
    'Show-PowerOptionsApplet', 'New-MessageOfTheDay', 'Use-Impersonation' )

    # Cmdlets to export from this module
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport = @('net', 'sys', 'ipg', 'off', 'out', 'reb', 'nap', 'adv', 'pwr', 'vol', 'col', 'run')

    # DscResources to export from this module
    DscResourcesToExport = @()

    # Formats to be loaded with this module
    FormatsToProcess = @()

    # Types to be loaded with this module
    TypesToProcess = @()

    # Scripts to be run in the caller's environment
    ScriptsToProcess = @()

    # The functions that are exposed by this module
    NestedModules = @()

    # The files that are contained within the module
    FileList = @('Pogo.psm1', 'Pogo.psd1', 'PogoNet.ps1', 'PogoSys.ps1')

    # Private data for this module
    PrivateData = @{}

    # Help info URI
    HelpInfoURI = 'https://github.com/dmaccormac/pogo'

    # Default prefix for cmdlets in this module. If this module is imported with a prefix, it will override this default.
    DefaultCommandPrefix = 'PG'
}
