(lang dune 3.16)
(name chronio)
(generate_opam_files true)

(authors "Dhairya Sharma")
(maintainers "Dhairya Sharma")
(license Apache-2.0)

(package
 (name chronio)
 (synopsis "ChronIO 4-Lane Barrel Timed-I/O Protocol Emulator ASIC Generator in Hardcaml")
 (depends
  (ocaml (>= 5.1.0))
  dune
  base
  stdio
  hardcaml
  hardcaml_waveterm
  ppx_hardcaml
  ppx_jane
  ppx_expect))
