-module(eda_inc_sslv4).

-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-behaviour(ranch_protocol).
-export([
    start_link/4,
    set_active_once/1,
    set_active_true/1,
    set_active_false/1
]).

-define(TIMEOUT, 60000).

start_link(Ref, Socket, Transport, Opts) ->
    {ok, proc_lib:spawn_link(?MODULE, init, [{Ref, Socket, Transport, Opts}])}.

set_active_once(Pid) ->
    Pid ! {setopts, [{active, once}]}.

set_active_true(Pid) ->
    Pid ! {setopts, [{active, true}]}.

set_active_false(Pid) ->
    Pid ! {setopts, [{active, false}]}.


init({Ref, Socket, Transport, Opts}) ->
    CbMod = proplists:get_value(cb_mod, Opts),
    SocketOpts = proplists:get_value(socket_opts, Opts),
    ok = ranch:accept_ack(Ref),
    SocketOpts = proplists:get_value(socket_opts, Opts),
    SocketActiveState = proplists:get_value(active, SocketOpts, once),
    ok = Transport:setopts(Socket, SocketOpts),
    gen_server:enter_loop(?MODULE, [], #{
        ref => Ref,
        socket => Socket,
        transport => Transport,
        socket_opts => SocketOpts,
        socket_active_state => {active, SocketActiveState},
        cb_mod => CbMod
    }, 60000).

handle_call(_Request, _From, State) ->
    {reply, {error, unknown_call}, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

% TODO
% - Use active, true, but only with back pressure enabled.

handle_info({tcp, Socket, Data},
        #{ socket := Socket,
           transport := Transport,
           socket_active_state := {active, once},
           socket_opts := SocketOpts,
           cb_mod := CbMod } = State) ->
    ok = CbMod:recv_data(self(), SocketOpts, Data),
    ok = Transport:setopts(Socket, [{active, once}]),
    {noreply, State};
handle_info({tcp_closed, Socket}, #{ socket := Socket } = State) ->
    {stop, tcp_closed, State};
handle_info(Info, State) ->
    eda_log:log(warning, "Unknwon Info ~p\n", [Info]),
    {noreply, State}.

terminate(_Reason, #{
        socket := Socket,
        transport := Transport } = _State) ->
    ok = Transport:close(Socket).

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
