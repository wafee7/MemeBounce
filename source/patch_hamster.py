import struct, hashlib, shutil, os

# ── helpers ──────────────────────────────────────────────────────────────────

def make_ctex(orig_ctex_bytes, new_webp_bytes):
    """Replace WebP payload in a GST2 ctex, keeping original 52-byte header prefix."""
    return orig_ctex_bytes[:52] + struct.pack('<I', len(new_webp_bytes)) + new_webp_bytes

def read_pck(src_pck):
    with open(src_pck, 'rb') as f:
        data = f.read()
    magic, pack_ver, v_maj, v_min, v_pat, flags, file_base, dir_offset = \
        struct.unpack('<4sIIIIIQQ', data[:40])
    pos = dir_offset
    count, = struct.unpack('<I', data[pos:pos+4]); pos += 4
    files = []
    for _ in range(count):
        plen, = struct.unpack('<I', data[pos:pos+4]); pos += 4
        pbytes = data[pos:pos+plen]; pos += plen
        offset, size = struct.unpack('<QQ', data[pos:pos+16]); pos += 16
        md5 = data[pos:pos+16]; pos += 16
        fflags, = struct.unpack('<I', data[pos:pos+4]); pos += 4
        real_off = file_base + offset
        fdata = data[real_off:real_off + size]
        files.append({'pbytes': pbytes, 'data': fdata, 'flags': fflags,
                      'orig_offset': offset, 'orig_size': size})
    return data, magic, pack_ver, v_maj, v_min, v_pat, flags, file_base, files

def write_pck(dst_pck, magic, pack_ver, v_maj, v_min, v_pat, flags, file_base, files):
    out = bytearray(b'\x00' * file_base)
    for item in files:
        pad = (16 - len(out) % 16) % 16
        out.extend(b'\x00' * pad)
        item['new_offset'] = len(out) - file_base
        item['new_size'] = len(item['data'])
        item['new_md5'] = hashlib.md5(item['data']).digest()
        out.extend(item['data'])
    dir_offset_new = len(out)
    out.extend(struct.pack('<I', len(files)))
    for item in files:
        out.extend(struct.pack('<I', len(item['pbytes']))); out.extend(item['pbytes'])
        out.extend(struct.pack('<QQ', item['new_offset'], item['new_size']))
        out.extend(item['new_md5']); out.extend(struct.pack('<I', item['flags']))
    header = struct.pack('<4sIIIIIQQ',
                         magic, pack_ver, v_maj, v_min, v_pat,
                         flags, file_base, dir_offset_new)
    out[:len(header)] = header
    with open(dst_pck, 'wb') as f:
        f.write(out)
    print(f"  Written {len(out):,} bytes → {dst_pck}")

# ── load webp payloads ────────────────────────────────────────────────────────

WORK = r"c:\Users\Administrator\Desktop\ICT\Exam Prep"
GAME = r"C:\Users\Administrator\Desktop\My Next Game\Harvest HackClub\game"

with open(os.path.join(WORK, 'fluff_64.webp'), 'rb') as f: webp64 = f.read()
with open(os.path.join(WORK, 'fluff_16.webp'), 'rb') as f: webp16 = f.read()
print(f"Loaded fluff_64.webp ({len(webp64)} B), fluff_16.webp ({len(webp16)} B)")

# ── slots to replace (meme-4 and meme-5 in all three folders) ────────────────
# Key = substring that must appear in the null-terminated path string
# Value = (use_64, use_16) — which webp to use

REPLACE_PATTERNS = {
    # Memes/ billboard (64×64)
    'pixel-cat-meme-4.png-c4a654d28de0d3c2ce9a0f99b76784a1': ('64', None),
    'pixel-cat-meme-5.png-4d3ccdab209d25d3eff0c210107d3489': ('64', None),
    # memes_big/ HUD overlay (64×64)
    'pixel-cat-meme-4.png-d121614df5df48e5db29fa25e7911af7': ('64', None),
    'pixel-cat-meme-5.png-52d1fa0bde40223e37f89c5fd5e850d5': ('64', None),
    # flyers/ enemy skins (16×16)
    'pixel-cat-meme-4.png-58fff0911a3eec7b19563d08285961ea': (None, '16'),
    'pixel-cat-meme-5.png-eaeb6630e368bad29f836657fd52caf3': (None, '16'),
}

def patch_pck(src, dst):
    print(f"\nPatching {src} → {dst}")
    data, magic, pack_ver, v_maj, v_min, v_pat, flags, file_base, files = read_pck(src)
    patched = 0
    for item in files:
        path_str = item['pbytes'].decode('utf-8', 'ignore').rstrip('\x00')
        for key, (sz64, sz16) in REPLACE_PATTERNS.items():
            if key in path_str:
                orig_ctex = item['data']
                webp = webp64 if sz64 else webp16
                item['data'] = make_ctex(orig_ctex, webp)
                print(f"  REPLACED: ...{path_str[-60:]}  ({len(orig_ctex)} → {len(item['data'])} B)")
                patched += 1
                break
    print(f"  Total replacements: {patched}")
    write_pck(dst, magic, pack_ver, v_maj, v_min, v_pat, flags, file_base, files)

# ── patch both PCK files ──────────────────────────────────────────────────────

src_rebound = os.path.join(GAME, 'rebound.pck')
src_index   = os.path.join(GAME, 'index.pck')
tmp_rebound = os.path.join(WORK, 'rebound_hamster.pck')
tmp_index   = os.path.join(WORK, 'index_hamster.pck')

patch_pck(src_rebound, tmp_rebound)
patch_pck(src_index,   tmp_index)

# ── copy back ────────────────────────────────────────────────────────────────

print("\nCopying patched PCKs back to game folder...")
shutil.copy2(tmp_rebound, src_rebound)
shutil.copy2(tmp_index,   src_index)
print("Done! rebound.pck and index.pck updated.")
print("\nVerification sizes:")
print(f"  rebound.pck: {os.path.getsize(src_rebound):,} bytes")
print(f"  index.pck:   {os.path.getsize(src_index):,} bytes")
