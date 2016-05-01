-module(elgar_monitor).

-export([start/1]).

% Spawn exports
-export([accept/3,recv/2]).

start(Port) ->
    io:format("Starting Elgar Monitor on port ~p~n",[Port]),
    {ok, ListenSocket} = gen_tcp:listen(Port,[list,inet]),
    spawn(?MODULE,accept,[ListenSocket,[],{erlang:timestamp(),"starting..."}]).

accept(ListenSocket,Clients,Status) ->
    case gen_tcp:accept(ListenSocket,100) of
	{ok, Socket} ->
	    Pid = spawn(?MODULE,recv,[Socket,self()]),
	    gen_tcp:controlling_process(Socket, Pid),
	    inet:setopts(Socket, [{active, true},{nodelay,true}]),
	    accept(ListenSocket,[Pid | Clients],Status);
	{error,timeout} ->
	    receive
		terminate ->
		    io:format("Shutting down monitor.~n"),
		    %% Wait 1s so the webpage updates to finished...
		    timer:sleep(1000),
		    lists:map(fun(C) -> C ! terminate end, Clients),
		    gen_tcp:close(ListenSocket);
		{status,NewStatus} ->
		    accept(ListenSocket,Clients,{erlang:timestamp(),NewStatus});
		{get_status,From} ->
		    From ! Status,
		    accept(ListenSocket,Clients,Status)
	    after 100 ->
		    accept(ListenSocket,Clients,Status)
	    end;
	{error,closed} ->
	    ok;
	Error ->
	    io:format("MONITOR ACCEPT ERROR: ~p~n",[Error]),
	    gen_tcp:close(ListenSocket),
	    Error
    end.

recv(Socket,Parent) ->
    receive
	{tcp,Socket,Packet} ->
	    Parent ! {get_status,self()},
	    ResMsg = receive 
			 Status ->
			     make_http(process(Packet,Status))
		     end,
	    gen_tcp:send(Socket, ResMsg),
	    gen_tcp:close(Socket);
	{tcp_closed,Socket} ->
	    ok;
	{tcp_error,Socket,Reason} ->
	    io:format("MONITOR CLIENT ERROR: ~p~n",[Reason]),
	    gen_tcp:close(Socket),
	    {error,Reason};
	terminate ->
	    gen_tcp:send(Socket,"Elgar shutting down.\n"),
	    gen_tcp:close(Socket);
	Other ->
	    io:format("UNEXPECTED MONITOR CLIENT MESSAGE: ~p~n",[Other]),
	    recv(Socket,Parent)
    end.

process("GET " ++ More,Status) ->
    Lines = re:split(More,"\r\n"),
    %% io:format("Lines:~p~n",[Lines]),
    W1 = re:split(hd(Lines)," "),
    %% io:format("W1:~p~n",[W1]),
    File = hd(W1),

    case File of
	<<"/">> ->
	    {200,"OK",[{"Content-Type", "text/html"},{"Connection","close"}],page()};
	<<"/status">> ->
	    {200,"OK",[{"Content-Type", "text/html"},{"Connection","close"}],make_status(Status)};
	_Other ->
	    {404,"Not Found",[{"Content-Type", "text/html"}],"That URL is not supported."}
    end;
process(_Packet,_Status) ->
    {501,"Not Implemented",[],""}.

make_http({Code,Msg,Details,Content}) ->
    Start = lists:flatten(io_lib:format("HTTP/1.1 ~p ~s\r\n",[Code,Msg])),
    DMsg = lists:flatten(lists:map(fun({D,V}) -> lists:flatten(io_lib:format("~s: ~s\r\n",[D,V])) end, Details)),
    ConMsg = lists:flatten(io_lib:format("\r\n~s\r\n\r\n",[Content])),
    Start ++ DMsg ++ ConMsg.

page() ->
    "<html>\n" ++
	"<head>\n" ++
	"<title>Elgar Monitor</title>\n" ++
	"<script src=\"https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js\"></script>" ++
	"</head>\n" ++
	"<body>\n" ++
	"<h1>Elgar Status</h1>\n" ++
	"<div id=\"status\"></div>" ++
	"<script type=\"text/javascript\">function update() { $(\"#status\").load(\"/status\"); window.setTimeout(update,1000);} update();</script>\n" ++
	"</body>\n" ++
	"</html>".

make_status({StatDate,Status}) ->
    {{Y,M,D},{H,Min,S}} = calendar:now_to_datetime(StatDate),
    lists:flatten(io_lib:format("<h4>Status at ~4..0B/~2..0B/~2..0B ~2..0B:~2..0B:~2..0B</h4>\n~s\n",[Y,M,D,H,Min,S,Status]));
make_status(Stat) ->
    lists:flatten(io_lib:format("<h4>Status</h4>~p~n",[Stat])).


