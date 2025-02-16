-module(tcp_server).

-export([start/2]).

%% Lazily copied from erlang.org
start(Num,LPort) ->
    case gen_tcp:listen(LPort,[{active, false},{packet,2}]) of
        {ok, ListenSock} ->
            ok = start_servers(Num,ListenSock),
            {ok, Port} = inet:port(ListenSock),
            Port;
        {error,Reason} ->
            {error,Reason}
    end.

start_servers(0,_) ->
    ok;
start_servers(Num,LS) ->
    _ = spawn(fun() -> server(LS) end),
    start_servers(Num-1, LS).

server(LS) ->
    case gen_tcp:accept(LS) of
        {ok,S} ->
            ok = loop(S),
            ok = server(LS);
        Other ->
            io:format("accept returned ~w - goodbye!~n",[Other]),
            ok
    end.

loop(S) ->
    ok = inet:setopts(S, [{active,once}]),
    receive
        {tcp,S,Data} ->
            Answer = process(Data),
            ok = gen_tcp:send(S, Answer),
            loop(S);
        {tcp_closed,S} ->
            io:format("Socket ~w closed [~w]~n",[S,self()]),
            ok
    end.

process(Data) ->
    io:format("~p ~p\n", [?FUNCTION_NAME, Data]),
    <<"reply">>.