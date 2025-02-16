-module(inc_example_1_tcpv4_retransmit).

-include_lib("kernel/include/logger.hrl").

-behaviour(eda_incomming_proto_cb).

-export([
    recv_data/3
]).

recv_data(_Pid, _SocketOpts, _Data) ->
    % timer:sleep(1000),
    % eda_metrics:tcp_data_inc(),
    % ?LOG_INFO("recv_data Pid: ~p, SocketOpts: ~p. Data: ~p~n", [Pid, SocketOpts, Data]).
    ok.
