-module(elgar_tests).

-include_lib("eunit/include/eunit.hrl").

elgar_test_() ->
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
       {inorder,
	[{"Null test",?_assert(true)}]
       }
      }]
    }.
	
