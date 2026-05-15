#include "..\script_component.hpp"
/*
 * Author: Lynx
 *
 *
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kat_triagecard_fnc
 *
 * Public: No
 */
 
params["_date"];
_year = _date select 0;
_month = _date select 1;
_months = [
	"JAN",
	"FEB",
	"MAR",
	"APR",
	"MAY",
	"JUN",
	"JUL",
	"AUG",
	"SEP",
	"OCT",
	"NOV",
	"DEC"
];
_month = _months select (_month - 1);
_day = _date select 2;

format ["%1-%2-%3", _day, _month, ((str _year) select [2,2])];
