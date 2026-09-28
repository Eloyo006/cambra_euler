# Genera les icones PNG (Android < 8) i una icona gran per al README a partir
# del mateix disseny que res/drawable/ic_launcher_foreground.xml:
# un pany daurat amb el símbol ≡ sobre fons AppColors.ink.
# Ús (des de l'arrel del projecte):  powershell -File tool/make_icons.ps1
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$res = Join-Path $root 'android/app/src/main/res'
$ink = [System.Drawing.Color]::FromArgb(255, 0x12, 0x16, 0x1D)
$gold = [System.Drawing.Color]::FromArgb(255, 0xE0, 0xB0, 0x4A)

function New-RoundRect([single]$x, [single]$y, [single]$w, [single]$h, [single]$r) {
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = 2 * $r
    $p.AddArc($x, $y, $d, $d, 180, 90)
    $p.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $p.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $p.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $p.CloseFigure()
    return $p
}

function Save-Icon([int]$size, [string]$path, [bool]$round) {
    $bmp = New-Object System.Drawing.Bitmap $size, $size
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.Clear([System.Drawing.Color]::Transparent)

    # Fons: quadrat arrodonit (o cercle) de color ink.
    $bg = New-Object System.Drawing.SolidBrush $ink
    if ($round) {
        $g.FillEllipse($bg, 0, 0, $size - 1, $size - 1)
    } else {
        $g.FillPath($bg, (New-RoundRect 0 0 ($size - 1) ($size - 1) ($size * 0.18)))
    }

    # Mateix dibuix que el vector (viewport 108): es mostra la zona 18–90.
    $s = $size / 72.0
    $o = -18.0
    function X([double]$v) { return [single](($v + $o) * $s) }

    $pen = New-Object System.Drawing.Pen $gold, ([single](6 * $s))
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $g.DrawLine($pen, (X 42), (X 50), (X 42), (X 41))
    $g.DrawLine($pen, (X 66), (X 50), (X 66), (X 41))
    $g.DrawArc($pen, (X 42), (X 29), [single](24 * $s), [single](24 * $s), 180, 180)

    $goldBrush = New-Object System.Drawing.SolidBrush $gold
    $g.FillPath($goldBrush, (New-RoundRect (X 34) (X 48) ([single](40 * $s)) ([single](32 * $s)) ([single](5 * $s))))

    $inkBrush = New-Object System.Drawing.SolidBrush $ink
    foreach ($y in 55.5, 62.25, 69) {
        $g.FillRectangle($inkBrush, (X 44), (X $y), [single](20 * $s), [single](3.5 * $s))
    }

    $g.Dispose()
    $dir = Split-Path -Parent $path
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force $dir | Out-Null }
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
}

$sizes = @{ 'mdpi' = 48; 'hdpi' = 72; 'xhdpi' = 96; 'xxhdpi' = 144; 'xxxhdpi' = 192 }
foreach ($k in $sizes.Keys) {
    Save-Icon $sizes[$k] (Join-Path $res "mipmap-$k/ic_launcher.png") $false
}
Save-Icon 512 (Join-Path $root 'docs/img/icona.png') $false
Write-Output 'Icones generades.'
