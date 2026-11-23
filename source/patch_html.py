import re, sys

HTML_PATH = r"C:\Users\Administrator\Desktop\My Next Game\Harvest HackClub\game\rebound.html"
B64_PATH  = r"c:\Users\Administrator\Desktop\ICT\Exam Prep\hamster_b64.txt"

with open(B64_PATH, 'r') as f:
    b64 = f.read().strip()

with open(HTML_PATH, 'r', encoding='utf-8') as f:
    html = f.read()

# ── 1. Inject hamster Image object before first function definition ──────────
IMG_INIT = f"""// Hamster meme image for failure screens
const hamsterImg = new Image();
hamsterImg.src = 'data:image/png;base64,{b64}';
let hamsterReady = false;
hamsterImg.onload = () => {{ hamsterReady = true; }};

"""

# Insert right before the first "function " declaration in the script
insert_before = "function resize() {"
if "hamsterImg" in html:
    print("Hamster img already injected, skipping init injection")
else:
    idx = html.index(insert_before)
    html = html[:idx] + IMG_INIT + html[idx:]
    print(f"Injected hamsterImg init at index {idx}")

# ── 2. Replace drawFailMsg function ─────────────────────────────────────────
OLD_FUNC = (
    "function drawFailMsg() {\n"
    "  if (failAlpha <= 0) return;\n"
    "  const alpha = Math.min(1, failAlpha);\n"
    "  ctx.save();\n"
    "  ctx.globalAlpha = alpha;\n"
    "  ctx.font = '12px monospace';\n"
    "  ctx.textAlign = 'center';\n"
    "  ctx.fillStyle = COL_FAIL;\n"
    "  ctx.fillText(failMsg, CANVAS_W/2 + (Math.random()<0.1?(Math.random()-0.5)*4:0), CANVAS_H/2);\n"
    "  ctx.font = '5px monospace';\n"
    "  ctx.fillStyle = '#94a3b8';\n"
    "  ctx.fillText('PRESS R TO REBOUND MANUALLY', CANVAS_W/2, CANVAS_H/2 + 12);\n"
    "  ctx.restore();\n"
    "  failAlpha -= 0.015;\n"
    "}"
)

NEW_FUNC = (
    "function drawFailMsg() {\n"
    "  if (failAlpha <= 0) return;\n"
    "  const alpha = Math.min(1, failAlpha);\n"
    "  ctx.save();\n"
    "  ctx.globalAlpha = alpha;\n"
    "\n"
    "  // Hamster meme on ~40% of failures\n"
    "  if (hamsterReady && (attempts % 3 === 0 || attempts % 7 === 0)) {\n"
    "    const iw = 80, ih = 72;\n"
    "    const ix = CANVAS_W/2 - iw/2;\n"
    "    const iy = CANVAS_H/2 - ih - 16;\n"
    "    ctx.drawImage(hamsterImg, ix, iy, iw, ih);\n"
    "    const captions = ['GG', 'BONK', 'COPIUM', 'SKILL ISSUE', 'F'];\n"
    "    ctx.font = 'bold 8px monospace';\n"
    "    ctx.fillStyle = '#facc15';\n"
    "    ctx.textAlign = 'center';\n"
    "    ctx.fillText(captions[attempts % captions.length], CANVAS_W/2, iy - 3);\n"
    "  }\n"
    "\n"
    "  ctx.font = '12px monospace';\n"
    "  ctx.textAlign = 'center';\n"
    "  ctx.fillStyle = COL_FAIL;\n"
    "  ctx.fillText(failMsg, CANVAS_W/2 + (Math.random()<0.1?(Math.random()-0.5)*4:0), CANVAS_H/2);\n"
    "  ctx.font = '5px monospace';\n"
    "  ctx.fillStyle = '#94a3b8';\n"
    "  ctx.fillText('PRESS R TO REBOUND MANUALLY', CANVAS_W/2, CANVAS_H/2 + 12);\n"
    "  ctx.restore();\n"
    "  failAlpha -= 0.015;\n"
    "}"
)

# Normalize line endings for matching
html_norm = html.replace('\r\n', '\n')
old_norm  = OLD_FUNC.replace('\r\n', '\n')

if old_norm in html_norm:
    html_norm = html_norm.replace(old_norm, NEW_FUNC, 1)
    print("Replaced drawFailMsg successfully")
else:
    print("WARNING: exact drawFailMsg pattern not found — trying regex replace")
    pattern = r'function drawFailMsg\(\) \{.*?failAlpha -= 0\.015;\n\}'
    html_norm, n = re.subn(pattern, NEW_FUNC, html_norm, count=1, flags=re.DOTALL)
    print(f"Regex replacements: {n}")

with open(HTML_PATH, 'w', encoding='utf-8', newline='\n') as f:
    f.write(html_norm)
print(f"Saved {HTML_PATH} ({len(html_norm):,} chars)")
