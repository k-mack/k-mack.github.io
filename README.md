# Blog

My personal blog at <https://k-mack.gitlab.io/blog/>.

## Cloning

This repository has a submodule to control the blog's theme, so cloning the project is most easily done with the command below:

```bash
git clone --recurse-submodules git@gitlab.com:k-mack/blog.git
```

## Updating the Theme

The blog's theme is integrated into the repository as a submodule.
To update the theme's repository, run the following command from the root directory:

```bash
git submodule update --remote
```
