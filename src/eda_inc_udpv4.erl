-module(eda_inc_udpv4).

-export([
    start_link/1,
    id/2
]).

-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

% TODO : use maps
-define(STATE, eda_inc_udpv4_state).
-record(?STATE,{socket, recv_len, cb_mod, active}).

%% ------------------------------------------------------------------
%% API

start_link(Args) ->
    %io:format("Args ~p\n\n\n", [Args]),
    OpenOpts = proplists:get_value(open_opts, Args),
    {ip, Address} = proplists:lookup(ip, OpenOpts),
    {port,Port} = proplists:lookup(port,Args),
    gen_server:start_link({local, name(Address, Port)}, ?MODULE, [Args], []).

id(Address, Port) ->
    name(Address, Port).

%% ------------------------------------------------------------------

init([Args]) ->
    % dbg:tracer(),
    % dbg:p(all, call),
    % dbg:tpl(gen_udp, cx),
    {port,Port} = proplists:lookup(port,Args),
    {open_opts,OpenOpts} = proplists:lookup(open_opts,Args),
    {cb_mod, CbMod} = proplists:lookup(cb_mod, Args),
    {recv_len, RcvLen} = proplists:lookup(recv_len, Args),
    {ok, Socket} = gen_udp:open(Port, OpenOpts),
    io:format("UDP OPEN Socket ~p\n", [Socket]),
    Active =
        case proplists:get_value(active, OpenOpts, {active, false}) of
            false ->
                self() ! recv,
                false;
            true ->
                true;
            once ->
                once;
            N when is_integer(N) ->
                N
        end,
    {ok, #?STATE{
        socket = Socket,
        recv_len = RcvLen,
        cb_mod = CbMod,
        active = Active
    }}.

handle_call(Request, _From, State) ->
    io:format("Unhandled Requst ~p ~n", [Request]),
    {reply, {error, unknown_call}, State}.

handle_cast(Msg, State) ->
    io:format("Unhandled Msg ~p ~n", [Msg]),
    {noreply, State}.

handle_info(recv, #?STATE{ socket = Socket,
                           recv_len = RecvLen,
                           cb_mod = CbMod,
                           active = Active = false } = State) ->
    case gen_udp:recv(Socket, RecvLen) of
        {ok, {Address, Port, Packet}} ->
            ok = CbMod:recv_data({Address, Port, Packet, Active}),
            % TODO: change to timeout...
            %       or tight loop
            self() ! recv,
            {noreply, State};
        {error, Reason} ->
            {stop, {error, Reason}, State}
    end;
handle_info({udp, ServerSocket, Address, Port, Packet},
        #?STATE{ socket = ServerSocket,
                 cb_mod = CbMod,
                 active = Active = true } = State) ->
    ok = CbMod:recv_data({Address, Port, Packet}),
    {noreply, State};
handle_info({udp, ServerSocket, Address, Port, Packet, Active},
        #?STATE{ socket = ServerSocket,
                 cb_mod = CbMod,
                 active = once } = State) ->
    ok = CbMod:recv_data({Address, Port, Packet, Active}),
    % TODO: we could actually write a callback behaviour for
    %       udp, where active is passed to the mod,
    %       allowing the CBMod to decice whether to apply
    %       backpressure.
    % So let the CB mod reply with ACTIVE
    ok = inet:setopts(ServerSocket, [{active, once}]),
    {noreply, State};
handle_info({udp_passive, ServerSocket},
        #?STATE{ socket = ServerSocket,
                 cb_mod = CbMod,
                 active = Active } = State) ->
    NewActive = CbMod:event({{udp_passive, ServerSocket}, Active}),
    ok = inet:setopts(ServerSocket, NewActive),
    {noreply, State};
handle_info(Info, State) ->
    io:format("Unhandled Info ~p ~n", [Info]),
    {noreply, State}.

terminate(Reason, _State) ->
    io:format("Terminate ~p ~p~n", [?MODULE, Reason]),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% ------------------------------------------------------------------
%% Internal

name(Address, Port) ->
    AddressString = case Address of
        A when is_tuple(Address) ->
            inet:ntoa(A);
        A when is_list(A) ->
            A;
        A when is_atom(A) ->
            atom_to_list(A)
    end,
    list_to_atom(
        atom_to_list(?MODULE)++"_"++AddressString++"_"++integer_to_list(Port)
    ).
