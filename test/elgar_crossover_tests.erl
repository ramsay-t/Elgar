-module(elgar_crossover_tests).

-include_lib("eunit/include/eunit.hrl").

sc(P,Q) ->
    {F,_} = case P of
		[] ->
		    {[],[]};
		_ ->
		    lists:split(rand:uniform(length(P)),P)
	    end,
    {_,S} = case Q of
		[] ->
		    {[],[]};
		_ ->
		    lists:split(rand:uniform(length(Q)),Q)
	    end,
    F ++ S.

cross_test_() ->
    {"Crossover tests",
     [
      {setup,
       fun() ->
	       ?debugMsg("Crossover Setup"),
	       Pid = sk_peasant:start(),
	       Pid
       end,
       fun(Pid) ->
	       Pid ! terminate,
	       timer:sleep(100),
	       ok
       end,
       {timeout, 10,{"String Crossover", ?_assertEqual(9,length(elgar_crossover:cross(["aaa","bbb","abc"],fun sc/2)))}
       }
      }]
    }.
