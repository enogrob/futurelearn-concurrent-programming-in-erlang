-module(frequency).
-export([start/0,allocate/0,deallocate/1,stop/0,test_overload/0,test_overload_and_clear/0]).
-export([init/0]).

%% These are the start functions used to create and
%% initialize the server.

start() ->
    register(frequency,
	     spawn(frequency, init, [])).

init() ->
  Frequencies = {get_frequencies(), []},
  loop(Frequencies).

% Hard Coded
get_frequencies() -> [10,11,12,13,14,15].

%% The Main Loop
loop(Frequencies) ->
  timer:sleep(1500),
  receive
    {request, Pid, allocate} ->
      {NewFrequencies, Reply} = allocate(Frequencies, Pid),
      Pid ! {reply, Reply},
      loop(NewFrequencies);
    {request, Pid , {deallocate, Freq}} ->
      NewFrequencies = deallocate(Frequencies, Freq),
      Pid ! {reply, ok},
      loop(NewFrequencies);
    {request, Pid, stop} ->
      Pid ! {reply, stopped}
  end.

%% Functional interface

allocate() ->
    frequency ! {request, self(), allocate},
    receive
	    {reply, Reply} -> Reply
    after 1000 ->
      io:format("the server is overloaded, request  failed~n")
    end.

deallocate(Freq) ->
    frequency ! {request, self(), {deallocate, Freq}},
    receive
	    {reply, Reply} -> Reply
    after 1000 ->
      io:format("the server is overloaded, request  failed~n")
    end.

clear() ->
  receive
    _Msg ->
    io:format("~w ~n", [_Msg]),
    clear()
  after 0 ->
    ok
  end.

stop() ->
    frequency ! {request, self(), stop},
    receive
      {reply, Reply} -> Reply
    after 1000 ->
      io:format("the server is overloaded, request  failed~n")
    end.

%% The Internal Help Functions used to allocate and
%% deallocate frequencies.

allocate({[], Allocated}, _Pid) ->
  {{[], Allocated}, {error, no_frequency}};
allocate({[Freq|Free], Allocated}, Pid) ->
  {{Free, [{Freq, Pid}|Allocated]}, {ok, Freq}}.

deallocate({Free, Allocated}, Freq) ->
  NewAllocated=lists:keydelete(Freq, 1, Allocated),
  {[Freq|Free],  NewAllocated}.

% Tests in order to simulate overload

test_overload() ->
  start(),
  allocate(),
  allocate(),
  allocate(),
  allocate(),
  allocate(),
  allocate(),
  io:format("Wait (6 * 1500) = 6 seconds~n"),
  % will show messages
  timer:sleep(6000),
  clear(),
  frequency:stop().

test_overload_and_clear() ->
  start(),
  allocate(),
  timer:sleep(1500),
  allocate(),
  timer:sleep(1500),
  allocate(),
  timer:sleep(1500),
  clear(),
  frequency:stop().
