

class SearchSettings {

    double _minValue;
    double _maxValue;
    double _currentValue;
    double _divisions;

    SearchSettings(this._minValue, this._maxValue, this._currentValue, this._divisions);

    double get currentValue => _currentValue;

    set currentValue(double value) {
        _currentValue = value;
    }

    double get maxValue => _maxValue;

    set maxValue(double value) {
        _maxValue = value;
    }

    double get minValue => _minValue;

    set minValue(double value) {
        _minValue = value;
    }

    double get divisions => _divisions;

    set divisions(double value) {
        _divisions = value;
    }

    @override
    String toString() {
        return 'SearchSettings{_minValue: $_minValue, _maxValue: $_maxValue, _currentValue: $_currentValue, _divisions: $_divisions}';
    }


}