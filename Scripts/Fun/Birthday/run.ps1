# Happy Birthday Song in PowerShell

# Function to play a note
function Play-NoteWithCake {
    param(
        [int]$frequency,
        [int]$duration = 400,
        [string]$color = "Magenta"
    )

    # Clear and show cake in chosen color
    Clear-Host
    Write-Host $cake -ForegroundColor $color

    # Play the beep
    [console]::beep($frequency, $duration)
}

# Show cake ASCII art
$cake = @"
             i i i i i
           |^^^^^^^^^^^|
         __|___________|__
        |^^^^^^^^^^^^^^^^^|
        |                 |
        |                 |
        ~~~~~~~~~~~~~~~~~~~
          HAPPY BIRTHDAY!
"@

# Notes (frequencies in Hz)
$C  = 262
$D  = 294
$E  = 330
$F  = 349
$G  = 392
$A  = 440
$Bb = 466   # B flat (A#)
$B  = 494
$C5 = 523

# Colors to rotate through for each note
$colors = @("Magenta", "Yellow", "Cyan", "Green", "Red", "White", "Blue")
$colorIndex = 0

# Helper to get next color
function Get-NextColor {
    $script:colorIndex = ($script:colorIndex + 1) % $colors.Count
    return $colors[$script:colorIndex]
}

# Play "Happy Birthday" with cake color changes

[console]::Beep(37, 1000)   # 37Hz for 400ms

Play-NoteWithCake $C 400 (Get-NextColor)
Play-NoteWithCake $C 200 (Get-NextColor)
Play-NoteWithCake $D 600 (Get-NextColor)
Play-NoteWithCake $C 600 (Get-NextColor)
Play-NoteWithCake $F 600 (Get-NextColor)
Play-NoteWithCake $E 1200 (Get-NextColor)

Play-NoteWithCake $C 400 (Get-NextColor)
Play-NoteWithCake $C 200 (Get-NextColor)
Play-NoteWithCake $D 600 (Get-NextColor)
Play-NoteWithCake $C 600 (Get-NextColor)
Play-NoteWithCake $G 600 (Get-NextColor)
Play-NoteWithCake $F 1200 (Get-NextColor)

Play-NoteWithCake $C 400 (Get-NextColor)
Play-NoteWithCake $C 200 (Get-NextColor)
Play-NoteWithCake $C5 600 (Get-NextColor)
Play-NoteWithCake $A 600 (Get-NextColor)
Play-NoteWithCake $F 600 (Get-NextColor)
Play-NoteWithCake $E 600 (Get-NextColor)
Play-NoteWithCake $D 1200 (Get-NextColor)

Play-NoteWithCake $Bb 400 (Get-NextColor)
Play-NoteWithCake $Bb 200 (Get-NextColor)
Play-NoteWithCake $A 600 (Get-NextColor)
Play-NoteWithCake $F 600 (Get-NextColor)
Play-NoteWithCake $G 600 (Get-NextColor)
Play-NoteWithCake $F 1200 (Get-NextColor)
