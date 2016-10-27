if (!(Get-FormatData "LogonSession")) {
    Update-FormatData -Append `
    (Join-Path $PSScriptRoot "logonsession.format.ps1xml")
}

Function Get-Logons {
    [CmdletBinding()]
    [OutputType()]
    Param(
        [Parameter(Position=0, ValueFromPipeline=$true)]
        [string] $ComputerName = $env:ComputerName,
        
        [Parameter()]
        [ValidateSet("All", "Interactive", "RemoteInteractive", "Unfiltered")]
        [string] $LogonType = "All"
    )

    begin {
        # documented here: https://msdn.microsoft.com/en-us/library/aa394189(v=vs.85).aspx
        $logontypes = @{
            0  = "System"
            2  = "Interactive"
            3  = "Network"
            4  = "Batch"
            5  = "Service"
            6  = "Proxy"
            7  = "Unlock"
            8  = "NetworkCleartext"
            9  = "NewCredentials"
            10 = "RemoteInteractive"
            11 = "CachedInteractive"
            12 = "CachedRemoteInteractive"
            13 = "CachedUnlock"
        }
        
        switch ($LogonType) {
            "All"               { $typefilter = @(2, 10) }
            "Interactive"       { $typefilter = @(2)     }
            "RemoteInteractive" { $typefilter = @(10)    }
            "Unfiltered"        { $typefilter = @(2..13) }
        }
    }

    process {
        $sessions = Get-CIMInstance -ClassName Win32_LogonSession -ComputerName $ComputerName
        $logons = Get-CIMInstance -ClassName Win32_LoggedOnUser -ComputerName $ComputerName

        foreach ($session in ($sessions | where {$_.LogonType -in $typefilter})) {
            $logon = $logons | where {$_.Dependent.LogonId -eq $session.LogonId}
            
            $result = New-Object -TypeName "PSObject" -Property @{
                "ComputerName" = $ComputerName
                "LogonId" = $session.LogonId
                "StartTime" = $session.StartTime
                "AuthType" = $session.AuthenticationPackage
                "Account" = [string]::join(
                    "\",
                    $logon.Antecedent.Domain,
                    $logon.Antecedent.Name
                )
                "LogonType" = $logontypes[[int]$session.LogonType]
            }
            $result.PSTypeNames.Insert(0, "LogonSession")
            
            $result
        }
    }
}