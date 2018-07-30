-module(eda_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-include_lib("eda/include/eda.hrl").

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    ChildSpecs = [
        % First out
        eda:child(eda_out_sup, supervisor),
        % Then in
        eda:child(eda_inc_sup, supervisor)
    ],
    SupFlags = #{
        strategy => one_for_one, % optional
        intensity => 5,          % optional
        period => 1              % optional
    },
    {ok, {SupFlags, ChildSpecs}}.