part of circles;


class Circle_with_circle {
  
  var c0,c1;
    
  CanvasElement canvas;
  CanvasRenderingContext2D context;

//  bool rightDown = false;
//  bool leftDown = false;

  num width;
  num height;
  
  Circle_with_circle(this.canvas) {
    context = canvas.getContext("2d");
    width = canvas.width;
    height = canvas.height;
    // Below replace canvas with document if interested in whole page 
//    canvas.onKeyDown.listen(onKeyDown);
//    canvas.onKeyUp.listen(onKeyUp);
    canvas.onMouseMove.listen(onMouseMove);
    canvas.style.cursor = 'crosshair';
    _init();
  }

  _init(){
    c0 = new Circle.XYR(100, height-80, 30) ;
    c1 = new Circle.XYR(235, 40, 20) ;    
    c0.fillColor = 'rgba(0,0,255,0.3)';
    c0.strokeColor = 'rgba(0,0,255,0.6)';
    c1.fillColor = 'rgba(0,255,0,0.3)';
    c1.strokeColor = 'rgba(0,200,0,0.6)';
    redraw();
  }
  
  _clear([String col = 'rgb(0,0,0)']){
    context
    ..fillStyle = col   
    ..fillRect(0, 0, width, height);
  }
  
  _grid(num size, [String col = 'rgb(0,0,0)']){
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
  

  redraw() {
    _clear('rgb(255, 247, 239)');
    _grid(32.0, 'rgb(247, 231, 221)');
    c1.draw(context);
    c0.draw(context);    
    List t = tangents_between_circles(c0.cx, c0.cy, c0.radius, c1.cx, c1.cy, c1.radius);
    if(t.isNotEmpty){
      drawTangents(t, 0, 'rgb(255,0,255)');
      drawTangentPoints(t, 0, 'rgb(255,0,255)');
      if(t.length > 4){
        drawTangents(t, 8, 'rgb(255,160,0)');
        drawTangentPoints(t, 8, 'rgb(255,160,0)');
      }
      // test for intersection
      t = circle_circle_p(c0.cx, c0.cy, c0.radius, c1.cx, c1.cy, c1.radius);
      if(t.isNotEmpty){
        context
        ..fillStyle = 'rgb(255, 0, 0)';
        for(int i = 0; i < t.length; i += 2)
          context
          ..beginPath()
          ..arc(t[i], t[i+1], 3, 0, 2*PI, false)..fill()
          ..closePath();
      }
    }
  }

  drawTangents(List list, int start, String color){
    context
    ..strokeStyle = color
    ..lineWidth = 1.2
    ..beginPath();
    for(int i = start; i < start + 8; i += 4)
      context..moveTo(list[i], list[i+1])..lineTo(list[i+2], list[i+3])..stroke();
    context.closePath();
  }    
    
  drawTangentPoints(List list, int start, String color){
    context
    ..fillStyle = color;
    for(int i = start; i < start + 8; i += 2){
      context..beginPath()
      ..arc(list[i], list[i+1], 3.5, 0, 2*PI, true)..fill()
      ..closePath();
    }
  }    
    
  
  // Change a position of a racket with the mouse left or right mouvement.
  onMouseMove(event) {
    Rectangle surface = canvas.getBoundingClientRect();
    num mx = event.client.x - surface.left;
    num my = event.client.y - surface.top;
    mx = (mx < 0) ? 0 : mx;
    mx = (mx >= width) ? width - 1 : mx;
    my = (my < 0) ? 0 : my;
    my = (my >= width) ? height - 1 : my;
    c1.cx = mx;
    c1.cy = my;
    redraw();
  }
  
/*  
  // Set rightDown or leftDown if the right or left keys are down.
  void onKeyDown(event) {
    if (event.keyCode == 39) {
      rightDown = true;
    } else if (event.keyCode == 37) {
      leftDown = true;
    }
  }

  // Unset rightDown or leftDown when the right or left key is released.
  void onKeyUp(event) {
    if (event.keyCode == 39) {
      rightDown = false;
    } else if (event.keyCode == 37) {
      leftDown = false;
    }
  }
*/


}

