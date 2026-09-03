# Notes from test suite modernization (2026-08-20)

Findings from evaluating this bundle's test suite.

## Result: the suite cannot run and no Ruby fix can change that

`Support/tests/run_tests.rb` is a golden-file grammar test: it pipes each file in `input/` through `./gtm` against `Syntaxes/Scala.tmLanguage` and compares the tokenized result line by line with the blessed files in `output/`. The concept is exactly right and it is the only grammar assertion suite in the whole bundle collection.

The problem is the harness. `Support/tests/gtm` is `GrammarTestMate`, a closed-source tool by Allan Odgaard that was distributed as a binary from `updates.textmate.org/gtm.bz2` (announced on the TextMate mailing list, thread "Unit Testing Grammars: GrammarTestMate"). The committed binary is a 32-bit Intel (i386) Mach-O executable. macOS dropped 32-bit support in 10.15, Apple Silicon never had it, and Rosetta 2 does not translate 32-bit code. The download URL is dead and no source was ever published.

Nothing was changed in this pass. The runner's portability problems (relative `./gtm` and fixture paths) are moot until a harness exists.

## What still has value

- The six `input/*.scala` fixtures and six `output/*.output` goldens are intact and meaningful. The golden format is TextMate's scope-tagged pseudo-XML, for example `<keyword.declaration.scala>class</keyword.declaration.scala>`.
- The dead binary is kept in place as documentation of the harness interface: `gtm < input/file.scala ../../Syntaxes/Scala.tmLanguage`, one grammar path argument, tokenized text on stdout.

## Paths to revival

1. **Build a GrammarTestMate replacement on the TextMate 2 source.** The format matches what TextMate generates for commands with input format XML: `ng::buffer_t::xml_substr` (`textmate/Frameworks/buffer/src/buffer.cc`) emits scope-tagged text for a buffer, and assigning the buffer a grammar from `Frameworks/parse` produces the scopes. A small command line tool wrapping those two pieces would replace `gtm` outright and could serve every bundle, not just this one.
2. **Adopt the VS Code ecosystem tooling** ([vscode-textmate](https://github.com/microsoft/vscode-textmate), [vscode-tmgrammar-test](https://github.com/PanAeon/vscode-tmgrammar-test)), which tokenizes with the same grammar format but brings a Node.js dependency and a different output shape, so the goldens would need regeneration.
