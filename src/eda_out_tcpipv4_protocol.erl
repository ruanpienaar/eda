-module(eda_out_tcpipv4_protocol).

-export([start_link/0]).

% Try and connect to server,
% once connected, try and read data to send out.

start_link() ->
    {ok, proc_lib:start_link(?MODULE, init, [])}.

init([]) ->
    ok = proc_lib:init_ack({ok, self()}).