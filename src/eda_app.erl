-module(eda_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    {ok, Pid} = eda_sup:start_link(),
    eda_log:log(debug, "All Out : ~p\n", [eda:all_out()]),
    eda_log:log(debug, "All Inc : ~p\n", [eda:all_inc()]),
    {ok, Pid}.

stop(_State) ->
    ok.
