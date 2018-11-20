-module(eda_inc_sup).

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

    {ok, IncProtos} = application:get_env(eda, incomming_data_protocols),
    ChildSpecs =
        lists:foldl(fun({Ref, ProtoOpts}, A) ->
            case proplists:get_value(type, ProtoOpts) of
                ?TCPV4 ->
                    NumAcceptrs = proplists:get_value(num_acceptors, ProtoOpts),
                    Port = proplists:get_value(port, ProtoOpts),
                    ListenerSpec = ranch:child_spec(
                        Ref, NumAcceptrs, ranch_tcp,
                        [{port, Port}], eda_inc_tcpv4, ProtoOpts
                    ),
                    [ListenerSpec|A];
                ?UDPV4 ->
                    OpenOpts = proplists:get_value(open_opts, ProtoOpts),
                    {ip, Address} = proplists:lookup(ip, OpenOpts),
                    Port = proplists:get_value(port, ProtoOpts),
                    [eda:child(eda_inc_udpv4:id(Address, Port), eda_inc_udpv4, worker, [ProtoOpts])|A];
                ?SSLV4 ->
                    NumAcceptrs = proplists:get_value(num_acceptors, ProtoOpts),
                    Port = proplists:get_value(port, ProtoOpts),
                    ListenerSpec = ranch:child_spec(
                        Ref, NumAcceptrs, ranch_ssl,
                        [
                            {port, Port},
                            {certfile, "/Users/ruanpienaar/code/eda/priv/rootCA.crt"},
                            {keyfile, "/Users/ruanpienaar/code/eda/priv/rootCA.pem"}
                        ], eda_inc_sslv4, ProtoOpts
                    ),
                    [ListenerSpec|A];
                X ->
                    eda_log:log(warning, "incomming ~p unsupported protocol option.~n", [X]),
                    A
            end
        end, [], IncProtos),

    SupFlags = #{
        strategy => one_for_one, % optional
        intensity => 50,         % optional
        period => 5              % optional
    },
    {ok, {SupFlags, ChildSpecs}}.

