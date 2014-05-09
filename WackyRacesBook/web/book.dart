part of magazine;


class Book{
  
  static const int BACK = -1;
  static const int FORWARD = 1;
  static const int DONE = 0;
  static const int GOTO = -999;
  static const int HALT = 999;

  Queue<int> queue = new Queue<int>();
  
  Timer timer;
  Stopwatch watch = new Stopwatch()..start();
  num turnTime = 1.5 * 1E6;
  
  CanvasElement canvas;
  CanvasRenderingContext2D context;

  int width, height;
  num mx, my;
  
  int action = HALT;
  int gotoPage = 0;

  String coverColor = 'rgb(32,32,200)';
  num bookOrgX, bookOrgY, bookBorder;
  num pageW, pageH;
  num t;
  
  List<Vector2D> a = new List<Vector2D>(4);
  List<Vector2D> b = new List<Vector2D>(4);
  List<Vector2D> c = new List<Vector2D>(5);
  List<Vector2D> bk = new List<Vector2D>(4);
  Vector2D pivot = new Vector2D();
  Vector2D turnLine = new Vector2D();

  List<PageBase> pages = new List<PageBase>();
  int pageNo = -1;
  
  /**
   * Create a book
   * canvas - the drawing surface
   * spineX / spineY - the coordinates of the top of the spine
   * pageWidth / pageHeight the size of the pages
   * border - the edge round the pages that represent the book cover
   */
  Book(this.canvas, num spineX, num spineY, num pageWidth, num pageHeight, num border) {
    context = canvas.getContext("2d");
    width = canvas.width;
    height = canvas.height;
    bookOrgX = spineX.toDouble();
    bookOrgY = spineY.toDouble();
    bookBorder = border.toDouble();
    pageW = pageWidth.toDouble();
    pageH = pageHeight.toDouble();
    bk[0] = new Vector2D.XY(-pageW, 0);
    bk[1] = new Vector2D.XY(-pageW, pageH);
    bk[2] = new Vector2D.XY(pageW, pageH);
    bk[3] = new Vector2D.XY(pageW, 0);

    for (int i = 0; i < 4; i++){
      a[i] = new Vector2D();
      b[i] = new Vector2D();
      c[i] = new Vector2D.Vector(bk[i]);
    }
    c[4] = new Vector2D.Vector(bk[3]);

    querySelector('#prev').onClick.listen((e) => prevPage());
    querySelector('#next').onClick.listen((e) => nextPage());
    querySelector('#p0').onClick.listen((e) => gotoPageNo(0));
    querySelector('#p1').onClick.listen((e) => gotoPageNo(1));
    querySelector('#p2').onClick.listen((e) => gotoPageNo(2));
    querySelector('#p3').onClick.listen((e) => gotoPageNo(3));
    querySelector('#p4').onClick.listen((e) => gotoPageNo(4));
    querySelector('#p5').onClick.listen((e) => gotoPageNo(5));
    querySelector('#p6').onClick.listen((e) => gotoPageNo(6));
    querySelector('#p7').onClick.listen((e) => gotoPageNo(7));
    querySelector('#p8').onClick.listen((e) => gotoPageNo(8));
    querySelector('#p9').onClick.listen((e) => gotoPageNo(9));
    querySelector('#p10').onClick.listen((e) => gotoPageNo(10));
    querySelector('#p11').onClick.listen((e) => gotoPageNo(11));
    querySelector('#p12').onClick.listen((e) => gotoPageNo(12));

    timer = new Timer.periodic(const Duration(milliseconds: 50),
        (t) => processQueue());
    action = DONE;
  }
  
  processQueue(){
    if(queue.isNotEmpty && action == DONE){
      int op = queue.removeFirst();
      switch(op){
        case FORWARD:
          if(pageNo + 2 < pages.length){
            action = FORWARD;
            watch.reset();
            timer = new Timer.periodic(const Duration(milliseconds: 15),
                (t) => redraw());
          }
          break;
        case BACK:
          if(pageNo >= 1){
            action = BACK;
            watch.reset();
            timer = new Timer.periodic(const Duration(milliseconds: 15),
                (t) => redraw());
          }
          break;
        case GOTO:
          // Don't do this directly
          int nbrTurnsNeeded = (gotoPage - pageNo).abs()~/2;
          if(nbrTurnsNeeded > 0){
            int dir = (gotoPage > pageNo) ? FORWARD : BACK;
            for(int i = 0; i < nbrTurnsNeeded; i++)
              queue.add(dir);
          }
          break;
        default:
          redraw();
      }
    }
  }
  
  addToQueue(int new_action, [int showpage = -1]){
    // Remove all DONE actions from end of the queue
    while(queue.isNotEmpty){
      int old_action = queue.removeLast();
      if(old_action != DONE){
        queue.add(old_action);
        break;
      }
    }
    // Removed unneeded DONE's so now process new_action
    if(new_action == GOTO){
      queue.clear();
      gotoPage = (showpage % 2 == 0) ? showpage - 1 : showpage;
    }
    queue.add(new_action);
  }
  
  nextPage(){
    queue.add(FORWARD);
  }
  
  prevPage(){
    queue.add(BACK);
  }
  
  gotoPageNo(num pn){
//    var d = document.querySelector('#description');
//    d.innerHtml = "<h3>Page selector</h3><p>Goto page " + pn.toString() + "</p>";
    addToQueue(GOTO, pn);
  }
  
  
//  makePages(){
//    pages.add(new Page(this, 0, ["images/wacky_0.jpg"], "texts/text0.txt"));
//    for(int i = 0; i < 13; i++)
//      pages.add(new MyImagePage(this, i, "images/wacky_$i.jpg"));
//  }
  
  redraw(){
    _clear();
    context
    ..save()
    ..translate(bookOrgX, bookOrgY);
    // Book cover
    context
    ..fillStyle = 'rgb(0,100,0)'
    ..strokeStyle = 'rgb(100,255,100)'
    ..fillRect(-pageW-bookBorder, -bookBorder, (pageW + bookBorder)*2, pageH + bookBorder*2)
    ..strokeRect(-pageW-bookBorder + 4, -bookBorder + 4, (pageW + bookBorder)*2 -8, pageH + bookBorder*2-8);
    // Preapre main clipper
    for(int i = 0; i < 4; i++)
      c[i].setVector(bk[i]);
    c[4].setVector(bk[3]);
    // Calculate turn values
    if(action != DONE){
      t = min(1.0, watch.elapsedMicroseconds / turnTime); 
      doTurnMaths(action, t);
    }
    // Set clip region for main pages
    context
    ..save()..beginPath()
    ..moveTo(c[0].x, c[0].y)
    ..lineTo(c[1].x, c[1].y)
    ..lineTo(c[2].x, c[2].y)
    ..lineTo(c[3].x, c[3].y)
    ..lineTo(c[4].x, c[4].y)
    ..clip();
    // draw left page
    if(pageNo > 0)
      context.drawImage(pages[pageNo].canvas, -pageW, 0);
    // draw right page
    if(pageNo + 1 < pages.length)
      context.drawImage(pages[pageNo+1].canvas, 0, 0);
    context.restore();
    // Draw spine shadow
    drawSpineShadow();
    // See if we are currently turning a page
    if(action != DONE){
      drawTurn();
      if(t == 1.0){ //Has turn finisihed.
        pageNo += (action == BACK) ? -2 : 2;
        action = DONE;
        t = 0.0;
        timer.cancel();
        queue.add(DONE);
      }
    }
    context.restore();
  }
  
  drawSpineShadow(){
    context
    ..strokeStyle = 'rgba(0,0,0,0.06)'
    ..lineWidth = 16 .. beginPath() ..moveTo(0,0) ..lineTo(0, pageH)..closePath()..stroke()
    ..lineWidth = 8 .. beginPath() ..moveTo(0,0) ..lineTo(0, pageH)..closePath()..stroke()
    ..lineWidth = 4 .. beginPath() ..moveTo(0,0) ..lineTo(0, pageH)..closePath()..stroke()
    ..strokeStyle = 'rgba(0,0,0,0.1)'
    ..lineWidth = 2  .. beginPath() ..moveTo(0,0) ..lineTo(0, pageH)..closePath()..stroke();
  }
  
  drawTurn(){
    int revealPage, turnPage;
    double deltaX, deltaAngle;
    switch(action){
      case FORWARD:
        revealPage = pageNo + 3;
        turnPage = pageNo + 2;
        deltaX = 0.0;
        deltaAngle = 0.0;
        break;
      case BACK:
        revealPage = pageNo - 2;
        turnPage = pageNo - 1;
        deltaX = -pageW;
        deltaAngle = PI;
        break;  
    }
    // Reveal page (b)
    if(revealPage > 0 && revealPage < pages.length){
      context
      ..save()
      ..beginPath()
      ..moveTo(b[0].x, b[0].y)
      ..lineTo(b[1].x, b[1].y)
      ..lineTo(b[2].x, b[2].y)
      ..lineTo(b[3].x, b[3].y)
      ..clip()
      ..drawImage(pages[revealPage].canvas, deltaX, 0)
      // Create shadow from turning page
      ..strokeStyle = 'rgba(0,0,0,0.08)'
      ..beginPath()..lineWidth = 20 ..moveTo(b[0].x, b[0].y)..lineTo(b[3].x, b[3].y)..closePath()..stroke()
      ..beginPath()..lineWidth = 10 ..moveTo(b[0].x, b[0].y)..lineTo(b[3].x, b[3].y)..closePath()..stroke()
      ..beginPath()..lineWidth = 5 ..moveTo(b[0].x, b[0].y)..lineTo(b[3].x, b[3].y)..closePath()..stroke() 
      ..restore();
      context;
    }
  
    // turning page (a)
    double pivotAngle = deltaAngle + atan2(a[0].y - a[1].y, a[0].x - a[1].x);
    context
    ..save()
    ..beginPath()
    ..moveTo(a[0].x, a[0].y)
    ..lineTo(a[1].x, a[1].y)
    ..lineTo(a[2].x, a[2].y)
    ..lineTo(a[3].x, a[3].y)
    ..clip()
    ..translate(pivot.x, pivot.y)
    ..rotate(pivotAngle)
    ..drawImage(pages[turnPage].canvas, deltaX, 0)
    ..restore();
  }
  
  doTurnMaths(int dir, double t) {
    a[0].setXY((1-t) * pageW, pageH);
    b[0].setVector(a[0]);
    c[2].setVector(a[0]);
     // Calculate next point
    var angle = getAngle(t);
    turnLine.setVector(a[0]);
    turnLine.x += 2*pageH * cos(-angle);
    turnLine.y += 2*pageH * sin(-angle);
    a[1].setVector(point_nearest_infinite_line(a[0], turnLine, bk[2]));
    a[1].mult(2);
    a[1].subVec(bk[2]);
    b[1].setVector(bk[2]);
    // calc page pivot point
    pivot.x = - (a[0].y - a[1].y);
    pivot.y = (a[0].x - a[1].x);
    pivot.normalize();
    pivot.mult(-pageH);
    pivot.addVec(a[1]);
    Vector2D intercept = line_line_pv(a[0], turnLine, bk[2], bk[3]);
    if(intercept != null){
      // intercepts on book edge
      a[2].setVector(intercept);
      a[3].setVector(intercept);
      b[2].setVector(intercept);
      b[3].setVector(intercept);
      c[3].setVector(intercept);
    }
    else {
      // intercepts on top edge
      intercept = line_line_pv(a[0], turnLine, bk[0], bk[3]);
      a[2].setVector(pivot);
      b[2].setVector(bk[3]);
      a[3].setVector(intercept);
      b[3].setVector(intercept);
      c[3].setVector(intercept);
      c[4].setVector(intercept);
    }
    if (dir == BACK) {
      for (int i = 0; i < a.length; i++){
        a[i].x *= -1;
        b[i].x *= -1;
        c[i].x *= -1;
      }
      c[4].x *= -1;
      pivot.x *= -1;
    }
  }

  double getAngle(double t) {
    double start = PI/2.5;
    double end = PI/2;
    double range = end - start;
    return (start + t * range);
  }

  _clear(){
    context
    ..fillStyle = 'rgba(0,0,0,0.0)'
    ..clearRect(0,0, width, height);
  }

}
