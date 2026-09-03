#!/usr/bin/env ruby
# Golden file tests for the Scala grammar: each input/*.scala is run through
# gtm, TextMate's grammar test tool, and its scoped output has to match
# output/*.output line for line.
#
#   ruby Support/tests/run_tests.rb              # compare
#   ruby Support/tests/run_tests.rb --regenerate # rewrite the goldens from the current grammar
#
# gtm is found through the GTM environment variable, then PATH, then inside the
# TextMate application. Continuous integration downloads it from the
# application repository's gtm prerelease.

tests_dir = File.expand_path(__dir__)
grammar   = File.expand_path("../../Syntaxes/Scala.tmLanguage", tests_dir)

candidates  = [ENV["GTM"]].compact
candidates += ENV.fetch("PATH", "").split(":").map { |dir| File.join(dir, "gtm") }
candidates << File.join(ENV["TM_APP_PATH"], "Contents/MacOS/gtm") if ENV["TM_APP_PATH"]
candidates << "/Applications/TextMate.app/Contents/MacOS/gtm"
gtm = candidates.find { |path| File.executable?(path) }
abort "gtm not found: set GTM, put it on PATH, or install TextMate" unless gtm

regenerate = ARGV.include?("--regenerate")
failures = 0

Dir[File.join(tests_dir, "input", "*.scala")].sort.each do |input|
  name   = File.basename(input, ".scala")
  golden = File.join(tests_dir, "output", "#{name}.output")
  actual = IO.popen([gtm, grammar], "r+") { |io| io.write(File.read(input)); io.close_write; io.read }

  if regenerate
    File.write(golden, actual)
    puts "#{name}: regenerated"
    next
  end

  expected = File.exist?(golden) ? File.read(golden) : nil
  if actual == expected
    puts "#{name}: ok"
  else
    failures += 1
    puts "#{name}: FAILED"
    if expected
      actual.lines.zip(expected.lines).each_with_index do |(a, e), i|
        puts "  line #{i + 1}:\n    got      #{a.to_s.chomp}\n    expected #{e.to_s.chomp}" if a != e
      end
    end
  end
end

exit(failures.zero? ? 0 : 1)
