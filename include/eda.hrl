-define(CHILD(I, Type),
    #{
        id => I,
        start => {I, start_link, []},
        restart => permanent,
        shutdown => 5000,
        type => worker,
        modules => [I]
    }
).