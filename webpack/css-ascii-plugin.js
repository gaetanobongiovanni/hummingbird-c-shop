/**
 * C-Shop: keep the built CSS pure ASCII.
 *
 * The minifier turns escapes such as content: "\e313" (Material Icons glyphs)
 * into raw UTF-8 characters. PrestaShop's CCC concatenates the theme CSS into
 * assets/cache/*.css and the server sends it without a charset, so browsers
 * read it as Windows-1252: the menu arrows showed up as "îŒ“".
 * This plugin re-escapes every non-ASCII character as a CSS escape after
 * minification, so the encoding no longer matters.
 */
const { Compilation, sources } = require('webpack');

const escapeNonAscii = (css) => css.replace(/[^\x00-\x7f]/gu, (ch) => `\\${ch.codePointAt(0).toString(16)} `);

class CssAsciiPlugin {
  apply(compiler) {
    compiler.hooks.thisCompilation.tap('CssAsciiPlugin', (compilation) => {
      compilation.hooks.processAssets.tap(
        { name: 'CssAsciiPlugin', stage: Compilation.PROCESS_ASSETS_STAGE_OPTIMIZE_SIZE + 1 },
        (assets) => {
          Object.keys(assets)
            .filter((name) => name.endsWith('.css'))
            .forEach((name) => {
              const css = assets[name].source().toString();
              const ascii = escapeNonAscii(css);
              if (ascii !== css) {
                compilation.updateAsset(name, new sources.RawSource(ascii));
              }
            });
        },
      );
    });
  }
}

module.exports = { CssAsciiPlugin, escapeNonAscii };
