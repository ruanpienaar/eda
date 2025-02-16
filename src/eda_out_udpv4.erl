-module(eda_out_udpv4).

-export([start_link/0]).

%% TODO: USE GUN !!!

% Try and connect to server,
% once connected, try and read data to send out.

start_link() ->
    {ok, proc_lib:start_link(?MODULE, init, [])}.

% init([]) ->
%     ok = proc_lib:init_ack({ok, self()}).