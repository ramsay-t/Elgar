-module(elgar_fitness_tests).

-include_lib("eunit/include/eunit.hrl").

-compile(export_all).

pop1() ->
    ["a","abc","dd"].

f(P) ->
   length(P)/10.0. 

score_test_() ->
    {"Test Scoring",
     [
      {setup,
       fun() ->
	       Pid = sk_peasant:start(),
	       Pid
       end,
       fun(Pid) ->
	       Pid ! terminate,
	       ok
       end,
       [{"Scoring and Sorting", ?_assertEqual([{0.3,"abc"},{0.2,"dd"},{0.1,"a"}],elgar_fitness:score(pop1(),fun f/1))},
	{"Null population", ?_assertEqual([],elgar_fitness:score([],fun f/1))}
	]
      }
     ]
    }.

