library circles;

import 'dart:html';
import 'dart:async';
import "dart:math";

import "../../quarks_libs/bin/geometry2d.dart";
import "../../quarks_libs/bin/shapes2d.dart";

part "circle_with_circle.dart";
part "circle_with_line.dart";
part "circle_tangents.dart";

void main() {
  new Circle_with_circle(document.querySelector('#circ2circ_a'));
  new Circle_with_line(document.querySelector('#circ2circ_b'));
  new Circle_tangents(document.querySelector('#circ2circ_c'));
}
