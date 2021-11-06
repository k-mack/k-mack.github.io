---
title: "Hugo and Content Types (RTM)"
date: 2020-11-07T15:00:00-08:00
tags: ["hugo"]
---

Hugo has not been the most intuitive thing for me to configure.
I have spent more time than I would like reading Beautiful Hugo's layouts to understand why the pages look the way they do.
However, this is the point of what I am doing here:
learning, writing, and sharing.

<!--more-->

As an example to my point above, I was puzzled why the header of my blog post pages included a short, center-aligned horizontal rule underneath the page title.

![Unwanted horizontal rule underneath post title](/blog/img/unwanted-beautifulhugo-post-header-horizontal-rule.png)

I followed Hugo's quick start guide to generate a new site and create a post.

```shell_session
$ hugo new site blog && cd blog
$ # initialize git repo, add Beautiful Hugo and configure theme in config.toml
$ hugo new posts/my-first-post.md
```

What did I do wrong?
Below is a snippet from Beautiful Hugo's `header.html` layout.
The pesky `<hr class="small">` that puzzled me resulted from the page's `.Type` parameter _not_ being equal to `post`.
What is `.Type` and how does it get defined? 

```html {linenos=table,hl_lines=["11-13"],linenostart=56}
<div class="intro-header no-img">
  <div class="container">
    <div class="row">
      <div class="col-lg-8 col-lg-offset-2 col-md-10 col-md-offset-1">
        <div class="{{ .Type }}-heading">
          {{ if eq .Type "list" }}
            <h1>{{ if .Data.Singular }}#{{ end }}{{ .Title }}</h1>
          {{ else }}
            <h1>{{ with $title }}{{.}}{{ else }}<br/>{{ end }}</h1>
          {{ end }}
          {{ if ne .Type "post" }}
            <hr class="small">
          {{ end }}
          {{ if $subtitle }}
            {{ if eq .Type "page" }}
              <span class="{{ .Type }}-subheading">{{ $subtitle }}</span>
            {{ else }}
              <h2 class="{{ .Type }}-subheading">{{ $subtitle }}</h2>
            {{ end }}
          {{ end }}
          {{ if eq .Type "post" }}
            {{ partial "post_meta.html" . }}
          {{ end }}
        </div>
      </div>
    </div>
  </div>
</div>
```

Thankfully, Hugo's documentation is decent, and after a bit of searching, I learned about _content types_.

> A **content type** is a way to organize your content.
> Hugo resolves the content type from either the `type` in front matter or, if not set, the first directory in the file path.
> E.g. `content/blog/my-first-event.md` will be of type `blog` if no `type` set.[^1]

Basically, Hugo uses convention over configuration to define a page's content type.
The page I created, it turns out, defaults to a content type of `posts`,
and Beautiful Hugo's `header.html` layout template applies the horizontal rule in question to pages that are _not_ of the content type `post`.

All solutions are obvious once you understand the problem, right?

```shell_session
$ mv content/posts content/post
```

That's better.

[^1]: https://gohugo.io/content-management/types/
