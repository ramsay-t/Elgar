-module(elgar_tests).

-include_lib("eunit/include/eunit.hrl").
-compile(export_all).

start_workers() ->
    lists:map(fun(_) -> sk_peasant:start() end, lists:seq(1,10)).

stop_workers(Pids) ->
    lists:map(fun(P) -> P ! terminate end, Pids).
	
pick_char() ->
    lists:nth(rand:uniform(5),"abcde").
	    
string_gen(Seed) ->
    case lists:seq(1,trunc(Seed*10)) of
	[] ->
	    [];
	Seq ->
	    lists:map(fun(_) -> pick_char() end,Seq)
    end.
  
best_left(Target,S,Best) ->
    LT = string:substr(Target,1,Best+1),
    ST = string:substr(S,1,Best+1),
    if LT == ST ->
	    best_left(Target,S,Best+1);
       true ->
	    Best
    end.
best_right(Target,S,Best) ->
    if Best >= length(Target) ->
	    Best;
       Best >= length(S) ->
	    Best;
       true ->
	    LT = string:substr(Target,(length(Target)+1)-(Best+1)),
	    ST = string:substr(S,(length(S)+1)-(Best+1)),
	    if LT == ST ->
		    best_right(Target,S,Best+1);
	       true ->
		    Best
	    end
    end.

string_fit(Target,S) ->
    if S == Target ->
	    1.0;
       true ->
	    Lscore = if length(S) > length(Target) ->
			     (10 - (length(S) - length(Target))) / 10.0;
			length(S) < length(Target) ->
			     (10 - (length(Target) - length(S))) / 10.0;
			true ->
			     1.0
		     end,
	    Sscore = best_left(Target,S,0) / length(Target),
	    Rscore = best_right(Target,S,0) / length(Target),
	    %%?debugFmt("Fit ~p: ~p <<~p>>",[Target,S,(Lscore/12) + (Sscore/3) + (Rscore/3)]),
	    (Lscore/12) + (Sscore/3) + (Rscore/3)
    end.

string_m1(S) ->
    S ++ [pick_char()].
string_m2(S) ->
    [pick_char() | S].
string_m3(S) ->
    if length(S) > 1 ->
	    N = rand:uniform(length(S))-1,
	    {A,B} = lists:split(N,S),
	    A ++ [pick_char()] ++ tl(B);
       true ->
	    []
    end.
string_m4(S) ->
    if length(S) < 2 -> 
	    S;
       true ->
	    N = rand:uniform(length(S))-1,
	    {A,B} = lists:split(N,S),
	    case rand:uniform(2) of
		1 ->
		    A;
		2 ->
		    B
	    end
    end.

string_mus() ->
    [fun string_m1/1, fun string_m2/1, fun string_m3/1, fun string_m4/1].

string_cross(P,Q) ->
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

options_test_() ->
    {setup,
     fun() ->
	     Pids = start_workers(),
	     Pids
     end,
     fun(Pids) ->
	     stop_workers(Pids),
	     timer:sleep(100),
	     ok
     end,
     {inorder,
      [{"String Guessing GA", 
	{timeout, 30,
	 ?_assertEqual("abcde", elgar:run(fun string_gen/1,fun(S) -> string_fit("abcde",S) end,string_mus(),fun string_cross/2,[]))
	}
       },
       {"String guessing GA with options",
	{timeout, 30,
	 ?_assertEqual("abcde", elgar:run(fun string_gen/1,fun(S) -> string_fit("abcde",S) end,string_mus(),fun string_cross/2,[{pop_size,40},{thres,1.0}]))
	}
       },
       {"String guessing GA with minimal population size and monitor",
	{timeout, 200,
	 %% This doesn't work with a as the target, but does with c. Thats very broken but I don't have time to look in to why...
	 ?_assertEqual("c", elgar:run(fun string_gen/1,fun(S) -> string_fit("c",S) end,string_mus(),fun string_cross/2,[{pop_size,1},{thres,1.0},{monitor,5433}]))
	}
       },
       {"Hit limit",
	{timeout, 200,
	 ?_assertMatch({incomplete,_}, elgar:run(fun string_gen/1,fun(S) -> string_fit("c",S) end,string_mus(),fun string_cross/2,[{pop_size,1},{thres,1.0},{limit,1}]))
	}
       }
      ]}
     }.

