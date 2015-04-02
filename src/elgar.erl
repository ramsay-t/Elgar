-module(elgar).

-export([run/5]).

run(Gen,Fit,Mus,Cross,Options) ->
    PopSize = case lists:keyfind(pop_size,1,Options) of
		  {pop_size,P} ->
		      P;
		  _ ->
		      10
	      end,
    Pop = elgar_generator:gen(Gen,PopSize),
    Thres = case lists:keyfind(thres,1,Options) of
		  {thres,T} ->
		      T;
		  _ ->
		      1.0
	      end,
    loop(Pop,Fit,Mus,Cross,Thres).

loop(Pop,Fit,Mus,Cross,Thres) ->    
    PopSize = length(Pop),
    PopP = elgar_mutation:make_mutants(Pop,PopSize,Mus) ++ elgar_crossover:cross(Pop,Cross),
    [{S,P} | ScoreSet] = elgar_fitness:score(PopP,Fit),
    if S >= Thres ->
	    P;
       true ->
	    {SH,_} = lists:split(PopSize,ScoreSet),
	    NewPop = lists:map(fun({_,PP}) -> PP end,SH),
	    loop(NewPop,Fit,Mus,Cross,Thres)
    end.

