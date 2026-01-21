:- module(simplex_wrapper, [main/0]).

:- use_module(library(charsio), [char_type/2]).
:- use_module(library(dcgs)).
:- use_module(library(lists), [foldl/4, sum_list/2, maplist/3, length/2]).
:- use_module(library(os), [argv/1]).
:- use_module(library(simplex), [gen_state/1, minimize/3, variable_value/3, constraint/3]).

digits([C|Cs]) --> [C], { char_type(C, numeric) }, digits(Cs).
digits([]) --> [].

integer(N) --> digits(Cs), { length(Cs, L), L > 0, number_chars(N, Cs) }, !.

xs([x(X)|Xs]) --> integer(X), xs(Xs).
xs(Xs) --> ",", xs(Xs).
xs([]) --> [].

constr([c(Xs, T)|Cs]) --> xs(Xs), "=", integer(T), constr(Cs).
constr(Cs) --> "|", constr(Cs).
constr([]) --> [].

linear_problem(lp(Obj, Cs)) --> xs(Obj), "|", constr(Cs).

parse_linear_problem(Cs, LP) :- once(phrase(linear_problem(LP), Cs)).

add_eq_constraint(c(Xs, T), S0, S) :- constraint(Xs = T, S0, S).
add_int_constraint(X, S0, S) :- constraint(integral(X), S0, S).
add_gte_zero_constraint(X, S0, S) :- constraint([X] >= 0, S0, S).

solve_equation(lp(Xs, Constr), Solution) :-
  gen_state(S0),
  foldl(add_eq_constraint, Constr, S0, S1),
  foldl(add_int_constraint, Xs, S1, S2),
  foldl(add_gte_zero_constraint, Xs, S2, S3),
  minimize(Xs, S3, S),
  maplist(variable_value(S), Xs, Vals),
  sum_list(Vals, Solution).

main :-
  argv(Input),
  maplist(parse_linear_problem, Input, LPs),
  maplist(solve_equation, LPs, Rs),
  sum_list(Rs, Sum),
  write(Sum), nl,
  halt.

