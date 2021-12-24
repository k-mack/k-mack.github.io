---
title: "Techniques for Writing Docs in a Markup Language"
date: 2021-12-24T00:30:00-08:00
tags: ["tips", "writing", "documentation"]
---

Software projects need to have good documentation.
This improves the software's approachability and impacts its users and contributors.
More importantly, it increases the software's signal-to-noise ratio,
allowing developers to better understand if the software meets their needs.
This is not revolutionary:
high-level software developed today
(i.e., using the C programming language or above)
presumably uses third-party code, open-source or not.
Writing software documentation, however, is challenging and thoughtful work.
This is the reason why technology companies hire technical writers and developer advocates:
they know good documentation is critical for their product.

Markup languages,
such as Markdown and AsciiDoc,
have become essential in developing software documentation.
Their similarity to programming,
with toolchains and a lightweight syntax,
aligns with the developer mindset more so than traditional word processors.
Documents written in them have a low barrier to read
(e.g., you need only a text viewer installed, like `more`)
and easy to read `diff`s,
making their history easy to track using a version control system.

Like software source code, markup languages allow authors to write the same content a thousand different ways.
With this type of flexibility and creativity in the documentation process,
it helps to employ techniques to make writing documentation as enjoyable as writing code
and to make the documentation source files as aesthetically pleasing, consistent, and efficient as well-styled source code.
This post shares four such techniques that have improved my writing experience.

<!--more-->

But first, a short overview of my journey with writing technical documentation :).

## Personal Context

When I joined the company I am at now in 2012, Microsoft Word was primarily used throughout the company for authoring software documentation.
It was not used for software library API documentation;
tools like Doxygen and Javadoc were used for that.
Word was for creating
user and administrator guides,
tutorials,
frequently asked questions (FAQs),
etc.
The primary reason for using Word was that customers expected documentation as Word documents,
and the customers were application users, not developers.

This was back when Subversion was the dominate version control system in the company,
and the slack to invest in tooling around documentation generation and transformation didn't exist.
Combining these with some other old-school mentalities meant that managing documentation was a bit painful:
The latest and stable version of the document was maintained by one person.
If a person was to modify the document,
the person had to
obtain a copy of the latest version,
rename the file such that its name was suffixed with the author's initials
(e.g., `User_Guide-km.docx`),
turn on Word's Track Changes feature,
make the modifications,
and send the modified file to the maintainer.
The maintainer was responsible for merging the edits of all the contributors into the document.
The document was then sent to all contributors for review to ensure no edit was lost.
If an error was found in the document during review,
then the workflow's recursion kicked in until everyone was satisfied the document.

This was a bit of gut punched to me.
I joined the company after finishing my master's thesis, which I wrote in LaTeX.
I was accustomed to treating documentation like code:
use a toolchain to transform source files to an output format,
automate document generation (e.g., with GNU Make),
and commit changes to version control.
My brain was wired to think about content first and its presentation second
(e.g., `*.cpp -> *.o -> {libmylib.a, libmylib.so}`).

After the company made the move to Git and when Markdown became a hit with the staff,
teams started to use markup languages to write software documentation.
Contributors were branching and merging edits to Markdown files in Git.
Each change to the Markdown files could be easily seen via `git diff` and `git show`.
It was contributor-friendly,
and the world seemed right and just :P.
The last step was to convert the final, peer-reviewed Markdown content into a Word document.
Tools like pandoc were found to be helpful for this.
As time went on, things kept getting better:
customers became more open to PDF and HTML,
teams moved from Markdown to Asciidoctor to create richer documents,
and the company-hosted GitLab instance made reviewing changes a delight.

The world, however, isn't black and white,
and as is usual for software developers,
technique and style became a topic of discussion.
One of the nice things about Word is that it puts all authors into the same frame of mind.
The structure of Word is uniform and universal.
It matches how we are taught to write from an early age:
pull out a blank piece of paper and start writing from left to right, top to bottom.
Made a mistake?
Erase, use Wite-Out, or start over.
There is no commenting out sentences or variable substitution.
What you write is what you get,
and Word follows this.
At least to my knowledge, you can't separate content from presentation in Word:
Sentences are delimited by a period and a space.
Paragraphs are delimited by a newline.
Ordered and unordered lists use a default icon and scheme, set by the person who created the Word document.
Looking back, this rigid word processing environment eased the contribution and merging process in the sense that,
for example,
you didn't have Bob breaking his sections into separate Word documents
while Nancy confined her contributions to one document but wrote a sentence per line.
Transitioning from Word to markup introduced "developer chaos" in managing documentation contributions.
This chaos mirrors that which is experienced with coding best practices and styles.

After a bit of back in forth about how to manage the flexibility of markup languages,
I found some core techniques that help me write good and maintainable documentation.

## Techniques for Writing Docs

In 2015, I found and watched [Dan Allen](https://github.com/mojavelinux)'s presentation at Devnexus titled "[Discover the Zen of Writing with Asciidoctor](https://www.youtube.com/watch?v=Aq2USmIItrs)."
The full presentation is great whether you use Asciidoctor or not.
However, the gold for authors is his section on [Zen techniques](https://www.youtube.com/watch?v=Aq2USmIItrs&t=3454s).

**Full disclosure:
The techniques below are from Dan Allen's 2015 Devnexus presentation (see links above).
Full credit goes to him.
I am merely echoing them in an attempt to share them and attest to how awesome they are.**

After giving credit to where credit is due, let's dive into some of the techniques that Dan shares in his presentation.
Note that this post could be titled something like "4 Writing Techniques Every Programmer Should Know," but it sounds like clickbait to me.
Then again, I am just generally not good with creating titles.

### 1. Like Code, Don't Repeat Yourself

Since writing technical documents in a markup language is like writing code, don’t repeat yourself.
Just like copy-and-pasting code throughout an application can result in inconsistencies,
duplicating the same text throughout your documents can leave them fragmented when one section is modified but the others are not.

There are tools that allow authors to import documents into other documents.
This makes it easy to pull out licenses, introductions, appendices, images, etc. into their own documents and then import them into others.
Changes in these then fan out to all the other documents.

### 2. Like Code, Write a Statement Per Line

Most statements in code are given their own line.
Apply this same principle to your documents:
every sentence or significant clause (or semi-colon, colon, or list) starts a new line.
Most documentation formats require a blank line to introduce a paragraph.
Therefore, contiguous statements per line will be rendered as a single paragraph.
This is a powerful writing technique for a number of reasons:

1. It taps into your programming mindset and aligns with the technical, structured workflow that you know and use everywhere else.
2. If a change occurs, it is localized to that line (i.e., no wrapping) which means the diff is incredibly easy to read.
3. Long sentences run over 80 columns, which means you’re probably ranting or meandering.
   Technical documents are not novels; they should be concise and to the point.
   Of course, some sentences are going to be over 80 characters, but if you’re pushing 100 characters, consider revising.
   In other words, be judicious.
   (A [thesaurus](https://www.powerthesaurus.org/) can help you say more with less.)
4. Sentences can be easily moved around.
5. Sentences can be easily commented out (if your documentation syntax supports comments).

### 3. Like Code, Write Comments

Commenting is powerful in code and just as powerful in documents.
Comments in your document allow you to save off chunks of text without being rendered in your generated document.
This is important for keeping around thoughts and objectives for paragraphs, sections, etc.
This helps the other authors and editors understand what you are trying to accomplish.

Not all markup formats support comments.
If the one you use supports them, then don’t be afraid to use them.

### 4. Like Code, Use Variables

A number of documentation formats support variables that can encapsulate information used repeatedly throughout a document.
This is also a way to shorten sentences to fit on a single line and to keep from repeating yourself.
I like to use Asciidoctor's attributes to store the long and abbreviated names of the application I am writing about:

```asciidoctor
// attributes
:app-abbr: App
:app-name: Long Application Name Here
:app-uri-downloads: https://sourceforge.net/
:app-uri-downloads-link: {app-uri-downloads}[Downloads]

== Introduction

{app-name} ({app-abbr}) is an application that *blah blah blah*.

// ...

== Getting Started

Get started with {app-abbr} by downloading a pre-built binary from {app-uri-downloads-link}.

// ...

== FAQs

[quote]
Where can I download {app-abbr}?

Pre-built binaries can be downloaded from {app-uri-downloads-link}.

// ...
```

## Conclusion

The goal of this post was to share techniques to help make writing good software documentation enjoyable with a markup language.
The four techniques shared were credited to Dan Allen of the Asciidoctor project.

_Fin_.
