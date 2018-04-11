-module(eda_out_sup).

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

    {ok, OutProtos} = application:get_env(eda, outgoing_data_protocols),
    ChildSpecs =
        lists:foldl(fun({_Ref, ProtoOpts}, A) ->
            case proplists:get_value(type, ProtoOpts) of
                tcpipv4 ->
                    % [?CHILD(eda_out_tcpipv4_protocol, worker)|A];
                    % TODO: we need to create it per ID, so that it's unique...
                    A;
                X ->
                    io:format("outgoing ~p unsupported protocol option.~n", [X]),
                    A
            end
        end, [], OutProtos),

    % {ok, { {one_for_one, 5, 10}, Children} }.
    SupFlags = #{
        strategy => one_for_one, % optional
        intensity => 50,         % optional
        period => 5              % optional
    },
    {ok, {SupFlags, ChildSpecs}}.

