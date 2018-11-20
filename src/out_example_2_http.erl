-module(out_example_2_http).
-export([
    send_data/0
]).

send_data() ->
    eda_log:log(debug, "send_data ~n", []).