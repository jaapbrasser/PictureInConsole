Function Write-Pixel
{
    param(
            [String] [parameter(mandatory=$true, Valuefrompipeline = $true)] $Path,
            [Switch] $ToASCII
    )
    Begin
    {
        [void] [System.Reflection.Assembly]::LoadWithPartialName('System.drawing')
        
        # Console Colors and their Hexadecimal values
        $Colors = @{
            'FF000000' =   '0'
            'FF000080' =   '1'
            'FF008000' =   '2'
            'FF008080' =   '3'
            'FF800000' =   '4'
            'FF800080' =   '5'
            'FF808000' =   '6'
            'FFC0C0C0' =   '7'
            'FF808080' =   '8'
            'FF0000FF' =   '9'
            'FF00FF00' =   'A'
            'FF00FFFF' =   'B'
            'FFFF0000' =   'C'
            'FFFF00FF' =   'D'
            'FFFFFF00' =   'E'
            'FFFFFFFF' =   'F'
        }
        $AsciiString = [char[]]@(33..126+33..126+33..126+33..126+33..126+33..126+33..126+33..126+33..126+33..126+33..126)
        
        # Algorithm to calculate closest Console color (Only 16) to a color of Pixel
        Function Get-ClosestConsoleColor($PixelColor)
        {
            ($(foreach ($item in $Colors.Keys) {
                [pscustomobject]@{
                    'Color' = $Item
                    'Diff'  = [math]::abs([convert]::ToInt32($Item,16) - [convert]::ToInt32($PixelColor,16))
                } 
            }) | Sort-Object Diff)[0].color
        }
    }
    Process
    {
        Foreach($item in $Path)
        {
            #Convert Image to BitMap            
            $BitMap = [System.Drawing.Bitmap]::FromFile((Get-Item $Item).fullname)

            Foreach($y in (1..($BitMap.Height-1)))
            {
                $Line = Foreach($x in (1..($BitMap.Width-1)))
                {
                    $Pixel = $BitMap.GetPixel($X,$Y)        
                    $Colors.Item((Get-ClosestConsoleColor $Pixel.name))
                }

                If($ToASCII) # Condition to check ToASCII switch
                {
                    Foreach ($Matched in [regex]::Matches(-join $Line,'(.)\1*')) {
                        $String = -join (Get-Random -InputObject $AsciiString -Count ($Matched.Length))
                        Write-Host -Object $String -BackgroundColor ([int]"0x$($Matched.Groups.Value[1])") -NoNewline
                    }
                }
                else
                {
                    Foreach ($Matched in [regex]::Matches(-join $Line,'(.)\1*')) {
                        Write-Host -Object (' '*$Matched.Length) -BackgroundColor ([int]"0x$($Matched.Groups.Value[1])") -NoNewline
                    }
                }
                Write-Host '' # Blank write-host to Start the next row
            }
        }        
    
    }
    end
    {
    
    }

}