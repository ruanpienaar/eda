-module(inc_example_2_udpv4).
-export([
    recv_data/1,
    event/1
]).

%% @doc This is a example callback module for eda_inc_udpv4
%% @end

% TODO: Create behaviour for UDP
% TODO: finish specs

% -spec recv_data(tuple()) -> ok | list().
recv_data(Data={Address, Port, Packet, Active = true}) ->
    io:format("CB MOD ~p\n~p\n", [?MODULE, Data]),
    % here we can select what active to return.
    % [{active, Active}];
    ok;
recv_data(Data={Address, Port, Packet, Active}) ->
    io:format("CB MOD ~p\n~p\n", [?MODULE, Data]),
    % here we can select what active to return.
    [{active, Active}];
recv_data(Data) ->
    io:format("recv_data : ~p~n", [Data]).

% -spec event(events()) -> list().
event({{udp_passive, _Socket}, Active}) ->
    io:format("received udp_passive when active : ~p~n", [Active]),
    % here we can select what active to return.
    [{active, Active}];
event(Event) ->
    io:format("Unknown Event : ~p~n", [Event]),
    [].