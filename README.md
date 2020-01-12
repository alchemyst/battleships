# Battleships

Code for playing the game Battleships.

This code was originally developed in Matlab for a subject called CRV210 at the University of Pretoria in 2006.

The optimal algorithm in the code here is captured in `carlbattle.m` and followsa similar strategy to [this blog post](http://datagenetics.com/blog/december32011/index.html) which is also referenced in this [Reddit post](https://www.reddit.com/r/dataisbeautiful/comments/emurd7/winning_at_battleship_using_probability_oc/). 

It is also interesting to check that Eric S Raymond has written a full version of battleships which is hosted in C [here](https://gitlab.com/esr/bs). The algorithm in this implementation is implemented in `esrbattle.m`.

To see the probability fields animated for a battle do the following:

```
>>> battle('init', 1)
>>> carlbattle(1)
```
