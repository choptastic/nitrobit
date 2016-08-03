%% -*- mode: nitrogen -*-
%% vim: ts=4 sw=4 et
-module (demo_v1).
-compile(export_all).
-include_lib("nitrogen_core/include/wf.hrl").
-include("records.hrl").

main() -> #template { file="./site/templates/bare.html" }.

title() -> "Welcome to NitroBit".

body() -> 
    #container_12{body=[
        #h1{text=title()},
        #panel{id=wrapper, body=entry_form()}
    ]}.

entry_form() ->
    #grid_12{body=[
        #label{text="Watch a Bitcoin Address"},
        #textbox{id=address, size=50, placeholder="YOUR BITCOIN ADDRESS"},
        #button{text="Start Watching", postback=start}
    ]}.

watching_form(Address) ->
    [
        #grid_6{style="text-align:Center", body=[
            #h3{text=Address},
            #qr{data=Address, size=300}
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
    wf:update(wrapper, watching_form(Address)),
    {ok, _Pid} = wf:comet(fun() -> transaction_loop(Address, []) end).


transaction_loop(Address, Txs) ->
    {Worth, AllTxs} = blockchain:get_address(Address),
    NewTxs = AllTxs -- Txs,
    wf:update(worth, blockchain:format_amount(Worth)),
    insert_transactions(NewTxs),
    wf:flush(),
    timer:sleep(5000),
    ?MODULE:transaction_loop(Address, NewTxs ++ Txs).

insert_transactions(Txs) ->
    TxsBody = [draw_transaction(T) || T <- Txs],
    wf:insert_top(transactions, TxsBody).

draw_transaction({_Hash, Time, Value, Action, Addresses}) ->
    #panel{actions=#effect{effect=slide, speed=1500}, body=[
        qdate:to_string("Y-m-d g:i:sa", Time),
        ", ",wf:to_list(Action), 
        " <b>",blockchain:format_amount(Value),"</b> ",
        wf:join(Addresses, ", "),
        #hr{}
    ]}.


















