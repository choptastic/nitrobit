-module(nitrogen_main_handler).
-export([run/0, ws_init/0]).

handlers() ->
	nitrogen:handler(debug_crash_handler, []).

ws_init() ->
	handlers().

run() ->
	%% Put any custom handlers here
	%% See http://nitrogenproject.com/doc/handlers.html
	%% Example:
	%%
	%%   wf_handler:set_handler(MySecurityHandler, HandlerConfig),
	%%
	wf:header('cache-control',"no-cache"),
	wf:content_type("text/html; charset=utf-8"),
	handlers(),
	wf_core:run().
