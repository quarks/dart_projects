part of magazine;

class Line_Line_Anim extends Geometry2D_Anim {

  List<num> q, u, a, r, k, bits;
  List xy;

  num sweepLengthX = 300, sweepLengthY = 240, sweepSpeed = 2 * PI / 20,
      sweepAngle = 0;
  num scx = 8, scy = 8;

  Line line0, line1, line2;

  Line_Line_Anim.size(num x, num y, num w, num h): super.size(x, y, w, h) {
    _init();

    watch = new Stopwatch()..start();
    currTime = lastTime = watch.elapsedMicroseconds;

    timer = new Timer.periodic(const Duration(milliseconds: 25), (t) => redraw()
        );

  }

  _init() {
    q = [43, 27, 81, 27, 97, 43, 97, 108, 81, 124, 43, 124, 27, 108, 27, 43, 43,
        27];
    u = [113, 81, 113, 118, 118, 124, 140, 124, 147, 116];
    a = [167, 118, 167, 86, 172, 81, 194, 81, 199, 86, 199, 118, 194, 124, 172,
        124, 167, 118];
    r = [215, 89, 226, 81, 242, 81, 242, 86];
    k = [258, 75, 264, 70, 280, 70, 285, 75, 285, 91, 280, 97, 258, 97];
    bits = [81, 108, 97, 124, 147, 81, 147, 124, 199, 118, 205, 124, 215, 81,
        215, 124, 258, 38, 258, 124, 264, 97, 285, 124];
    sweepLengthX = 160;
    sweepLengthY = 130;

    line0 = new Line.XY(17, 140, 16 + sweepLengthX, 140);
    line0
        ..strokeColor = 'rgb(0,128,255)'
        ..strokeWeight = 2.5;
    line1 = new Line.XY(294, 140, 294 - sweepLengthX, 140);
    line1
        ..strokeColor = 'rgb(0,128,255)'
        ..strokeWeight = 2.5;
    line2 = new Line.XY(line0.ex, line0.ey, line1.ex, line1.ey);
    line2
        ..strokeColor = 'rgb(0,128,255)'
        ..strokeWeight = 2.5;
    xy = new List<num>();
  }

  redraw() {
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
    context
        ..beginPath()
        ..arc(line0.sx, line0.sy, 3, 0, 2 * PI)
        ..fill()
        ..closePath();
    context
        ..beginPath()
        ..arc(line0.ex, line0.ey, 3, 0, 2 * PI)
        ..fill()
        ..closePath();
    context
        ..beginPath()
        ..arc(line1.sx, line1.sy, 3, 0, 2 * PI)
        ..fill()
        ..closePath();
    context
        ..beginPath()
        ..arc(line1.ex, line1.ey, 3, 0, 2 * PI)
        ..fill()
        ..closePath();

    xy.clear();
    _intercepts(line0);
    _intercepts(line1);
    _intercepts(line2);
    if (xy.length > 0) {
      context..fillStyle = 'rgb(255,0,0)';
      for (int i = 0; i < xy.length; i += 2) {
        context
            ..beginPath()
            ..arc(xy[i], xy[i + 1], 5, 0, 2 * PI)
            ..fill()
            ..closePath();
      }
    }
    repaint();
  }

  _intercepts(Line line) {
    List list;
    xy.addAll(line_lines_p(line.sx, line.sy, line.ex, line.ey, q, true));
    xy.addAll(line_lines_p(line.sx, line.sy, line.ex, line.ey, u, true));
    xy.addAll(line_lines_p(line.sx, line.sy, line.ex, line.ey, a, true));
    xy.addAll(line_lines_p(line.sx, line.sy, line.ex, line.ey, r, true));
    xy.addAll(line_lines_p(line.sx, line.sy, line.ex, line.ey, k, true));
    xy.addAll(line_lines_p(line.sx, line.sy, line.ex, line.ey, bits, false));
  }

  _updateSweep() {
    // Left line
    num angle = 2 * PI - sweepAngle;
    line0.ex = line0.sx + sweepLengthX * cos(angle);
    line0.ey = line0.sy + sweepLengthY * sin(angle);
    angle = 1.5 * PI - sweepAngle;
    line1.ex = line1.sx + sweepLengthX * cos(angle);
    line1.ey = line1.sy + sweepLengthY * sin(angle);
    line2.sx = line0.ex;
    line2.sy = line0.ey;
    line2.ex = line1.ex;
    line2.ey = line1.ey;
  }

  _updateAngle(num etime) {
    sweepAngle += sweepSpeed * etime / 1000000;
    if (sweepAngle < 0 || sweepAngle > PI / 2) {
      sweepSpeed *= -1;
      sweepAngle = sweepAngle < 0 ? 0 : PI / 2;
    }

  }

  _drawPolyLine(List<num> list) {
    context
        ..strokeStyle = 'rgb(0,180,0)'
        ..lineCap = 'round'
        ..lineWidth = 6
        ..beginPath();
    for (int i = 0; i < list.length; i += 2) {
      if (i == 0) context.moveTo(list[i], list[i + 1]); else context.lineTo(
          list[i], list[i + 1]);
    }
    context
        ..stroke()
        ..closePath();
  }

  _drawLines(List<num> list) {
    context
        ..strokeStyle = 'rgb(0,180,0)'
        ..lineCap = 'round'
        ..lineWidth = 6
        ..beginPath();
    for (int i = 0; i < list.length; i += 4) {
      context.moveTo(list[i], list[i + 1]);
      context.lineTo(list[i + 2], list[i + 3]);
    }
    context
        ..stroke()
        ..closePath();
  }
}


class Line_Point_Anim extends Geometry2D_Anim {

  Vector2D mp, pol, poil;
  Line line, inf_line;

  String ptext;
  num ctextLength;

  bool pnl, pnil;

  Line_Point_Anim.size(num x, num y, num w, num h): super.size(x, y, w, h) {
    mp = new Vector2D.XY(192, 224);
    pnl = pnil = false;

    line = new Line.XY(86, 197, 193, 81);
    line
        ..strokeColor = 'rgb(20,128,20)'
        ..strokeWeight = 2.5;
    List<num> ends = new List<num>();
    _isOnScreen(ends, line, 0, 0, width, 0);
    _isOnScreen(ends, line, width, 0, width, height);
    _isOnScreen(ends, line, width, height, 0, height);
    _isOnScreen(ends, line, 0, height, 0, 0);
    inf_line = new Line.XY(ends[0], ends[1], ends[2], ends[3]);
    inf_line
        ..strokeColor = 'rgb(100,160,100)'
        ..strokeWeight = 1.2;
    redraw();

  }

  _isOnScreen(List<num> list, Line line, num left, num top, num right, num
      bottom) {
    List intersect = line_line_infinite_p(left, top, right, bottom, line.sx,
        line.sy, line.ex, line.ey);
    if (intersect[0] >= 0 && intersect[1] >= 0 && intersect[0] <= width &&
        intersect[1] <= height) list.addAll(intersect);
  }

  redraw() {
    _processData();
    _clear();
    _grid(32.0);
    _drawLegend();
    inf_line.draw(context);
    line.draw(context);
    _drawIntersect();
    _draw_coords();
    _drawPoint();
    repaint();
  }

  _drawIntersect() {
    if (poil != null) {
      context
          ..strokeStyle = 'rgb(0,0,0)'
          ..lineWidth = 1
          ..beginPath()
          ..moveTo(mp.x, mp.y)
          ..lineTo(poil.x, poil.y)
          ..stroke()
          ..closePath();
      context
          ..fillStyle = (pol == null) ? 'rgba(255,0,255,0.1)' :
              'rgba(0,0,255,0.1)'
          ..beginPath()
          ..arc(poil.x, poil.y, 16, 0, 2 * PI)
          ..fill()
          ..closePath();
    }
  }

  _draw_coords() {
    if (poil != null) {
      context
          ..font = "8pt Arial"
          ..fillStyle = (pol == null) ? 'rgb(255,0,255)' : 'rgb(0,0,255)';
      if (which_side_ppv(line.start, line.end, mp) == PLANE_INSIDE) {
        context.fillText(ptext, poil.x + 7, poil.y + 8);
      } else {
        num offset = context.measureText(ptext).width + 6;
        context.fillText(ptext, poil.x - offset, poil.y - 2);
      }
    }
  }

  _drawPoint() {
    if (poil != null) {
      var d = ((10 * dist(poil, mp)).round() / 10).toString();
      context
          ..font = "8pt Arial"
          ..fillStyle = 'rgb(255,0,0)'
          ..beginPath()
          ..arc(mp.x, mp.y, 3, 0, 2 * PI)
          ..fill()
          ..closePath();
      if (which_side_ppv(line.start, line.end, mp) == PLANE_OUTSIDE) {
        context.fillText(d, mp.x + 7, mp.y + 8);
      } else {
        num offset = context.measureText(d).width + 6;
        context.fillText(d, mp.x - offset, mp.y - 2);
      }
    }
  }

  _drawLegend() {
    context
        ..font = "11pt Arial"
        ..fillStyle = 'rgb(0,0,0)'
        ..fillText("Infinite line", 20, 20)
        ..fillText("Finite line", 20, 36);
    if (pnil) {
      context
          ..fillStyle = 'rgb(255,0,255)'
          ..beginPath()
          ..arc(10, 16, 6, 0, 2 * PI)
          ..fill()
          ..closePath();
    }
    if (pnl) {
      context
          ..fillStyle = 'rgb(0,0,255)'
          ..beginPath()
          ..arc(10, 32, 6, 0, 2 * PI)
          ..fill()
          ..closePath();
    }
  }

  _processData() {
    pnl = is_point_near_line(line.start, line.end, mp);
    pnil = is_point_near_line(inf_line.start, inf_line.end, mp);
    pol = point_nearest_line(line.start, line.end, mp);
    poil = point_nearest_infinite_line(line.start, line.end, mp);
    num px = poil.x;
    px = px.round();
    num py = poil.y;
    py = py.round();

    ptext = "[$px,$py]";
  }


  onMouseMove(num sketchX, num sketchY, var event) {
    if (isOver(sketchX, sketchY)) {
      mx = sketchX;
      my = sketchY;
      mx = (mx < 0) ? 0 : mx;
      mx = (mx >= width) ? width - 1 : mx;
      my = (my < 0) ? 0 : my;
      my = (my >= width) ? height - 1 : my;
      mp.x = mx;
      mp.y = my;
      redraw();
    }
  }
}

class Circle_Line_Anim extends Geometry2D_Anim {

  Line l0;
  var c0;
  bool dragged = false;

  Circle_Line_Anim.size(num x, num y, num w, num h): super.size(x, y, w, h) {
    c0 = new Circle.XYR(width / 2, height / 2, 55);
    c0.fillColor = 'rgba(0,0,255,0.3)';
    c0.strokeColor = 'rgba(0,0,255,0.6)';
    l0 = new Line.XY(20, 40, width - 20, height - 40);
    l0.strokeColor = 'rgb(128,128,0)';
    redraw();
  }

  redraw() {
    _clear();
    _grid(32.0);
    c0.draw(context);
    l0.draw(context);
    if (l0.sx != l0.ex || l0.sy != l0.ey) {
      List t = line_circle_p(l0.sx, l0.sy, l0.ex, l0.ey, c0.cx, c0.cy, c0.radius
          );
      if (t.isNotEmpty) {
        context
            ..fillStyle = 'rgb(255, 0, 0)'
            ..beginPath();
        for (int i = 0; i < t.length; i += 2) context
            ..arc(t[i], t[i + 1], 4, 0, 2 * PI, false)
            ..fill();
        context.closePath();
      }
    }
    repaint();
  }

  onMouseMove(num sketchX, num sketchY, var event) {
    if (isOver(sketchX, sketchY)) {
      mx = sketchX;
      my = sketchY;
      if (dragged) {
        l0.ex = mx;
        l0.ey = my;
        redraw();
      }
    }
  }

  onMouseDown(num sketchX, num sketchY, var event) {
    l0.sx = mx;
    l0.sy = my;
    l0.ex = mx;
    l0.ey = my;
    dragged = true;
    redraw();
  }

  onMouseUp(num sketchX, num sketchY, var event) {
    if ((l0.sx == l0.ex && l0.sy == l0.ey)) {
      Random rnd = new Random();
      l0.sx = rnd.nextInt(width.round());
      l0.ex = rnd.nextInt(width.round());
      l0.sy = rnd.nextInt(height.round());
      l0.ey = rnd.nextInt(height.round());
    }
    dragged = false;
    redraw();

  }

  onMouseLeave(num sketchX, num sketchY, var event) {
    dragged = false;
    redraw();
  }

}


class Oblong_Line_Anim extends Geometry2D_Anim {

  List<Oblong> oblong;

  Line sweep;
  num sweepSpeed = 2 * PI / 12, sweepAngle = 0;
  num sweepLeftX, sweepUpY, sweepRightX, sweepDownY, scx, scy;

  Oblong_Line_Anim.size(num x, num y, num w, num h): super.size(x, y, w, h) {
    scx = 96;
    scy = 128;
    sweepLeftX = scx - 8;
    sweepRightX = canvas.width - scx - 8;
    sweepUpY = scy - 8;
    sweepDownY = canvas.height - scy - 8;
    sweep = new Line.XY(scx, scy, 0, 0)
        ..strokeColor = 'rgb(128,160,128)'
        ..strokeWeight = 2.5;
    oblong = new List<Oblong>();
    oblong.add(new Oblong.XYWH(20, 24, 100, 90));
    oblong.add(new Oblong.XYWH(50, 142, 100, 50));
    oblong.add(new Oblong.XYWH(200, 20, 40, 30));
    oblong.add(new Oblong.XYWH(180, 80, 20, 20));
    oblong.add(new Oblong.XYWH(170, 110, 50, 20));
    oblong.add(new Oblong.XYWH(200, 136, 40, 30));
    oblong.add(new Oblong.XYWH(270, 45, 30, 140));
    for (Oblong ob in oblong) {
      ob.fillColor = 'rgba(150,150,240,0.3)';
      ob.strokeColor = 'rgba(120,120,200,0.6)';
      ob.strokeWeight = 2;
    }

    watch = new Stopwatch()..start();
    currTime = lastTime = watch.elapsedMicroseconds;

    timer = new Timer.periodic(const Duration(milliseconds: 20), (t) => redraw()
        );
  }

  redraw() {
    currTime = watch.elapsedMicroseconds;
    elapsedTime = currTime - lastTime;
    lastTime = currTime;
    _updateSweep(elapsedTime);
    _clear();
    _grid(32.0);
    for (Oblong ob in oblong) ob.draw(context);
    _testForIntersections();
    sweep.draw(context);
    context
        ..fillStyle = sweep.strokeColor
        ..beginPath()
        ..arc(scx, scy, 4, 0, 2 * PI)
        ..fill()
        ..closePath();
    repaint();
  }

  _testForIntersections() {
    for (Oblong ob in oblong) {
      if (line_box_xywh(sweep.sx, sweep.sy, sweep.ex, sweep.ey, ob.x, ob.y,
          ob.width, ob.height)) {
        ob.fillColor = 'rgba(255,255,160,0.3)';
        ob.strokeColor = 'rgba(200,200,120,0.6)';

      } else {
        ob.fillColor = 'rgba(150,150,240,0.3)';
        ob.strokeColor = 'rgba(120,120,200,0.6)';
      }
      ob.draw(context);
    }
  }

  _updateSweep(int etime) {
    sweepAngle += sweepSpeed * etime / 1000000;
    num dx = cos(sweepAngle);
    dx *= (dx < 0) ? sweepLeftX : sweepRightX;
    num dy = sin(sweepAngle);
    dy *= (dy < 0) ? sweepUpY : sweepDownY;
    sweep.ex = sweep.sx + dx;
    sweep.ey = sweep.sy + dy;
  }

}


class Oblong_Oblong_Anim extends Geometry2D_Anim {

  List<Oblong> oblong;
  Oblong floater;

  Oblong_Oblong_Anim.size(num x, num y, num w, num h): super.size(x, y, w, h) {
    oblong = new List<Oblong>();
    oblong.add(new Oblong.XYWH(20, 24, 100, 90));
    oblong.add(new Oblong.XYWH(50, 142, 100, 50));
    oblong.add(new Oblong.XYWH(200, 20, 40, 30));
    oblong.add(new Oblong.XYWH(180, 80, 20, 20));
    oblong.add(new Oblong.XYWH(170, 110, 50, 20));
    oblong.add(new Oblong.XYWH(200, 136, 40, 30));
    oblong.add(new Oblong.XYWH(270, 45, 30, 140));
    for (Oblong ob in oblong) {
      ob.fillColor = 'rgba(150,150,240,0.3)';
      ob.strokeColor = 'rgba(120,120,200,0.6)';
    }
    floater = new Oblong.XYWH(86, 98, 90, 70);
    floater.fillColor = 'rgba(100,240,100,0.6)';
    floater.strokeColor = 'rgba(32,180,32,0.7)';

    redraw();
  }

  redraw() {
    context..save();
    _clear();
    _grid(32.0);
    for (Oblong ob in oblong) ob.draw(context);
    floater.draw(context);
    for (Oblong ob in oblong) {
      ob.draw(context);
      Float64List intersect = box_box_p(ob.x, ob.y, ob.x + ob.width, ob.y +
          ob.height, floater.x, floater.y, floater.x + floater.width, floater.y +
          floater.height);
      if (intersect.length > 0) {
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
    repaint();
  }

  onMouseMove(num sketchX, num sketchY, var event) {
    if (isOver(sketchX, sketchY)) {
      mx = sketchX;
      my = sketchY;
      floater.x = mx - floater.width / 2;
      floater.y = my - floater.height / 2;
      redraw();
    }
  }
}


class Circle_Tangents_Anim extends Geometry2D_Anim {
  var c0;

  Circle_Tangents_Anim.size(num x, num y, num w, num h): super.size(x, y, w, h)
      {
    c0 = new Circle.XYR(canvas.width / 2.4, canvas.height / 1.9, 36);
    c0.fillColor = 'rgba(0,0,255,0.3)';
    c0.strokeColor = 'rgba(0,0,255,0.6)';
    mx = 30;
    my = 30;
    redraw();
  }

  redraw() {
    _clear();
    _grid(32.0);
    List t = tangents_to_circle(mx, my, c0.cx, c0.cy, c0.radius);
    if (t.isNotEmpty) {
      context
          ..strokeStyle = 'rgb(255, 0, 255)'
          ..lineWidth = 1
          ..beginPath();
      for (int i = 0; i < t.length; i += 2) context
          ..moveTo(mx, my)
          ..lineTo(t[i], t[i + 1])
          ..stroke();
      context.closePath();
    }
    c0.draw(context);
    if (t.isNotEmpty) {
      context
          ..fillStyle = 'rgb(255, 0, 255)'
          ..beginPath();
      for (int i = 0; i < t.length; i += 2) context
          ..arc(t[i], t[i + 1], 4, 0, 2 * PI)
          ..fill();
      context.closePath();
    }
    repaint();
  }

  onMouseMove(num sketchX, num sketchY, var event) {
    if (isOver(sketchX, sketchY)) {
      mx = sketchX;
      my = sketchY;
      redraw();
    }
  }
}


class Circle_Circle_Anim extends Geometry2D_Anim {

  var c0, c1;

  Circle_Circle_Anim.size(num x, num y, num w, num h): super.size(x, y, w, h) {
    c0 = new Circle.XYR(100, canvas.height - 80, 30);
    c1 = new Circle.XYR(235, 40, 20);
    c0.fillColor = 'rgba(0,0,255,0.3)';
    c0.strokeColor = 'rgba(0,0,255,0.6)';
    c1.fillColor = 'rgba(0,255,0,0.3)';
    c1.strokeColor = 'rgba(0,200,0,0.6)';
    redraw();
  }

  redraw() {
    _clear();
    _grid(32.0);
    c1.draw(context);
    c0.draw(context);
    List t = tangents_between_circles(c0.cx, c0.cy, c0.radius, c1.cx, c1.cy,
        c1.radius);
    if (t.isNotEmpty) {
      drawTangents(t, 0, 'rgb(255,0,255)');
      drawTangentPoints(t, 0, 'rgb(255,0,255)');
      if (t.length > 4) {
        drawTangents(t, 8, 'rgb(255,160,0)');
        drawTangentPoints(t, 8, 'rgb(255,160,0)');
      }
      // test for intersection
      t = circle_circle_p(c0.cx, c0.cy, c0.radius, c1.cx, c1.cy, c1.radius);
      if (t.isNotEmpty) {
        context..fillStyle = 'rgb(255, 0, 0)';
        for (int i = 0; i < t.length; i += 2) context
            ..beginPath()
            ..arc(t[i], t[i + 1], 3, 0, 2 * PI, false)
            ..fill()
            ..closePath();
      }
    }
    repaint();
  }

  drawTangents(List list, int start, String color) {
    context
        ..strokeStyle = color
        ..lineWidth = 1.2
        ..beginPath();
    for (int i = start; i < start + 8; i += 4) context
        ..moveTo(list[i], list[i + 1])
        ..lineTo(list[i + 2], list[i + 3])
        ..stroke();
    context.closePath();
  }

  drawTangentPoints(List list, int start, String color) {
    context..fillStyle = color;
    for (int i = start; i < start + 8; i += 2) {
      context
          ..beginPath()
          ..arc(list[i], list[i + 1], 3.5, 0, 2 * PI, true)
          ..fill()
          ..closePath();
    }
  }

  onMouseMove(num sketchX, num sketchY, var event) {
    if (isOver(sketchX, sketchY)) {
      mx = sketchX;
      my = sketchY;
      c1.cx = mx;
      c1.cy = my;
      redraw();
    }
  }
}

class Geometry2D_Anim extends Sketch {

  Geometry2D_Anim.size(num x, num y, num w, num h): super.size(x, y, w, h);

  Timer timer;
  Stopwatch watch;

  num currTime, lastTime, elapsedTime;
  num mx, my;

  static const String GRAPH_BACK = 'rgb(250, 240, 230)';
  static const String GRAPH_LINE = 'rgb(247, 231, 221)';
  static const String GRAPH_BORDER = 'rgb(220, 204, 180)';


  _clear([String col = GRAPH_BACK]) {
    context
        ..fillStyle = col
        ..fillRect(0, 0, width, height);
  }

  _grid(num size, [String col = GRAPH_LINE]) {
    context
        ..strokeStyle = col
        ..lineWidth = 1.2
        ..beginPath();
    for (num g = 0; g <= width; g += size) context
        ..moveTo(g, 0)
        ..lineTo(g, height)
        ..stroke();
    for (num g = 0; g <= height; g += size) context
        ..moveTo(0, g)
        ..lineTo(width, g)
        ..stroke();
    context.closePath();
    context
        ..strokeStyle = GRAPH_BORDER
        ..lineWidth = 2
        ..strokeRect(1, 1, width - 2, height - 2);
  }

}
