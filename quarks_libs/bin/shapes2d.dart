library shapes2d;

import 'dart:html';
import 'dart:math';

import"geometry2d.dart";
import"vector2d.dart";

abstract class Shape {
  
  Vector2D pos = new Vector2D();
  
  set x(num value) => pos.x = value; 
  get x => pos.x;
  
  set y(num value) => pos.y = value; 
  get y => pos.y;
  
  String fillColor = 'rgb(192,192,192)';
  String strokeColor = 'rgb(128,128,128)';
  num strokeWeight = 2.0;
  
  Shape(){ }
  
  bool contains(num x, num y) => false;
  
  draw(CanvasRenderingContext2D context);
}

class Line extends Shape {

  
  Vector2D end = new Vector2D();
  
  set start(Vector2D value) => pos.setVector(value);  
  get start => pos;
  
  set sx(num value) => pos.x = value; 
  get sx => pos.x;
  
  set sy(num value) => pos.y = value; 
  get sy => pos.y;
 
  set ex(num value) => end.x = value; 
  get ex => end.x;
  
  set ey(num value) => end.y = value; 
  get ey => end.y;
 
  Line.XY(num sx, num sy, num ex, num ey ){
    pos.x = sx;
    pos.y = sy;
    end.x = ex;
    end.y = ey;
  }
  
  draw(CanvasRenderingContext2D context){
    context
    ..strokeStyle = strokeColor
    ..lineWidth = strokeWeight
    ..beginPath()
    ..moveTo(pos.x,pos.y)..lineTo(ex, ey)
    ..closePath()
    ..stroke();
  }
  
  toString() => 'Line [$sx,$sy] to [$ex,$ey]';
}


class Circle extends Shape {

  num radius;

  set cx(num value) => pos.x = value; 
  get cx => pos.x;
  
  set cy(num value) => pos.y = value; 
  get cy => pos.y;

  Circle.XYR(px, py, this.radius){
    pos.x = px;
    pos.y = py;
  }
 
  bool contains(num px, num py) => isInsideCirle_xy(pos.x, pos.y, radius, px, py);

  draw(CanvasRenderingContext2D context){
    context
    ..save()
    ..translate(pos.x, pos.y)
    ..strokeStyle = strokeColor
    ..fillStyle = fillColor
    ..lineWidth = strokeWeight
    ..beginPath()
    ..arc(0, 0, radius, 0, 2*PI, false)
    ..closePath()
    ..fill()
    ..stroke()
    ..restore();
  }
  
  toString() => 'Circle [$cx, $cy] radius  $radius';
}

class Oblong extends Shape {

  num width;
  num height;

  Oblong();
    
  Oblong.XYWH(px, py, this.width, this.height){
    pos.x = px;
    pos.y = py;
  }
 
  bool contains(num px, num py) => isInsideRectangle_xywh(pos.x, pos.y, width, height, px, py);
  
  draw(CanvasRenderingContext2D context){
    context
    ..save()
    ..translate(pos.x, pos.y)
    ..strokeStyle = strokeColor
    ..fillStyle = fillColor
    ..lineWidth = strokeWeight
    ..beginPath()
    ..rect(0, 0, width, height)
    ..closePath()
    ..fill()
    ..stroke()
    ..restore();
  }
 
  toString() => 'Oblong [$pos.x, $pos.y] to [${pos.x+width},${pos.y+height}]   Width: $width   Height: $height';

}

class Polygon extends Shape {

  List<Vector2D> con;
  
  Polygon();
    
  Polygon.C(px, py, contour){
   px = py = 0;
   con = contour;
  }

  Polygon.XYC(px, py, contour){
    pos.x = px;
    pos.y = py;
    con = new List<Vector2D>();
    for(int i = 0; i < contour.length; i += 2)
      con.add(new Vector2D.XY(contour[i], contour[i+1]));
  }
    
  Polygon.VC(px, py, this.con){
    pos.x = px;
    pos.y = py;
  }

  bool contains(num px, num py) => isInsidePolygon(con, px-pos.x, py-pos.y);
  
  draw(CanvasRenderingContext2D context){
    context
    ..save()
    ..translate(pos.x, pos.y)
    ..strokeStyle = strokeColor
    ..fillStyle = fillColor
    ..lineWidth = strokeWeight
    ..beginPath()
    ..moveTo(con[0].x, con[0].y);
    for(int i = 1; i < con.length; i++)
      context.lineTo(con[i].x, con[i].y);
    context
    ..closePath()
    ..fill()
    ..stroke()
    ..restore();
  }
  
  toString() => 'Polygon offset [$pos.x, $pos.y]  Vertices \n $con';
}