-module(eda_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    {ok, Pid} = eda_sup:start_link(),
    io:format("All Out : ~p\n", [eda:all_out()]),
    io:format("All Inc : ~p\n", [eda:all_inc()]),
    {ok, Pid}.

stop(_State) ->
    ok.
