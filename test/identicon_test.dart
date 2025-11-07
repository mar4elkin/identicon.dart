import 'dart:io';
import 'dart:convert';
import 'package:identicon_dart/identicon.dart';
import 'package:test/test.dart';

void main() {
  group('Identicon Class', () {
    const testValue = 'test';
    const testSize = 150;
    const testCellsCount = 5;

    late Identicon identicon;

    setUp(() {
      identicon = Identicon(value: testValue, size: testSize, cellsCount: testCellsCount);
    });

    group('Constructor', () {
      test('should create instance with default values', () {
        final defaultIdenticon = Identicon();
        expect(defaultIdenticon.value, equals('example'));
        expect(defaultIdenticon.size, equals(150));
        expect(defaultIdenticon.cellsCount, equals(5));
      });

      test('should create instance with custom values', () {
        expect(identicon.value, equals(testValue));
        expect(identicon.size, equals(testSize));
        expect(identicon.cellsCount, equals(testCellsCount));
      });

      test('should handle cellsCount outside valid range', () {
        expect(() => Identicon(cellsCount: 2), returnsNormally);
        expect(() => Identicon(cellsCount: 8), returnsNormally);
      });
    });

    group('Grid Generation', () {
      test('should generate non-empty grid', () {
        final grid = identicon.raw();
        expect(grid, isNotEmpty);
        expect(grid.length, equals(testCellsCount));
      });

      test('should generate symmetric grid', () {
        final grid = identicon.raw();
        
        for (int i = 0; i < grid.length; i++) {
          final row = grid[i];
          for (int j = 0; j < row.length ~/ 2; j++) {
            expect(row[j], equals(row[row.length - 1 - j]),
                reason: 'Row $i should be symmetric at positions $j and ${row.length - 1 - j}');
          }
        }
      });

      test('should generate grid with correct dimensions', () {
        final grid = identicon.raw();
        
        expect(grid.length, equals(testCellsCount));
        for (final row in grid) {
          expect(row.length, equals(testCellsCount));
        }
      });

      test('grid should contain only boolean values', () {
        final grid = identicon.raw();
        
        for (final row in grid) {
          for (final cell in row) {
            expect(cell, isA<bool>());
          }
        }
      });
    });

    group('Color Generation', () {
      test('should generate consistent color for same input', () {
        final identicon1 = Identicon(value: 'test');
        final identicon2 = Identicon(value: 'test');
        
        final grid1 = identicon1.raw();
        final grid2 = identicon2.raw();
        
        expect(grid1, equals(grid2));
      });

      test('should generate different colors for different inputs', () {
        final identicon1 = Identicon(value: 'test1');
        final identicon2 = Identicon(value: 'test2');
        
        final grid1 = identicon1.raw();
        final grid2 = identicon2.raw();
        
        expect(grid1, isNot(equals(grid2)));
      });
    });

    group('File Operations', () {
      const testFilename = 'test_identicon';

      tearDown(() {
        final file = File('$testFilename.png');
        if (file.existsSync()) {
          file.deleteSync();
        }
      });

      test('should create PNG file', () {
        identicon.toFile(filename: testFilename);
        
        final file = File('$testFilename.png');
        expect(file.existsSync(), isTrue);
        
        expect(file.lengthSync(), greaterThan(0));
      });

      test('should create file with default name', () {
        identicon.toFile();
        
        final file = File('identicon.png');
        expect(file.existsSync(), isTrue);
        file.deleteSync();
      });
    });

    group('Base64 Operations', () {
      test('should generate valid base64 string', () {
        final base64String = identicon.toBase64();
        
        expect(base64String, isNotEmpty);
        expect(base64String, startsWith('data:image/png;base64,'));
        
        final base64Data = base64String.replaceFirst('data:image/png;base64,', '');
        expect(() => base64.decode(base64Data), returnsNormally);
      });

      test('base64 string should contain image data', () {
        final base64String = identicon.toBase64();
        final base64Data = base64String.replaceFirst('data:image/png;base64,', '');
        final bytes = base64.decode(base64Data);
        
        expect(bytes, isNotEmpty);
        
        expect(bytes[0], equals(0x89));
        expect(bytes[1], equals(0x50));
        expect(bytes[2], equals(0x4E));
        expect(bytes[3], equals(0x47));
      });
    });

    group('Different Configurations', () {
      test('should work with different sizes', () {
        const sizes = [50, 100, 200, 500];
        
        for (final size in sizes) {
          final customIdenticon = Identicon(size: size);
          expect(() => customIdenticon.toBase64(), returnsNormally);
        }
      });

      test('should work with different cellsCount in valid range', () {
        const validCellsCounts = [3, 4, 5, 6, 7];
        
        for (final count in validCellsCounts) {
          final customIdenticon = Identicon(cellsCount: count);
          final grid = customIdenticon.raw();
          
          expect(grid.length, equals(count));
          for (final row in grid) {
            expect(row.length, equals(count));
          }
        }
      });

      test('should handle empty string value', () {
        expect(() => Identicon(value: ''), returnsNormally);
        final emptyIdenticon = Identicon(value: '');
        expect(emptyIdenticon.toBase64(), isNotEmpty);
      });

      test('should handle special characters in value', () {
        const specialValues = ['hello@world', 'test with spaces', '🎉emoji🎉'];
        
        for (final value in specialValues) {
          expect(() => Identicon(value: value), returnsNormally);
        }
      });
    });

    group('Performance', () {
      test('should generate identicon quickly', () {
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 100; i++) {
          Identicon(value: 'test$i');
        }
        
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });
  });
}