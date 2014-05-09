import 'dart:html';
import 'dart:convert' show JSON;


class PageLayout {
  String textfile;
  
  List<ImageArea> imageAreas = new List<ImageArea>();
  
  List<TextArea> textAreas = new List<TextArea>();
  
  PageLayout(){
  }
  
  dummyData(){
    textfile = "pagetext.txt";
    imageAreas.add(new ImageArea.xyf(20,30,"bitmap1.png"));
    imageAreas.add(new ImageArea.xyf(40,50,"bitmap2.png"));
    textAreas.add(new TextArea.xywh(10, 20, 30, 40));
    textAreas.add(new TextArea.xywh(110, 120, 130, 140));
    
  }
  
  initFromJson(String s){
    var map = JSON.decode(s);
    textfile = map["textfile"];
    num nbr_images = map["nbr_images"];
    for(int n = 0; n < nbr_images; n++){
      ImageArea ia = new ImageArea();
      ia.fromJson(map["image$n"]);
      imageAreas.add(ia);
    }
    num nbr_textareas = map["nbr_textareas"];
    for(int n = 0; n < nbr_textareas; n++){
      TextArea ta = new TextArea();
      ta.fromJson(map["textarea$n"]);
      textAreas.add(ta);
    }
  }
  
  String toJson(){
    StringBuffer s = new StringBuffer();
    s.writeln('{');
    s.writeln('"textfile":"$textfile"');
    
    // Image areas
    s.writeln(',"nbr_images":${imageAreas.length}');
    for(int n = 0; n < imageAreas.length; n++)
      s.writeln(',"image$n":"${imageAreas[n].toJson()}"');
    
    // Text areas
    s.writeln(',"nbr_textareas":${textAreas.length}');
    for(int n = 0; n < textAreas.length; n++)
      s.writeln(',"textarea$n":"${textAreas[n].toJson()}"');
 
    
    s.writeln('}');
 
    return s.toString();
  }
  
  String toString(){
    StringBuffer s = new StringBuffer();
    s.writeln('================= PageLaout ====================');
    s.writeln('textfile = $textfile');
    for(ImageArea ia in imageAreas)
      s.writeln(ia.toString());
    for(TextArea ta in textAreas)
      s.writeln(ta.toString());
    s.writeln('================================================');
    return s.toString();
  }
}

class ImageArea {
  String filename;
  num x;
  num y;

  ImageArea();
  
  ImageArea.xyf(this.x, this.y, this.filename);
  
  fromJson(String s){
    var map = JSON.decode(s);
    filename = map["filename"];
    x = map["x"];
    y = map["y"];
  }
  
  String toJson(){
    return '{\\"x\\":$x,\\"y\\":$y,\\"filename\\":\\"$filename\\"}';
  }

  toString(){
    return "    Image area [$x, $y, $filename ]";
  }
}

class TextArea {
  num x;
  num y;
  num w;
  num h;
  
  TextArea();
  
  TextArea.xywh(this.x, this.y, this.w, this.h);
  
  fromJson(String s){
    var map = JSON.decode(s);
    x = map["x"];
    y = map["y"];
    w = map["w"];
    h = map["h"];
  }

  String toJson(){
    return '{\\"x\\":$x,\\"y\\":$y,\\"w\\":$w,\\"h\\":$h}';
  }
  
  toString(){
    return "    Text area [$x, $y, $w, $h ]";
  }
}

void main() {
  PageLayout pl = new PageLayout();
  pl.dummyData();
  String s = pl.toJson();
  querySelector("#json").innerHtml = s;
  print(s);
  print('==============================================================');
  PageLayout pl2 = new PageLayout();
  pl2.initFromJson(s);
  print(pl2.toJson());
  print(pl2.toString());
}

