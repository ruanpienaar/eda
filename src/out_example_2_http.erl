-module(out_example_2_http).
-export([
    send_data/0
]).

send_data() ->
    io:format("send_data ~n", []).