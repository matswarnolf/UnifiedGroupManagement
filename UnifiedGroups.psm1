function Set-UnifiedGroupCreator {
    <#
      .SYNOPSIS
      This function sets the ability to create Unified Groups (Office 365 groups) to a specific security group.
  
      .DESCRIPTION
      This function disables Self-Service group creation in SharePoint, Planner, Outlook etc and instead gives
      creation rights to a specific named Security Group in Azure AD
  
      .PARAMETER GroupName
      The name of an existing Azure AD Security Group
  
      .PARAMETER cred
      The name of a credential object to use
      You can create this object by writing "$cred = Get-Credential" without the quotation marks
      and responding to the authentication dialog. 
  
      .EXAMPLE
      Set-UnifiedGroupCreator -GroupName O365GroupCreator -cred $cred
      This example will attempt to log on to Azure AD using the credential object $cred 
      and disable self-service group creation
      and enable members of the group "O365GroupCreator" to create Unified groups
  
      .NOTES
      Axians FTW
  

    #>
  
  
    [Cmdletbinding()]
    Param 
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]
        $GroupName,
        [Parameter(Mandatory)]
        [pscredential[]]
        $cred
    )
    Begin {
        Import-Module -Name AzureADPreview
        Connect-AzureAD -Credential $cred
    }
    Process {
        $SecGroup = Get-AzureADGroup -SearchString $GroupName
        $Template = Get-AzureADDirectorySettingTemplate | Where-Object {$_.DisplayName -eq 'Group.Unified'}
        $Setting = $Template.CreateDirectorySetting()
        New-AzureADDirectorySetting -DirectorySetting $Setting
        $Setting = Get-AzureADDirectorySetting -Id (Get-AzureADDirectorySetting | Where-Object -Property DisplayName -Value 'Group.Unified' -EQ).id
        $Setting['EnableGroupCreation'] = $False
        $Setting['GroupCreationAllowedGroupId'] = (Get-AzureADGroup -SearchString $SecGroup).objectid
    }
    End {  
        (Get-AzureADDirectorySetting).Values
    }
    
}
  
function Restore-UnifiedGroupCreator {
    <#
      .SYNOPSIS
      This function will remove all custom settings that control unified group creation
      and reset the default behaviour to let any user be able to create a Office 365 Group.
  
      .DESCRIPTION
      This function will attempt to log on using the credential object you supplied
      and remove any AzureADDirectorySetting that handles "Group.Unified" 
      effectively enabling any user to create Unified Groups (Office 365 Groups)
  
      .PARAMETER Cred
      The name of a credential object to use
      You can create this object by writing "$cred = Get-Credential" without the quotation marks
      and responding to the authentication dialog.
  
      .EXAMPLE
      Restore-UnifiedGroupCreator -Cred $credential
      Describe what this call does
  
      .NOTES
      Place additional notes here.
  

    #>
  
  
    [cmdletbinding()]
    Param 
    (
        # Parameter help description
        [Parameter(Mandatory)]
        [System.Management.Automation.Credential()][PSCredential]
        $Cred 
    )
    Begin {
        Import-Module -Name AzureADPreview
        Connect-AzureAD -Credential $cred
    }
    Process {
        $reply = Read-Host -Prompt "Continue?[y/n]"
        if ( $reply -match "[yY]" ) {
            $SettingId = Get-AzureADDirectorySetting -All $True | where-object {$_.DisplayName -eq 'Group.Unified'}
            Remove-AzureADDirectorySetting -Id $SettingId.Id
        }
        else {
            Return   
        }
    }
    End {
        (Get-AzureADDirectorySetting).Values
    }  
}

function Restore-UnifiedGroup {
    <#
      .SYNOPSIS
      This function will attempt to restore a recently deleted Unified Group 
  
      .DESCRIPTION
      This function will attempt to log on using the credential object you supplied
      and query Azure AD for restorable
  
      .PARAMETER Cred
      Describe parameter -Cred.
  
      .EXAMPLE
      Restore-UnifiedGroupCreator -Cred Value
      Describe what this call does
  
      .NOTES
      Place additional notes here.
  

    #>
    [Cmdletbinding()]
    param 
    (
        # Parameter help description
        [Parameter(Mandatory)]
        [System.Management.Automation.Credential()][PSCredential]
        $Cred 
    )
    Begin {
        Import-module -Name AzureADPreview
        Connect-AzureAD -Credential $cred
        $RestorableGroups = Get-AzureADMSDeletedGroup
    }
    Process {
        $result = If ($RestorableGroups.Count -gt 1) {
            $IDX = 0
            $(foreach ($item in $RestorableGroups) {
                    $item | Select-Object @{l = 'IDX'; e = {$IDX}}, DisplayName
                    $IDX++
                }) |  Out-GridView -Title 'Select one or more folders to use' -OutputMode Multiple |
                ForEach-Object { $RestorableGroups[$_.IDX] }
            $Result
            Restore-AzureADMSDeletedDirectoryObject -Id $Result.Id
        }
    }
    End {
        Get-AzureADGroup -ObjectId $result.id
    }
}