-module(eda_inc_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-include("eda.hrl").

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

    {ok, IncProtos} = application:get_env(eda, incomming_data_protocols),
    ChildSpecs =
        lists:foldl(fun({Ref, ProtoOpts}, A) ->
            case proplists:get_value(type, ProtoOpts) of
                tcpipv4 ->
                    NumAcceptrs = proplists:get_value(num_acceptors, ProtoOpts),
                    Port = proplists:get_value(port, ProtoOpts),
                    ListenerSpec = ranch:child_spec(
                        Ref, NumAcceptrs, ranch_tcp,
                        [{port, Port}], eda_inc_tcpipv4_protocol, ProtoOpts
                    ),
                    [ListenerSpec|A];
                X ->
                    io:format("incomming ~p unsupported protocol option.~n", [X]),
                    A
            end
        end, [], IncProtos),

    % {ok, { {one_for_one, 5, 10}, Children} }.
    SupFlags = #{
        strategy => one_for_one, % optional
        intensity => 50,         % optional
        period => 5              % optional
    },
    {ok, {SupFlags, ChildSpecs}}.
