-module(eda_out_sup).

-include_lib("kernel/include/logger.hrl").

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

    % TODO
    % - build screening per item ( check required fields present )

    {ok, OutProtos} = application:get_env(eda, outgoing_data_protocols),
    ChildSpecs =
        lists:foldl(fun({_Ref, Client}, Acc) ->
            {_Name, ClientOpts} = Client,
            case proplists:get_value(type, ClientOpts) of
                Type = ?TCPV4 ->
                    [ edc_sup:tcpv4_child_spec(Type, ClientOpts) | Acc ];
                X ->
                    ?LOG_WARNING("outgoing ~p unsupported protocol option.~n", [X]),
                    Acc
            end
        end, [], OutProtos),
    SupFlags = #{
        strategy => one_for_one, % optional
        intensity => 50,         % optional
        period => 5              % optional
    },
    {ok, {SupFlags, ChildSpecs}}.
