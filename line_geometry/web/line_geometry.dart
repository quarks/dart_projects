library lines;

import 'dart:html';
import 'dart:async';
import "dart:math";

import "../../quarks_libs/bin/geometry2d.dart";
import "../../quarks_libs/bin/shapes2d.dart";
import "../../quarks_libs/bin/vector2d.dart";

part "line_a.dart";
part "line_b.dart";


void main() {
  new LineRect(document.querySelector('#lineA'));
  new LineLine(document.querySelector('#lineB'));


}
