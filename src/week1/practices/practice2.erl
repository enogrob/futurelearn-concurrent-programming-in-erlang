-module(practice2).
-compile([export_all]).

start() ->
  register(receiver, spawn(?MODULE, receiver ,[])).

receiver() ->
  receive

    stop ->
      io:format("receiver has been stopped");

    {From, Msg} ->
      From ! {ok, Msg},
      receiver();

    Msg ->
      io:format("message:~w~n",[{ok, Msg}]),
      receiver()

  end.
