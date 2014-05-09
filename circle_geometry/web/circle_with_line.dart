part of circles;


class Circle_with_line {
  Line l0;
  var c0;
  
  CanvasElement canvas;
  CanvasRenderingContext2D context;

  num mx, my;
  bool dragged = false;
  
  num left;
  num top;
  num width;
  num height;
  
  Circle_with_line(this.canvas) {
    context = canvas.getContext("2d");
    Rectangle surface = canvas.getBoundingClientRect();
    left = surface.left.round();
    top = surface.top.round();
    width = surface.width;
    height = surface.height;
    // Below replace canvas with document if interested in whole page 
//    canvas.onKeyDown.listen(onKeyDown);
//    canvas.onKeyUp.listen(onKeyUp);
    canvas.onMouseMove.listen(onMouseMove);
    canvas.onMouseDown.listen(onMouseDown);
    canvas.onMouseUp.listen(onMouseUp);
    canvas.onMouseLeave.listen(onMouseLeave);
//   canvas.onClick.listen(onClick);
    canvas.style.cursor = 'crosshair';
    _init();
  }

  _init(){
    c0 = new Circle.XYR(width/2, height/2, 55) ;
    c0.fillColor = 'rgba(0,0,255,0.3)';
    c0.strokeColor = 'rgba(0,0,255,0.6)';
    l0 = new Line.XY(20,40,width-20,height-40);
    l0.strokeColor = 'rgb(128,128,0)';
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

    c0.draw(context);    
    l0.draw(context);
    if(l0.sx != l0.ex || l0.sy != l0.ey){
      List t = line_circle_p(l0.sx, l0.sy, l0.ex, l0.ey, c0.cx, c0.cy, c0.radius);
      if(t.isNotEmpty){
        context
        ..fillStyle = 'rgb(255, 0, 0)'
        ..beginPath();
        for(int i = 0; i < t.length; i += 2)
          context..arc(t[i], t[i+1], 4, 0, 2*PI, false)..fill();
         context.closePath();
      }
    }
  }

  // Change a position of a racket with the mouse left or right mouvement.
  onMouseMove(event) {
    _resolveMouseCoordinates(event.client.x, event.client.y);
    if(dragged){
      l0.ex = mx;
      l0.ey = my;
      redraw();
    }
  }
  
  onMouseDown(event) {
   _resolveMouseCoordinates(event.client.x, event.client.y);
   l0.sx = mx;
   l0.sy = my;
   l0.ex = mx;
   l0.ey = my;
    dragged = true;
    redraw();
  }
  
  onMouseUp(event) {
    _resolveMouseCoordinates(event.client.x, event.client.y);
    if((l0.sx == l0.ex && l0.sy == l0.ey)){
      Random rnd = new Random();
      l0.sx = rnd.nextInt(width.round());
      l0.ex = rnd.nextInt(width.round());
      l0.sy = rnd.nextInt(height.round());
      l0.ey = rnd.nextInt(height.round());
    }
    dragged = false;
    redraw();
  }
  
  onMouseLeave(event) {
    dragged = false;
    redraw();
  }

  
  _resolveMouseCoordinates(num x, num y){
    Rectangle surface = canvas.getBoundingClientRect();
    mx = x - surface.left;
    my = y - surface.top;
    mx = (mx < 0) ? 0 : mx;
    mx = (mx >= width) ? width - 1 : mx;
    my = (my < 0) ? 0 : my;
    my = (my >= height) ? height - 1 : my;
  }
}