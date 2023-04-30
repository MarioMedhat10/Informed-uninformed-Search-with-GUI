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
    %(false ->write('this place is not empty');   set_cell(R,C,*,Board,NewBoard)).


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


place_domino(Board, NewBoard,MoveCost):-

   (place_domino_horizontal(_, _, Board, NewBoard);
    place_domino_vertical(_, _, Board, NewBoard)),
   MoveCost is 1.


makeGame(Row,Col,B1X,B1Y,B2X,B2Y,MM,MaxDominos):-
    create_board(Row,Col,B),
    place_bomb(B1X,B1Y,B,NB),
    place_bomb(B2X,B2Y,NB,NNB),

    search([[NNB,null,0,0,0]],[],MM,MaxDominos,Row,Col).


isGoal(Row,Col,State,MaxDominos):-
    findall((X,Y),isEmpty(Row,Col,State,X,Y),Goal),
    length(Goal,L),
    MaxDominos is ((Row * Col)-2-L) div 2,
    L is 0,
    MaxDominos is ((Row * Col)-2) div 2.

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

search(Open, Closed, Goal,MaxDominos,Row,Col):-
    getBestState(Open, [CurrentState,Parent,G,H,F], _), % Step 1
    isGoal(Row,Col,CurrentState,MaxDominos),
    MaxDominos is G,
    CurrentState = Goal, % Step 2
    write("Search is complete!"), nl,
    printSolution([CurrentState,Parent,G,H,F], Closed).

search(Open, Closed, Goal,MaxDominos,Row,Col):-
    getBestState(Open, CurrentNode, TmpOpen),
    getAllValidChildren(CurrentNode,TmpOpen,Closed,Goal,Children,Row,Col), % Step3
    addChildren(Children, TmpOpen, NewOpen), % Step 4
    append(Closed, [CurrentNode], NewClosed), % Step 5.1
    search(NewOpen, NewClosed, Goal, MaxDominos,Row,Col ). % Step 5.2

% Implementation of step 3 to get the next states
getAllValidChildren(Node, Open, Closed, Goal, Children,Row,Col):-
    findall(Next, getNextState(Node,Open,Closed,Goal,Next,Row,Col),Children).

getNextState([State,_,G,_,_],Open,Closed,Goal,[Next,State,NewG,NewH,NewF],Row,Col):-
    place_domino(State, Next, MoveCost),
    calculateH(Next, Goal, NewH,Row,Col),
    NewG is G + MoveCost,
    NewF is NewG + NewH,
    not(member([Next,_,_,_,_], Open)),
    not(member([Next,_,_,_,_], Closed)).

calculateH(Next ,_ ,NewH,Row,Col):-
    findall((X,Y),isEmpty(Row,Col,Next,X,Y),L),
    length(L ,NewH ).

% Implementation of addChildren and getBestState
addChildren(Children, Open, NewOpen):-
    append(Open, Children, NewOpen).

getBestState(Open, BestChild, Rest):-
    findMin(Open, BestChild),
    delete(Open, BestChild, Rest).
% Implementation of findMin in getBestState determines the search

% Greedy best-first search
findMin([X], X):- !.

findMin([Head|T], Min):-
    findMin(T, TmpMin),
    Head = [_,_,_,HeadH,_],
    TmpMin = [_,_,_,TmpH,_],
    (TmpH < HeadH -> Min = TmpMin ; Min = Head).

% Instead of adding children at the end and searching for the best
% each time using getBestState, we can make addChildren add in the
% right place (sorted open list) and getBestState just returns the
% head of open.

% Implementation of printSolution to print the actual solution path
printSolution([State, null, G, H, F],_):-
    print_board(State), nl,
    format("The move cost is ~d",G),nl,
    format("The heuristic cost is ~d",H),nl,
    format("The evaluation function cost is ~d",F),nl.

printSolution([State, Parent, G, H, F], Closed):-
    member([Parent, GrandParent, PrevG, Ph, Pf], Closed),
    printSolution([Parent, GrandParent, PrevG, Ph, Pf], Closed),
    print_board(State), nl,
    format("The move cost is ~d",G),nl,
    format("The heuristic cost is ~d",H),nl,
    format("The evaluation function cost is ~d",F),nl.

