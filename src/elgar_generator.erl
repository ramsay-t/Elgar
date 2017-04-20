-module(elgar_generator).

-export([gen/2]).

-include("include/elgar.hrl").

-spec gen(generator(),pos_integer()) -> [genome()].
gen(Gen,PopSize) ->
    skel:do([{pool, [fun(_) -> Gen(rand:uniform()) end], {max,PopSize}}], lists:seq(1,PopSize)).
