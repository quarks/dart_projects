library magazine;

import 'dart:html';
import "dart:math";
import 'dart:async';
import "dart:typed_data";

import "../../quarks_libs/bin/book.dart";
import "../../quarks_libs/bin/geometry2d.dart";
import "../../quarks_libs/bin/shapes2d.dart";
import "../../quarks_libs/bin/vector2d.dart";

part "sketch.dart";
part "animations.dart";

Book book;

void main() {
  var canvas = document.querySelector('#book');

  BIND_COLOR = 'rgba(0,0,128,0.2)';
  PAGE_BORDER = 'rgba(0,0,64,0.2)';
  COVER_COLOR = 'rgb(32,32,200)';
  COVER_TRIM_COLOR = 'rgb(128,128,255)';
  PAGE_COLOR = 'rgb(255,250,240)';
  FONT_COLOR = 'rgb(0,0,255)';
  PAGE_NO_FONT = "8pt Arial";
  
  book = new Book(canvas,     // HTML5 canvas
      canvas.width / 2, 50,   // Position [x,y] of top of spine
      330, 470,               // Page width and heigh
      8,                      // Boo cover border round pages
      "cover.jpg"    // Optional picture for book cover
      );        
//  book.blankCover();

  int pn = 1;

  Sketch s;
  Page p;
 
  book.pages.add(new Page(book, "- Intro -", "layouts/blank.txt"));

  
  s = new Line_Point_Anim.size(10,50,310,310);
  p = new Page(book, "- Page ${pn++} - ", "layouts/line2point_1.txt");
  p.addSketch(s);
  book.pages.add(p);

  s = new Line_Line_Anim.size(10,50,310,160);
  p = new Page(book, "- Page ${pn++} - ", "layouts/line2line_1.txt");
  p.addSketch(s);
  book.pages.add(p);

  book.pages.add(new Page(book, "- Page ${pn++} - ", "layouts/line2point_2.txt"));
 
  s = new Circle_Line_Anim.size(10,50,310,200);
  p = new Page(book, "- Page ${pn++} - ", "layouts/circle2line_1.txt");
  p.addSketch(s);
  book.pages.add(p);

  s = new Circle_Circle_Anim.size(10,80,310,170);
  p = new Page(book, "- Page ${pn++} - ", "layouts/circle2circle_1.txt");
  p.addSketch(s);
  book.pages.add(p);

  s = new Circle_Tangents_Anim.size(10,50,310,200);
  p = new Page(book, "- Page ${pn++} - ", "layouts/tan2circ_1.txt");
  p.addSketch(s);
  book.pages.add(p);

  s = new Oblong_Oblong_Anim.size(10,80,310,210);
  p = new Page(book, "- Page ${pn++} - ", "layouts/oblong2oblong_1.txt");
  p.addSketch(s);
  book.pages.add(p);
  
  s = new Oblong_Line_Anim.size(10,180,310,220);
  p = new Page(book, "- Page ${pn++} - ", "layouts/oblong2line_1.txt");
  p.addSketch(s);
  book.pages.add(p);

  

  book.pages.add(new Page(book, "- Page ${pn++} - ", "layouts/layout1.txt"));
  book.pages.add(new Page(book, "- Page ${pn++} - ", "layouts/layout1.txt"));
  book.pages.add(new Page(book, "- Page ${pn++} - "));
  book.pages.add(new Page(book, "- Page ${pn++} - ", "layouts/layout1.txt"));
  book.pages.add(new Page(book, "- Page ${pn++} - ", "layouts/layout1.txt"));
  book.pages.add(new Page(book, "- Page ${pn++} - ", "layouts/layout1.txt"));
  book.pages.add(new Page(book, "- Page ${pn++} - ", "layouts/layout1.txt"));
  book.pages.add(new Page(book, "- Page ${pn++} - ", "layouts/layout1.txt"));
  book.pages.add(new Page(book, "- Page ${pn++} - ", "layouts/layout1.txt"));
  book.pages.add(new Page(book, "- Page ${pn++} - ", "layouts/layout1.txt"));
  book.pages.add(new Page(book, "- Page ${pn++} - ", "layouts/layout1.txt"));
  book.numberPages();
  
  book.redraw();

  querySelector('#prev').onClick.listen((e) => book.prevPage());
  querySelector('#next').onClick.listen((e) => book.nextPage());
  querySelector('#p0').onClick.listen((e) => book.gotoPageNo(0));
  querySelector('#p1').onClick.listen((e) => book.gotoPageNo(1));
  querySelector('#p2').onClick.listen((e) => book.gotoPageNo(2));
  querySelector('#p3').onClick.listen((e) => book.gotoPageNo(3));
  querySelector('#p4').onClick.listen((e) => book.gotoPageNo(4));
  querySelector('#p5').onClick.listen((e) => book.gotoPageNo(5));
  querySelector('#p6').onClick.listen((e) => book.gotoPageNo(6));
  querySelector('#p7').onClick.listen((e) => book.gotoPageNo(7));
  querySelector('#p8').onClick.listen((e) => book.gotoPageNo(8));
  querySelector('#p9').onClick.listen((e) => book.gotoPageNo(9));
  querySelector('#p10').onClick.listen((e) => book.gotoPageNo(10));
  querySelector('#p11').onClick.listen((e) => book.gotoPageNo(11));
  querySelector('#p12').onClick.listen((e) => book.gotoPageNo(12));

}
