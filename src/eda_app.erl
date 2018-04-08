-module(eda_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

-include("eda.hrl").

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    eda_sup:start_link().

stop(_State) ->
    ok.
