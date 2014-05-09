part of lines;

class LineLine {
  
  Timer timer;
  Stopwatch watch;
  num currTime, lastTime, elapsedTime;
  
  CanvasElement canvas;
  CanvasRenderingContext2D context;
  
  List<num> q,u,a,r,k, bits;
  List xy;
  
  num sweepLengthX = 300, sweepLengthY = 240, sweepSpeed = 2*PI/20, sweepAngle = 0;
  num scx = 8, scy = 8;

  Line line0, line1, line2;
  
  num width;
  num height;
  
  
  LineLine(this.canvas) {
    context = canvas.getContext("2d");
    context.font = "8pt Arial";
    width = canvas.width;
    height = canvas.height;
    canvas.style.cursor = 'crosshair';
    _init();
    
    watch = new Stopwatch()..start();
    currTime = lastTime = watch.elapsedMicroseconds;
    
    timer = new Timer.periodic(const Duration(milliseconds: 25),
        (t) => redraw());
  }

  
  _init(){
    q = [ 80,50, 150,50, 180,80, 180,200, 150,230, 80,230, 50,200, 50,80, 80,50]; 
    u = [ 210,150, 210,220, 220,230, 260,230, 274,216];
    a = [ 310,220, 310,160, 320,150, 360,150, 370,160, 370,220, 360,230, 320,230, 310,220 ];
    r = [ 400, 165, 420,150, 450,150, 450,160 ];
    k = [ 480,140, 490,130, 520,130, 530,140, 530,170, 520,180, 480,180];
    bits = [ 150,200,180,230, 274,150,274,230, 370,220,380,230, 400,150,400,230, 480,70,480,230, 490,180,530,230];

    num f = 310.0/ 576.0;
    for(int i = 0; i < q.length; i++) q[i] = (q[i] * f).round();
    for(int i = 0; i < u.length; i++) u[i] = (u[i] * f).round();
    for(int i = 0; i < a.length; i++) a[i] = (a[i] * f).round();
    for(int i = 0; i < r.length; i++) r[i] = (r[i] * f).round();
    for(int i = 0; i < k.length; i++) k[i] = (k[i] * f).round();
    for(int i = 0; i < bits.length; i++) bits[i] = (bits[i] * f).round();
    
    print("q = $q;");
    print("u = $u;");
    print("a = $a");
    print("r = $r;");
    print("k = $k;");
    print("bits = $bits;");
    
    
    sweepLengthX = (sweepLengthX * f).round();
    sweepLengthY = (sweepLengthY * f).round();
    print("sweepLengthX = $sweepLengthX;");
    print("sweepLengthY = $sweepLengthY;");
   
    line0 = new Line.XY(32*f,244*f,32*f+sweepLengthX,240*f);
    line0..strokeColor = 'rgb(0,128,255)'..strokeWeight = 2.5;
    line1 = new Line.XY(544*f,244*f,544*f-sweepLengthX,244*f);
    line1..strokeColor = 'rgb(0,128,255)'..strokeWeight = 2.5;
    line2 = new Line.XY(line0.ex, line0.ey, line1.ex, line1.ey);
    line2..strokeColor = 'rgb(0,128,255)'..strokeWeight = 2.5;
    xy = new List<num>();
  }

  redraw(){
    currTime = watch.elapsedMicroseconds;
    elapsedTime = currTime - lastTime;
    lastTime = currTime;
    _updateAngle(elapsedTime);
    _updateSweep();
    _clear('rgb(255, 247, 239)');
    _grid(32.0, 'rgb(247, 231, 221)');
    _drawPolyLine(q);
    _drawPolyLine(u);
    _drawPolyLine(a);
    _drawPolyLine(r);
    _drawPolyLine(k);
    _drawLines(bits);
    line0.draw(context);
    line1.draw(context);
    line2.draw(context);
    context..fillStyle = line0.strokeColor;
    context..beginPath()..arc(line0.sx, line0.sy, 3, 0, 2*PI)..fill()..closePath();
    context..beginPath()..arc(line0.ex, line0.ey, 3, 0, 2*PI)..fill()..closePath();
    context..beginPath()..arc(line1.sx, line1.sy, 3, 0, 2*PI)..fill()..closePath();
    context..beginPath()..arc(line1.ex, line1.ey, 3, 0, 2*PI)..fill()..closePath();
    
        xy.clear();
    _intercepts(line0);
    _intercepts(line1);
    _intercepts(line2);
    if(xy.length > 0){
      context..fillStyle = 'rgb(255,0,0)';
      for(int i = 0; i < xy.length; i += 2){
        context..beginPath()..arc(xy[i], xy[i+1], 5, 0, 2*PI)
        ..fill()
        ..closePath();
      }
    }
    
  }

  _intercepts(Line line){
    List list;
    xy.addAll(line_lines_p(line.sx, line.sy, line.ex, line.ey, q, true));
    xy.addAll(line_lines_p(line.sx, line.sy, line.ex, line.ey, u, true));
    xy.addAll(line_lines_p(line.sx, line.sy, line.ex, line.ey, a, true));
    xy.addAll(line_lines_p(line.sx, line.sy, line.ex, line.ey, r, true));
    xy.addAll(line_lines_p(line.sx, line.sy, line.ex, line.ey, k, true));
    xy.addAll(line_lines_p(line.sx, line.sy, line.ex, line.ey, bits, false));
  }
  
  _updateSweep(){
    // Left line
    num angle = 2*PI - sweepAngle;
    line0.ex = line0.sx + sweepLengthX*cos(angle);
    line0.ey = line0.sy + sweepLengthY*sin(angle);
    angle = 1.5*PI - sweepAngle;
    line1.ex = line1.sx + sweepLengthX*cos(angle);
    line1.ey = line1.sy + sweepLengthY*sin(angle);
    line2.sx = line0.ex;
    line2.sy = line0.ey;
    line2.ex = line1.ex;
    line2.ey = line1.ey;
    
    
  }
  
  _updateAngle(num etime){
    sweepAngle += sweepSpeed * etime/1000000;
    if(sweepAngle < 0 || sweepAngle > PI/2){
      sweepSpeed *= -1;
      sweepAngle = sweepAngle < 0 ? 0 : PI/2;
    }
    
  }
  _drawPolyLine(List<num> list){
    context
    ..strokeStyle = 'rgb(0,180,0)'
    ..lineCap = 'round'
    ..lineWidth = 6
    ..beginPath();
    for(int i = 0; i < list.length; i+=2){
       if(i == 0)
         context.moveTo(list[i], list[i+1]);
       else
         context.lineTo(list[i], list[i+1]);
    }
    context
    ..stroke()..closePath();
  }
  
  
  _drawLines(List<num> list){
    context
    ..strokeStyle = 'rgb(0,180,0)' 
    ..lineCap = 'round'
    ..lineWidth = 6
    ..beginPath();
    for(int i = 0; i < list.length; i+=4){
         context.moveTo(list[i], list[i+1]);
         context.lineTo(list[i+2], list[i+3]);
    }
    context
    ..stroke()..closePath();
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