part of lines;



class LineRect {
  
    
  CanvasElement canvas;
  CanvasRenderingContext2D context;
  
  num width;
  num height;
  String ptext;
  num ctextLength;
  

  Vector2D mp, pol, poil;
  Line line, inf_line;
  
  bool pnl, pnil;
  
  LineRect(this.canvas) {
    context = canvas.getContext("2d");
    context.font = "8pt Arial";
    width = canvas.width;
    height = canvas.height;
    // Below replace canvas with document if interested in whole page 
  //    canvas.onKeyDown.listen(onKeyDown);
  //    canvas.onKeyUp.listen(onKeyUp);
    canvas.onMouseMove.listen(onMouseMove);
    canvas.style.cursor = 'none';
    _init();
  }
  
  _init(){
    mp = new Vector2D.XY(192,224);
    pnl = pnil =false;
    ptext = ""; ctextLength = 0;
    line = new Line.XY(86, 197, 193, 81);
    line..strokeColor = 'rgb(20,128,20)'
        ..strokeWeight = 2.5;
    List<num> ends = new List<num>();
    _isOnScreen(ends, line, 0,0, width,0);
    _isOnScreen(ends, line, width,0, width,height);
    _isOnScreen(ends, line, width,height, 0,height);
    _isOnScreen(ends, line, 0,height, 0,0);
    inf_line = new Line.XY(ends[0],ends[1],ends[2], ends[3]);
    inf_line..strokeColor = 'rgb(100,160,100)'
        ..strokeWeight = 1.2;
    redraw();
  }
  
  _isOnScreen(List<num> list, Line line, num left, num top, num right, num bottom){
    List intersect = line_line_infinite_p(left,top, right,bottom, line.sx,line.sy, line.ex,line.ey);
    if(intersect[0] >= 0 && intersect[1] >= 0 && intersect[0] <= width && intersect[1] <= height)
      list.addAll(intersect);
  }
  
  redraw() {
    _processData();
   _clear('rgb(255, 247, 239)');
    _grid(32.0, 'rgb(247, 231, 221)');
    _drawLegend();
    inf_line.draw(context);
    line.draw(context);
    _drawIntersect();
    _draw_coords();
    _drawPoint();
  }
  
  _drawIntersect(){
    if(poil != null){
      context
      ..strokeStyle = 'rgb(0,0,0)'
      ..lineWidth = 1
      ..beginPath()
      ..moveTo(mp.x, mp.y)
      ..lineTo(poil.x, poil.y)
      ..stroke()
      ..closePath();
      context
      ..fillStyle = (pol == null) ? 'rgba(255,0,255,0.1)' : 'rgba(0,0,255,0.1)'
      ..beginPath()
      ..arc(poil.x, poil.y, 16, 0, 2*PI)
      ..fill()
      ..closePath();
    }
  }
  
  _draw_coords(){
    if(poil != null){
      context
      ..font = "8pt Arial"
      ..fillStyle = (pol == null) ? 'rgb(255,0,255)' : 'rgb(0,0,255)';
      if(which_side_ppv(line.start, line.end, mp) == PLANE_INSIDE){
        context.fillText(ptext, poil.x + 7, poil.y + 8);
      }
      else {
        num offset = context.measureText(ptext).width + 6;
        context.fillText(ptext, poil.x - offset, poil.y - 2);
      }
    }
  }
  
  _drawPoint(){
    if(poil != null){
      var d = ((10 * dist(poil, mp)).round()/10).toString();
      context
      ..font = "8pt Arial"
      ..fillStyle = 'rgb(255,0,0)'
      ..beginPath()
      ..arc(mp.x, mp.y, 3, 0, 2*PI)
      ..fill()
      ..closePath();
      if(which_side_ppv(line.start, line.end, mp) == PLANE_OUTSIDE){
        context.fillText(d, mp.x + 7, mp.y + 8);
      }
      else {
        num offset = context.measureText(d).width + 6;
        context.fillText(d, mp.x - offset, mp.y - 2);
      }
    }
  }
  
  _drawLegend(){
    context
    ..font = "11pt Arial"
    ..fillStyle = 'rgb(0,0,0)'
    ..fillText("Infinite line", 20,20)
    ..fillText("Finite line", 20,36);
    if(pnil){
      context
      ..fillStyle = 'rgb(255,0,255)'
      ..beginPath()
      ..arc(10, 16, 6, 0, 2*PI)
      ..fill()
      ..closePath();
    }
    if(pnl){
      context
      ..fillStyle = 'rgb(0,0,255)'
      ..beginPath()
      ..arc(10, 32, 6, 0, 2*PI)
      ..fill()
      ..closePath();
    }    
  }
  
  _processData(){
    pnl = is_point_near_line(line.start, line.end, mp);
    pnil = is_point_near_line(inf_line.start, inf_line.end, mp);
    pol = point_nearest_line(line.start, line.end, mp);
    poil =  point_nearest_infinite_line(line.start, line.end, mp);
    num px = poil.x; px = px.round();
    num py = poil.y; py = py.round();

    ptext = "[$px,$py]";
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
    mp.x = mx; mp.y = my;
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
  

  
}