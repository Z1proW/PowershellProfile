### Inspired by ChrisTitusTech's profile (https://github.com/ChrisTitusTech/powershell-profile)
### Edited and extended by Z1proW

# remove beep
Set-PSReadLineOption -BellStyle None

# better history
Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
Set-PSReadLineOption -MaximumHistoryCount 10000

# better tab-completion based on history
Set-PSReadLineOption -PredictionSource History
# list of possible completions instead of inline preview
#Set-PSReadLineOption -PredictionViewStyle ListView
# tab for completion instead of right arrow
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# reverse search with Ctrl+R
Set-PSReadLineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory

# prompt with current git branch in yellow
function prompt {
    $path = $PWD.Path
    $branch = git branch --show-current 2>$null
    if ($branch) {
        "PS $path ($($PSStyle.Foreground.Yellow)$branch$($PSStyle.Reset))> "
    } else {
        "PS $path> "
    }
}

# Import Terminal-Icons if available
if (Get-Module -ListAvailable Terminal-Icons) {
    Import-Module Terminal-Icons
}


# Make it easy to edit this profile once it's installed
function edit-profile {
    if ($host.Name -match "ise") {
        $psISE.CurrentPowerShellTab.Files.Add($profile.CurrentUserAllHosts)
    }
    elseif (Get-Command code -ErrorAction SilentlyContinue) {
        code $profile.CurrentUserAllHosts
    }
    else {
        Invoke-Item $profile.CurrentUserAllHosts
    }
}


function lazyg
{
	git add .
	git commit -m "$args"
	git push
}

function gitinit {
    git init
    git add .
    git commit -m "initial commit"
}


function download {
    wget -c $args -P "$env:USERPROFILE\Desktop\"
}


function update {
    winget upgrade --all `
        --silent `
        --accept-package-agreements `
        --accept-source-agreements `
        --disable-interactivity;
}

# elevate terminal
function admin {
    Start-Process wt -Verb RunAs
    Start-Sleep -Milliseconds 500
    [Environment]::Exit(0)
}

function Reload {
    Start-Process wt
    Start-Sleep -Milliseconds 300
    [Environment]::Exit(0)
}
Set-Alias -Name rl -Value Reload


# Navigation
function cd...  { Set-Location ..\.. }
function cd.... { Set-Location ..\..\.. }
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }
function back { Set-Location - }
function home { Set-Location $HOME }
function desktop { Set-Location $HOME\Desktop }
function documents { Set-Location $HOME\Documents }
function open { Start-Process . }
function files { Get-ChildItem -Path $pwd -File }
function tree {
    param(
        [string]$Path = ".",
        [int]$Depth = -1,
        [switch]$DirectoriesOnly,
        [switch]$ShowHidden,
        [string[]]$Ignore = @()
    )

    function Should-Ignore($name) {
        foreach ($pattern in $Ignore) {
            if ($name -like $pattern) { return $true }
        }
        return $false
    }

    function Show-Tree($CurrentPath, $Prefix = "", $Level = 0) {

        if ($Depth -ne -1 -and $Level -gt $Depth) { return }

        $items = Get-ChildItem -LiteralPath $CurrentPath -Force:$ShowHidden

        # filter
        $items = $items | Where-Object {
            -not (Should-Ignore $_.Name)
        }

        # directories first (like Linux tree)
        $items = $items | Sort-Object `
            @{Expression = "PSIsContainer"; Descending = $true}, `
            @{Expression = "Name"; Ascending = $true}

        $count = $items.Count
        $i = 0

        foreach ($item in $items) {
            $i++
            $isLast = $i -eq $count

            $connector = if ($isLast) { "└── " } else { "├── " }

            # color output
            if ($item.PSIsContainer) {
                Write-Host "$Prefix$connector$($item.Name)" -ForegroundColor Cyan
            } elseif (-not $DirectoriesOnly) {
                Write-Host "$Prefix$connector$($item.Name)" -ForegroundColor DarkGray
            }

            # recurse into folders
            if ($item.PSIsContainer) {
                $newPrefix = $Prefix + ($(if ($isLast) { "    " } else { "│   " }))
                Show-Tree $item.FullName $newPrefix ($Level + 1)
            }
        }
    }

    Write-Host $Path -ForegroundColor Green
    Show-Tree $Path
}

# Compute file hashes
function sha1   { Get-FileHash -Algorithm SHA1 $args }
function sha256 { Get-FileHash -Algorithm SHA256 $args }


Function ip
{
	(Invoke-WebRequest http://ifconfig.me/ip).Content
}

function uptime
{
    $boot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    New-TimeSpan $boot (Get-Date)
}


function find($name)
{
	Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
		$place_path = $_.directory
		Write-Output "${place_path}\${_}"
	}
}

function unzip ($file)
{
	Write-Output("Extracting", $file, "to", $pwd)
	$fullFile = Get-ChildItem -Path $pwd -Filter .\cove.zip | ForEach-Object{$_.FullName}
	Expand-Archive -Path $fullFile -DestinationPath $pwd
}

function grep($regex, $dir)
{
	if ( $dir )
	{
		Get-ChildItem $dir | select-string $regex
		return
	}
	$input | select-string $regex
}

function touch($file) {
    $dir = Split-Path $file
    if ($dir -and !(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
    }
    New-Item -ItemType File -Path $file -Force | Out-Null
}

function findandreplace($file, $find, $replace)
{
	(Get-Content $file).replace("$find", $replace) | Set-Content $file
}

function size {
    $bytes = (Get-ChildItem . -Recurse -File -ErrorAction SilentlyContinue |
        Measure-Object Length -Sum).Sum

    if (-not $bytes) {
        Write-Host "Empty folder"
        return
    }

    switch ($bytes) {
        { $_ -ge 1GB } { "{0:N2} GB" -f ($_ / 1GB); break }
        { $_ -ge 1MB } { "{0:N2} MB" -f ($_ / 1MB); break }
        { $_ -ge 1KB } { "{0:N2} KB" -f ($_ / 1KB); break }
        default        { "$bytes bytes" }
    }
}

function sizes {
    Get-ChildItem -Directory -ErrorAction SilentlyContinue |
    ForEach-Object {
        $size = 0

        try {
            $size = (Get-ChildItem $_.FullName -Recurse -File -Force -ErrorAction SilentlyContinue |
            Measure-Object Length -Sum).Sum
        } catch {}

        [PSCustomObject]@{
            Folder = $_.Name
            SizeMB = [math]::Round(($size / 1MB), 2)
        }
    } |
    Sort-Object SizeMB -Descending
}


function cleantmp {
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
}

function cleantrash {
    Clear-RecycleBin -Force
}


function which($name)
{
	Get-Command $name | Select-Object -ExpandProperty Definition
}

function export($name, $value)
{
	set-item -force -path "env:$name" -value $value;
}

function pkill($name)
{
	Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}

function dns($name) {
    Resolve-DnsName $name
}

function http($url) {
    try {
        Invoke-WebRequest $url -UseBasicParsing -Method Head | Select-Object StatusCode
    } catch {
        "Down or unreachable"
    }
}

function ports {
    Get-NetTCPConnection | Select-Object LocalPort, State, OwningProcess
}


function hist($pattern) {
    Get-History | Where-Object CommandLine -like "*$pattern*"
}

function help {
    Write-Host ""
    Write-Host "=== Custom PowerShell Profile Help ===" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "⚙️ Profile" -ForegroundColor Yellow
    Write-Host "  edit-profile  -> Open this profile in editor"
    Write-Host "  reload        -> Restart Windows Terminal"
    Write-Host ""

    Write-Host "🧠 Git shortcuts" -ForegroundColor Yellow
    Write-Host "  gitinit       -> git init/add ./commit"
    Write-Host "  lazyg         -> git add/commit/push"
    Write-Host ""

    Write-Host "📦 System / Updates" -ForegroundColor Yellow
    Write-Host "  admin         -> Restart terminal as Administrator"
    Write-Host "  update        -> Upgrade all winget packages"
    Write-Host "  cleantmp      -> Clean ~\AppData\Local\Temp"
    Write-Host "  cleantrash    -> Clean Recycle Bin"
    Write-Host ""

    Write-Host "📁 Navigation" -ForegroundColor Yellow
    Write-Host "  ..            -> Shortcut for 'cd ..'"
    Write-Host "  ... / cd...   -> Go up 2 directories"
    Write-Host "  .... / cd.... -> Go up 3 directories"
    Write-Host "  back          -> Go back to previous directory"
    Write-Host "  home          -> Go to User Home directory"
    Write-Host "  desktop       -> Go to Desktop"
    Write-Host "  documents     -> Go to Documents"
    Write-Host "  open          -> Open current directory in File Explorer"
    Write-Host ""

    Write-Host "📄 File Utilities" -ForegroundColor Yellow
    Write-Host "  unzip <file>  -> Unzip an archive"
    Write-Host "  grep          -> Search text in files"
    Write-Host "  touch         -> Create empty file"
    Write-Host "  find          -> Search files by name"
    Write-Host "  sha1 / sha256 -> File hashes"
    Write-Host "  files         -> List only files in current folder"
    Write-Host "  tree          -> List dirs/files in a tree like format"
    Write-Host "  findandreplace <file> <find> <replace> -> Replaces all occurrences of a string inside a file"
    Write-Host ""

    Write-Host "🌐 Network" -ForegroundColor Yellow
    Write-Host "  download URL  -> Download file to Desktop (wget -c)"
    Write-Host "  ip            -> Show public IP"
    Write-Host "  dns <name>    -> Get public IP of a domain name"
    Write-Host "  http <url>    -> HTTP check"
    Write-Host "  ports         -> Check open ports"
    Write-Host ""

    Write-Host "🔧 Utilities" -ForegroundColor Yellow
    Write-Host "  history <regex> -> Show commandline history"
    Write-Host "  size          -> Show size of current directory (size of accessible files only)"
    Write-Host "  sizes         -> Show sizes of directories in current location"
    Write-Host "  which         -> Show command path"
    Write-Host "  uptime        -> System uptime"
    Write-Host "  export <name> <value> -> Creates or updates an environment variable for the current session"
    Write-Host "  pkill <process-name> -> Kills all processes matching a name"
    Write-Host ""

    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host ""
}
Set-Alias h help

# Tab-completions for `choco` (Chocolatey)
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile))
{
  Import-Module "$ChocolateyProfile"
}

# Oh my posh theme (tonybaloney theme)
#if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
#    oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\tonybaloney.omp.json" | Invoke-Expression
#}
