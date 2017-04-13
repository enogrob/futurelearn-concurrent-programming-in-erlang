-module(frequency_supervisor).
-compile([export_all]).

start() ->
    register(supervisor, spawn(?MODULE, init, [])).

init() ->
    process_flag(trap_exit, true),
    start_server(),
    loop(whereis(frequency)).

start_server() ->
    register(frequency, spawn_link(frequency, init, [])).

loop(Pid) ->
    receive
        {'EXIT', Pid, Why} ->
            io:format("Server stopped because ~p~n", [Why]),
            start_server(),
            loop(spawn_link(frequency, init, []));
        {stop, From} ->
            io:format("Supervisor stopped!~n"),
            exit(Pid, kill),
            From ! {reply, ok}
    end.

stop() ->
    supervisor ! {stop, self()},
    receive
        {reply, Reply} ->
            Reply
    end.
