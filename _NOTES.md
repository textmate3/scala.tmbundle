# Notes on the test suite

`Support/tests/run_tests.rb` is a golden file grammar test. Each `input/*.scala` is run through `gtm`, TextMate's grammar test tool, against `Syntaxes/Scala.tmLanguage`, and the scoped output has to match `output/*.output` exactly. `--regenerate` rewrites the goldens from the current grammar, which is the step to take, and to review by eye, after any deliberate grammar change.

The tool comes from the application: `GTM` in the environment, then `PATH`, then `Contents/MacOS/gtm` inside TextMate. Continuous integration downloads it from the `gtm` prerelease on the application repository, which the application's own workflow uploads on every push to `main`.
