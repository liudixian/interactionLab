<#
.SYNOPSIS
    打包 InteractiveLab 插件（原 GenartLib）为蓝图项目可直接使用的预编译版本。
.DESCRIPTION
    复制以下内容到输出目录：
    - InteractiveLab.uplugin (插件描述)
    - Binaries/Win64/*.dll + UnrealEditor.modules (预编译二进制)
    - Binaries/ThirdParty/**/dll (第三方依赖DLL，含 KinectAzure Win64/GPU 子目录)
    - Content/** (蓝图资产)
    - ThirdParty/OnnxRuntime/models/*.onnx (YOLO模型)
    - ThirdParty/MediapipeBridge/models/* (MediaPipe模型)
    - ThirdParty/KinectAzure/k4abt/models/*.onnx (Kinect Body Tracking模型)
    - Config/*
    排除：源代码(.cpp/.h/.cs)、Intermediate/、.pdb、.trae/
.PARAMETER OutputDir
    输出目录，默认为 ../InteractiveLab_BpRelease
.EXAMPLE
    .\PackageBlueprintPlugin.ps1 -OutputDir "D:\Releases\InteractiveLab_v1"
#>
param(
    [string]$OutputDir = ""
)

$ErrorActionPreference = "Stop"

# 脚本所在目录即为 InteractiveLab 插件根目录（与文件夹名无关）
$PluginRoot = $MyInvocation.MyCommand.Path
if ($PluginRoot) {
    $PluginRoot = Split-Path $PluginRoot -Parent
} else {
    $PluginRoot = $PSScriptRoot
}
if ([string]::IsNullOrEmpty($PluginRoot)) {
    $PluginRoot = "e:\P4worksSpace2\LG_Main\lingangInstallation\Plugins\InteractiveLab"
}
$PluginName = "InteractiveLab"

if ([string]::IsNullOrEmpty($OutputDir)) {
    $OutputDir = Join-Path (Split-Path $PluginRoot -Parent) "InteractiveLab_BpRelease"
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Packaging $PluginName for Blueprint use" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Source: $PluginRoot"
Write-Host "Output: $OutputDir"
Write-Host ""

# 清理输出目录
if (Test-Path $OutputDir) {
    Write-Host "Cleaning existing output directory..." -ForegroundColor Yellow
    Remove-Item -Path $OutputDir -Recurse -Force
}
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

# 统计变量
$copiedFiles = 0
$copiedSize = 0

function Copy-FileWithLog {
    param([string]$Src, [string]$Dst)
    $dir = Split-Path $Dst -Parent
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    Copy-Item -Path $Src -Destination $Dst -Force
    $script:copiedFiles++
    $size = (Get-Item $Src).Length
    $script:copiedSize += $size
}

function Copy-DirWithLog {
    param([string]$Src, [string]$Dst, [string[]]$IncludeFilters = @("*"), [string[]]$ExcludeFilters = @())
    if (!(Test-Path $Src)) {
        Write-Host "  [SKIP] Not found: $Src" -ForegroundColor DarkGray
        return
    }
    Get-ChildItem -Path $Src -Recurse -File | ForEach-Object {
        $relPath = $_.FullName.Substring($Src.Length).TrimStart('\','/')
        $shouldInclude = $false
        foreach ($filter in $IncludeFilters) {
            if ($_.Name -like $filter) { $shouldInclude = $true; break }
        }
        foreach ($filter in $ExcludeFilters) {
            if ($_.Name -like $filter) { $shouldInclude = $false; break }
        }
        if ($shouldInclude) {
            $dstPath = Join-Path $Dst $relPath
            Copy-FileWithLog -Src $_.FullName -Dst $dstPath
        }
    }
}

# 1. 插件描述文件
Write-Host "[1/7] Copying uplugin..." -ForegroundColor Green
Copy-FileWithLog -Src (Join-Path $PluginRoot "$PluginName.uplugin") -Dst (Join-Path $OutputDir "$PluginName.uplugin")

# 2. 预编译二进制 (Binaries/Win64/*.dll + .modules, 排除 .pdb)
Write-Host "[2/7] Copying module binaries (no .pdb)..." -ForegroundColor Green
$BinSrc = Join-Path $PluginRoot "Binaries\Win64"
$BinDst = Join-Path $OutputDir "Binaries\Win64"
Copy-DirWithLog -Src $BinSrc -Dst $BinDst -IncludeFilters @("*.dll","*.modules") -ExcludeFilters @("*.pdb")

# 3. 第三方DLL依赖
Write-Host "[3/7] Copying third-party DLLs..." -ForegroundColor Green
$TpSrc = Join-Path $PluginRoot "Binaries\ThirdParty"
$TpDst = Join-Path $OutputDir "Binaries\ThirdParty"
if (Test-Path $TpSrc) {
    Copy-DirWithLog -Src $TpSrc -Dst $TpDst -IncludeFilters @("*.dll") -ExcludeFilters @("*.pdb","*.lib")
}

# 4. Content (蓝图资产)
Write-Host "[4/7] Copying Content..." -ForegroundColor Green
$ContentSrc = Join-Path $PluginRoot "Content"
$ContentDst = Join-Path $OutputDir "Content"
Copy-DirWithLog -Src $ContentSrc -Dst $ContentDst

# 5. YOLO ONNX 模型（插件根 ThirdParty/，预编译分发不含 Source）
Write-Host "[5/8] Copying YOLO ONNX models..." -ForegroundColor Green
$YoloModelSrc = Join-Path $PluginRoot "ThirdParty\OnnxRuntime\models"
$YoloModelDst = Join-Path $OutputDir "ThirdParty\OnnxRuntime\models"
Copy-DirWithLog -Src $YoloModelSrc -Dst $YoloModelDst -IncludeFilters @("*.onnx","*.names")

# 6. MediaPipe 模型
Write-Host "[6/8] Copying MediaPipe models..." -ForegroundColor Green
$MpModelSrc = Join-Path $PluginRoot "ThirdParty\MediapipeBridge\models"
$MpModelDst = Join-Path $OutputDir "ThirdParty\MediapipeBridge\models"
Copy-DirWithLog -Src $MpModelSrc -Dst $MpModelDst -IncludeFilters @("*.task","*.tflite","*.bin","*.obj")

# 7. Kinect Body Tracking 模型
Write-Host "[7/8] Copying Kinect Azure models..." -ForegroundColor Green
$KbtModelSrc = Join-Path $PluginRoot "ThirdParty\KinectAzure\k4abt\models"
$KbtModelDst = Join-Path $OutputDir "ThirdParty\KinectAzure\k4abt\models"
Copy-DirWithLog -Src $KbtModelSrc -Dst $KbtModelDst -IncludeFilters @("*.onnx")

# 8. Config
Write-Host "[8/8] Copying Config..." -ForegroundColor Green
$ConfigSrc = Join-Path $PluginRoot "Config"
$ConfigDst = Join-Path $OutputDir "Config"
Copy-DirWithLog -Src $ConfigSrc -Dst $ConfigDst

# 汇总
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Packaging Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ("Files copied: {0}" -f $copiedFiles)
Write-Host ("Total size:   {0:N2} MB" -f ($copiedSize / 1MB))
Write-Host ("Output:       {0}" -f $OutputDir)
Write-Host ""

# 列出输出目录结构
Write-Host "Output structure:" -ForegroundColor Yellow
Get-ChildItem -Path $OutputDir -Recurse -Directory | ForEach-Object {
    $rel = $_.FullName.Substring($OutputDir.Length)
    $count = (Get-ChildItem $_.FullName -File).Count
    Write-Host ("  {0} ({1} files)" -f $rel, $count)
}

Write-Host ""
Write-Host "To use: Copy the 'InteractiveLab' folder into your project's Plugins/ directory." -ForegroundColor Cyan
