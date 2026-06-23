// Tiny markdown renderer — enough for our content. Not a general parser.
// Supports: # / ## / ### headings, > blockquotes, - / * lists, **bold**, *italic*, `code`, paragraphs.

const escape = (s: string) =>
  s
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');

function inline(s: string): string {
  return s
    .replace(/`([^`]+)`/g, '<code class="rounded bg-paper-warm px-1.5 py-0.5 font-mono text-[0.9em]">$1</code>')
    .replace(/\*\*([^*]+)\*\*/g, '<strong class="font-semibold">$1</strong>')
    .replace(/(^|[^*])\*([^*]+)\*/g, '$1<em class="italic">$2</em>');
}

export function renderMarkdown(input: string): string {
  const lines = input.replace(/\r\n/g, '\n').split('\n');
  const out: string[] = [];
  let para: string[] = [];
  let list: string[] | null = null;
  let quote: string[] | null = null;

  const flushPara = () => {
    if (para.length) {
      out.push(`<p class="my-5 leading-relaxed text-ink-soft">${inline(escape(para.join(' ')))}</p>`);
      para = [];
    }
  };
  const flushList = () => {
    if (list) {
      out.push(
        `<ul class="my-5 list-disc space-y-2 pl-6 text-ink-soft">${list
          .map((li) => `<li class="leading-relaxed">${inline(escape(li))}</li>`)
          .join('')}</ul>`,
      );
      list = null;
    }
  };
  const flushQuote = () => {
    if (quote) {
      out.push(
        `<blockquote class="my-6 border-l-4 border-accent bg-paper-warm/60 px-5 py-4 font-display text-lg italic text-ink">${inline(
          escape(quote.join(' ')),
        )}</blockquote>`,
      );
      quote = null;
    }
  };
  const flushAll = () => { flushPara(); flushList(); flushQuote(); };

  for (const raw of lines) {
    const line = raw.trimEnd();
    if (!line.trim()) { flushAll(); continue; }

    if (line.startsWith('### ')) { flushAll(); out.push(`<h3 class="mt-8 mb-3 font-display text-xl text-ink">${inline(escape(line.slice(4)))}</h3>`); continue; }
    if (line.startsWith('## ')) { flushAll(); out.push(`<h2 class="mt-10 mb-4 font-display text-2xl text-ink">${inline(escape(line.slice(3)))}</h2>`); continue; }
    if (line.startsWith('# ')) { flushAll(); out.push(`<h1 class="mt-12 mb-5 font-display text-3xl text-ink">${inline(escape(line.slice(2)))}</h1>`); continue; }
    if (line.startsWith('> ')) { flushPara(); flushList(); quote = quote || []; quote.push(line.slice(2)); continue; }
    if (line.startsWith('- ') || line.startsWith('* ')) { flushPara(); flushQuote(); list = list || []; list.push(line.slice(2)); continue; }
    if (/^\d+\.\s/.test(line)) { flushPara(); flushQuote(); list = list || []; list.push(line.replace(/^\d+\.\s/, '')); continue; }
    para.push(line);
  }
  flushAll();
  return out.join('\n');
}
