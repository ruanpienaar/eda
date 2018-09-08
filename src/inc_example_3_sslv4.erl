-module(inc_example_3_sslv4).
-behaviour(eda_incomming_proto_cb).
-export([
    recv_data/3
]).

recv_data(Pid, _SocketOpts, Data) ->
    % timer:sleep(1000),
    io:format("recv_data Pid: ~p, Data: ~p~n", [Pid, Data]).