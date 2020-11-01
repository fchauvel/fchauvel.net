+++
tags = ["book", "review", "software"]
categories = ["book-review", "software", "design"]
title = "Clean Architecture, by R. Martin"
description = ""
date = "2020-11-01"
menu = ""
banner = "images/books.jpg"
images = []
+++

<!-- hook -->

Does software architecture sound like a vague philosophical idea,
disconnected from the practicalities of programming? Yes? This might
be a good read.

![Book
cover](/images/books/clean_architecture.jpg)

<!--
    1. How did I come accross it?
    2. Why did I choose it!
-->

I liked [Clean
Code](https://www.goodreads.com/book/show/3735293-clean-code) and [The
Clean
Coder](https://www.goodreads.com/book/show/10284614-the-clean-coder)
by R. Martin, I felt tempted to read this other volume about software
architecture. While I had been hesitating for some time, reading [just
enough software
architecture](https://www.goodreads.com/book/show/9005772-just-enough-software-architecture)
by G. Fairbanks revamped my interest, and I took the (tiny)
plunge. Besides, I got to try the Amazon Kindle for the first time, and
I liked it!. The book still costs [15 EUR on
Amazon](https://www.amazon.co.uk/Clean-Architecture-Craftsmans-Software-Structure-ebook-dp-B075LRM681/dp/B075LRM681/)
though.

<!-- Brief Summary -->

R. Martin details his "Clean Architecture" in six parts. After an
introduction in Part I, he explains in Part II why the rules of
software architecture are unlikely to change before he reiterates his
SOLID principles in Part III. From there, he "zooms out" and discusses
how these SOLID principles apply to larger software entities, namely
components in Part IV and architecture in Part V. In Part VI, he lists
details such as GUI, storage or frameworks that can hurt the
architecture. The curious will find in Part VII a selection of war
stories from Robert's career that shaped this "clean architecture".

<!-- Who is the author, when did he wrote the book -->

[Robert Cecil Martin](https://en.wikipedia.org/wiki/Robert_C._Martin)
is one of the louder voices in Software Engineering. He has authored
books and magazine articles on programming, agile practices, and was
one of the founders of the Agile manifesto.

<!-- Evaluation: How does she structure her/his argument -->

As for the style, I found Robert's voice peremptory, and I am not so
much into war stories from the 60ies. Robert argues convincingly and
mainly refers to relevant books and articles, but I don't remember
empirical about others using his clean architecture.

As for the substance, this is more technical than other books on
software architecture. It is about classes, modules, components,
releases, etc. I felt Part II and III add little if, like me, you
already went through [Clean
Code](https://www.goodreads.com/book/show/3735293-clean-code) and [The
Clean
Coder](https://www.goodreads.com/book/show/10284614-the-clean-coder). But
I like the rest. The clean architecture departs from "testing from the
very outset", which ensures the user always has something to play with
(see [Growing-object oriented system guided by
tests](https://www.goodreads.com/book/show/4268826-growing-object-oriented-software-guided-by-tests)). Robert
trades this against tests that better withstand changes over time,
since they don't hit volatile things like the UI or the storage,
etc. It's a tradeoff.

<!-- Rating and Recommendation: Who should read it -->

Eventually, I liked it and gave it 3 stars. I would recommend it to
those that see software architecture as a pure (useless?) academic
exercise. Robert's clean architecture is one practical way to bridge
the model-code gap, that is, to have an architecture that exists beyond
whiteboards.
