# Maze dimensions (odd numbers for proper carving)
$width = 27
$height = 27

# Initialize grid with walls (#)
$maze = @()
for ($y = 0; $y -lt $height; $y++) {
    $row = @()
    for ($x = 0; $x -lt $width; $x++) {
        $row += '##'
    }
    $maze += ,$row
}

# Directions for carving passages (2 cells at a time)
$directions = @(
    @{dx=0; dy=-2},
    @{dx=0; dy=2},
    @{dx=-2; dy=0},
    @{dx=2; dy=0}
)

function Shuffle {
    param([array]$array)
    for ($i = $array.Length - 1; $i -gt 0; $i--) {
        $j = Get-Random -Minimum 0 -Maximum ($i + 1)
        $temp = $array[$i]
        $array[$i] = $array[$j]
        $array[$j] = $temp
    }
    return $array
}

function Carve-Passage {
    param($x, $y)

    $maze[$y][$x] = '  '  # Mark current cell as path

    $shuffledDirs = Shuffle $directions
    foreach ($dir in $shuffledDirs) {
        $nx = $x + $dir.dx
        $ny = $y + $dir.dy

        # Ensure next cell is within bounds (leaving 1-cell border)
        if ($nx -gt 0 -and $ny -gt 0 -and $nx -lt ($width - 1) -and $ny -lt ($height - 1)) {
            if ($maze[$ny][$nx] -eq '##') {
                # Carve wall between current and next cell
                $maze[$y + [math]::Sign($dir.dy)][$x + [math]::Sign($dir.dx)] = '  '
                # Recurse to next cell
                Carve-Passage -x $nx -y $ny
            }
        }
    }
}

# Choose random starting cell (odd coordinates inside maze)
$startX = Get-Random -Minimum 1 -Maximum ($width - 2)
if ($startX % 2 -eq 0) { $startX++ }
if ($startX -ge $width - 1) { $startX -= 2 }

$startY = Get-Random -Minimum 1 -Maximum ($height - 2)
if ($startY % 2 -eq 0) { $startY++ }
if ($startY -ge $height - 1) { $startY -= 2 }

# Carve maze starting from random odd cell
Carve-Passage -x $startX -y $startY

# Function to find candidate edge cells adjacent to paths
function Find-Edge-Openings {
    param($maze, $width, $height)

    $openings = @()

    # Top and Bottom rows (exclude corners)
    for ($x = 1; $x -lt $width - 1; $x++) {
        if ($maze[1][$x] -eq '  ') { $openings += @{x=$x; y=0} }
        if ($maze[$height - 2][$x] -eq '  ') { $openings += @{x=$x; y=$height - 1} }
    }
    # Left and Right columns (exclude corners)
    for ($y = 1; $y -lt $height - 1; $y++) {
        if ($maze[$y][1] -eq '  ') { $openings += @{x=0; y=$y} }
        if ($maze[$y][$width - 2] -eq '  ') { $openings += @{x=$width - 1; y=$y} }
    }

    return $openings
}

# Find possible entrances and exits on edges
$edgeOpenings = Find-Edge-Openings -maze $maze -width $width -height $height

# If less than 2 openings, force carve some openings to edges
if ($edgeOpenings.Count -lt 2) {
    # Try to force carve openings top and bottom
    for ($x = 1; $x -lt $width - 1; $x++) {
        if ($maze[1][$x] -eq '  ') {
            $maze[0][$x] = '  '
            $edgeOpenings += @{x=$x; y=0}
            break
        }
    }
    for ($x = $width - 2; $x -ge 1; $x--) {
        if ($maze[$height - 2][$x] -eq '  ') {
            $maze[$height - 1][$x] = '  '
            $edgeOpenings += @{x=$x; y=$height - 1}
            break
        }
    }
}

# Pick two openings as start and end (furthest apart if you want)
# Simple: pick first and last
$startPos = $edgeOpenings[0]
$endPos = $edgeOpenings[-1]

# Mark Start and Exit
$maze[$startPos.y][$startPos.x] = 'S'
$maze[$endPos.y][$endPos.x] = 'EX'

# Place player on start position
$playerX = $startPos.x
$playerY = $startPos.y
$maze[$playerY][$playerX] = '@@'

function Draw-Maze {
    Clear-Host
    foreach ($row in $maze) {
        $row -join '' | Write-Output
    }
    Write-Host "`nUse W/A/S/D to move the player (@@). Reach the exit (EX) to win. Press Q to quit."
}

# Movement loop
$notWon = $true
do {
    Draw-Maze

    do {
        $keyInfo = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        $keyChar = $keyInfo.Character.ToString().ToLower()
    } while ($keyChar -notin @('w', 'a', 's', 'd', 'q'))

    $newX = $playerX
    $newY = $playerY

    switch ($keyChar) {
        'w' { $newY-- }
        's' { $newY++ }
        'a' { $newX-- }
        'd' { $newX++ }
        'q' { $notWon = $false }
    }

    # Check if move is valid (not wall)
    if ($maze[$newY][$newX] -ne '##') {
        # Check for exit
        if ($maze[$newY][$newX] -eq 'EX') {
            $maze[$playerY][$playerX] = '  '
            $playerX = $newX
            $playerY = $newY
            $maze[$playerY][$playerX] = '@@'
            Draw-Maze
            Write-Host "You reached the exit! You win!"
            break
        }

        # Move player
        $maze[$playerY][$playerX] = '  '
        $playerX = $newX
        $playerY = $newY
        $maze[$playerY][$playerX] = '@@'
    }

} while ($notWon)
pause