# Logons

Get all logon sessions from the specified computer.

    PS C:\> Get-Logons -ComputerName bob-pc -LogonType "RemoteInteractive"
    
    
    Computer: bob-pc
    
    
    LogonId StartTime           LogonType         AuthType  Account
    ------- ---------           ---------         --------  -------
    290004  27.10.2016 21:36:23 RemoteInteractive Negotiate AD\bob
    289956  27.10.2016 21:36:23 RemoteInteractive Kerberos  AD\bob