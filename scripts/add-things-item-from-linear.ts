#!/usr/bin/env -S /opt/homebrew/bin/deno run --allow-run

import { encodeUrl } from 'https://deno.land/x/encodeurl/mod.ts';
import { exec } from 'https://deno.land/x/exec/mod.ts';
import { readLines } from 'https://deno.land/std@0.202.0/io/mod.ts';

for await (const markdownLink of readLines(Deno.stdin)) {
  let [title, url] = markdownLink.split('](');
  title = title.replace('\\[', '[').replace('\\]', ']').split(' : ')[1];
  url = url.replace(url[url.length - 1], '').replace('https://', 'linear://');
  await exec(
    `open "things:///add?title=${title}&notes=${url}&when=today&show-quick-entry=true&list=FLX%20Websites"`
  );
}
