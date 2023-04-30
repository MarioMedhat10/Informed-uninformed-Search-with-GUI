create_board(Rows, Cols, Board) :-
    length(Board, Rows),
    create_rows(Cols, Board).

create_rows(_, []):-!.
create_rows(Cols, [Row|Rows]) :-
    length(Row, Cols),
    maplist(=(0),Row),
    create_rows(Cols, Rows).

print_board([]):-!.
print_board([Row|Rows]) :-
    write(Row), nl,
    print_board(Rows).

board(X,Y):-
    create_board(X,Y,R), print_board(R).

%replace a specific cell
replace([_|T], 1, X, [X|T]):-!.
replace([H|T], I, X, [H|R]) :-
    I > 1,
    NI is I - 1,
    replace(T, NI, X, R).

%assign a specific char to a specific cell
set_cell(Row, Col, Char, Board, NewBoard) :-
    nth1(Row, Board, OldRow),

    nth1(Col, OldRow, _),
    nth1(Row, NewBoard, NewRow),
    nth1(Col, NewRow, Char),
    replace(OldRow, Col, Char, NewRow),
    replace(Board, Row, NewRow, NewBoard).

place_bomb(R,C,Board,NewBoard):-
        (   nth1(R,Board,X),
            nth1(C,X,0))->
        set_cell(R,C,"*",Board,NewBoard);
        write('this bomb place is not empty'),false .


place_domino_horizontal(Row, Col, Board, NewBoard) :-

       nth1(Row,Board,X),
       nth1(Col,X,0),
       set_cell(Row, Col, "h", Board, TempBoard),
       Col1 is Col + 1,
       nth1(Row,TempBoard,Y),
       nth1(Col1,Y,0),
       set_cell(Row, Col1, "h", TempBoard, NewBoard).

place_domino_vertical(Row, Col, Board, NewBoard) :-

       nth1(Row,Board,X),
       nth1(Col,X,0),
       set_cell(Row, Col, "v", Board, TempBoard),
       Row1 is Row + 1,
       nth1(Row1,TempBoard,Y),
       nth1(Col,Y,0),
       set_cell(Row1, Col, "v", TempBoard, NewBoard).


place_domino(Board, NewBoard):-

   (place_domino_horizontal(_, _, Board, NewBoard);
    place_domino_vertical(_, _, Board, NewBoard)).


makeGame(Row,Col,B1X,B1Y,B2X,B2Y,MM):-
    create_board(Row,Col,B),
    place_bomb(B1X,B1Y,B,NB),
    place_bomb(B2X,B2Y,NB,NNB),

    search([[NNB,null]],[],MM,Row,Col).

isGoal(Row,Col,State):-
    findall((X,Y),isEmpty(Row,Col,State,X,Y),Goal),
    length(Goal,L),
    L is 0.

isEmpty(Row,Col,State,X1,Y1):-
    between(1,Row,X1),
    between(1,Col,Y1),
    (   nth1(X1,State,X),
    nth1(Y1,X,0),
    Row1 is X1 + 1,
    nth1(Row1,State,Y),
    nth1(Y1,Y,0));
    (  nth1(X1,State,X),
       nth1(Y1,X,0),
       Col1 is Y1 + 1,
       nth1(X1,State,Y),
       nth1(Col1,Y,0) ).

search(Open, Closed, Goal , Row,Col):-
    getState(Open, [CurrentState,Parent], _), % Step 1
    isGoal(Row,Col,CurrentState),
    CurrentState = Goal, % Step 2
    write("Search is complete!"), nl,
    printSolution([CurrentState,Parent], Closed).

search(Open, Closed, Goal,Row,Col):-
    getState(Open, CurrentNode, TmpOpen),
    getAllValidChildren(CurrentNode,TmpOpen,Closed,Children), % Step3
    addChildren(Children, TmpOpen, NewOpen), % Step 4
    append(Closed, [CurrentNode], NewClosed), % Step 5.1
    search(NewOpen, NewClosed, Goal,Row,Col). % Step 5.2

% Implementation of step 3 to get the next states
getAllValidChildren(Node, Open, Closed, Children):-
    findall(Next, getNextState(Node, Open, Closed, Next), Children).

getNextState([State,_], Open, Closed, [Next,State]):-
    place_domino(State, Next),
    not(member([Next,_], Open)),
    not(member([Next,_], Closed)).

% Implementation of getState and addChildren determine the search

% BFS
getState([CurrentNode|Rest], CurrentNode, Rest).
addChildren(Children, Open, NewOpen):-
append(Open, Children, NewOpen).

% Implementation of printSolution to print the actual solution path
printSolution([State, null],_):-
print_board(State), nl.
printSolution([State, Parent], Closed):-
member([Parent, GrandParent], Closed),
printSolution([Parent, GrandParent], Closed),
print_board(State), nl.
