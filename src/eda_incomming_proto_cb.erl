-module(eda_incomming_proto_cb).

-callback recv_data(EDAProtoPid :: pid(), SocketOpts :: proplists:proplist(), Data :: term()) -> ok.