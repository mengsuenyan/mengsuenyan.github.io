$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Source
. (Join-Path $ScriptPath New-Markdown.ps1)

function Update-Index {
    param(
        [Parameter(Mandatory=$true)]
        [string]$RootDir,
        [string]$IndexFileName="index.md"
    )

    $RootDir = (Resolve-Path $RootDir).Path
    $indexPath = Join-Path $RootDir $IndexFileName

    $docspath = Join-Path $RootDir 'docs'
    
    $md = New-Markdown $indexPath
    function __itedir__ {
        param(
            [parameter(Mandatory=$true)]
            [string] $path,
            [ValidateRange(1,6)]
            [byte] $lvl
        )
        $dirs = Get-ChildItem $path -Directory
        foreach ($dir in $dirs) {
            $header = $md.AddHeader($dir, $lvl)
            $files = Get-ChildItem $dir.FullName -File
            foreach ($file in $files) {
                $md.AddLink($header, $file.basename, $file.FullName.TrimStart($RootDir))
            }
            __itedir__ $dir.FullName ($lvl + 1)
        }
    }

    $md.AddHeader("mengsuenyan的个人博客", 1)

    __itedir__ $docspath 2
    $md.SaveFile()
}

$RootDir = Split-Path (Resolve-Path $ScriptPath) -Parent
$IndexFileName = 'index.md'
Update-Index $RootDir $IndexFileName