-module(elgar_fitness).

-export([score/2]).

-include("elgar.hrl").

-spec score([genome()],fitness_function()) -> [{integer(),genome()}].
score([],_F) ->
    [];
score(Pop,F) ->
    Scores = skel:do([{pool,[{seq,fun(P) -> {F(P),P} end}],{max,length(Pop)}}],Pop),
    lists:reverse(lists:sort(Scores)).

    
