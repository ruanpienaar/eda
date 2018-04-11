-module(example_4_tcpipv4).
% -behaviour(eda_outgoing_proto_cb).
-export([
    read_data/0
]).

read_data() ->
    <<"Data">>.