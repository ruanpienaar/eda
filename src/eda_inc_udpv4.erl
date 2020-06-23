-module(eda_inc_udpv4).

-include_lib("kernel/include/logger.hrl").

-export([
    start_link/1,
    id/2
]).

%% TODO: shall we rename this module to eda_inc_udp? Since ipv6 is in Opts?

-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

% TODO : use maps
-define(STATE, eda_inc_udpv4_state).
-record(?STATE,{socket, recv_len, cb_mod, active}).

%% ------------------------------------------------------------------
%% API

start_link(Args) ->
    %% ?LOG_DEBUG("Args ~p\n\n\n", [Args]),
    OpenOpts = proplists:get_value(open_opts, Args),
    {ip, Address} = proplists:lookup(ip, OpenOpts),
    {port, Port} = proplists:lookup(port,Args),
    gen_server:start_link({local, name(Address, Port)}, ?MODULE, [Args], []).

id(Address, Port) ->
    name(Address, Port).

%% ------------------------------------------------------------------

init([Args]) ->
    {port,Port} = proplists:lookup(port,Args),
    {open_opts,OpenOpts} = proplists:lookup(open_opts,Args),
    {cb_mod, CbMod} = proplists:lookup(cb_mod, Args),
    {recv_len, RcvLen} = proplists:lookup(recv_len, Args),
    {ok, ServerSocket} = gen_udp:open(Port, OpenOpts),
    ?LOG_DEBUG("UDP OPEN ServerSocket ~p\n", [ServerSocket]),
    Active =
        case proplists:get_value(active, OpenOpts, false) of
            false ->
                % TODO: change recv messages to timeout, or tightloop?
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
        socket = ServerSocket,
        recv_len = RcvLen,
        cb_mod = CbMod,
        active = Active
    }}.

handle_call(Request, _From, State) ->
    ?LOG_WARNING("Unhandled Requst ~p ~n", [Request]),
    {reply, {error, unknown_call}, State}.

handle_cast(Msg, State) ->
    ?LOG_WARNING("Unhandled Msg ~p ~n", [Msg]),
    {noreply, State}.

% Active == false
handle_info(recv, #?STATE{ socket = ServerSocket,
                           recv_len = RecvLen,
                           cb_mod = CbMod,
                           active = Active = false } = State) ->
    case gen_udp:recv(ServerSocket, RecvLen) of
        {ok, {Address, Port, Packet}} ->
            case CbMod:recv_data({Address, Port, Packet, Active}) of
                ok ->
                    self() ! recv,
                    {noreply, State};
                [{active, false}] ->
                    self() ! recv,
                    {noreply, State};
                [{active, NewActive}] ->
                    ok = inet:setopts(ServerSocket, [{active, NewActive}]),
                    {noreply, State#?STATE{ active = NewActive }}
            end;
        {error, Reason} ->
            {stop, {error, Reason}, State}
    end;
% Active == true / once / N
handle_info({udp, ServerSocket, Address, Port, Packet},
        #?STATE{ socket = ServerSocket,
                 cb_mod = CbMod,
                 active = Active } = State) ->
    case CbMod:recv_data({Address, Port, Packet, Active}) of
        ok ->
            {noreply, State};
        [{active, NewActive}] ->
            ok = inet:setopts(ServerSocket, [{active, NewActive}]),
            {noreply, State#?STATE{ active = NewActive }}
    end;
% UDP passive
handle_info({udp_passive, ServerSocket},
        #?STATE{ socket = ServerSocket,
                 cb_mod = CbMod,
                 active = Active } = State) ->
    NewActive = CbMod:event({{udp_passive, ServerSocket}, Active}),
    ok = inet:setopts(ServerSocket, NewActive),
    {noreply, State#?STATE{ active = NewActive }};
handle_info(Info, State) ->
    ?LOG_WARNING("Unhandled Info ~p ~n", [Info]),
    {noreply, State}.

terminate(Reason, _State) ->
    ?LOG_WARNING("Terminate ~p ~p~n", [?MODULE, Reason]),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% ------------------------------------------------------------------
%% Internal

%% TODO: atom creation is a bit bad / undesired.
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
