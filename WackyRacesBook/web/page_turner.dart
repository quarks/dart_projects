library magazine;

import 'dart:html';
import "dart:math";
import 'dart:async';
import 'dart:collection';


//import "../../quarks_libs/bin/geometry2d.dart";
//import "../../quarks_libs/bin/vector2d.dart";

part "book.dart";
part "page.dart";
part "page_content.dart";

Book book;

void main() {
  var canvas = document.querySelector('#book');
  
  book = new Book(canvas, canvas.width/2, 50, 330, 300, 10);

  for(int i = 0; i < 13; i++)
    book.pages.add(new MyImagePage(book, i, "images/wacky_$i.jpg"));

  book.redraw();
}
