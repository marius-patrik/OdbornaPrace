import { cp, mkdir, rm, stat, writeFile } from "node:fs/promises";
import { join } from "node:path";

// The public Pages PDF must be fetched from the RELEASE ASSET, not from
// a potentially newer (or older) checked-in/generated workspace artifact.
const tag = process.env.PAPER_RELEASE_TAG ?? "";
if (!/^[a-zA-Z0-9._-]+$/.test(tag)) {
  throw new Error("PAPER_RELEASE_TAG is required and must be a GitHub release tag");
}
const pdf = join("release-artifacts", "ODBORNA_PRACE.pdf");
const info = await stat(pdf).catch(() => null);
if (!info?.isFile() || info.size < 1024) throw new Error("missing released PDF: " + pdf);
const site = "site";
await rm(site, { recursive: true, force: true });
await mkdir(site, { recursive: true });
await cp(pdf, join(site, "ODBORNA_PRACE.pdf"));
const releaseURL = `https://github.com/marius-patrik/OdbornaPrace/releases/tag/${tag}`;
const document = `<!doctype html>
<html lang="cs">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="color-scheme" content="light">
  <title>Odborná práce — Agentické inženýrství ve vývoji softwaru</title>
  <meta name="description" content="Agentické inženýrství ve vývoji softwaru: Návrh a implementace DarkFactory. Publikované vydání odborné práce.">
  <style>
    :root { font-family: system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif; color:#20232a; background:#f0f1f3; }
    * { box-sizing:border-box; }
    body { margin:0; min-height:100vh; display:flex; flex-direction:column; }
    header { background:#fff; border-bottom:1px solid #d8dce1; padding:13px clamp(15px,3vw,40px); display:flex; align-items:center; flex-wrap:wrap; justify-content:space-between; gap:12px; }
    .title { font-size:15px; font-weight:650; margin:0 0 3px; }
    .subtitle { font-size:12px; color:#626974; }
    nav { display:flex; align-items:center; flex-wrap:wrap; gap:9px 16px; font-size:13px; }
    a { color:#1358ab; text-decoration:none; }
    a:hover { text-decoration:underline; }
    main { flex:1; min-height:calc(100vh - 80px); display:flex; padding:12px; }
    iframe { width:100%; min-height:80vh; flex:1; border:1px solid #d8dce1; border-radius:6px; background:white; }
    @media (max-width:600px) { main { padding:0; } iframe { border:0; border-radius:0; } }
  </style>
</head>
<body>
  <header>
    <div><div class="title">Agentické inženýrství ve vývoji softwaru</div><div class="subtitle">Návrh a implementace DarkFactory · vydání ${tag}</div></div>
    <nav>
      <a href="./ODBORNA_PRACE.pdf" download>Stáhnout PDF</a>
      <a href="${releaseURL}">Vydání na GitHubu</a>
      <a href="https://github.com/marius-patrik/OdbornaPrace">Zdrojové soubory</a>
      <a href="https://github.com/marius-patrik/GHCode">GHCode</a>
    </nav>
  </header>
  <main>
    <iframe src="./ODBORNA_PRACE.pdf#view=FitH" title="Publikované PDF odborné práce">
      <p>V prohlížeči nelze zobrazit PDF. <a href="./ODBORNA_PRACE.pdf">Otevřít PDF</a>.</p>
    </iframe>
  </main>
</body>
</html>
`;
await writeFile(join(site,"index.html"),document,"utf8");
console.log(`ok: publication site embeds release asset ${tag}`);
