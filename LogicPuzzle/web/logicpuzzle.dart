library logic_puzzler;

import 'dart:html';
import 'dart:async';
import 'dart:convert' show JSON;


CanvasElement canvas;
CanvasRenderingContext2D context;
var pdiv = document.querySelector('#PUZZLE_TEXT');

void main() {

  canvas = document.querySelector('#puzzle');
  context = canvas.getContext("2d");

  var pdiv = document.querySelector('#PUZZLE_TEXT');

  Puzzle p = new Puzzle("puzzles/p0001.txt");
}

class Puzzle {

  String descFile = null;
  String descHTML = "";
  String solutionFile = null;
  String solutionHTML = "";

  String imgFile = null;
  ImageElement img = null;

  List a = ['Alan', 'Bertie', 'Jenny', 'Kate', 'Mikey'];
  List<String> b;
  List<String> c;
  List<String> d;


  int nbrAnswers = 0,
      nbrUnknowns = 0;

  Puzzle(String puzzleFile) {
    if (puzzleFile != null) {
      HttpRequest.getString(puzzleFile).then(_getContent);
    }
  }

  _getContent(String s) {
    fromJson(s);
    // Load page content
    var futures = [];
    // Load the paper texture (if any)
    if (imgFile != null) {
      img = new ImageElement(src: 'images/$imgFile');
      futures.add(img.onLoad.first);
    }
    // Load the desc HTML if any
    if (descFile != null) {
      futures.add(HttpRequest.getString('puzzles/$descFile').then((s) =>
          descHTML = s));
    }
    // Load the HTML if any
    if (solutionFile != null) {
      futures.add(HttpRequest.getString('puzzles/$solutionFile').then((s) =>
          solutionHTML = s));
    }
    // When everything is loaded then render
    Future.wait(futures).then((_) => render());
  }

  render() {
    pdiv.innerHtml = descHTML +
        "<p>No. of Answers $nbrAnswers</p><p>No. of Unknowns $nbrUnknowns</p><p>A $a</p><p>B $b</p><p>C $c</p><p>D $d</p>";
  }
  
  fromJson(String s) {
    var map = JSON.decode(s);
    descFile = map["descFile"];
    solutionFile = map["solutionFile"];
    imgFile = map["imgFile"];
    nbrAnswers = map["nbrAnswers"];
    nbrUnknowns = map["nbrUnknowns"];
    try {
      a = JSON.decode(map["a"]);
      b = JSON.decode(map["b"]);
      c = JSON.decode(map["c"]);
      d = JSON.decode(map["d"]);
    } catch (e) {
      print("Exception \n$e");
    }
  }

  //"c":"[ \"4\", \"5\", \"6\", \"7\", \"8\" ]"

}
