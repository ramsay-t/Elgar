-type genome() :: any().

-type fitness_function() :: fun((genome()) -> integer()).

-type generator() :: fun((float()) -> genome()).

-type mutation_function() :: fun((genome()) -> genome()).
