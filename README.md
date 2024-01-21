# Blog

My personal blog at <https://k-mack.gitlab.io/blog/>.
Thanks for [Porkbun](https://porkbun.com/), the site is also at <https://kevinmacksa.me/>.

## Cloning

This repository has submodules, so cloning the project is most easily done with the command below:

```bash
git clone --recurse-submodules git@gitlab.com:k-mack/blog.git
```

## Updating the Submodules

Update the repository's submodules by running the following command:

```bash
git submodule update --remote
```

## Nix

Hop into a development shell with everything you shell:

```bash
nix develop
```
