-module(eda_app).

-include_lib("kernel/include/logger.hrl").

-behaviour(application).

-export([
    start/2,
    stop/1
]).

start(_StartType, _StartArgs) ->
    {ok, Pid} = eda_sup:start_link(),
    ?LOG_DEBUG("All Out : ~p\n", [eda:all_out()]),
    ?LOG_DEBUG("All Inc : ~p\n", [eda:all_inc()]),
    {ok, Pid}.

stop(_State) ->
    ok.
