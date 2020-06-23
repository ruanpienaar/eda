-module(inc_example_2_udpv4).

-include_lib("kernel/include/logger.hrl").

-export([
    recv_data/1,
    event/1
]).

%% @doc This is a example callback module for eda_inc_udpv4
%% @end

% TODO: Create behaviour for UDP
% TODO: finish specs

% -spec recv_data(tuple()) -> ok | list().
recv_data(Data={_Address, _Port, _Packet, _Active = true}) ->
    ?LOG_DEBUG("CB MOD ~p\n~p\n", [?MODULE, Data]),
    % here we can select what active to return.
    % [{active, Active}];
    ok;
recv_data(Data={_Address, _Port, _Packet, Active}) ->
    ?LOG_DEBUG("CB MOD ~p\n~p\n", [?MODULE, Data]),
    % here we can select what active to return.
    [{active, Active}];
recv_data(Data) ->
    ?LOG_DEBUG("recv_data : ~p~n", [Data]).

% -spec event(events()) -> list().
event({{udp_passive, _Socket}, Active}) ->
    ?LOG_DEBUG("received udp_passive when active : ~p~n", [Active]),
    % here we can select what active to return.
    [{active, Active}];
event(Event) ->
    ?LOG_DEBUG("Unknown Event : ~p~n", [Event]),
    [].
