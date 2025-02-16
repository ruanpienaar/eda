-module(tcp_client_no_wait_reply).

-export([client/2]).

%% Lazily copied from erlang.org
client(PortNo,Message) ->
    {ok,Sock} = gen_tcp:connect("localhost",PortNo,[{active,false},{packet,2}]),
    ok = gen_tcp:send(Sock,Message),
    % A = gen_tcp:recv(Sock,0),
    ok = gen_tcp:close(Sock),
    % A.
    ok.