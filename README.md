# UnifiedGroupManagement

This is a simple project, a module that contains functions to manage Unified Groups in Azure AD. 
This is one of my very first projects, and I intend to clean it up eventually. 

## Set-UnifiedGroupCreator

This function disables self service group creation in Azure AD and give all that creation power to a seurity group you specify. 
At the time of writing the code it required that all members of that group be licensed with Azure AD P1 licenses.
Please check current licensing rules before using this. 

## Restore-UnifiedGroupCreator

This function restores Unified Group Creation to being self-service.

## Restore-UnifiedGroup

This function will look for restorable (recently deleted) Unified Groups in Azure AD, list them in a GridView so you can pick which ones you want to restore, and restore them to their former glory. All associated services (SharePoint Sites etc) should reappear shortly after restoring the group. 

## Caution and disclaimer

You need to read and understand every piece of code you run in a production environment, get help if you must. Ultimately you are 100% responsible for what happens to your system when you use this code. 

## Share and share alike

Please build on this code and make it you own. And pay it forward. 
