-module(out_example_2_http).

-include_lib("kernel/include/logger.hrl").

-export([
    send_data/0
]).

send_data() ->
    ?LOG_INFO("send_data ~n", []).
