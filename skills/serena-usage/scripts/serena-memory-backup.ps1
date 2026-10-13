<#
.SYNOPSIS
    Backup default Serena project memories to a timestamped folder.
.DESCRIPTION
    Copies only <project>/.serena/memories/**/*.md, preserving relative paths,
    and writes a summary index. Does not include global memories, other Serena
    configuration/cache files or custom relocated memory directories.
.PARAMETER ProjectDir
    Project root. Defaults to current working directory.
.PARAMETER BackupDir
    Backup destination root. Defaults to <project>/.serena-backups.
.EXAMPLE
    ./serena-memory-backup.ps1 -ProjectDir "C:\Projects\MyApp"
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$ProjectDir = ".",

    [Parameter(Position = 1)]
    [string]$BackupDir
)

$ErrorActionPreference = "Stop"
$projectPath = (Resolve-Path -LiteralPath $ProjectDir).Path
$memoryDir = Join-Path (Join-Path $projectPath ".serena") "memories"

if (-not (Test-Path -LiteralPath $memoryDir -PathType Container)) {
    throw "No project memories found at '$memoryDir'. Check the active Serena project or configured memory location."
}

$memoryFiles = @(Get-ChildItem -LiteralPath $memoryDir -File -Recurse -Filter "*.md")
if ($memoryFiles.Count -eq 0) {
    Write-Warning "No Markdown memory files found in '$memoryDir'. No backup created."
    return
}

if ([string]::IsNullOrWhiteSpace($BackupDir)) {
    $BackupDir = Join-Path $projectPath ".serena-backups"
}

$timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$targetDir = Join-Path $BackupDir $timestamp
New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

$indexEntries = @()
foreach ($file in $memoryFiles) {
    $relativePath = $file.FullName.Substring($memoryDir.Length).TrimStart([char[]]@('\', '/'))
    $destPath = Join-Path $targetDir $relativePath
    $parent = Split-Path -Path $destPath -Parent
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
    Copy-Item -LiteralPath $file.FullName -Destination $destPath -Force

    $indexEntries += [PSCustomObject]@{
        File = $relativePath.Replace('\', '/')
        SizeBytes = $file.Length
        LastModified = $file.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')
    }
}

$indexContent = @(
    '# Serena Project Memory Backup',
    '',
    "Backup date: $timestamp",
    "Source: $memoryDir",
    "Memory files: $($memoryFiles.Count)",
    '',
    '| Memory file | Bytes | Last modified |',
    '|---|---:|---|'
)
foreach ($item in $indexEntries | Sort-Object File) {
    $indexContent += "| $($item.File.Replace('|', '\|')) | $($item.SizeBytes) | $($item.LastModified) |"
}
$indexPath = Join-Path $targetDir 'BACKUP_INDEX.md'
Set-Content -LiteralPath $indexPath -Value $indexContent -Encoding utf8
Write-Host "Backed up $($memoryFiles.Count) Serena project memory file(s) to '$targetDir'." -ForegroundColor Green
Write-Host "Index: $indexPath"
