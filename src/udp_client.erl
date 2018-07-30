-module(udp_client).

-export([
    start_link/2,
    stop/2,
    send/4
]).

-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-define(SERVER, ?MODULE).

-define(STATE, udp_client_state).
-record(?STATE,{address, port, socket}).

%% ------------------------------------------------------------------
%% API

%% @doc Start a udp_client with a 4 octet tuple {0,0,0,0}, or host string.
%%      Specify a seperate port when starting the client on the same host,
%%      as where the server is started. and then specify the Server's port in
%%      send/4 at SendingPort
%% @end

start_link(Port, Opts) ->
    IpAddress = proplists:get_value(ip, Opts),
    gen_server:start_link({local, name(IpAddress, Port)}, ?MODULE, {IpAddress, Port, Opts}, []).

stop(Address, Port) ->
    IpAddress = proplists:get_value(ip, [Address]),
    gen_server:stop(name(IpAddress, Port)).

%% @doc call the started gen_server with name ?MODULE++address++port
%% @end

-spec send({ip, inet:socket_address()}, inet:port_number(), inet:port_number(), binary()) -> ok.
send(Address, Port, SendingPort, Packet) ->
    IpAddress = proplists:get_value(ip, [Address]),
    gen_server:cast(name(IpAddress, Port), {send, SendingPort, Packet}).

%% ------------------------------------------------------------------

init({Address, Port, Opts}) ->
    %% TODO: build solution for {error, Reason}...
    {ok, Socket} = gen_udp:open(Port, Opts),
    {ok, #?STATE{
        address = Address,
        port = Port,
        socket = Socket
    }}.

handle_call(_Request, _From, State) ->
    {reply, {error, unknown_call}, State}.

handle_cast({send, SendingPort, Packet}, #?STATE{ address = Address,
                                                  socket = Socket } = State) ->
    ok = gen_udp:send(Socket, Address, SendingPort, Packet),
    {noreply, State};
handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% ------------------------------------------------------------------
%% Internal

name(Address, Port) ->
    AddressString = case Address of
        A when is_tuple(Address) andalso size(Address) == 4 ->
            inet:ntoa(A);
        A when is_list(A) ->
            A;
        A when is_atom(A) ->
            atom_to_list(A)
    end,
    list_to_atom(
        atom_to_list(?MODULE)++"_"++AddressString++"_"++integer_to_list(Port)
    ).
