const { escapeNonAscii } = require('../css-ascii-plugin');

describe('escapeNonAscii', () => {
  it('escapes Material Icons glyphs so the CSS survives a Windows-1252 decode', () => {
    expect(escapeNonAscii('.x:after{content:""}')).toBe('.x:after{content:"\\e313 "}');
  });

  it('escapes typographic characters and leaves ASCII untouched', () => {
    expect(escapeNonAscii('a{content:"— x"}')).toBe('a{content:"\\2014  x"}');
    expect(escapeNonAscii('a{color:red}')).toBe('a{color:red}');
  });

  it('handles characters outside the BMP as one code point', () => {
    expect(escapeNonAscii('\u{1F600}')).toBe('\\1f600 ');
  });
});
