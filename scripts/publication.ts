import { mkdtemp, readFile, readdir, rm, stat, writeFile } from "node:fs/promises";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { createHash } from "node:crypto";
import TurndownService from "turndown";
import { gfm } from "turndown-plugin-gfm";

const ROOT = process.cwd();
const PAPER = "paper/main.typ";
const FONTS = "paper/components/fonts";
const PDF = "ODBORNA_PRACE.pdf";
const MARKDOWN = "README.md";
const IMAGE_DIR = "paper/components/img";
const METADATA = "paper/components/metadata.typ";

async function run(command: string[]) {
  const child = Bun.spawn(command, { cwd: ROOT, stdout: "inherit", stderr: "inherit" });
  const exitCode = await child.exited;
  if (exitCode !== 0) throw new Error(`command failed (${exitCode}): ${command.join(" ")}`);
}

function digest(buffer: Uint8Array) {
  return createHash("sha256").update(buffer).digest("hex");
}

// Typst HTML export embeds every illustration as base64. Link the exact original
// bytes instead, keeping the compiled README small and images sourced from paper/.
async function relinkImages(markdown: string) {
  const images = new Map<string, string>();
  for (const filename of await readdir(IMAGE_DIR)) {
    const path = join(IMAGE_DIR, filename);
    const info = await stat(path);
    if (!info.isFile()) continue;
    images.set(digest(await readFile(path)), path.split("\\").join("/"));
  }
  let count = 0;
  const result = markdown.replace(/!\[([^\]]*)\]\(data:image\/[^;]+;base64,([a-zA-Z0-9+/=]+)\)/g, (_match, alt: string, base64: string) => {
    const file = images.get(digest(Buffer.from(base64, "base64")));
    if (!file) throw new Error("HTML exporter emitted an illustration not matching paper/components/img");
    count++;
    return `![${alt}](${file})`;
  });
  if (count < 5) throw new Error("Unexpectedly few images recovered from canonical paper");
  return result;
}

async function publicationHeader() {
  const source = await readFile(METADATA, "utf8");
  const field = (key: string) => {
    const match = source.match(new RegExp(`^\\s*${key}:\\s*"([^"]+)"`, "m"));
    if (!match) throw new Error("Missing paper metadata field: " + key);
    return match[1];
  };
  const year = source.match(/^\s*year:\s*(\d{4})/m)?.[1];
  if (!year) throw new Error("Missing paper metadata field: year");
  return `# ${field("title")}\n\n**${field("subtitle")}**\n\n${field("school")} · ${field("author")} · ${year}\n\n`;
}

async function validatePublication() {
  const pdf = await Bun.file(PDF).arrayBuffer();
  if (new TextDecoder().decode(pdf.slice(0, 5)) !== "%PDF-") {
    throw new Error("Typst output is not a PDF: " + PDF);
  }
  const markdown = await readFile(MARKDOWN, "utf8");
  if (markdown.trim().length < 10000 ||
    !markdown.includes("# Agentické inženýrství ve vývoji softwaru") ||
    !markdown.includes("DarkFactory") ||
    markdown.includes("data:image/")) {
    throw new Error("README.md does not contain complete canonical paper text/assets");
  }
}

await stat(PAPER);
await run(["typst", "compile", "--font-path", FONTS, PAPER, PDF]);
const temp = await mkdtemp(join(tmpdir(), "odbornaprace-"));
try {
  const htmlPath = join(temp, "publication.html");
  await run(["typst", "compile", "--features", "html", "--format", "html", "--font-path", FONTS, PAPER, htmlPath]);
  const html = await readFile(htmlPath, "utf8");
  const body = html.match(/<body[^>]*>([\s\S]*?)<\/body>/i)?.[1] ?? html;
  const turndown = new TurndownService({
    headingStyle: "atx",
    bulletListMarker: "-",
    codeBlockStyle: "fenced",
  });
  turndown.use(gfm);
  turndown.keep(["math", "svg", "sup", "sub"]);
  const derived = turndown.turndown(body).trim();
  const markdown = await relinkImages(derived);
  await writeFile(MARKDOWN, (await publicationHeader()) + markdown + "\n", "utf8");
} finally {
  await rm(temp, { recursive: true, force: true });
}
await validatePublication();
console.log("ok: paper/main.typ -> ODBORNA_PRACE.pdf + README.md (with linked source figures)");
