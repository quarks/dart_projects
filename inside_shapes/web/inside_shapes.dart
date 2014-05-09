library inside_shape_1;

import 'dart:html';
import 'dart:async';
import "dart:math";


import "../../quarks_libs/bin/shapes2d.dart";



void main() {
  new InsideA(document.querySelector('#insideA'));

}

class InsideA {
  var c0, c1, ob0, p0, p1;

  num mx = 0, my = 0;

  CanvasElement canvas;
  CanvasRenderingContext2D context;

  num width, height;
  
  InsideA(this.canvas) {
    context = canvas.getContext("2d");
    width = canvas.width;
    height = canvas.height;
    // Below replace canvas with document if interested in whole page 
//  canvas.onKeyDown.listen(onKeyDown);
//  canvas.onKeyUp.listen(onKeyUp);
    canvas.onMouseMove.listen(onMouseMove);
    canvas.style.cursor = 'crosshair';
    _init();
  }
  
  void _init(){
    c0 = new Circle.XYR(75, 180, 50);
    c1 = new Circle.XYR(128, 49, 30);
    ob0 = new Oblong.XYWH(192, 48, 50, 80);
    p0 = new Polygon.XYC(176 ,176, [ 0,0, -32,-64, 32,0, -32,64]);
    p1 = new Polygon.XYC(60 ,70, [ -10,0, -20,-20, 32,-70, 0,-20, 10,0, -50,80]);
    redraw();
  }
  
  void _clear([String col = 'rgb(0,0,0)']){
    context
    ..fillStyle = col   
    ..fillRect(0, 0, width, height);
  }
  
  void _grid(num size, [String col = 'rgb(0,0,0)']){
    context
    ..strokeStyle = col
    ..lineWidth = 1.2
    ..beginPath();
    for(num g = 0; g <= width; g += size)
      context..moveTo(g, 0)..lineTo(g, height)..stroke();
    for(num g = 0; g <= height; g += size)
      context..moveTo(0, g)..lineTo(width, g)..stroke();
    context.closePath();
  }
  
  
  void redraw() {
    context..save();
    _clear('rgb(255, 247, 239)');
    _grid(32.0, 'rgb(247, 231, 221)');
    // Shape colours
    c0.fillColor = 'rgba(0,0,255,0.3)';
    c0.strokeColor = 'rgba(0,0,200,0.6)';
    c1.fillColor = 'rgba(255,255,100,0.3)';
    c1.strokeColor = 'rgba(200,200,50,0.6)';
    ob0.fillColor = 'rgba(0,255,0,0.3)';
    ob0.strokeColor = 'rgba(0,200,0,0.6)';
    p0.fillColor = 'rgba(255,100,100,0.3)';
    p0.strokeColor = 'rgba(200,50,50,0.6)';
    p1.fillColor = 'rgba(100,255,255,0.3)';
    p1.strokeColor = 'rgba(10,200,200,0.6)';
    // See if the mouse is over one of the shapes
    testMouseOver(c0);
    testMouseOver(c1);
    testMouseOver(ob0);
    testMouseOver(p0);
    testMouseOver(p1);
    // Draw the shapes
    p0.draw(context);
    p1.draw(context);
    c0.draw(context);
    c1.draw(context);
    ob0.draw(context);    
  }
  
  void testMouseOver(Shape shape){
    if(shape.contains(mx, my)){
      shape.fillColor = 'rgba(200,200,200,0.3)';
      shape.strokeColor = 'rgba(0,0,0,0.6)';    
    }  
  }
  
  void onMouseMove(event) {
    Rectangle surface = canvas.getBoundingClientRect();
    mx = event.client.x - surface.left;
    my = event.client.y - surface.top;
    mx = (mx < 0) ? 0 : mx;
    mx = (mx >= width) ? width - 1 : mx;
    my = (my < 0) ? 0 : my;
    my = (my >= width) ? height - 1 : my;

    redraw();
  }
}