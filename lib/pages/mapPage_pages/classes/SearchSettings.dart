

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


    void setMinValue(double value) {
        _minValue = value;
    }

    void setMaxValue(double value) {
        _maxValue = value;
    }

    void setCurrentValue(double value) {
        _currentValue = value;
    }

    void setDivisions(double value) {
        _divisions = value;
    }



    @override
    String toString() {
        return 'SearchSettings{_minValue: $_minValue, _maxValue: $_maxValue, _currentValue: $_currentValue, _divisions: $_divisions}';
    }


}