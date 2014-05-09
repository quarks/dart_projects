library oblongs;

import 'dart:html';
import 'dart:async';
import "dart:math";
import "dart:typed_data";

import "../../quarks_libs/bin/geometry2d.dart";
import "../../quarks_libs/bin/shapes2d.dart";

part "oblong_oblong.dart";
part "oblong_line.dart";

void main() {
  new OblongA(document.querySelector('#oblongA'));
  new OblongLine(document.querySelector('#oblongB'));

}

