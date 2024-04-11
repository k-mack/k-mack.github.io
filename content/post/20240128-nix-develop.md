---
title: "Overriding buildGoModule"
date: 2024-01-28T10:27:00-08:00
tags: ["nix"]
---

I used Nix flakes to customize the version of Hugo for a development shell.
I didn't realize I was going to have to override Nix's built-in `buildGoModule` function.

<!--more-->

I've [been]({{< relref "20231230-nixos-init.md" >}}) [learning]({{< relref "20240111-nix-shell.md" >}}) Nix for about a month,
and it's been an interesting experience.
Despite all the documentation surrounding Nix,
I've found I learn the most by looking at the Nix codebase or other people's flakes on GitHub.

After learning how to use `nix shell` to drop into a development environment for this blog,
the next logical step seemed to write a flake that codified this and would allow me to simply type `nix develop`.
`nix shell` solved the initial problem for me, but it installs whatever version of Hugo is found in the `nixpkgs-unstable` branch.
I want to always install the same version of Hugo as the one I use for CI to create the blog before it is published.

The Hugo package in Nix is derived using `buildGoModule`, which makes sense since Hugo is Go application.
All I needed to do was to tweak the version and `fetchFromGitHub` attributes within the function.

My initial attempt at this was to use
[overrideAttrs](https://ryantm.github.io/nixpkgs/using/overrides/#sec-pkg-overrideAttrs).
I wasn't able to get this to work,
and I think it was because `buildGoModule` is more than `mkDerivation`,
which is what `overrideAttrs` modifies.
Instead, I used an
[overlay](https://nixos-and-flakes.thiscute.world/nixpkgs/overlays)
to
[override](https://ryantm.github.io/nixpkgs/using/overrides/#sec-pkg-override)
Hugo's arguments,
and Hugo's only argument is the `buildGoModule` function.
It feels kind of crazy, but it works!

Below is the full flake for my blog.
The highlighted lines say it all :).

```nix {linenos=table,hl_lines=["13-54"]}
{
  description = "My blog";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          overlays = [
            # Override Hugo's package to use the version used by the blog. Note:
            # using whatever version is provided by `nixpkgs` would probably be
            # fine, but I'm doing this to learn about nix and flakes :).
            #
            # `final` is the result of the fix point calculation. Use it to
            # access packages that could be modified somewhere else in the
            # overlay stack. `prev` is one overlay down in the stack (and base
            # nixpkgs for the first overlay). Use it to access the package
            # recipes you want to customize and for library functions. 
            (final: prev: {
              hugo = prev.hugo.override {
                # The Hugo package is built using the built-in function
                # `buildGoModule`. We need to override it to update the version
                # of Hugo. We do this by overriding the `buildGoModule` function
                # used by the package derivation with a function that calls the
                # built-in `buildGoModule` with the output of a lambda function
                # that returns the previous args updated with some new values.
                # *dizzy*
                #
                # Therefore, when hugo's `buildGoModule` is called with its
                # currently defined attribute set, we intercept it and update
                # its attribute set before calling `buildGoModule`.
                #
                # This is crazy, but it works.
                buildGoModule = previousArgs: prev.buildGoModule (previousArgs // rec {
                  version = "0.121.2";

                  # `fetchFromGitHub` is a built-in function, hence `prev` is
                  # used to access it
                  src = prev.fetchFromGitHub {
                    owner = "gohugoio";
                    repo = "hugo";
                    rev = "refs/tags/v${version}";
                    # Leave blank, run `nix develop`, and use the correct hash
                    # from the resulting error message.
                    hash = "sha256-YwwvxkS+oqTMZzwq6iiB/0vLHIyeReQi76B7fCgqtcY=";
                    };
                });
              };
            })
          ];
          pkgs = import nixpkgs {
            inherit system overlays;
          };
        in
        with pkgs;
        {
          devShells.default = mkShell {
          packages = [
            brotli
            gzip
            hugo
            ];
          };
        }
      );
}
```

_Fin_.
