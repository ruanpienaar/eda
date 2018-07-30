-module(inc_example_2_udpv4).
-export([
    recv_data/1,
    event/1
]).

% TODO: Create behaviour for UDP
% TODO: finish specs

% -spec recv_data(tuple()) -> list().
recv_data(Data={Address, Port, Packet, Active}) ->
    io:format("CB MOD ~p\n~p\n", [?MODULE, Data]),
    % TODO: here we can select what active to return.
    [{active, Active}];
recv_data(Data) ->
    io:format("recv_data : ~p~n", [Data]).

% -spec event(events()) -> list().
event({{udp_passive, _Socket}, Active}) ->
    io:format("received udp_passive when active : ~p~n", [Active]),
    % TODO: here we can select what active to return.
    [{active, Active}];
event(Event) ->
    io:format("Unknown Event : ~p~n", [Event]),
    [].