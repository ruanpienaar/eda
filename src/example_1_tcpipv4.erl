-module(example_1_tcpipv4).
-export([
    recv_data/3
]).

recv_data(Pid, _SocketOpts, Data) ->
    % timer:sleep(1000),
    io:format("recv_data Pid: ~p, Data: ~p~n", [Pid, Data]).