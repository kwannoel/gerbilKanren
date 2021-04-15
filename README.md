# GbKanren

MicroKanren in Gerbil Scheme.

# Prerequisites

See `shell.nix`.

# Sanity

1. Compiling `hello-world.scm`

    ``` sh
    nix-shell
    make hello-world
    ```

1. Running `hello-world`

    ``` scm
    > (import :hello-world)
    > (hello "world")
    hello world
    ```

# Further exploration

- Examine algorithm synthesis. See the following papers:

  1. https://core.ac.uk/download/pdf/82068652.pdf
  1. https://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.56.5579&rep=rep1&type=pdf
  1. https://arxiv.org/pdf/1909.01747.pdf
