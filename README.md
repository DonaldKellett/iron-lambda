# iron-lambda

My copy of (possibly modified portions of) [Iron Lambda](https://github.com/discus-lang/iron) by [Ben Lippmeier](https://github.com/benl23x5) _with the explicit aim of making it easier to step through the proofs interactively using CoqIDE_. Specifically, the files are taken from [commit `8407013900c5f274014ee12e967752d30dde996a`](https://github.com/discus-lang/iron/commit/8407013900c5f274014ee12e967752d30dde996a) in the original repo.

## Build Instructions

To build and step through the files in this version of Iron Lambda, you will need Coq 8.6 and probably also CoqIDE 8.6. This repo has only been tested in macOS Catalina 10.15.2 so it is not guaranteed to work on other OSes or even other versions of macOS. Furthermore, build instructions are currently only available for [`opam`](https://opam.ocaml.org).

It is highly likely that the current Coq version you are using (if you already have one) is much newer than Coq 8.6 (similar for CoqIDE). In that case, if you do not want to downgrade your Coq version globally, you can create a local [switch](https://opam.ocaml.org/doc/man/opam-switch.html) in your copy of this repo and install Coq 8.6 + CoqIDE 8.6 there as follows:

```bash
$ opam switch create /path/to/your/iron-lambda/ 4.05.0 # Create local switch and install OCaml 4.05.0 there
$ cd /path/to/your/iron-lambda/
$ opam switch show # should print "/path/to/your/iron-lambda/"; if not, do NOT proceed
$ opam pin add coq 8.6 # Pin Coq to 8.6 in local switch only
$ opam pin add coqide 8.6 # Pin CoqIDE to 8.6 in local switch only
```

After having the correct versions of Coq and CoqIDE installed, execute the following (while in `/path/to/your/iron-lambda/`):

```bash
$ coq_makefile -f _CoqProject -o Makefile # Create Makefile from _CoqProject
$ make
```

`make` should succeed (perhaps with a few warnings) and you should now be able to step through the vernacular files in this repo interactively using CoqIDE 8.6. If not then feel free to open an issue.

## Lambda Calculi

### Simple

Simply Typed Lambda Calculus (STLC). "Simple" here refers to the lack of polymorphism.

## LICENSE

See [LICENSE](./blob/master/LICENSE) (copied from https://github.com/discus-lang/iron/blob/master/LICENSE)
