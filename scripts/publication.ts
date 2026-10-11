import { mkdtemp, readFile, rm, stat, writeFile } from "node:fs/promises";
import { join } from "node:path";
import { tmpdir } from "node:os";
import TurndownService from "turndown";
import { gfm } from "turndown-plugin-gfm";

// Both publication formats MUST be rendered from the same canonical Typst entrypoint.
// Do not compile the retired top-level index.typ.
const ROOT = process.cwd();
const PAPER = "paper/main.typ";
const FONTS = "paper/components/fonts";
const PDF = "ODBORNA_PRACE.pdf";
const MARKDOWN = "README.md";

async function run(command: string[]) {
  const child = Bun.spawn(command, { cwd: ROOT, stdout: "inherit", stderr: "inherit" });
  const exitCode = await child.exited;
  if (exitCode !== 0) throw new Error(`command failed (${exitCode}): ${command.join(" ")}`);
}

async function validatePublication() {
  const pdf = await Bun.file(PDF).arrayBuffer();
  if (new TextDecoder().decode(pdf.slice(0, 5)) !== "%PDF-") {
    throw new Error("Typst output is not a PDF: " + PDF);
  }
  const markdown = await readFile(MARKDOWN, "utf8");
  if (markdown.trim().length < 256 || !markdown.includes("Agentické inženýrství ve vývoji softwaru")) {
    throw new Error("README.md does not contain the current paper title");
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
  await writeFile(MARKDOWN, turndown.turndown(body).trim() + "\n", "utf8");
} finally {
  await rm(temp, { recursive: true, force: true });
}
await validatePublication();
console.log("ok: paper/main.typ -> ODBORNA_PRACE.pdf + README.md");
