-module(elgar_mutation_tests).

-include_lib("eunit/include/eunit.hrl").

m1(P) ->
    "a" ++ P.
m2(P) ->
    "b" ++ P.

mutation_test_() ->
    {"Test Mutations",
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
       {timeout, 10,
	[{"Mutants", ?_assertEqual(6,begin 
					 M = elgar_mutation:make_mutants(["a","b"],2,[fun m1/1,fun m2/1]), 
					 length(M) 
				     end)}
	]}
      }
     ]
    }.
