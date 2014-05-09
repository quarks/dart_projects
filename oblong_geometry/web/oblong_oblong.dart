part of oblongs;

class OblongA {
  
  CanvasElement canvas;
  CanvasRenderingContext2D context;
  num width, height;
  num mx = 0, my = 0;

  List<Oblong> oblong;
  Oblong floater;

  OblongA(this.canvas) {
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
  
  _init(){
    oblong = new List<Oblong>();
    oblong.add(new Oblong.XYWH(20,50,100,90));
    oblong.add(new Oblong.XYWH(50,160,100,50));
    oblong.add(new Oblong.XYWH(200,20,40,30));
    oblong.add(new Oblong.XYWH(180,80,20,20));
    oblong.add(new Oblong.XYWH(170,110,50,20));
    oblong.add(new Oblong.XYWH(200,150,40,90));
    for(Oblong ob in oblong){
      ob.fillColor = 'rgba(160,160,255,0.3)';
      ob.strokeColor = 'rgba(120,120,200,0.6)'; 
    }
    floater = new Oblong.XYWH(86,98,90,70);
    floater.fillColor = 'rgba(100,255,100,0.3)';
    floater.strokeColor = 'rgba(60,200,60,0.6)'; 
    
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
    context..save();
    _clear('rgb(255, 247, 239)');
    _grid(32.0, 'rgb(247, 231, 221)');
    for(Oblong ob in oblong)
      ob.draw(context);
    floater.draw(context);
    for(Oblong ob in oblong){
      ob.draw(context);
      Float64List intersect = box_box_p(ob.x, ob.y, ob.x + ob.width, ob.y + ob.height, 
          floater.x, floater.y, floater.x + floater.width, floater.y + floater.height);
      if(intersect.length > 0){
        num x0 = intersect[0];
        num y0 = intersect[1];
        num w = intersect[2] - intersect[0];
        num h = intersect[3] - intersect[1];
        context
        ..strokeStyle = 'rgb(255,0,0)'
        ..lineWidth = 2
        ..beginPath()
        ..rect(x0, y0, w, h)
        ..stroke()
        ..closePath();
      }
    }
   
  }
  
  onMouseMove(event) {
    Rectangle surface = canvas.getBoundingClientRect();
    mx = event.client.x - surface.left;
    my = event.client.y - surface.top;
    mx = (mx < 0) ? 0 : mx;
    mx = (mx >= width) ? width - 1 : mx;
    my = (my < 0) ? 0 : my;
    my = (my >= width) ? height - 1 : my;

    floater.x = mx - floater.width/2;
    floater.y = my - floater.height/2;
    redraw();
  }
}