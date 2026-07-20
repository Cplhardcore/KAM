#include "..\script_component.hpp"
/*
 *
 * Public: No
 */

params [["_progress", 0, [0]], ["_start", 1, [0]], ["_peak", 1.1, [0]], ["_end", 0.6, [0]], ["_peakPos", 0.5, [0]]];

_progress = _progress max 0 min 1;
_peakPos = _peakPos max 0.01 min 0.99;

private _result = if (_progress <= _peakPos) then {
    private _t = _progress / _peakPos;
    _start + ((_peak - _start) * sin (_t * 90))
} else {
    private _t = (_progress - _peakPos) / (1 - _peakPos);
    _peak + ((_end - _peak) * sin (_t * 90))
};

_result

