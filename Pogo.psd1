@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'Pogo.psm1'

    # Version number of this module.
    ModuleVersion = '1.0.0'

    # ID used to uniquely identify this module
    GUID = 'e2a2c734-89a7-40bd-8880-fc04422ac3ca'

    # Author of this module
    Author = 'Dan MacCormac <dmaccormac@gmail.com>'

    # Company or vendor of this module
    CompanyName = 'Your Company Name'

    # Copyright statement for this module
    Copyright = '© 2024 Your Company Name. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'This module provides monitoring tools for system and network performance.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Minimum version of the common language runtime (CLR) required by this module
    CLRVersion = '4.0'

    # Required modules imported by this module
    RequiredModules = @()

    # Required assemblies loaded by this module
    RequiredAssemblies = @()

    # Functions to export from this module
    FunctionsToExport = @('New-SystemMonitor', 'New-NetworkMonitor', 'Get-IPGeoLocation')

    # Cmdlets to export from this module
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport = @('net', 'sys', 'ipg')

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
    DefaultCommandPrefix = 'Pogo'
}
