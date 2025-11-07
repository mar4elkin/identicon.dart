import 'dart:io';
import 'dart:convert';
import 'package:image/image.dart';
import 'package:crypto/crypto.dart';

class Color {
  final int r;
  final int g;
  final int b;

  Color({required this.r, required this.g, required this.b});

  @override
  String toString() {
    return 'Color{R: $r, G: $g, B: $b}';
  }
}

class Identicon {
  final String value;
  final int size;
  final int cellsCount;

  late final Color _color;
  late final List<List<bool>> _grid = [];
  late final Image _img;
  

  Identicon({
    this.value = "example",
    this.size = 150,
    this.cellsCount = 5
  }) {
    if (cellsCount < 3 || cellsCount > 7) {
      return;
    }

    var hash = md5.convert(utf8.encode(value)).bytes;
    var middle = (cellsCount / 2).ceil();
    
    _color = Color(r: hash[0], g: hash[1], b: hash[2]);

    for (int i = 0; i < cellsCount; i++) {
      _grid.add([]);
      for (int j = 0; j < middle; j++) {
        int hashIndex = (i * middle + j) % hash.length;
        _grid[i].add(hash[hashIndex].isEven);
      }
      var tmp = List<bool>.from(_grid[i]);
      for (int k = middle; k < cellsCount; k++) {
        _grid[i].add(tmp[cellsCount - k - 1]);
      }
    }

    _img = Image(width: size, height: size);
    fill(_img, color: ColorRgb8(255, 255, 255));
    double cellSizePx = size / cellsCount; 

    for (int i = 0; i < cellsCount; i++) {
      for (int j = 0; j < cellsCount; j++) {
        if (_grid[i][j]) {
          fillRect(_img,
            x1: (j * cellSizePx).toInt(),
            y1: (i * cellSizePx).toInt(),
            x2: ((j + 1) * cellSizePx).toInt(),
            y2: ((i + 1) * cellSizePx).toInt(),
            color: ColorRgb8(_color.r, _color.g, _color.b)
          );
        }
      } 
    }
  }

  List<List<bool>> raw() {
    return _grid;
  }

  void toFile({String filename = 'identicon'}) {
    File('$filename.png').writeAsBytesSync(encodePng(_img));
  }

  String toBase64() {
    List<int> pngBytes = encodePng(_img);
    String base64Img = base64Encode(pngBytes);
    return 'data:image/png;base64,$base64Img';
  }
}