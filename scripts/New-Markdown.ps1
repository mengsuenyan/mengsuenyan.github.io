. (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Source) OOP.ps1)

function New-Markdown {
    param(
        [string] $filename=$null
    )

    if (!$filename) {
        $filename = $MSYUtil.dateTimeStr()
    }
    if (!$filename.EndsWith('.md')) {
        $filename += '.md'
    }

    OOPClass Markdown {
        $initVal = New-Object -TypeName System.Collections.Specialized.OrderedDictionary
        note content $initVal
        note filename $filename

        const FLG_ORDERED_LIST 1
        const FLG_ORDERED_LISTEND 2
        const FLG_UNORDERED_LIST 3
        const FLG_LINK 4
    
        method SaveFile {
            param(
                [bool]$ishavetoc = $true
            )

            $backfile = $this.filename.Insert($this.filename.Length - '.md'.Length, '_backup_')
            if (Test-Path $this.filename) {
                Move-Item $this.filename $backfile
            }

            function __itecnt__ {
                param(
                    [System.Collections.Specialized.OrderedDictionary] $header,
                    [System.Collections.ArrayList] $cnt
                )

                foreach ($ele in $header.GetEnumerator()) {
                    if ($ele.Value -is [System.Collections.Specialized.OrderedDictionary]) {
                        if ($ishavetoc) {
                            $tmp =  $ele.Key -split " "
$txt=@"
$($tmp[0], ' [',($tmp[1..$tmp.Length] -join ""),'](#toc)' -join "")
"@
                            $tmp=$cnt.Add($txt)
                        }                        
                        $tmp = $cnt.Add("`n")

                        __itecnt__ $ele.Value $cnt
                    } else {
                        $tmp = $cnt.Add($ele.Key)
                    }
                }

            }

            try {
                $cnt = New-Object -TypeName System.Collections.ArrayList
                if ($ishavetoc) {
$txt=@"
<span id='toc'></span>
[TOC]

"@
                    $tmp=$cnt.Add($txt)
}
                
                __itecnt__ $this.content $cnt
                

                Set-Content -Path $this.filename -Value ($cnt.ToArray() -join "`n") -Encoding UTF8
            } catch {
                Write-Error $_
            } finally {
                if (Test-Path $this.filename) {
                    Remove-Item -Force $backfile
                } else {
                    if (Test-Path $backfile) {
                        Move-Item $backfile $this.filename
                    }
                }
            }
        }

        method toHeaderString {
           param(
                [Parameter(Mandatory=$true)]
                [string] $title,
                [Parameter(Mandatory=$true)]
                [ValidateRange(1,6)]
                [byte] $lvl
            )

$txt=@"
$('#'*$lvl) $title
"@
            $txt
        }

        method FindHeader {
            param(
                [Parameter(Mandatory=$true)]
                [string] $title,
                [Parameter(Mandatory=$true)]
                [ValidateRange(1,6)]
                [byte] $lvl
            )

            $key = $this.toHeaderString($title, $lvl)

            function __iteCnt__ {
                param(
                    [System.Collections.Specialized.OrderedDictionary] $cnt
                )

                if ($cnt.Contains($key)) {
                    return $cnt[$key]
                } else {
                    foreach ($val in $cnt.Values) {
                        if ($val -is [System.Collections.Specialized.OrderedDictionary]) {
                            __iteCnt__ $val
                        }
                    }
                }

                return $null
            }

            $ret = __iteCnt__ $this.content
            if ($ret -is [System.Object[]]) {
                return $null
            } else {
                return $ret
            }
        }

        method AddHeader {
            param(
                [Parameter(Mandatory=$true)]
                [string] $title,
                [Parameter(Mandatory=$true)]
                [ValidateRange(1,6)]
                [byte] $lvl
            )
        
            $key = $this.toHeaderString($title, $lvl)
            $this.content[$key]= New-Object System.Collections.Specialized.OrderedDictionary

            $this.content[$key]
        }

        method GetHeader {
            param(
                [Parameter(Mandatory=$true)]
                [AllowNull()]
                [AllowEmptyString()]
                [string] $title,
                [Parameter(Mandatory=$true)]
                [AllowNull()]
                [ValidateRange(0,6)]
                [byte] $lvl
            )

            if ($title -and $lvl) {
                $this.FindHeader($title, $lvl)
            } else {
                $this.content
            }
        }

        method AddOrderedListByHD {
            param(
                [Parameter(Mandatory=$true)]
                [System.Collections.Specialized.OrderedDictionary] $header,
                [string] $str = $null,
                [bool] $isnewlist = $false
            )

            if ($str -and $header) {
                $lastlist = $null
                $idx = 1
                foreach ($ele in $header.GetEnumerator()) {
                    if ($ele.Value -eq $this.FLG_ORDERED_LIST) {
                        $idx += 1
                        $lastlist = $ele
                    } elseif ($ele.Value -eq $this.FLG_ORDERED_LISTEND) {
                        $idx = 1
                    }
                }

                if ($isnewlist -and $lastlist) {
                    $header.Remove($lastlist.key)
                    $header[$lastlist.Key] = $this.FLG_ORDERED_LISTEND
                }
$txt = @"
${idx}. $str
"@
                $header[$txt]=$this.FLG_ORDERED_LIST
            }
        }

        method AddOrderedListByTL {
            param(
                [Parameter(Mandatory=$true)]
                [string] $title,
                [Parameter(Mandatory=$true)]
                [ValidateRange(1,6)]
                [byte] $lvl,
                [string] $str = $null,
                [bool] $isnewlist = $false
            )

            $header = $this.GetHeader($title, $lvl)
            $this.AddOrderedListByHD($header, $str, $isnewlist)
        }

        method AddUnorderedList {
            param(
                [Parameter(Mandatory=$true)]
                [System.Collections.Specialized.OrderedDictionary] $header,
                [string] $str = $null
            )

            if ($str -and $header) {
$txt = @"
- $str
"@
                $header[$txt] = $this.FLG_UNORDERED_LIST
            }
        }

        method AddLink {
            param(
                [Parameter(Mandatory=$true)]
                [System.Collections.Specialized.OrderedDictionary] $header,
                [string] $text = $null,
                [string] $link = $null
            )

            if ($text -and $header) {
$txt=@"
- [${text}]($link)
"@
                $header[$txt] = $this.FLG_LINK
            }
        }

        method AddText {
            param(
                [Parameter(Mandatory=$true)]
                [System.Collections.Specialized.OrderedDictionary] $header,
                [string] $text = $null
            )
            if ($text -and $header) {
$txt=@"
${text}
"@
                $header[$txt] = $this.FLG_LINK
            }
        }

        method AddImgLink {
            param(
                [Parameter(Mandatory=$true)]
                [System.Collections.Specialized.OrderedDictionary] $header,
                [string] $text = $null,
                [string] $link = $null
            )

            if ($text -and $header) {
$txt=@"
![${text}]($link)
"@
                $header[$txt] = $this.FLG_LINK
            }
        }


    }

    $md =  OOPnew Markdown
    return $md
}

