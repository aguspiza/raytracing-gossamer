#!/usr/bin/env bash
# Checks that ray.tga is byte-identical to the image raytracing-nim (optimized),
# raytracing-goose and raytracing-bend2 write, at 1 and 4 samples per pixel.
set -euo pipefail
cd "$(dirname "$0")"
gos build --release >/dev/null
bin=target/release/raytracing-gossamer

expect() {
  local got
  got=$(sha256sum ray.tga | cut -d' ' -f1)
  if [[ $got == "$1" ]]; then echo "ok   $2"; else echo "FAIL $2"; fail=1; fi
}

fail=0
"$bin" 1 >/dev/null
expect b5fac3add377b40d3be30b5faf42446996ad6ff0e6438455323400c991cae5fe "1 spp"
"$bin" 4 >/dev/null
expect 0ebc7bc784ecd46fd0034b1fb26c51fc1842aa085eab967d6a8e06fef7d37f00 "4 spp"
exit $fail
