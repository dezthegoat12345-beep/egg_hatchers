# Generate tiny placeholder WAV assets for Egg Hatchers Sound System v1.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$musicDir = Join-Path $root 'assets\sounds\music'
$sfxDir = Join-Path $root 'assets\sounds\sfx'
New-Item -ItemType Directory -Force -Path $musicDir | Out-Null
New-Item -ItemType Directory -Force -Path $sfxDir | Out-Null

function Write-WavSamples {
    param(
        [string]$Path,
        [scriptblock]$SampleGenerator,
        [double]$Duration,
        [int]$SampleRate = 22050,
        [double]$Volume = 0.35
    )
    $sampleCount = [int]($SampleRate * $Duration)
    $dataSize = $sampleCount * 2
    $dir = Split-Path $Path
    if ($dir) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    $fs = [System.IO.File]::Create($Path)
    $bw = New-Object System.IO.BinaryWriter($fs)
    $bw.Write([System.Text.Encoding]::ASCII.GetBytes('RIFF'))
    $bw.Write([int](36 + $dataSize))
    $bw.Write([System.Text.Encoding]::ASCII.GetBytes('WAVE'))
    $bw.Write([System.Text.Encoding]::ASCII.GetBytes('fmt '))
    $bw.Write([int]16)
    $bw.Write([System.Int16]1)
    $bw.Write([System.Int16]1)
    $bw.Write([int]$SampleRate)
    $bw.Write([int]($SampleRate * 2))
    $bw.Write([System.Int16]2)
    $bw.Write([System.Int16]16)
    $bw.Write([System.Text.Encoding]::ASCII.GetBytes('data'))
    $bw.Write([int]$dataSize)
    for ($i = 0; $i -lt $sampleCount; $i++) {
        $t = $i / [double]$SampleRate
        $sample = & $SampleGenerator $t $Duration
        $val = [int]([math]::Max(-32767, [math]::Min(32767, $sample * $Volume * 32767)))
        $bw.Write([System.Int16]$val)
    }
    $bw.Close()
    $fs.Close()
}

function Write-ToneWav {
    param([string]$Path, [double]$Frequency, [double]$Duration, [double]$Volume = 0.35)
    Write-WavSamples -Path $Path -Duration $Duration -Volume $Volume -SampleGenerator {
        param($t, $dur)
        $fade = [math]::Min(0.08, $dur * 0.2)
        $env = 1.0
        if ($t -lt $fade) { $env = $t / $fade }
        elseif ($t -gt ($dur - $fade)) { $env = [math]::Max(0, ($dur - $t) / $fade) }
        [math]::Sin(2 * [math]::PI * $Frequency * $t) * $env
    }
}

function Write-MusicLoopWav {
    param([string]$Path, [double[]]$Frequencies, [double]$BarDuration = 0.45, [double]$Volume = 0.22)
    $notes = @()
    foreach ($f in $Frequencies) { $notes += $f }
    $duration = $BarDuration * $notes.Count * 2
    $idx = 0
    $noteDur = $BarDuration
    Write-WavSamples -Path $Path -Duration $duration -Volume $Volume -SampleGenerator {
        param($t, $dur)
        $loopLen = $noteDur * $notes.Count
        $localT = $t % $loopLen
        $noteIndex = [int]($localT / $noteDur) % $notes.Count
        $freq = $notes[$noteIndex]
        $nt = $localT % $noteDur
        $fade = 0.04
        $env = 1.0
        if ($nt -lt $fade) { $env = $nt / $fade }
        elseif ($nt -gt ($noteDur - $fade)) { $env = [math]::Max(0, ($noteDur - $nt) / $fade) }
        [math]::Sin(2 * [math]::PI * $freq * $nt) * $env
    }
}

Write-MusicLoopWav (Join-Path $musicDir 'hatchery_loop.wav') @(262, 330, 392, 330)
Write-MusicLoopWav (Join-Path $musicDir 'boss_battle_loop.wav') @(196, 247, 294, 247, 220) 0.42 0.24
Write-MusicLoopWav (Join-Path $musicDir 'final_boss_loop.wav') @(147, 175, 208, 233, 175) 0.4 0.26

function Write-ShellCrackWav {
    param([string]$Path)
    $sampleRate = 22050
    $duration = 0.16
    $sampleCount = [int]($sampleRate * $duration)
    Write-WavSamples -Path $Path -Duration $duration -Volume 0.28 -SampleRate $sampleRate -SampleGenerator {
        param($t, $dur)
        $rng = [System.Random]::new(42)
        $env = 1.0
        if ($t -lt 0.008) { $env = $t / 0.008 }
        elseif ($t -gt ($dur - 0.025)) { $env = [math]::Max(0, ($dur - $t) / 0.025) }

        $noise = 0.0
        if ($t -lt 0.035) {
            $noise = ($rng.NextDouble() * 2 - 1) * [math]::Exp(-$t * 120)
        }

        $snap1 = 0.0
        if ($t -ge 0.004 -and $t -lt 0.045) {
            $local = $t - 0.004
            $snap1 = [math]::Sin(2 * [math]::PI * 1680 * $local) * [math]::Exp(-$local * 95)
        }

        $snap2 = 0.0
        if ($t -ge 0.038 -and $t -lt 0.09) {
            $local = $t - 0.038
            $snap2 = [math]::Sin(2 * [math]::PI * 920 * $local) * [math]::Exp(-$local * 70) * 0.65
        }

        $thump = 0.0
        if ($t -ge 0.01 -and $t -lt 0.07) {
            $local = $t - 0.01
            $thump = [math]::Sin(2 * [math]::PI * 210 * $local) * [math]::Exp(-$local * 55) * 0.35
        }

        ($noise * 0.55 + $snap1 * 0.85 + $snap2 + $thump) * $env
    }
}

Write-ShellCrackWav (Join-Path $sfxDir 'egg_crack.wav')

$sfx = @{
    'egg_crack.wav' = $null  # generated separately
    'hatch_reveal.wav' = @{ f = 659; d = 0.2 }
    'rare_chime.wav' = @{ f = 880; d = 0.18 }
    'coin_reward.wav' = @{ f = 988; d = 0.14 }
    'token_reward.wav' = @{ f = 740; d = 0.14 }
    'egg_shard_reward.wav' = @{ f = 930; d = 0.16 }
    'button_tap.wav' = @{ f = 640; d = 0.05 }
    'purchase.wav' = @{ f = 784; d = 0.12 }
    'error_locked.wav' = @{ f = 220; d = 0.16 }
    'player_shoot.wav' = @{ f = 360; d = 0.07 }
    'boss_projectile.wav' = @{ f = 240; d = 0.06 }
    'player_hit.wav' = @{ f = 180; d = 0.12 }
    'boss_hit.wav' = @{ f = 310; d = 0.1 }
    'shield_break.wav' = @{ f = 500; d = 0.12 }
    'rage_mode.wav' = @{ f = 130; d = 0.18 }
    'victory.wav' = @{ f = 784; d = 0.2 }
    'defeat.wav' = @{ f = 196; d = 0.2 }
    'finisher_slash.wav' = @{ f = 700; d = 0.07 }
    'finisher_bonus.wav' = @{ f = 1100; d = 0.14 }
    'slime_pop.wav' = @{ f = 280; d = 0.12 }
    'golem_crack.wav' = @{ f = 200; d = 0.14 }
    'feather_burst.wav' = @{ f = 440; d = 0.12 }
    'royal_pop.wav' = @{ f = 520; d = 0.14 }
    'guardian_shatter.wav' = @{ f = 620; d = 0.12 }
    'phoenix_flap.wav' = @{ f = 300; d = 0.08 }
    'phoenix_impact.wav' = @{ f = 180; d = 0.14 }
    'phoenix_laugh.wav' = @{ f = 260; d = 0.1 }
    'rotten_pulse.wav' = @{ f = 140; d = 0.14 }
    'rotten_collapse.wav' = @{ f = 90; d = 0.16 }
    'rotten_explosion.wav' = @{ f = 80; d = 0.2 }
    'rotten_shard_harvest.wav' = @{ f = 988; d = 0.16 }
}

foreach ($entry in $sfx.GetEnumerator()) {
    if ($null -eq $entry.Value) { continue }
    Write-ToneWav (Join-Path $sfxDir $entry.Key) $entry.Value.f $entry.Value.d
}

Write-Host "Generated $($sfx.Count) sfx + 3 music files"
