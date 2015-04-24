-module(elgar_crossover).

-export([cross/2]).

-include("elgar.hrl").

-spec cross([genome()],crossover_function()) -> [genome()].
cross(Pop,CrossFun) ->
    lists:merge(skel:do([{pool,[fun(P) ->
				      lists:map(fun(Q) ->
							CrossFun(P,Q)
						end,
						Pop)
			       end],{max,length(Pop)}}],
			Pop)).

