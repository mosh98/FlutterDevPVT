

import 'package:flutter_test/flutter_test.dart';

import 'package:dog_prototype/pages/mapPage_libs/mapPage_models/SearchSettings.dart';


const double MINVALUE = 1;
const double MAXVALUE = 100;
const double CURRENTVALUE = 50;
const double DIVISIONS = 10;


void main() {
     SearchSettings searchSettings;



    group('SearchSettings - default tests', () {
        test('create settings does not result in null', (){
            searchSettings = SearchSettings(MINVALUE, MAXVALUE, CURRENTVALUE, DIVISIONS);
            expect(searchSettings, isNot(null));
        });

        test('SearchSettings - get minvalue', () {
            expect(MINVALUE, searchSettings.getMinValue());
        });

        test('SearchSettings - get mavalue', () {
            expect(MAXVALUE, searchSettings.getMaxValue());
        });
        test('SearchSettings - get currentValue', () {
            expect(CURRENTVALUE, searchSettings.getCurrentValue());
        });

        test('SearchSettings - setCurrentValue out of min range', () {
            expect(false, searchSettings.setCurrentValue(MINVALUE-1));
        });


        test('SearchSettings - setCurrentValue out of max range', () {
            expect(false, searchSettings.setCurrentValue(MAXVALUE+1));
        });

        test('SearchSettings - setCurrentValue at max range', () {
            expect(MAXVALUE, searchSettings.setCurrentValue(MAXVALUE));
        });



        test('SearchSettings - setCurrentValue ', () {
            searchSettings = SearchSettings(MINVALUE, MAXVALUE, CURRENTVALUE, DIVISIONS);

            expect(CURRENTVALUE-1, searchSettings.setCurrentValue(CURRENTVALUE-1));
        });




    });
}
