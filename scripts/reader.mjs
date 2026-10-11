import { getDocument, GlobalWorkerOptions, TextLayer } from "./pdfjs/pdf.mjs";

const pdfUrl = "./ODBORNA_PRACE.pdf";
GlobalWorkerOptions.workerSrc = new URL("./pdfjs/pdf.worker.mjs", import.meta.url).href;

const viewport = document.getElementById("viewport");
const pages = document.getElementById("pages");
const status = document.getElementById("status");
const currentInput = document.getElementById("current-page");
const countOutput = document.getElementById("page-count");
const previous = document.getElementById("previous");
const next = document.getElementById("next");
const zoomOut = document.getElementById("zoom-out");
const zoomIn = document.getElementById("zoom-in");
const zoomDisplay = document.getElementById("zoom-display");

let pdf = null;
let baseWidth = 595;
let baseHeight = 842;
let zoom = 1;
let current = 1;
let generation = 0;
let observer;
const shells = [];
const rendered = new Set();
const rendering = new Set();

function setStatus(message) { status.textContent = message; }

function updateNavigation() {
  currentInput.value = String(current);
  previous.disabled = current <= 1;
  next.disabled = !pdf || current >= pdf.numPages;
  zoomOut.disabled = zoom <= 0.55;
  zoomIn.disabled = zoom >= 2.5;
  zoomDisplay.textContent = Math.round(zoom * 100) + "%";
}

function displayScale() {
  // Default to the width of the reader; users can zoom in from there.
  const fit = Math.min(1.6, Math.max(0.3, (viewport.clientWidth - 30) / baseWidth));
  return fit * zoom;
}

function buildPlaceholders() {
  generation += 1;
  const scale = displayScale();
  const active = current;
  rendered.clear();
  rendering.clear();
  if (observer) observer.disconnect();
  pages.replaceChildren();
  shells.length = 0;
  for (let n = 1; n <= pdf.numPages; n++) {
    const shell = document.createElement("section");
    shell.className = "page-shell";
    shell.dataset.page = String(n);
    shell.setAttribute("aria-label", "Strana " + n + " z " + pdf.numPages);
    shell.style.width = Math.round(baseWidth * scale) + "px";
    shell.style.height = Math.round(baseHeight * scale) + "px";
    pages.append(shell);
    shells.push(shell);
  }
  observer = new IntersectionObserver((entries) => {
    for (const entry of entries) {
      if (entry.isIntersecting) void renderPage(Number(entry.target.dataset.page), generation);
    }
    updateVisiblePage();
  }, {root:viewport, rootMargin:"450px 0px", threshold:0});
  for (const shell of shells) observer.observe(shell);
  updateNavigation();
  // Preserve position on a zoom change.
  if (active > 1) requestAnimationFrame(() => goToPage(active));
}

async function renderPage(pageNumber, version) {
  if (!pdf || rendered.has(pageNumber) || rendering.has(pageNumber)) return;
  rendering.add(pageNumber);
  try {
    const page = await pdf.getPage(pageNumber);
    if (version !== generation) return;
    const pageViewport = page.getViewport({scale:displayScale()});
    const shell = shells[pageNumber - 1];
    if (!shell) return;

    // Pixel density affects sharpness, not the CSS/scroll dimensions.
    const dpr = Math.min(window.devicePixelRatio || 1, 2);
    const canvas = document.createElement("canvas");
    canvas.setAttribute("aria-hidden", "true");
    canvas.width = Math.ceil(pageViewport.width * dpr);
    canvas.height = Math.ceil(pageViewport.height * dpr);
    canvas.style.width = "100%";
    canvas.style.height = "100%";
    const context = canvas.getContext("2d", {alpha:false});
    if (!context) throw new Error("Canvas 2D is unavailable");
    const task = page.render({
      canvasContext:context,
      canvas,
      viewport:pageViewport,
      transform: dpr === 1 ? undefined : [dpr,0,0,dpr,0,0]
    });
    await task.promise;
    if (version !== generation) return;
    shell.replaceChildren(canvas);
    rendered.add(pageNumber);
    // The transparent text layer enables text selection and copy.
    try {
      const textContainer = document.createElement("div");
      textContainer.className = "textLayer";
      textContainer.style.setProperty("--total-scale-factor", String(pageViewport.scale));
      shell.append(textContainer);
      const text = new TextLayer({
        textContentSource: page.streamTextContent(),
        container:textContainer,
        viewport:pageViewport
      });
      await text.render();
    } catch (error) {
      console.warn("The PDF page rendered, but its selectable text layer did not:",error);
    }
  } catch (error) {
    console.error("PDF page render failed:", pageNumber, error);
    if (version === generation) {
      const shell = shells[pageNumber - 1];
      if (shell) shell.textContent = "Stranu " + pageNumber + " nelze vykreslit.";
    }
  } finally {
    rendering.delete(pageNumber);
  }
}

function updateVisiblePage() {
  if (!pdf) return;
  const top = viewport.getBoundingClientRect().top;
  let best = 1, distance = Infinity;
  for (let i=0; i<shells.length; i++) {
    const rect = shells[i].getBoundingClientRect();
    const d = rect.bottom < top ? top - rect.bottom + 10000 : Math.abs(rect.top - top - 10);
    if (d < distance) { distance = d; best = i + 1; }
  }
  if (best !== current) { current = best; updateNavigation(); }
}

function goToPage(number) {
  if (!pdf) return;
  current = Math.max(1, Math.min(pdf.numPages, Math.round(number)));
  shells[current-1]?.scrollIntoView({block:"start", behavior:"instant"});
  updateNavigation();
}

function changeZoom(multiplier) {
  const target = Math.max(0.55, Math.min(2.5, Math.round(zoom * multiplier * 100) / 100));
  if (target === zoom) return;
  zoom = target;
  buildPlaceholders();
}

previous.addEventListener("click", () => goToPage(current - 1));
next.addEventListener("click", () => goToPage(current + 1));
currentInput.addEventListener("change", () => goToPage(Number(currentInput.value) || 1));
zoomOut.addEventListener("click", () => changeZoom(0.8));
zoomIn.addEventListener("click", () => changeZoom(1.25));
viewport.addEventListener("scroll", () => requestAnimationFrame(updateVisiblePage), {passive:true});
window.addEventListener("keydown", event => {
  if (event.target instanceof HTMLInputElement || event.target instanceof HTMLSelectElement) return;
  if (event.key === "PageDown") { event.preventDefault(); goToPage(current+1); }
  if (event.key === "PageUp") { event.preventDefault(); goToPage(current-1); }
});
let resizeTimer;
window.addEventListener("resize", () => {
  clearTimeout(resizeTimer);
  resizeTimer = setTimeout(() => { if(pdf) buildPlaceholders(); }, 180);
});

try {
  setStatus("Načítání odborné práce…");
  const loading = getDocument({
    url:pdfUrl,
    cMapUrl:"./pdfjs/cmaps/",
    cMapPacked:true,
    standardFontDataUrl:"./pdfjs/standard_fonts/",
  });
  pdf = await loading.promise;
  const sample = await pdf.getPage(1);
  const pageViewport = sample.getViewport({scale:1});
  baseWidth=pageViewport.width;
  baseHeight=pageViewport.height;
  countOutput.textContent = "/ " + pdf.numPages;
  setStatus("");
  buildPlaceholders();
  goToPage(1);
} catch (error) {
  console.error("Cannot open PDF with PDF.js", error);
  pages.replaceChildren();
  status.innerHTML = '<div class="fatal"><strong>Dokument se nepodařilo zobrazit.</strong><p>PDF nelze v tomto prohlížeči vykreslit. Můžete jej otevřít či stáhnout přímo:</p><a href="./ODBORNA_PRACE.pdf">Otevřít PDF</a></div>';
}
