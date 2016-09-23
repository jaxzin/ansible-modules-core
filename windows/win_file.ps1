#!powershell
# This file is part of Ansible
#
# Ansible is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ansible is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ansible.  If not, see <http://www.gnu.org/licenses/>.

# WANT_JSON
# POWERSHELL_COMMON

$ErrorActionPreference = "Stop"

$params = Parse-Args $args

# path
$path = Get-Attr $params "path" $FALSE
If ($path -eq $FALSE)
{
    $path = Get-Attr $params "dest" $FALSE
    If ($path -eq $FALSE)
    {
        $path = Get-Attr $params "name" $FALSE
        If ($path -eq $FALSE)
        {
            Fail-Json (New-Object psobject) "missing required argument: path"
        }
    }
}

# JH Following advice from Chris Church, only allow the following states
# in the windows version for now:
# state - file, directory, touch, absent
# (originally was: state - file, link, directory, hard, touch, absent)

$state = Get-Attr $params "state" "unspecified"
# if state is not supplied, test the $path to see if it looks like
# a file or a folder and set state to file or folder

# Get the target for a Windows shortcut
$target = Get-Attr $params "target" $null
$argumentsList = Get-Attr $params "arguments" $null
$workDir = Get-Attr $params "working_directory" $null

# result
$result = New-Object psobject @{
    changed = $FALSE
}

If ( $state -eq "touch" )
{
    If(Test-Path $path)
    {
        (Get-ChildItem $path).LastWriteTime = Get-Date
    }
    Else
    {
        echo $null > $path
    }
    $result.changed = $TRUE
}

If (Test-Path $path)
{
    $fileinfo = Get-Item $path
    If ( $state -eq "absent" )
    {
        Remove-Item -Recurse -Force $fileinfo
        $result.changed = $TRUE
    }
    Else
    {
        If ( $state -eq "directory" -and -not $fileinfo.PsIsContainer )
        {
            Fail-Json (New-Object psobject) "path is not a directory"
        }

        If ( $state -eq "file" -and $fileinfo.PsIsContainer )
        {
            Fail-Json (New-Object psobject) "path is not a file"
        }

        If ( $state -eq "shortcut" ) 
        {
            If ( $fileinfo.PsIsContainer -or (-not ( $path -like "*.lnk" ) ) )
            {
                Fail-Json (New-Object psobject) "path is not a shortcut"
            }
            Else 
            {
                $sh = New-Object -COM WScript.Shell
                $Shortcut = $sh.CreateShortcut($path)
                If ( $target -ne $null -and $Shortcut.TargetPath -ne $target )
                {
                   $oldTarget = $Shortcut.TargetPath
                   $Shortcut.TargetPath = $target
                   $Shortcut.Save()
                   $result.changed = $TRUE
                   $result.msg = "Changed target to $target from $oldTarget."
                }
    
                If ( $argumentsList -ne $null -and $Shortcut.Arguments -ne $argumentsList )
                {
                   $Shortcut.Arguments  = $argumentsList
                   $Shortcut.Save()
                   $result.changed = $TRUE
                   $result.msg = "Changed arguments."
                }
    
                If ( $workDir -ne $null -and $Shortcut.WorkingDirectory -ne $workDir )
                {
                   $Shortcut.WorkingDirectory = $workDir
                   $Shortcut.Save()
                   $result.changed = $TRUE
                   $result.msg = "Changed working directory."
                }
            }
        }
    }
}
Else
# doesn't yet exist
{
    If ( $state -eq "unspecified" )
    {
        $basename = Split-Path -Path $path -Leaf
        If ($basename.length -gt 0)
        {
           $state = "file"
        }
        Else
        {
           $state = "directory"
        }
    }

    If ( $state -eq "directory" )
    {
        New-Item -ItemType directory -Path $path
        $result.changed = $TRUE
    }

    If ( $state -eq "file" )
    {
        Fail-Json (New-Object psobject) "path will not be created"
    }

    If ( $state -eq "shortcut" )
    {
        $sh = New-Object -comObject WScript.Shell
        $Shortcut = $sh.CreateShortcut($path)
        If ($target -ne $null) { $Shortcut.TargetPath = $target }
        If ($argumentsList -ne $null) { $Shortcut.Arguments = $argumentsList }
        If ($workDir -ne $null) { $Shortcut.WorkingDirectory = $workDir }
        $Shortcut.Save()
        $result.changed = $TRUE
    }
}

Exit-Json $result
