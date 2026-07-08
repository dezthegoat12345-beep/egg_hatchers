"""Generate tiny placeholder WAV assets for Egg Hatchers Sound System v1."""
from __future__ import annotations

import math
import struct
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MUSIC_DIR = ROOT / "assets" / "sounds" / "music"
SFX_DIR = ROOT / "sounds" / "sfx"
SFX_DIR = ROOT / "assets" / "sounds" / "sfx"
SAMPLE_RATE = 22050


def write_wave(path: Path, samples: list[float], volume: float = 0.35) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "w") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        frames = bytearray()
        for sample in samples:
            val = int(max(-1.0, min(1.0, sample * volume)) * 32767)
            frames.extend(struct.pack("<h", val))
        wf.writeframes(frames)


def tone(freq: float, duration: float, fade: float = 0.08) -> list[float]:
    count = int(SAMPLE_RATE * duration)
    out: list[float] = []
    for i in range(count):
        t = i / SAMPLE_RATE
        env = 1.0
        if t < fade:
            env = t / fade
        elif t > duration - fade:
            env = max(0.0, (duration - t) / fade)
        out.append(math.sin(2 * math.pi * freq * t) * env)
    return out


def noise_burst(duration: float) -> list[float]:
    import random

    count = int(SAMPLE_RATE * duration)
    out: list[float] = []
    for i in range(count):
        t = i / SAMPLE_RATE
        env = max(0.0, 1.0 - t / duration)
        out.append((random.random() * 2 - 1) * env)
    return out


def mix(*tracks: list[float]) -> list[float]:
    length = max(len(t) for t in tracks)
    out = [0.0] * length
    for track in tracks:
        for i, sample in enumerate(track):
            out[i] += sample
    peak = max(abs(s) for s in out) or 1.0
    if peak > 1.0:
        out = [s / peak for s in out]
    return out


def music_loop(notes: list[tuple[float, float]], bar_duration: float = 0.45) -> list[float]:
    samples: list[float] = []
    for freq, bars in notes:
        samples.extend(tone(freq, bar_duration * bars))
    # loop twice for ~3-4s
    return samples + samples


def main() -> None:
    # Music loops
    write_wave(
        MUSIC_DIR / "hatchery_loop.wav",
        music_loop([(262, 2), (330, 2), (392, 2), (330, 2)], 0.5),
        volume=0.22,
    )
    write_wave(
        MUSIC_DIR / "boss_battle_loop.wav",
        music_loop([(196, 1), (247, 1), (294, 1), (247, 1), (220, 2)], 0.42),
        volume=0.24,
    )
    write_wave(
        MUSIC_DIR / "final_boss_loop.wav",
        music_loop([(147, 1), (175, 1), (208, 1), (233, 1), (175, 2)], 0.4),
        volume=0.26,
    )

    sfx_defs: dict[str, list[float]] = {
        "egg_crack": mix(tone(420, 0.08), tone(280, 0.12)),
        "hatch_reveal": mix(tone(523, 0.12), tone(659, 0.18), tone(784, 0.22)),
        "rare_chime": mix(tone(880, 0.15), tone(1175, 0.2)),
        "coin_reward": mix(tone(988, 0.1), tone(1319, 0.14)),
        "token_reward": mix(tone(740, 0.12), tone(988, 0.16)),
        "egg_shard_reward": mix(tone(620, 0.1), tone(930, 0.14), tone(1240, 0.18)),
        "button_tap": tone(640, 0.05),
        "purchase": mix(tone(523, 0.08), tone(784, 0.12)),
        "error_locked": mix(tone(220, 0.14), tone(185, 0.18)),
        "player_shoot": tone(360, 0.07),
        "boss_projectile": tone(240, 0.06),
        "player_hit": mix(tone(180, 0.12), noise_burst(0.08)),
        "boss_hit": mix(tone(310, 0.08), tone(220, 0.1)),
        "shield_break": mix(tone(500, 0.1), tone(350, 0.14)),
        "rage_mode": mix(tone(130, 0.16), tone(98, 0.2)),
        "victory": mix(tone(523, 0.12), tone(659, 0.16), tone(784, 0.22)),
        "defeat": mix(tone(196, 0.18), tone(147, 0.22)),
        "finisher_slash": mix(tone(700, 0.06), noise_burst(0.05)),
        "finisher_bonus": mix(tone(880, 0.1), tone(1100, 0.14)),
        "slime_pop": mix(tone(280, 0.1), noise_burst(0.12)),
        "golem_crack": mix(tone(200, 0.12), tone(150, 0.14)),
        "feather_burst": mix(tone(440, 0.1), tone(330, 0.12)),
        "royal_pop": mix(tone(350, 0.1), tone(520, 0.14)),
        "guardian_shatter": mix(tone(620, 0.1), tone(480, 0.12)),
        "phoenix_flap": tone(300, 0.08),
        "phoenix_impact": mix(tone(180, 0.14), noise_burst(0.1)),
        "phoenix_laugh": mix(tone(260, 0.08), tone(220, 0.1), tone(260, 0.08)),
        "rotten_pulse": mix(tone(140, 0.12), tone(110, 0.14)),
        "rotten_collapse": mix(tone(90, 0.16), noise_burst(0.12)),
        "rotten_explosion": mix(tone(80, 0.2), noise_burst(0.18), tone(120, 0.16)),
        "rotten_shard_harvest": mix(tone(740, 0.1), tone(988, 0.14), tone(1240, 0.16)),
    }

    for name, samples in sfx_defs.items():
        write_wave(SFX_DIR / f"{name}.wav", samples)

    print(f"Generated {len(sfx_defs)} sfx + 3 music files in {ROOT / 'assets' / 'sounds'}")


if __name__ == "__main__":
    main()
