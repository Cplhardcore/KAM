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
	LLSTRING(JAN),
	LLSTRING(FEB),
	LLSTRING(MAR),
	LLSTRING(APR),
	LLSTRING(MAY),
	LLSTRING(JUN),
	LLSTRING(JUL),
	LLSTRING(AUG),
	LLSTRING(SEP),
	LLSTRING(OCT),
	LLSTRING(NOV),
	LLSTRING(dec)
];
_month = _months select (_month - 1);
_day = _date select 2;

format ["%1-%2-%3", _day, _month, ((str _year) select [2,2])];
