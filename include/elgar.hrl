-type genome() :: any().

-type fitness_function() :: fun((genome()) -> float()).

-type generator() :: fun((float()) -> genome()).

-type mutation_function() :: fun((genome()) -> genome()).

-type crossover_function() :: fun((genome(),genome()) -> genome()).
