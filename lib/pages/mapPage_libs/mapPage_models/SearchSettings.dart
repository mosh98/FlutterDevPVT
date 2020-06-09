

import 'package:flutter/material.dart';

class SearchSettings {

    double _minValue;
    double _maxValue;
    double _currentValue;
    double _divisions;

    SearchSettings(this._minValue, this._maxValue, this._currentValue, this._divisions);


    double getCurrentValue() { return _currentValue; }
    double getDivisions() { return _divisions; }
    double getMinValue() { return _minValue; }
    double getMaxValue() { return _maxValue; }


    setMinValue(double value) {
        if (value > _maxValue)
            return false;
        return _minValue = value;
    }

     setMaxValue(double value) {
        if (value < _minValue)
            return false;
        return _maxValue = value;
    }

     setCurrentValue(double value) {
        if (!(value >= _minValue && value <= _maxValue))
            return false;
        return _currentValue = value;

    }

     setDivisions(double value) {
        if (value == null)
            return false;
        return _divisions = value;
    }



    @override
    String toString() {
        return 'SearchSettings{_minValue: $_minValue, _maxValue: $_maxValue, _currentValue: $_currentValue, _divisions: $_divisions}';
    }


}