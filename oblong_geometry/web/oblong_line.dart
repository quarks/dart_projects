part of oblongs;

class OblongLine {
  
  Timer timer;
  Stopwatch watch;
  
  CanvasElement canvas;
  CanvasRenderingContext2D context;
  
  List<Oblong> oblong;
  
  Line sweep;
  num sweepLength = 246, sweepSpeed = 2*PI/12, sweepAngle = 0;
  num scx = 8, scy = 8;
  bool pnl, pnil;
  String ptext;
  num ctextLength;
  
  num width;
  num height;
  
  num currTime, lastTime, elapsedTime;
  
  OblongLine(this.canvas) {
    context = canvas.getContext("2d");
    context.font = "8pt Arial";
    width = canvas.width;
    height = canvas.height;
    canvas.style.cursor = 'crosshair';
    _init();
    
    watch = new Stopwatch()..start();
    currTime = lastTime = watch.elapsedMicroseconds;
    
    timer = new Timer.periodic(const Duration(milliseconds: 14),
        (t) => redraw());
  }

  
  _init(){
    sweep = new Line.XY(scx, scy, scx + sweepLength, scy)
    ..strokeColor = 'rgb(128,160,128)'
    ..strokeWeight = 2.5;
    oblong = new List<Oblong>();
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
  }

  redraw(){
    currTime = watch.elapsedMicroseconds;
    elapsedTime = currTime - lastTime;
    lastTime = currTime;
    _updateSweep(elapsedTime);
    _clear('rgb(255, 247, 239)');
    _grid(32.0, 'rgb(247, 231, 221)');
    for(Oblong ob in oblong)
      ob.draw(context);
    _testForIntersections();
    sweep.draw(context);
    context
    ..fillStyle = sweep.strokeColor
    ..beginPath()
    ..arc(scx, scy, 4, 0, 2*PI)
    ..fill()
    ..closePath();
  }
  
  _testForIntersections(){
    for(Oblong ob in oblong)
      if(line_box_xywh(sweep.sx,sweep.sy,sweep.ex,sweep.ey,ob.x,ob.y,ob.width,ob.height))
        context
        ..strokeStyle = 'rgb(255,0,0)'
        ..lineWidth = 2
        ..beginPath()
        ..rect(ob.x,ob.y,ob.width,ob.height)
        ..stroke()
        ..closePath();    
  }
  
  _updateSweep(int etime){
    sweepAngle += sweepSpeed * etime/1000000;
    if(sweepAngle < 0 || sweepAngle > PI/2){
      sweepSpeed *= -1;
      sweepAngle = sweepAngle < 0 ? 0 : PI/2;
    }
    sweep.ex = sweep.sx + sweepLength * cos(sweepAngle);
    sweep.ey = sweep.sy + sweepLength * sin(sweepAngle);
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