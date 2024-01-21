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
		# used by the package derivation to a function that calls the
		# built-in `buildGoModule` with the output of a lambda function
		# that returns the previous args updated with some new values.
		# *dizzy*
		#
		# Therefore, when hugo's `buildGoModule` is called with its
		# currently defined attribute set, we hijack it but updating the
		# attribute set before calling `buildGoModule`.
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
	    packages = [ hugo ];
	  };
	}
      );
}
