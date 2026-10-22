#!/usr/bin/env python3
"""Genere les sons de LUNAR COURIER (WAV 16 bits mono, synthese pure, aucun sample externe).
Usage : python3 tools/make_audio.py [taux_hz]     (defaut 22050)
Ecrit dans ../sfx et ../mus. Necessite numpy."""
import sys, os, wave
import numpy as np

SR = int(sys.argv[1]) if len(sys.argv) > 1 else 22050
HERE = os.path.dirname(os.path.abspath(__file__))
SFX = os.path.join(HERE, "..", "sfx")
MUS = os.path.join(HERE, "..", "mus")
os.makedirs(SFX, exist_ok=True); os.makedirs(MUS, exist_ok=True)
rng = np.random.default_rng(7)

def t(d): return np.arange(int(d * SR)) / SR
def sine(f, d): return np.sin(2*np.pi*f*t(d))
def tri(f, d): return 2/np.pi*np.arcsin(np.sin(2*np.pi*f*t(d)))
def square(f, d): return np.sign(np.sin(2*np.pi*f*t(d)))
def noise(d): return rng.uniform(-1, 1, int(d*SR))
def env(n, a=0.005, r=0.1):
    e = np.ones(n); na = max(1, int(a*SR)); nr = max(1, int(r*SR))
    e[:na] = np.linspace(0, 1, na); e[-nr:] = np.minimum(e[-nr:], np.linspace(1, 0, nr)); return e
def lowpass(x, k):
    c = np.cumsum(np.insert(x, 0, 0)); y = (c[k:] - c[:-k]) / k
    return np.concatenate([np.full(k-1, y[0]), y])
def write(path, x, gain=0.8):
    x = np.clip(x / (np.max(np.abs(x)) + 1e-9) * gain, -1, 1)
    with wave.open(path, "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes((x * 32767).astype("<i2").tobytes())
def note(m): return 440.0 * 2 ** ((m - 69) / 12)

# ----------------------------------------------------------------- effets
# propulseur : grondement boucle (longueur = multiple entier de periodes basses)
n = int(0.4 * SR); base = lowpass(noise(0.4), 18) * 0.9
x = base + 0.5 * sine(70, 0.4) + 0.25 * sine(140, 0.4)
x[:200] *= np.linspace(0, 1, 200); x[-200:] *= np.linspace(1, 0, 200)
x = x * 0.9 + np.roll(x, n//2) * 0.0
write(os.path.join(SFX, "thrust.wav"), x, 0.55)

def seq(notes, dur, wave_fn=tri, gap=0.0):
    out = []
    for m in notes:
        s = wave_fn(note(m), dur); out.append(s * env(len(s), 0.004, dur*0.6))
        if gap: out.append(np.zeros(int(gap*SR)))
    return np.concatenate(out)

write(os.path.join(SFX, "pickup.wav"), seq([76, 81, 88], 0.07, square) * 0.7 + 0, 0.7)
write(os.path.join(SFX, "pad.wav"), np.concatenate([seq([72, 79], 0.12, tri), seq([84], 0.25, sine)]), 0.8)
land = np.concatenate([seq([67, 72, 76], 0.14, tri), seq([79], 0.5, sine)])
write(os.path.join(SFX, "land.wav"), land, 0.85)
h = lowpass(noise(0.35), 6) * np.linspace(1, 0, int(0.35*SR))**2 + 0.7*sine(90, 0.35)*np.linspace(1, 0, int(0.35*SR))
write(os.path.join(SFX, "hit.wav"), h, 0.9)
b = sine(110, 0.15) * np.linspace(1, 0, int(0.15*SR))**2 + lowpass(noise(0.15), 10) * 0.3
write(os.path.join(SFX, "bounce.wav"), b, 0.7)
write(os.path.join(SFX, "menu.wav"), seq([84], 0.05, square), 0.5)
write(os.path.join(SFX, "card.wav"), seq([79], 0.04, tri), 0.4)
f = np.concatenate([seq([60], 0.18, square), seq([55], 0.18, square), seq([48], 0.4, square)])
write(os.path.join(SFX, "fail.wav"), f, 0.7)
write(os.path.join(SFX, "warn.wav"), np.concatenate([seq([88], 0.07, square, 0.05), seq([88], 0.07, square)]), 0.5)

# ----------------------------------------------------------------- musiques (boucles de 8 s)
BPM = 120; BEAT = 60 / BPM; LEN = 8.0
def render(events, tail=2.0):
    """events: (beat, midi, dur_beats, kind, vel). Boucle sans couture (la queue est repliee au debut)."""
    total = int((LEN + tail) * SR); buf = np.zeros(total)
    for beat, m, dur, kind, vel in events:
        d = dur * BEAT + (0.6 if kind == "pad" else 0.3)
        f = note(m)
        if kind == "pad":
            s = (sine(f, d) + 0.5 * tri(f * 1.003, d)) * 0.5
            e = np.minimum(np.linspace(0, 1, len(s)) * 8, 1) * np.linspace(1, 0, len(s))**1.2
        elif kind == "pluck":
            s = tri(f, d) + 0.3 * sine(f * 2, d)
            e = np.exp(-np.linspace(0, 6, len(s)))
        elif kind == "bass":
            s = sine(f, d) + 0.3 * sine(f * 2, d)
            e = np.minimum(np.linspace(0, 1, len(s)) * 30, 1) * np.exp(-np.linspace(0, 2.5, len(s)))
        else:  # bell
            s = sine(f, d) + 0.4 * sine(f * 2.76, d)
            e = np.exp(-np.linspace(0, 7, len(s)))
        s = s * e * vel
        i = int((beat % 16) * BEAT * SR); n = min(len(s), total - i); buf[i:i+n] += s[:n]
    out = buf[:int(LEN*SR)].copy(); tl = buf[int(LEN*SR):]; out[:len(tl)] += tl
    return out

def track(chords, arp, bass_notes, bells=(), swing_vel=0.5):
    ev = []
    for bar, ch in enumerate(chords):
        for m in ch: ev.append((bar*4, m, 4, "pad", 0.35))
        ev.append((bar*4, bass_notes[bar], 2, "bass", 0.8))
        ev.append((bar*4 + 2, bass_notes[bar] + (7 if bar % 2 == 0 else 0), 2, "bass", 0.55))
        for i, a in enumerate(arp):
            ev.append((bar*4 + i*0.5, ch[a % len(ch)] + 12*(a // len(ch)), 0.5, "pluck", swing_vel))
    for beat, m in bells: ev.append((beat, m, 1.5, "bell", 0.5))
    return render(ev)

# story : La mineur, calme
write(os.path.join(MUS, "mus_story.wav"),
      track([[57, 60, 64], [53, 57, 60], [48, 52, 55], [52, 55, 59]], [0, 2, 1, 2, 0, 2, 1, 2], [45, 41, 36, 40], [(6, 88), (14, 91), (26, 84)], 0.30), 0.7)
# chapitre 1 : Re dorien, pulsation legere
write(os.path.join(MUS, "mus_ch1.wav"),
      track([[50, 57, 62], [53, 60, 65], [48, 55, 60], [55, 62, 67]], [0, 1, 2, 3, 2, 1, 2, 1], [38, 41, 36, 43], [(10, 86), (22, 89)], 0.35), 0.7)
# chapitre 2 : face cachee, plus sombre, notes rares
write(os.path.join(MUS, "mus_ch2.wav"),
      track([[46, 53, 58], [44, 51, 56], [47, 54, 59], [45, 52, 57]], [0, 3, 2, 5], [34, 32, 35, 33], [(2, 82), (9, 87), (18, 80), (27, 90)], 0.25), 0.7)
# chapitre 3 : Mi mineur, montee lumineuse
write(os.path.join(MUS, "mus_ch3.wav"),
      track([[52, 59, 64], [48, 55, 60], [55, 62, 67], [50, 57, 62]], [0, 1, 2, 4, 3, 2, 1, 2], [40, 36, 43, 38], [(4, 91), (12, 95), (20, 88), (28, 98)], 0.40), 0.7)
print("OK", SR, "Hz")
