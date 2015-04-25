-module(elgar_mutation_tests).

-include_lib("eunit/include/eunit.hrl").

m1(P) ->
    "a" ++ P.
m2(P) ->
    "b" ++ P.

mutation_test_() ->
    {setup,
     fun() ->
	     Pid = sk_peasant:start(),
	     Pid
     end,
     fun(Pid) ->
	     Pid ! terminate,
	     timer:sleep(100),
	     ok
     end,
     {timeout, 10,
      [{"Mutants", ?_assertEqual(6,length(elgar_mutation:make_mutants(["a","b"],2,[fun m1/1,fun m2/1])))}
      ]}
    }.
