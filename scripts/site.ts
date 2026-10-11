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

const pdfjsRoot = join("node_modules", "pdfjs-dist");
const vendor = join(site, "pdfjs");
await mkdir(vendor, {recursive:true});
for (const file of ["build/pdf.mjs","build/pdf.worker.mjs"]) {
  const source = join(pdfjsRoot, file);
  const fileInfo = await stat(source).catch(() => null);
  if (!fileInfo?.isFile()) throw new Error("Missing bundled PDF.js renderer: "+source);
  await cp(source, join(vendor, file.split("/").pop()!));
}
for (const folder of ["cmaps","standard_fonts"]) {
  await cp(join(pdfjsRoot,folder), join(vendor,folder), {recursive:true});
}
await cp("scripts/reader.mjs",join(site,"reader.mjs"));
await cp("scripts/reader.css",join(site,"reader.css"));
const releaseURL = "https://github.com/marius-patrik/OdbornaPrace/releases/tag/" + tag;
const document = '<!doctype html>\n'
  + '<html lang="cs"><head><meta charset="utf-8">'
  + '<meta name="viewport" content="width=device-width, initial-scale=1">'
  + '<title>Odborná práce — Agentické inženýrství ve vývoji softwaru</title>'
  + '<meta name="description" content="Agentické inženýrství ve vývoji softwaru: Návrh a implementace DarkFactory.">'
  + '<link rel="stylesheet" href="./reader.css">'
  + '</head><body>'
  + '<header><div><div class="title">Agentické inženýrství ve vývoji softwaru</div>'
  + '<div class="subtitle">Návrh a implementace DarkFactory · vydání ' + tag + '</div></div>'
  + '<nav><a href="./ODBORNA_PRACE.pdf" download>Stáhnout PDF</a>'
  + '<a href="' + releaseURL + '">Vydání na GitHubu</a>'
  + '<a href="https://github.com/marius-patrik/OdbornaPrace">Zdrojové soubory</a>'
  + '<a href="https://github.com/marius-patrik/GHCode">GHCode</a></nav></header>'
  + '<div class="toolbar" role="toolbar" aria-label="Ovládání čtečky PDF">'
  + '<div class="pages-control">'
  + '<button id="previous" aria-label="Předchozí strana" disabled>‹</button>'
  + '<label for="current-page">Strana</label>'
  + '<input id="current-page" type="number" value="1" min="1" aria-label="Číslo strany">'
  + '<span class="page-count" id="page-count">/ …</span>'
  + '<button id="next" aria-label="Další strana" disabled>›</button></div>'
  + '<div class="zoom-control">'
  + '<button id="zoom-out" aria-label="Oddálit">−</button>'
  + '<span id="zoom-display" aria-live="polite">100%</span>'
  + '<button id="zoom-in" aria-label="Přiblížit">+</button></div></div>'
  + '<main id="viewport" aria-label="Čtečka odborné práce">'
  + '<div id="status" role="status">Načítání odborné práce…</div>'
  + '<div id="pages" aria-label="Stránky dokumentu"></div></main>'
  + '<script src="./reader.mjs" type="module"></script>'
  + '</body></html>\n';
await writeFile(join(site,"index.html"),document,"utf8");
console.log("ok: PDF.js reader assembled from release asset " + tag);
