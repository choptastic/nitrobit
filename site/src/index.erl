%% -*- mode: nitrogen -*-
%% vim: ts=4 sw=4 et
-module (index).
-compile(export_all).
-include_lib("nitrogen_core/include/wf.hrl").
-include("records.hrl").

main() -> #template { file="./site/templates/bare.html" }.

title() -> "Welcome to NitroBit".

body() ->
    #container_12{body=[
        #h1{text="Welcome to NitroBit!"},
        #panel{id=entry_form, body=[
            #grid_12{body=[
                #label{text="Watch a Bitcoin Address"},
                #textbox{id=address, size=40, placeholder="YOUR BITCOIN ADDRESS"},
                #button{postback=start, text="Start Watching"}
            ]}
        ]}
    ]}.

watching_form(Address) ->
    [
        #grid_6{body=[
            #h3{style="text-align:center", text=Address},
            #qr{data=Address, size="450"}
        ]},
        #grid_6{body=[
            #h3{body=[
                "Current Value: ",
                #span{id=worth, text="Loading..."}
            ]},
            #h3{text="Receipts"},
            #panel{id=transactions}
        ]}
    ].

event(start) ->
    Address = wf:q(address),
    wf:replace(entry_form, watching_form(Address)),
    wf:comet(fun() -> transaction_loop(Address, []) end).

transaction_loop(Address, Txs) ->
    {Worth, AllTxs} = blockchain:get_address(Address),
    NewTxs = AllTxs -- Txs,
    wf:update(worth, [blockchain:format_amount(Worth), " BTC"]),
    insert_transactions(NewTxs),
    wf:flush(),
    timer:sleep(5000),
    ?MODULE:transaction_loop(Address, NewTxs ++ Txs).

insert_transactions(Txs) ->
    TxsBody = [draw_transaction(T) || T <- Txs],
    wf:insert_top(transactions, TxsBody).

draw_transaction({_Hash, Time, Value, Addresses}) ->
    #panel{actions=#effect{effect=slide, speed=1500}, body=[
        qdate:to_string("Y-m-d g:ia", Time),
        ": <b>", blockchain:format_amount(Value), " BTC</b> received ",
        wf:join(Addresses,", "),
        #hr{}
    ]}.
