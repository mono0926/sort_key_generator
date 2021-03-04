import 'package:sort_key_generator/sort_key_generator.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    test('not arguments', () {
      expect(generateSortKeyDouble(), 0);
    });
    test('previousのみ', () {
      expect(generateSortKeyDouble(previous: 0), 1);
    });
    test('nextのみ', () {
      expect(generateSortKeyDouble(next: 0), -1);
    });
    test('nextとprevious', () {
      expect(generateSortKeyDouble(previous: 1, next: 2), 1.5);
    });
    test('Generate 1074 times', () {
      var current = 1.0;
      List.generate(1074, (i) {
        final result = generateSortKeyDouble(previous: 0, next: current)!;
        expect(result, isNotNull);
        expect(result > 0, isTrue);
        expect(result < current, isTrue);
        current = result;
      });
      print(current);
    });
    test('Generate 1075 times → null', () {
      double? current = 1;
      List.generate(1075, (i) {
        final result = generateSortKeyDouble(previous: 0, next: current);
        current = result;
      });
      expect(current, isNull);
    });
  });
}
