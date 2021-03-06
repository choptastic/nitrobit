%% -*- mode: nitrogen -*-
%% vim: ts=4 sw=4 et
-module (index).
-compile(export_all).
-include_lib("nitrogen_core/include/wf.hrl").
-include("records.hrl").

main() -> #template { file="./site/templates/bare.html" }.

title() -> "Welcome to NitroBit".

address() -> "16i9Fbitroc54ZsJVuuSkQ4R65hMnufZMi".

autostart() ->
    wf:comet(fun() -> transaction_loop(address(), []) end).

body() ->
    {ok, Pid} = autostart(),
    #container_12{body=[
        #h1{text="Welcome to NitroBit!"},
        #panel{id=wrapper, body=watching_form(Pid, address())}
    ]}.

entry_form() ->
    #grid_12{body=[
        #label{text="Watch a Bitcoin Address"},
        #textbox{id=address, size=40, placeholder="YOUR BITCOIN ADDRESS"},
        #button{postback=start, text="Start Watching"}
    ]}.

watching_form(Pid, Address) ->
    [
        #grid_6{style="text-align:center", body=[
            #h3{text=Address},
            #button{text="Lookup Another Address", postback={cancel, Pid}},
            #qr{data=Address, size="450"}
        ]},
        #grid_6{body=[
            #h3{body=[
                "Current Value: ",
                #span{id=worth, text="Loading..."}
            ]},
            #panel{id=transactions}
        ]}
    ].

event(start) ->
    Address = wf:q(address),
    {ok, Pid} = wf:comet(fun() -> transaction_loop(Address, []) end),
    wf:update(wrapper, watching_form(Pid, Address));

event({cancel, Pid}) ->
    erlang:exit(Pid, kill),
    wf:update(wrapper, entry_form()).

transaction_loop(Address, Txs) ->
    {Worth, AllTxs} = blockchain:get_address(Address),
    NewTxs = AllTxs -- Txs,
    wf:update(worth, blockchain:format_amount(Worth)),
    insert_transactions(NewTxs),
    wf:flush(),
    timer:sleep(10000),
    ?MODULE:transaction_loop(Address, NewTxs ++ Txs).

insert_transactions(Txs) ->
    TxsBody = [draw_transaction(T) || T <- Txs],
    wf:insert_top(transactions, TxsBody).

draw_transaction({_Hash, Time, Value, Action, Addresses}) ->
    #panel{actions=#effect{effect=slide, speed=1500}, body=[
        qdate:to_string("Y-m-d g:ia", Time),
        ": ",wf:to_list(Action)," <b>", blockchain:format_amount(Value),"</b> ",
        wf:join(Addresses,", "),
        #hr{}
    ]}.
