-module(eda).

-export([
    all_inc/0,
    all_out/0
]).

% utils
-export([
    child/2,
    child/3,
    child/4
]).

%% @doc intended to be a API for Erlang Data Adaptor
%% @end

all_inc() ->
    supervisor:which_children(eda_inc_sup).

all_out() ->
    supervisor:which_children(eda_out_sup).

%% Utils

child(I, Type) ->
    child(I, Type, []).

child(I, Type, Args) ->
    child(I, I, Type, Args).

child(I, StartMod, Type, Args) ->
    #{
        id => I,
        start => {StartMod, start_link, Args},
        restart => permanent,
        shutdown => 5000,
        type => Type,
        modules => [I]
    }.