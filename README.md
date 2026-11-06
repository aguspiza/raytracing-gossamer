# raytracing-gossamer

Ray Tracing in One Weekend in [Gossamer](https://github.com/gossamer-lang/gossamer),
ported from [raytracing-nim](https://github.com/aguspiza/raytracing-nim)
(branch `fix-threads-and-cross`).

![100 samples per pixel](ray.png)

```
gos test                                        # unit tests
gos build --release                             # native binary (needs LLVM 18-22: opt, llc)
./target/release/raytracing-gossamer --samples 100 --ppm   # writes ray.tga (and ray.ppm)
```

Rows render in parallel with `par_chunks_mut`; each row seeds its own random generator,
so the image is the same on every run.

## Layout

- `src/vec3.gos`: `Vec3` with operator impls (`+ - * / -v`).
- `src/random.gos`: a xorshift32 `Rng`. `std::math::rand::Rng` is native code, and
  `par_chunks_mut` only takes pure callbacks.
- `src/scene.gos`: rays, materials (an enum), spheres, `World`, camera.
- `src/image.gos`: TGA and PPM encoders.
- `src/main.gos`: the scene, the per-pixel color loop and the parallel render.

## Timing

1200x600, 100 samples per pixel, Ryzen 7 5700U (16 threads), Windows 11, gos 0.76.0:

| | time |
| --- | --- |
| Gossamer, `par_chunks_mut` | 63 s |
| Nim 2.2.10 `fix-threads-and-cross`, `--threads:on -d:release` | 112 s |

## Notes on gos 0.76

- A free function from another file (or `mod`) called inside a `par_*` callback is
  reported as impure (GT0090) even when it only does arithmetic. Methods are fine,
  so the hit search is `World::hit` rather than a free function.
- Dereferencing a `std::flag` value (`*samples`) inside the `par_chunks_mut` callback
  hangs the program; read it into a plain binding first.
- `random_in_sphere` and `random_in_disk` keep the Nim behaviour: they accept the
  points *outside* the unit ball.
