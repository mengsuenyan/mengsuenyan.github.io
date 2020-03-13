$Global:__OOP_ClassTable__ = @{}

function Global:__OOP_parse__ {
    param(
        [Parameter(Mandatory=$true)]
        [scriptblock] $def
    )

    function note {
        param(
            [Parameter(Mandatory=$true)]
            [string] $name,
            $val = $null
        )
        New-Object -TypeName System.Management.Automation.PSNoteProperty -ArgumentList $name, $val
    }

    function const {
        param(
            [Parameter(Mandatory=$true)]
            [string] $name,
            [Parameter(Mandatory=$true)]
            $val
        )
        $cv = New-Object -TypeName System.Management.Automation.PSVariable $name, $val, 2
        New-Object -TypeName System.Management.Automation.PSNoteProperty -ArgumentList $name, $cv
    }

    function method {
        param(
            [Parameter(Mandatory=$true)]
            [string] $name,
            [Parameter(Mandatory=$true)]
            [scriptblock] $medef
        )
        New-Object -TypeName System.Management.Automation.PSScriptMethod -ArgumentList $name, $medef
    }

    $object = New-Object -TypeName System.Management.Automation.PSObject
    $members = & $def
    foreach ($mem in $members) {
        if (!$mem) {
            Write-Error "bad member $mem"
        } else {
            $object.psobject.Members.Add($mem)
        }
    }

    $object
}

function global:OOPClass {
    param(
        [Parameter(Mandatory=$true)]
        [string] $type,
        [Parameter(Mandatory=$true)]
        [scriptblock] $def
    )

    if ($Global:__OOP_ClassTable__[$type]) {
        throw "type $type is allready defined"
    } else {
        Global:__OOP_parse__ $def > $null

        $Global:__OOP_ClassTable__[$type] = $def
    }
}

function global:OOPnew {
    param(
        [Parameter(Mandatory=$true)]
        [string] $type
    )
    $def = $Global:__OOP_ClassTable__[$type]
    if (!$def) {
        throw "type $type is undefined"
    } else {
        Global:__OOP_parse__ $def
    }
}

function global:OOPdel {
    param(
        [string] $type
    )

    if ($type -and $Global:__OOP_ClassTable__[$type]) {
        $Global:__OOP_ClassTable__.Remove($type)
    }
}


$MSYUtil = New-Object System.Management.Automation.PSObject
Add-Member -InputObject $MSYUtil -MemberType ScriptMethod dateTimeStr {
    $datetime = Get-Date
    $str = $datetime.Year.ToString("0000") +
        $datetime.Month.ToString("00") +
        $datetime.Day.ToString("00") +
        $datetime.Hour.ToString("00") +
        $datetime.Minute.ToString("00") +
        $datetime.Second.ToString("00") + 
        $datetime.Millisecond.ToString("000")
    $str
}
