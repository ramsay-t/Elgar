-module(elgar_mutation).

-export([make_mutants/3]).

-include("include/elgar.hrl").

-spec make_mutants([genome()],pos_integer(),[mutation_function()]) -> [genome()].
make_mutants(Pop,Count,Mus) ->
    lists:merge(skel:do([{pool,[{seq,fun(P) -> 
					     [P | lists:map(fun(_) ->
								    M = lists:nth(random:uniform(length(Mus)),Mus),
								    M(P)
							    end,
							    lists:seq(1,Count))]
				     end}],
			  {max,length(Pop)}}],
			Pop)).

