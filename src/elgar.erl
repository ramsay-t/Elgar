-module(elgar).

-export([run/4]).

run(Gen,Fit,Mus,Options) ->
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
    loop(Pop,Fit,Mus,Thres).

loop(Pop,Fit,Mus,Thres) ->    
    PopSize = length(Pop),
    PopP = elgar_mutation:make_mutants(Pop,PopSize,Mus),
    [{S,P} | ScoreSet] = elgar_fitness:score(PopP),
    if S > Thres ->
	    P;
       true ->
	    {SH,_} = lists:split(PopSize,ScoreSet),
	    NewPop = lists:map(fun({_,PP}) -> PP end,SH),
	    loop(NewPop,Fit,Mus,Thres)
    end.

