-module(elgar_generator).

-export([gen/2]).

-include("include/elgar.hrl").

-spec gen(generator(),pos_integer()) -> [genome()].
gen(Gen,PopSize) ->
    lists:map(fun(_) -> Gen(random:uniform()) end, lists:seq(1,PopSize)).
