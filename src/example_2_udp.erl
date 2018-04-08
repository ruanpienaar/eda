-module(example_2_udp).
-export([
    recv_data/1
]).

recv_data(Data) ->
    io:format("recv_data : ~p~n", [Data]).