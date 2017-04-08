-module(palin).
-export([palin/1,nopunct/1,palindrome/1, server/1, pal_check/1]).

% palindrome problem
%
% palindrome("Madam I\'m Adam.") = true

rem_punct(String) -> lists:filter(
                      fun (Ch) ->
                        not(lists:member(Ch,".\"\'\t\n "))
                      end,
                      String).

to_small(String) -> lists:map(
                    fun(Ch) ->
                      case ($A =< Ch andalso Ch =< $Z) of
                        true -> Ch+32;
                        false -> Ch
                      end
                    end,
                    String).

palindrome_check(String) ->
                    Normalise = to_small(rem_punct(String)),
                    lists:reverse(Normalise) == Normalise.
nopunct([]) ->
    [];
nopunct([X|Xs]) ->
    case lists:member(X,".,\ ;:\t\n\'\"") of
	     true ->
	        nopunct(Xs);
	     false ->
	        [ X | nopunct(Xs) ]
    end.

nocaps([]) ->
    [];
nocaps([X|Xs]) ->
    [ nocap(X) | nocaps(Xs) ].

nocap(X) ->
    case $A =< X andalso X =< $Z of
	     true ->
	        X+32;
	     false ->
	        X
    end.

% literal palindrome

palin(Xs) ->
    Xs == reverse(Xs).

reverse(Xs) ->
    shunt(Xs,[]).

shunt([],Ys) ->
    Ys;
shunt([X|Xs],Ys) ->
    shunt(Xs,[X|Ys]).

palindrome(Xs) ->
    palin(nocaps(nopunct(Xs))).

pal_check(String) ->
  String==lists:reverse(String).

server(Pid) ->
  receive
    stop ->
      io:format("palin ~w is stopped ~n", [Pid]);

    {check, X} ->
      Result = palindrome_check(X),
      if
        Result == true ->
          Pid ! {Result, X ++ " is palindrome"};
        true ->
          Pid ! {Result, X ++ " is not palindrome"}
      end,
      server(Pid)
  end.
%   receive
%     {check, X} ->
%       Result = pal_check(X);
%       server(Pid);
%       % if
%       %   Result == true ->
%       %     Pid ! {result, X ++ " is a palindrome"};
%       %   true ->
%       %     Pid ! {result, X ++ " is not a palindrome"}
%       % end;
%     {stop, _} ->
%           io:format("palin stopped ~w~n",[Pid]);
%   end.
