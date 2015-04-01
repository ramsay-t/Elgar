-module(elgar_generator_tests).

-include_lib("eunit/include/eunit.hrl").

gen_test_() ->
    {"Generator tests", 
     {inparallel,[
		{"Fixed generator", ?_assertEqual([1,1,1,1,1,1,1,1,1,1],elgar_generator:gen(fun(_) -> 1 end,10))},
		{"Random Generator", ?_assertEqual(10,length(elgar_generator:gen(fun(Seed) -> Seed end,10)))}
	       ]}
    }.

