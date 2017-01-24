+++
menu = ""
draft = true
date = "2017-01-16T14:50:59+01:00"
title = "Permutation Partity"
description = ""
categories = []
tags = []
images = []
banner = ""
+++

Everyday, I try to solve one simple programming challenge. Last week,
I stumble upon
the
["Larry's Array" challenge](https://www.hackerrank.com/challenges/larrys-array),
a variation around
the [15 tiles puzzle](https://en.wikipedia.org/wiki/15_puzzle). I
explain below the problem and the though process that I followed to
reach a solution.

## The Problem

The problem is actually very brief. Given a permutation of the $N$
first integer&mdash; say $(1,3,2,4,6,5)$&mdash; we must decide whether
it is possible to sort it using only 3-step wide circular
permutations, one such that transforms $(a,b,c)$ into $(b, c, a)$.

For instance, if we consider $(1,4,3,2)$, the rotation of $(4,3,2)$ is
enough to sort the permutation.

## The Thought Process

At first, I was clueless, so I tried brute force, that is
basic
[depth-first search](https://gist.github.com/fchauvel/bff48ff298ae708c0c4576f13d2b01b2). Although
it does not scale, it gave me a way to test what permutation
can be sorted. Considering permutations of length 3 in lexicographical
order, I got: 

```no-code
(1,2,3) YES 
(1,3,2) NO 
(2,1,3) NO 
(2,3,1) YES
(3,1,2) YES 
(3,2,1) NO 
``` 

To better visualise patterns, I depict them as a string where 'O'
marks sortable permutations. For permutations of length 3, 4 and 5, we
get the following patterns, where 'O' marks sortable permutations.

```no-code
N=3: O--OO-
N=4: O--OO--OO--OO--OO--OO--O
N=5: O--OO--OO--OO--OO--OO--O-OO--OO--OO--OO--OO--OO-O--OO--OO...
                             ^                        ^ 
```

At first, it seemed that the pattern `O--O` repeats itself. That
is permutations whose rank has a remainder of 0 or 3 when divided
by 4 would be "sortable" ($r \equiv 0 \lor r \equiv
3\;(\textrm{mod} \, 4)$). Unfortunately, it is not that simple: The
pattern varies when we try with $N = 5$.

Looking at the case where $N=3$, we can see a smaller pattern `O-`
that is reversed every time the first digit is incremented.

```nocode
N=3: O- 
     -O
     O-
	 
N=4: O--OO- 
     -OO--O
     O--OO-
     -OO--O
	 
N=5: O--OO--OO--OO--OO--OO--O
     -OO--OO--OO--OO--OO--OO-
     O--OO--OO--OO--OO--OO--O
     -OO--OO--OO--OO--OO--OO-
     O--OO--OO--OO--OO--OO--O
```

As shown in the figure below, the pattern for $N=5$ alternates the
pattern for $N=4$ and its direct inverse. Similarly, the pattern for
$N=4$ alternates the pattern for $N=3$ and its direct
opposite. Finally, the pattern for $N=3$ alternates the pattern for
$N=2$ and its inverse.

![Nested parity patterns for N=5](/franck/images/parity_pattern.png)

My solution is therefore the following:
 
 1. Compute the rank of the given permutation, that is its position in
    the lexical ordering of permutation.
	
 2. Decide whether the rank is sortable, that if it maps to an "O" or
    a "-" in the above illustration.
	
The first step boils down to count the number of permutation that can
smaller than the given one. The following function does this
recursively:

```python
def rank(array):
    if len(array) == 0:
        return 0
    digits = [n for n in array[1:] if n < array[0]]
    return len(digits) * math.factorial(len(array)-1) + rank(array[1:])
```
 
The second step simply breaks down navigate this nesting of
patterns. For instance, provided that $N=5$, if the rank is 44 then we
know that are in the second row (each row contains 24 permutations,
$!(N-1) = !4 = 24$). Within this second row, we would have the rank 20
($=44-24$). This rank would in the fourth repetition of the $N=3$
pattern. There we would have the rank 2, and which is not
sortable. Here is function that does this:

```python
def sortable(rank, scale):
    if scale == 2:
        return rank == 0
    bound = math.factorial(scale-1)
    if rank // bound  % 2 == 0:
        return sortable(rank % bound, scale-1)
    else:
        return not sortable(rank % bound, scale-1)
```

We can use this function to visualise how swaps of elements generate
permutation and mark those that are sortable. Here is the result for
120 permutations possible for $N=5$. The permutation parity actually
reflects whether the minimum number of swaps needed to sort a
permutation is odd or even.

![The graph of permutations](/franck/images/permutations.png)

