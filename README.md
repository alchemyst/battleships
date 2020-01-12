# Battleships

Code for playing the game Battleships.

This code was originally developed in Matlab for a subject called CRV210 at the University of Pretoria in 2006.

The optimal algorithm in the code here is captured in `carlbattle.m` and tries to use a counting approach.

To see the probability fields animated for a battle do the following:

```
>>> battle('init', 1)
>>> carlbattle(1)
```

Other places where this has been discussed:

* Eric S Raymond has written a full version of battleships which is hosted in C [here](https://gitlab.com/esr/bs), circa 1987. The algorithm in this implementation is implemented in `esrbattle.m`.
* There was a [StackOverflow competition](https://stackoverflow.com/questions/1631414/what-is-the-best-battleship-ai) on this game in 2009
* [This blog post](http://datagenetics.com/blog/december32011/index.html) was a response to that competition
* The probabilities were discussed on Reddit in [/r/compsci](https://www.reddit.com/r/compsci/comments/qb4dd/battleship_probability_theory_and_central_limit/) in 2013
* The above blog post was referenced in [this Reddit post](https://www.reddit.com/r/dataisbeautiful/comments/emurd7/winning_at_battleship_using_probability_oc/) in 2020

