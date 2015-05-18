-module(elgar).

-export([run/5]).

run(Gen,Fit,Mus,Cross,Options) ->
    MonPid = case get_opt(Options,monitor,none) of
		 none ->
		     none;
		 Port ->
		     elgar_monitor:start(Port)
	     end,
    PopSize = case get_opt(Options,pop_size,50) of
		  S when S < 4 ->
		      4;
		  S ->
		      S
	      end,
    Limit = get_opt(Options,limit,100),
    Pop = elgar_generator:gen(Gen,PopSize),
    Thres = get_opt(Options,thres,1.0),
    loop(Pop,Fit,Mus,Cross,Thres,MonPid,Limit,1).

loop(Pop,_Fit,_Mus,_Cross,_Thres,MonPid,Limit,Counter) when Counter >= Limit ->
    update_status(MonPid,finished,Counter),
    {incomplete,hd(Pop)};
loop(Pop,Fit,Mus,Cross,Thres,MonPid,Limit,Counter) ->    
    PopSize = length(Pop),
    PopP = elgar_mutation:make_mutants(Pop,PopSize,Mus) ++ elgar_crossover:cross(Pop,Cross),
    [{S,P} | ScoreSet] = elgar_fitness:score(PopP,Fit),
    if S >= Thres ->
	    update_status(MonPid,finished,Counter),
	    P;
       true ->
	    {SH,_} = lists:split(PopSize-3,ScoreSet),
	    %% Include two from the middle too - this adds some necessary diversity!
	    {_,Worse} = lists:split(trunc(length(ScoreSet)/2),ScoreSet),
	    {_,Worst} = lists:split(trunc(length(Worse)/2),Worse),
	    SHP = [{S,P} | SH] ++ [hd(Worse),hd(Worst)],
	    update_status(MonPid,SHP,Counter),
	    NewPop = lists:map(fun({_,PP}) -> PP end,SHP),
	    loop(NewPop,Fit,Mus,Cross,Thres,MonPid,Limit,Counter+1)
    end.

update_status(MonPid,Status,Counter) ->
    case MonPid of
	none ->
	    ok;
	_ ->
	    if Status == finished ->
		    MonPid ! terminate;
	       true ->
		    %% Prevent flooding of the monitor
		    timer:sleep(100),
		    StatMsg = lists:flatten(io_lib:format("Iteration: ~p<br/>\n",[Counter]) ++ 
						lists:map(fun({S,P}) -> io_lib:format("~.6f ~p</br>",[S,P]) end,Status)),
		    MonPid ! {status,StatMsg}
	    end
    end.

get_opt(Options,O,Default) ->
    case lists:keyfind(O,1,Options) of
	{O,P} ->
	    P;
	_ ->
	    Default
    end.
