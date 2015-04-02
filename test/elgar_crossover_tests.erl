-module(elgar_crossover_tests).

-include_lib("eunit/include/eunit.hrl").

string_cross(P,Q) ->
    {F,_} = case P of
		[] ->
		    {[],[]};
		_ ->
		    lists:split(random:uniform(length(P)),P)
	    end,
    {_,S} = case Q of
		[] ->
		    {[],[]};
		_ ->
		    lists:split(random:uniform(length(Q)),Q)
	    end,
    F ++ S.

string_cross_test() ->
    PopP = elgar_crossover:cross(["aaa","bbb","abc"],fun string_cross/2),
    ?assertEqual(9,length(PopP)).

