-module(inc_example_1_tcpv4).
-behaviour(eda_incomming_proto_cb).
-export([
    recv_data/3
]).

recv_data(Pid, SocketOpts, Data) ->
    % timer:sleep(1000),
    eda_log:log(debug, "recv_data Pid: ~p, SocketOpts: ~p. Data: ~p~n", [Pid, SocketOpts, Data]).