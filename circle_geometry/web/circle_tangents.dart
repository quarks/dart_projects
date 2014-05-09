part of circles;


class Circle_tangents {
  
  var c0;
    
  CanvasElement canvas;
  CanvasRenderingContext2D context;

  num mx, my;

  num left;
  num top;
  num width;
  num height;
  
  Circle_tangents(this.canvas) {
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
    c0 = new Circle.XYR(width/1.8, height/1.9, 40) ;
    c0.fillColor = 'rgba(0,0,255,0.3)';
    c0.strokeColor = 'rgba(0,0,255,0.6)';
    mx = 30;
    my = 30;
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
    List t = tangents_to_circle(mx, my, c0.cx, c0.cy, c0.radius);
    if(t.isNotEmpty){
      context
      ..strokeStyle = 'rgb(255, 0, 255)'
      ..lineWidth = 1
      ..beginPath();
      for(int i = 0; i < t.length; i += 2)
        context..moveTo(mx, my)..lineTo(t[i], t[i+1])..stroke();
      context.closePath();
    }
    c0.draw(context);   
    if(t.isNotEmpty){
      context
      ..fillStyle = 'rgb(255, 0, 255)'
      ..beginPath();
      for(int i = 0; i < t.length; i += 2)
        context..arc(t[i], t[i+1], 4, 0, 2*PI)..fill();
      context.closePath();
    }  
  }

  onMouseMove(event) {
    Rectangle surface = canvas.getBoundingClientRect();
    mx = event.client.x - surface.left;
    my = event.client.y - surface.top;
    mx = (mx < 0) ? 0 : mx;
    mx = (mx >= width) ? width - 1 : mx;
    my = (my < 0) ? 0 : my;
    my = (my >= height) ? height - 1 : my;
    redraw();
  }
}