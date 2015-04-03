-module(elgar_tests).

-include_lib("eunit/include/eunit.hrl").
-compile(export_all).

start_workers() ->
    lists:map(fun(_) -> sk_peasant:start() end, lists:seq(1,10)).

stop_workers(Pids) ->
    lists:map(fun(P) -> P ! terminate end, Pids).
	
pick_char() ->
    lists:nth(random:uniform(5),"abcde").
	    
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
	    (Lscore/12) + (Sscore/3) + (Rscore/3)
    end.

string_m1(S) ->
    S ++ [pick_char()].
string_m2(S) ->
    [pick_char() | S].
string_m3(S) ->
    if length(S) > 1 ->
	    N = random:uniform(length(S))-1,
	    {A,B} = lists:split(N,S),
	    A ++ [pick_char()] ++ tl(B);
       true ->
	    []
    end.

string_mus() ->
    [fun string_m1/1, fun string_m2/1, fun string_m3/1].

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

string_test_() ->
    {"String guessing GA",
     {timeout, 10,
      begin 
	  Pids = start_workers(),
	  Res = elgar:run(fun string_gen/1,fun(S) -> string_fit("abcde",S) end,string_mus(),fun string_cross/2,[]),
	  stop_workers(Pids),
	  ?_assertEqual("abcde", Res)
      end}
    }.

options_test_() ->
    {inorder,
     [{"String guessing GA with options",
       {timeout, 10,
	begin 
	    Pids = start_workers(),
	    Res = elgar:run(fun string_gen/1,fun(S) -> string_fit("abcde",S) end,string_mus(),fun string_cross/2,[{pop_size,40},{thres,1.0}]),
	    stop_workers(Pids),
	    ?_assertEqual("abcde", Res)
	end}
      },
      {"String guessing GA with minimal population size and monitor",
       {timeout, 10,
	begin 
	    Pids2 = start_workers(),
	    Res2 = elgar:run(fun string_gen/1,fun(S) -> string_fit("a",S) end,string_mus(),fun string_cross/2,[{pop_size,1},{thres,1.0},{monitor,5433}]),
	    stop_workers(Pids2),
	    ?_assertEqual("a", Res2)
	end}
      }
     ]
    }.

