-module(inc_example_3_sslv4).

-include_lib("kernel/include/logger.hrl").

-behaviour(eda_incomming_proto_cb).

-export([
    recv_data/3
]).

recv_data(Pid, _SocketOpts, Data) ->
    % timer:sleep(1000),
    ?LOG_DEBUG("recv_data Pid: ~p, Data: ~p~n", [Pid, Data]).
