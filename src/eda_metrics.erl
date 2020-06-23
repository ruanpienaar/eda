-module(eda_metrics).

-export([
    init/0,
    tcp_data_inc/0
]).

init() ->
    ok = prometheus_counter:new(
        [
            {name, tcp_inc_data_count},
            {help, "Number of data receives from client"}
        ]
    ).

tcp_data_inc() ->
    prometheus_counter:inc(tcp_inc_data_count).
