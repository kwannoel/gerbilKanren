# GbKanren

MicroKanren in Gerbil Scheme.

# Prerequisites

1. `nix`

# Sanity

`Setup hello-world lib`
``` sh
nix-shell
make hello-world
```

`scm repl`

``` scm
> (import :hello-world)
> (hello "world")
hello world
```
