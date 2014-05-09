library book;

import 'dart:html';
import "dart:math";
import 'dart:async';
import 'dart:collection';
import 'dart:convert' show JSON;

import "geometry2d.dart";
import "vector2d.dart";


String BIND_COLOR = 'rgba(0,0,0,0.2)';
String PAGE_BORDER = 'rgba(0,0,0,0.2)';
String COVER_COLOR = 'rgb(32,32,200)';
String COVER_TRIM_COLOR = 'rgb(64,64,255)';
String PAGE_COLOR = 'rgb(255,250,240)';
String FONT_COLOR = 'rgb(0,0,255)';
String PAGE_NO_FONT = "8pt Calibri";

num TURN_FAST = 1.5 * 1E6;
num TURN_SLOW = 2.5 * 1E6;

var left_page_div, right_page_div;

// ######################################################################
// ######################################################################
// Book
// ######################################################################
// ######################################################################

/**
 * The class that represents a generic book where the pages can be turned.
 * created by Peter Lager
 */
class Book {

  PageTurnQueue ptq = new PageTurnQueue();
  Action action = new Action(Action.TURN_WAITING, null, null);

  Timer timer;
  Stopwatch watch = new Stopwatch()..start();

  CanvasElement surfaceCanvas;
  CanvasRenderingContext2D surfaceContext;
  CanvasElement bookCanvas;
  CanvasRenderingContext2D bookContext = null;
  ImageElement insideCover = null;

  int surfaceW, surfaceH;
  num mx, my;

  num bookOrgX, bookOrgY, bookBorder, bookW, bookH;
  num leftPageXoffset, rightPageXoffset;
  num pageW, pageH;
  num t;

  List<Vector2D> a = new List<Vector2D>(4);
  List<Vector2D> b = new List<Vector2D>(4);
  List<Vector2D> c = new List<Vector2D>(5);
  List<Vector2D> pg = new List<Vector2D>(4);
  Vector2D pivot = new Vector2D();
  Vector2D turnLine = new Vector2D();

  List<Page> pages = new List<Page>();
  int pageNo = -1;

  bool animUpdate = false;

  var pointerStyle;

  /**
   * Create a book
   * canvas - the drawing surface
   * spineX / spineY - the coordinates of the top of the spine
   * pageWidth / pageHeight the size of the pages
   * border - the edge round the pages that represent the book cover
   */
  Book(this.surfaceCanvas, num spineX, num spineY, num pageWidth, num
      pageHeight, num border, [String filename = null]) {
    // Get HTML div elements
    left_page_div = document.querySelector('#LEFT_PAGE_HTML');
    right_page_div = document.querySelector('#RIGHT_PAGE_HTML');
    // Get drawing context
    surfaceContext = surfaceCanvas.getContext("2d");
    // Dimension of drawing surface
    surfaceW = surfaceCanvas.width;
    surfaceH = surfaceCanvas.height;
    bookOrgX = spineX.toDouble();
    bookOrgY = spineY.toDouble();
    bookBorder = border.toDouble();
    pageW = pageWidth.toDouble();
    pageH = pageHeight.toDouble();
    // Page offsets for mouse
    rightPageXoffset = surfaceW / 2;
    leftPageXoffset = rightPageXoffset - pageW;
    // Book dimensions
    bookW = ((pageW + bookBorder) * 2).round();
    bookH = (pageH + bookBorder * 2).round();
    // Canvas and context for book cover
    bookCanvas = document.createElement('canvas');
    bookCanvas.width = bookW;
    bookCanvas.height = bookH;
    bookContext = bookCanvas.getContext("2d");
    blankCover();
    // Book metrics
    pg[0] = new Vector2D.XY(-pageW, 0);
    pg[1] = new Vector2D.XY(-pageW, pageH);
    pg[2] = new Vector2D.XY(pageW, pageH);
    pg[3] = new Vector2D.XY(pageW, 0);

    for (int i = 0; i < 4; i++) {
      a[i] = new Vector2D();
      b[i] = new Vector2D();
      c[i] = new Vector2D.Vector(pg[i]);
    }
    c[4] = new Vector2D.Vector(pg[3]);
    if (filename != null) {
      insideCover = (new ImageElement(src: 'images/$filename'));
      insideCover.onLoad.first.then((_) => _applyImage());
    } else {
      blankCover();
    }
    timer = new Timer.periodic(const Duration(milliseconds: 20), (t) =>
        _processQueue());
    action = new Action(Action.TURN_DONE, null, null);
    surfaceCanvas.onMouseDown.listen(onMouseDown);
    surfaceCanvas.onMouseMove.listen(onMouseMove);
    surfaceCanvas.onMouseUp.listen(onMouseUp);
    surfaceCanvas.onMouseWheel.listen(onMouseWheel);

    pointerStyle = surfaceCanvas.style.cursor = 'crosshair';
  }

  setCursorStyle([var cStyle = null]) {
    if (cStyle != null) {
      surfaceCanvas.style.cursor = cStyle;
    } else {
      surfaceCanvas.style.cursor = pointerStyle;
    }
  }

  onMouseDown(event) {
    if (action.isDONE()) {
      _resolveMouseCoordinates(event.client.x, event.client.y);
      if (pageNo >= 0) {
        pages[pageNo].onMouseDown(mx - leftPageXoffset, my - bookOrgY, event);
      }
      if (pageNo + 1 < pages.length) {
        pages[pageNo + 1].onMouseDown(mx - rightPageXoffset, my - bookOrgY,
            event);
      }
    }
  }

  onMouseMove(event) {
    if (action.isDONE()) {
      _resolveMouseCoordinates(event.client.x, event.client.y);
      if (pageNo >= 0) pages[pageNo].onMouseMove(mx - leftPageXoffset, my -
          bookOrgY, event);
      if (pageNo + 1 < pages.length) {
        pages[pageNo + 1].onMouseMove(mx - rightPageXoffset, my - bookOrgY,
            event);
      }
    }
  }

  onMouseUp(event) {
    if (action.isDONE()) {
      _resolveMouseCoordinates(event.client.x, event.client.y);
      if (pageNo >= 0) pages[pageNo].onMouseUp(mx - leftPageXoffset, my -
          bookOrgY, event);
      if (pageNo + 1 < pages.length) {
        pages[pageNo + 1].onMouseUp(mx - rightPageXoffset, my - bookOrgY, event
            );
      }
    }
  }

  onMouseWheel(event) {
    if (action.isDONE()) {
      _resolveMouseCoordinates(event.client.x, event.client.y);
      if (pageNo >= 0) pages[pageNo].onMouseWheel(mx - leftPageXoffset, my -
          bookOrgY, event);
      if (pageNo + 1 < pages.length) {
        pages[pageNo + 1].onMouseWheel(mx - rightPageXoffset, my - bookOrgY,
            event);
      }
    }
  }

  _resolveMouseCoordinates(num x, num y) {
    Rectangle surface = surfaceCanvas.getBoundingClientRect();
    mx = x - surface.left;
    my = y - surface.top;
    mx = (mx < 0) ? 0 : mx;
    mx = (mx >= surfaceW) ? surfaceW - 1 : mx;
    my = (my < 0) ? 0 : my;
    my = (my >= surfaceH) ? surfaceH - 1 : my;
  }

  nextPage() {
    ptq.addAction_t(Action.TURN_FORWARD, TURN_SLOW);
  }

  prevPage() {
    ptq.addAction_t(Action.TURN_BACK, TURN_SLOW);
  }

  gotoPageNo(num pn) {
    ptq.clear();
    ptq.addAction_tp(Action.GOTO_PAGE, TURN_SLOW, pn);
  }

  isPageVisible(int position) {
    bool visible;
    if (action.isBACK()) {
      visible = position >= pageNo - 2 && position <= pageNo + 1;
    } else if (action.isFORWARD()) {
      visible = position >= pageNo && position <= pageNo + 3;
    } else {
      visible = position >= pageNo && position <= pageNo + 1;
    }
    return visible;
  }

  // Make sure that the pages know where they are in the book
  numberPages() {
    for (int i = 0; i < pages.length; i++) pages[i].setPosInBook(i);
  }

  repaintBook() {
    animUpdate = true;
  }

  refresh() {
    ptq.addRefresh();
  }

  redraw() {
    _clear();
    // After clearing the surface draw the book cover
    surfaceContext
        ..save()
        ..translate(surfaceW / 2, bookOrgY - bookBorder)
        ..drawImage(bookCanvas, -bookW / 2, 0)
        ..restore();
    surfaceContext
        ..save()
        ..translate(bookOrgX, bookOrgY);
    // Preapre main clipper
    for (int i = 0; i < 4; i++) c[i].setVector(pg[i]);
    c[4].setVector(pg[3]);
    // Calculate turn values
    if (!action.isDONE()) {
      t = min(1.0, watch.elapsedMicroseconds / action.turnTime);
      _doTurnMaths(action.type, t);
    }
    // Set clip region for main pages
    surfaceContext
        ..save()
        ..beginPath()
        ..moveTo(c[0].x, c[0].y)
        ..lineTo(c[1].x, c[1].y)
        ..lineTo(c[2].x, c[2].y)
        ..lineTo(c[3].x, c[3].y)
        ..lineTo(c[4].x, c[4].y)
        ..clip();
    // draw left page
    if (pageNo > 0) surfaceContext.drawImage(pages[pageNo].canvas, -pageW, 0);
    // draw right page
    if (pageNo + 1 < pages.length) surfaceContext.drawImage(pages[pageNo +
        1].canvas, 0, 0);
    surfaceContext.restore();
    // See if we are currently turning a page
    if (!action.isDONE()) {
      _drawTurn();
      if (t >= 1.0) { //Has turn finisihed.
        pageNo += action.isBACK() ? -2 : 2;
        action.type = Action.TURN_DONE;
        t = 0.0;
        timer.cancel();
        ptq.addAction(Action.TURN_DONE);
      }
    }
    surfaceContext.restore();
  }

  _drawTurn() {
    int revealPage, turnPage;
    double deltaX, deltaAngle;
    switch (action.type) {
      case Action.TURN_FORWARD:
        revealPage = pageNo + 3;
        turnPage = pageNo + 2;
        deltaX = 0.0;
        deltaAngle = 0.0;
        break;
      case Action.TURN_BACK:
        revealPage = pageNo - 2;
        turnPage = pageNo - 1;
        deltaX = -pageW;
        deltaAngle = PI;
        break;
    }
    // Reveal page (b)
    if (revealPage > 0 && revealPage < pages.length) {
      surfaceContext
          ..save()
          ..beginPath()
          ..moveTo(b[0].x, b[0].y)
          ..lineTo(b[1].x, b[1].y)
          ..lineTo(b[2].x, b[2].y)
          ..lineTo(b[3].x, b[3].y)
          ..clip()
          ..drawImage(pages[revealPage].canvas, deltaX, 0);
      // Create shadow from turning page
      if (t > 0) {
        surfaceContext
            ..strokeStyle = 'rgba(0,0,0,0.3)'
            ..beginPath()
            ..lineWidth = 3
            ..moveTo(b[0].x, b[0].y)
            ..lineTo(b[3].x, b[3].y)
            ..closePath()
            ..stroke();
      }
      surfaceContext..restore();
      surfaceContext;
    }
    // turning page (a)
    double pivotAngle = deltaAngle + atan2(a[0].y - a[1].y, a[0].x - a[1].x);
    surfaceContext
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

  _doTurnMaths(int dir, double t) {
    a[0].setXY((1 - t) * pageW, pageH);
    b[0].setVector(a[0]);
    c[2].setVector(a[0]);
    // Calculate next point
    var angle = _getAngle(t);
    turnLine.setVector(a[0]);
    turnLine.x += 2 * pageH * cos(-angle);
    turnLine.y += 2 * pageH * sin(-angle);
    a[1].setVector(point_nearest_infinite_line(a[0], turnLine, pg[2]));
    a[1].mult(2);
    a[1].subVec(pg[2]);
    b[1].setVector(pg[2]);
    // calc page pivot point
    pivot.x = -(a[0].y - a[1].y);
    pivot.y = (a[0].x - a[1].x);
    pivot.normalize();
    pivot.mult(-pageH);
    pivot.addVec(a[1]);
    Vector2D intercept = line_line_pv(a[0], turnLine, pg[2], pg[3]);
    if (intercept != null) {
      // intercepts on book edge
      a[2].setVector(intercept);
      a[3].setVector(intercept);
      b[2].setVector(intercept);
      b[3].setVector(intercept);
      c[3].setVector(intercept);
    } else {
      // intercepts on top edge
      intercept = line_line_pv(a[0], turnLine, pg[0], pg[3]);
      a[2].setVector(pivot);
      b[2].setVector(pg[3]);
      a[3].setVector(intercept);
      b[3].setVector(intercept);
      c[3].setVector(intercept);
      c[4].setVector(intercept);
    }
    if (dir == Action.TURN_BACK) {
      for (int i = 0; i < a.length; i++) {
        a[i].x *= -1;
        b[i].x *= -1;
        c[i].x *= -1;
      }
      c[4].x *= -1;
      pivot.x *= -1;
    }
  }

  double _getAngle(double t) {
    double start = PI / 2.5;
    double end = PI / 2;
    double range = end - start;
    return (start + t * range);
  }

  _processQueue() {
    // Has there been an animation refresh request
    if (animUpdate) redraw();
    // Get next action
    if (action.isDONE()) {
      Action nextAction = ptq.getAction();
      switch (nextAction.type) {
        case Action.TURN_FORWARD:
          if (pageNo + 2 < pages.length) {
            action = nextAction;
            watch.reset();
            timer = new Timer.periodic(const Duration(milliseconds: 15), (t) =>
                redraw());
          }
          break;
        case Action.TURN_BACK:
          if (pageNo >= 1) {
            action = nextAction;
            watch.reset();
            timer = new Timer.periodic(const Duration(milliseconds: 15), (t) =>
                redraw());
          }
          break;
        case Action.GOTO_PAGE:
          // Don't do this directly
          int startPos = (pageNo + 1) ~/ 2;
          int endPos = (nextAction.pageNo + 1) ~/ 2;
          int nbrTurnsNeeded = (endPos - startPos).abs();
          if (nbrTurnsNeeded > 0) {
            int dir = (nextAction.pageNo > pageNo) ? Action.TURN_FORWARD :
                Action.TURN_BACK;
            for (int i = 0; i < nbrTurnsNeeded; i++) {
              ptq.addAction_t(dir, (i < nbrTurnsNeeded - 1 ? TURN_FAST :
                  TURN_SLOW));
            }
          }
          break;
        case Action.TURN_DONE:
          if (left_page_div != null && right_page_div != null) {
            // Left page HTML
            if (pageNo > -1 && pages[pageNo].content != null &&
                pages[pageNo].content.htmlText != null) left_page_div.innerHtml =
                pages[pageNo].content.htmlText; else left_page_div.innerHtml = "";
            // Right page HTML
            if (pageNo + 1 < pages.length && pages[pageNo + 1].content != null
                && pages[pageNo + 1].content.htmlText != null) right_page_div.innerHtml =
                pages[pageNo + 1].content.htmlText; else right_page_div.innerHtml = "";
          }
          // Only do this if there is no animation
          if (!animUpdate) redraw();
      }
    }
    animUpdate = false;
  }

  _clear() {
    surfaceContext
        ..fillStyle = 'rgba(0,0,0,0.0)'
        ..clearRect(0, 0, surfaceW, surfaceH);
  }

  // Apply image in centre
  _applyImage() {
    bookContext
        ..save()
        ..translate(bookW / 2, bookH / 2)
        ..drawImage(insideCover, -insideCover.width / 2, -insideCover.height / 2
            )
        ..restore();
    redraw();
  }

  blankCover() {
    num trimEdge = bookBorder / 2;
    bookContext
        ..fillStyle = COVER_COLOR
        ..beginPath()
        ..rect(0, 0, bookW, bookH)
        ..fill()
        ..closePath
        ..beginPath()
        ..strokeStyle = COVER_TRIM_COLOR
        ..lineWidth = 2
        ..rect(trimEdge, trimEdge, bookW - bookBorder, bookH - bookBorder)
        ..stroke()
        ..closePath();
  }
}


// ######################################################################
// ######################################################################
// Page
// ######################################################################
// ######################################################################

class Page {

  Book book;

  CanvasElement canvas;
  CanvasRenderingContext2D context;

  PageContent content;
  List<Sketch> sketches = new List<Sketch>();

  num posInBook = 0;
  String _pageNoText;

  bool dragged = false;
  bool isOver = false;

  num mx, my;

  var bindGradient;
  int bindSide = -1;

  int overSketch = -1;

  Page(this.book, this._pageNoText, [String playoutFile = null]) {
    canvas = document.createElement('canvas');
    canvas.width = book.pageW.toInt();
    canvas.height = book.pageH.toInt();
    context = canvas.getContext("2d");
    context.textBaseline = 'bottom';
    _preContentRender();
    // Load page layout then this to load all static page content
    if (playoutFile != null) {
      HttpRequest.getString(playoutFile).then(_getContent);
    }
  }

  setPosInBook(int pos) {
    posInBook = pos;
    bindSide = pos % 2;
    if (bindSide == 0) { // bound on left
      bindGradient = context.createLinearGradient(0, 0, 10, 0);
      bindGradient.addColorStop(0.0, BIND_COLOR);
      bindGradient.addColorStop(1.0, 'rgba(0,0,0,0)');
    } else { // bound on right
      bindGradient = context.createLinearGradient(canvas.width - 10, 0,
          canvas.width, 0);
      bindGradient.addColorStop(0.0, 'rgba(0,0,0,0)');
      bindGradient.addColorStop(1.0, BIND_COLOR);
    }
    _drawPageHighlight();
  }

  _drawPageHighlight() {
    if (bindGradient != null) {
      context
          ..strokeStyle = PAGE_BORDER
          ..lineWidth = 3
          ..fillStyle = bindGradient;
      if (bindSide == 0) {
        context
            ..fillRect(0, 0, 10, canvas.height)
            ..beginPath()
            ..moveTo(1, 1)
            ..lineTo(canvas.width - 1, 1)
            ..lineTo(canvas.width - 1, canvas.height - 1)
            ..lineTo(1, canvas.height - 1)
            ..stroke()
            ..closePath();

      } else {
        context
            ..fillStyle = bindGradient
            ..fillRect(canvas.width - 10, 0, canvas.width, canvas.height)
            ..beginPath()
            ..moveTo(canvas.width - 1, 1)
            ..lineTo(1, 1)
            ..lineTo(1, canvas.height - 1)
            ..lineTo(canvas.width - 1, canvas.height - 1)
            ..stroke()
            ..closePath();
      }
    }
  }

  addSketch(Sketch s) {
    if (s != null && !sketches.contains(s)) {
      s.addedToPage(this);
      sketches.add(s);
      s.paintOnPage();
    }
  }

  onMouseDown(num pageX, num pageY, var event) {
    for (Sketch s in sketches) {
      s.onMouseDown(pageX - s.view.left, pageY - s.view.top, event);
    }
  }

  int overWhichSketch(num pageX, num pageY) {
    for (int i = 0; i < sketches.length; i++) {
      Sketch s = sketches[i];
      if (s.isOver(pageX - s.view.left, pageY - s.view.top)) return i;
    }
    return -1;
  }

  bool _isOver(num x, num y) {
    return x >= 0 && x < book.pageW && y >= 0 && y < book.pageH;
  }

  onMouseMove(num pageX, num pageY, var event) {
    // Simulate mouse entering and leaving a sketch
    int lastOverSketch = overSketch;
    overSketch = overWhichSketch(pageX, pageY);
    if (lastOverSketch != overSketch) {
      Sketch s;
      if (lastOverSketch >= 0) {
        s = sketches[lastOverSketch];
        s.onMouseLeave(pageX - s.view.left, pageY - s.view.top, event);
      }
      if (overSketch >= 0) {
        s = sketches[overSketch];
        s.onMouseEnter(pageX - s.view.left, pageY - s.view.top, event);
      }
    }
    // Forward mouse move envents
    for (Sketch s in sketches) {
      s.onMouseMove(pageX - s.view.left, pageY - s.view.top, event);
    }
  }

  onMouseUp(num pageX, num pageY, var event) {
    for (Sketch s in sketches) {
      s.onMouseUp(pageX - s.view.left, pageY - s.view.top, event);
    }
  }

  onMouseWheel(num pageX, num pageY, var event) {
    for (Sketch s in sketches) {
      s.onMouseWheel(pageX - s.view.left, pageY - s.view.top, event);
    }
  }

  // This will only be called if the sketch is visible
  redrawSketch(Sketch s) {
    context.drawImage(s.canvas, s.view.left, s.view.top);
    book.repaintBook();
  }

  render() {
    // If we have a paper texture then use it else use color fill
    if (content.paper != null) {
      for (int py = 0; py < book.pageH; py += content.paper.height) {
        for (int px = 0; px < book.pageW; px += content.paper.width) {
          context.drawImage(content.paper, px, py);
        }
      }
    } else {
      context
          ..fillStyle = PAGE_COLOR
          ..rect(0, 0, book.pageW, book.pageH)
          ..fill();
    }
    // Now add the images
    for (int n = 0; n < content.imageContents.length; n++) {
      ImageContent imageContent = content.imageContents[n];
      context.drawImage(imageContent.image, imageContent.myArea.x,
          imageContent.myArea.y);
    }
    // Now add the text
    for (int i = 0; i < content.textContents.length; i++) {
      TextContent textContent = content.textContents[i];
      TextFormatter text_layout = new TextFormatter(context, textContent);
      if (text_layout != null) {
        // If we have a back color use it
        if (textContent.backColor != null) {
          context.fillStyle = textContent.backColor;
          for (Area a in textContent.myAreas) {
            context
                ..beginPath()
                ..rect(a.x, a.y, a.w, a.h)
                ..closePath()
                ..fill();
          }
        }
        context
            ..fillStyle = (textContent.fontColor == null) ? FONT_COLOR :
                textContent.fontColor
            ..font = textContent.font;
        for (Word word in text_layout.words) {
          context.fillText(word.word, word.x, word.y);
        }
      }
    }
    _drawPageHighlight();
    _displayPageNo();
    // Now repaint the sketchs if any.
    for (Sketch s in sketches) {
      context.drawImage(s.canvas, s.view.left, s.view.top);
    }
    book.repaintBook();
    // Update any HTML
    if (content != null && content.htmlText != null) book.refresh();
  }

  _getContent(String json) {
    content = new PageContent();
    content.fromJson(json);
    // Load page content
    var futures = [];
    // Load the paper texture (if any)
    if (content.paperFile != null) {
      content.paper = new ImageElement(src: 'images/${content.paperFile}');
      futures.add(content.paper.onLoad.first);
    }
    // Load the HTML if any
    if (content.htmlFile != null) {
      futures.add(HttpRequest.getString('html/${content.htmlFile}').then((s) =>
          content.htmlText = s));
    }
    // Setup loading the images
    for (int i = 0; i < content.imageContents.length; i++) {
      content.imageContents[i].image = new ImageElement(src:
          'images/${content.imageContents[i].filename}');
      futures.add(content.imageContents[i].image.onLoad.first);
    }
    // Load text content
    for (int i = 0; i < content.textContents.length; i++) {
      if (content.textContents[i].filename != null) {
        futures.add(HttpRequest.getString(
            'texts/${content.textContents[i].filename}').then((s) =>
            content.textContents[i].text = s));
      }
    }
    // When everything is loaded then render
    Future.wait(futures).then((_) => render());
  }

  // override in other page types
  _preContentRender() {
    context.font = "24pt Calibri";
    String message = "Loading Content";
    num posx = (book.pageW - context.measureText(message).width) / 2;
    context
        ..beginPath()
        ..fillStyle = 'rgb(255,220,220)'
        ..fillRect(0, 0, book.pageW, book.pageH)
        ..fill()
        ..closePath()
        ..fillStyle = 'rgb(100,10,10)'
        ..fillText(message, posx, book.pageH * 0.45);
    _displayPageNo();
  }

  _displayPageNo() {
    context
        ..fillStyle = FONT_COLOR
        ..font = PAGE_NO_FONT;
    num offset = context.measureText(_pageNoText).width;
    context.fillText(_pageNoText, (book.pageW - offset) / 2, book.pageH - 6);
  }
}


// ######################################################################
// ######################################################################
// Sketch
// ######################################################################
// ######################################################################

class Sketch {

  CanvasElement canvas;
  CanvasRenderingContext2D context;
  Page page;

  Rectangle view;

  num mx, my;
  num width, height;

  bool dragged;

  Sketch.size(num x, num y, num w, num h) {
    canvas = document.createElement('canvas');
    width = canvas.width = w.toInt();
    height = canvas.height = h.toInt();
    view = new Rectangle(x, y, canvas.width, canvas.height);
    context = canvas.getContext("2d");
    //   context.textBaseline = 'bottom';
  }

  addedToPage(Page p) => page = p;

  onMouseDown(num sketchX, num sketchY, var event) {
    dragged = true;
  }

  onMouseEnter(num sketchX, num sketchY, var event) {
  }

  onMouseLeave(num sketchX, num ksetchY, var event) {
  }

  onMouseMove(num sketchX, num sketchY, var event) {
  }

  onMouseUp(num sketchX, num sketchY, var event) {
  }

  onMouseWheel(num sketchX, num sketchY, var event) {
  }

  bool isOver(num x, num y) {
    return x >= 0 && x < view.width && y >= 0 && y < view.height;
  }

  isVisible() {
    return (page == null ? false : page.book.isPageVisible(page.posInBook));
  }

  paintOnPage() {
    if (page != null) page.redrawSketch(this);
  }
}


// ######################################################################
// ######################################################################
// PageContent
// ######################################################################
// ######################################################################

class PageContent {

  List<ImageContent> imageContents = new List<ImageContent>();
  List<TextContent> textContents = new List<TextContent>();
  Map<String, Area> areas = new Map<String, Area>();

  String paperFile;
  ImageElement paper;

  String htmlFile;
  String htmlDivName;
  String htmlText;

  String area_name_all, image_name_all, text_name_all;

  PageContent();

  fromJson(String s) {
    var map = JSON.decode(s);
    paperFile = map["PAPER"];
    htmlFile = map["HTML"];


    List<String> names;
    // Get and create the areas and ad them to areas
    area_name_all = map["AREA-NAMES"];
    if (area_name_all != null) {
      names = area_name_all.split(",");
      for (String name in names) {
        if (name.length > 0) {
          Area a = new Area.named(name);
          a.fromJson(map[name]);
          areas[name] = a;
        }
      }
    }
    // Get and create the image areas
    image_name_all = map["IMAGE-NAMES"];
    if (image_name_all != null) {
      names = image_name_all.split(",");
      for (String name in names) {
        if (name.length > 0) {
          ImageContent ia = new ImageContent.named(name);
          ia.fromJson(map[name], areas);
          imageContents.add(ia);
        }
      }
    }
    // Get and create the text areas
    text_name_all = map["TEXT-NAMES"];
    if (text_name_all != null) {
      names = text_name_all.split(",");
      for (String name in names) {
        if (name.length > 0) {
          TextContent ta = new TextContent.named(name);
          ta.fromJson(map[name], areas);
          textContents.add(ta);
        }
      }
    }
  }

  String toJson() {
    StringBuffer s = new StringBuffer();
    s.writeln('{');
    int comma = 0;
    // Page areas
    if (area_name_all != null) {
      comma++;
      s.writeln('"AREA-NAMES":"$area_name_all"}');
      for (String a in areas.keys.toList(growable: false)) {
        s.writeln(',${areas[a].toJson()}');
      }
    }
    // Images
    if (image_name_all != null) {
      if (comma > 0) s.write(',');
      comma++;
      s.writeln('"IMAGE-NAMES":"$image_name_all"}');
      for (ImageContent a in imageContents) {
        s.writeln(',${a.toJson()}');
      }
    }
    // Text areas
    if (text_name_all != null) {
      if (comma > 0) s.write(',');
      comma++;
      s.writeln('"TEXT-NAMES":"$text_name_all"}');
      for (TextContent a in textContents) {
        s.writeln(',${a.toJson()}');
      }
    }
    s.writeln('}');
    return s.toString();
  }

}


// ######################################################################
// ######################################################################
// Area
// ######################################################################
// ######################################################################

/**
 * Defines a 2D area on the page for either images or text
 */
class Area {
  String name;
  num x;
  num y;
  num w;
  num h;

  Area.named(this.name);

  fromJson(String s) {
    var map = JSON.decode(s);
    x = map["X"];
    y = map["Y"];
    w = map["W"];
    h = map["H"];
  }

  String toJson() {
    return '\"$name\":\"{\\"X\\":$x,\\"Y\\":$y,\\"W\\":$w,\\"H\\":$h}\"';
  }

}

// ######################################################################
// ######################################################################
// ImageContent
// ######################################################################
// ######################################################################

class ImageContent {
  // This is the image data read in from the file specified in the layout
  ImageElement image = null;

  // These are read in from the layout file
  String filename;
  // Filled when read from JSON
  String name;
  String myAreaName;
  Area myArea = null;


  ImageContent.named(this.name);

  ImageContent.fa(this.filename, this.myArea);

  fromJson(String s, Map<String, Area> areas) {
    var map = JSON.decode(s);
    filename = map["FILENAME"];
    myArea = areas[map["IMAGE-AREA"]];
  }

  String toJson() {
    return
        '\"$name\":\"{\\"IMAGE-AREA\\":\\"$myAreaName\\",\\"FILENAME\\":\\"$filename\\"}\"';
  }
}

// ######################################################################
// ######################################################################
// TextContent
// ######################################################################
// ######################################################################

class TextContent {
  // This is the text read in from the file specified in the layout
  String text = null;
  String name;
  // These are read in from the layout file
  String filename;
  String font;
  String fontColor;
  String backColor;
  String align; // LEFT RIGHT JUSTIFY CENTER
  num spacing = 16;

  String myAreaNames;
  List<Area> myAreas = new List<Area>();

  TextContent.named(this.name);

  TextContent.xywh(this.filename, String tfont, String talign, this.spacing) {
    this.font = (tfont == null || tfont.length == 0) ? "12pt Arial" : tfont;
    this.align = (talign == null || talign.length == 0) ? "LEFT" : talign;
  }

  fromJson(String s, Map<String, Area> areas) {
    var map = JSON.decode(s);
    filename = map["FILENAME"];
    text = map["TEXT"];
    font = map["FONT"];
    fontColor = map["FONT-COLOR"];
    backColor = map["BACK-COLOR"];
    align = map["ALIGN"];
    spacing = map["SPACING"];
    myAreaNames = map["TEXT-AREAS"];
    if (myAreaNames != null) {
      List<String> names = myAreaNames.split(',');
      for (String name in names) {
        myAreas.add(areas[name]);
      }
    }
  }

  String toJson() {
    return
        '\"$name\":\"{\\"FILENAME\\":\\"$filename\\",\\"TEXT-AREAS\\":\\"$myAreaNames\\",\\"FONT\\":\\"$font\\",\\"ALIGN\\":\\"$align\\",\\"FONT-COLOR\\":\\"$fontColor\\",\\"BACK-COLOR\\":\\"$backColor\\",\\"SPACING\\":$spacing}\"';
  }
}


// ######################################################################
// ######################################################################
// TextFormatter
// ######################################################################
// ######################################################################

/**
 * This is used to format blocks of code inside 'areas'
 */
class TextFormatter {

  factory TextFormatter(CanvasRenderingContext2D context, TextContent
      textContent) {
    if (textContent != null && textContent.myAreas.length > 0 &&
        textContent.text.length > 0) {
      TextFormatter layout = new TextFormatter._blank(context, textContent);
      return (layout._formatText() ? layout : null);
    }
    return null;
  }

  CanvasRenderingContext2D _context;
  TextContent _textContent;


  num _currY = 0;
  num _areaNbr = 0;
  Area _currArea;
  num _spaceWidth;
  // The final list
  List<Word> words = new List<Word>();

  TextFormatter._blank(this._context, this._textContent);

  bool _formatText() {
    _context.font = _textContent.font;
    _spaceWidth = _context.measureText(" ").width;
    List<String> paras = _textContent.text.split("\n");
    _currArea = _textContent.myAreas[_areaNbr];
    _currY = _currArea.y;
    for (String para in paras) {
      _currY += _textContent.spacing;
      words.addAll(_formatParagraph(para));
    }
    return true;
  }

  List<Word> _formatParagraph(String paragraph) {
    List<Word> parawords = new List<Word>();
    List<String> strings = paragraph.split(" ");
    for (String string in strings) {
      parawords.add(new Word.string(_context, string));
    }
    num n = 0, x = 0;
    List<Word> linewords = new List<Word>();
    while (n < parawords.length) {
      parawords[n].x = x + _currArea.x;
      parawords[n].y = _currY;
      x += parawords[n].width;
      if (x > _currArea.w) {
        _currY += _textContent.spacing;
        x = 0;
        _applyTextAlignment(linewords);
        linewords.clear();
        // See if we have filled this area
        if (_currY > _currArea.y + _currArea.h && ++_areaNbr <
            _textContent.myAreas.length) {
          _currArea = _textContent.myAreas[_areaNbr];
          _currY = _currArea.y + _textContent.spacing;
        }
      } else {
        linewords.add(parawords[n]);
        x += _spaceWidth;
        n++;
      }
    }
    if (linewords.length > 0) {
      _applyTextAlignment(linewords);
    }
    return parawords;
  }

  _applyTextAlignment(linewords) {
    num visibleLength = linewords[linewords.length - 1].x +
        linewords[linewords.length - 1].width - linewords[0].x;
    num slack = _currArea.w - visibleLength;
    if (_textContent.align == "RIGHT") {
      _applyRIGHT(linewords, slack);
    } else if (_textContent.align == "CENTER") {
      _applyCENTER(linewords, slack);
    } else if (_textContent.align == "JUSTIFY" && linewords.length >= 2) {
      _applyJUSTIFY(linewords, slack, visibleLength);
    }
  }

  // Center text alignment
  _applyCENTER(List<Word> linewords, num slack) {
    for (Word word in linewords) word.x += slack / 2;
  }

  // Right text alignment
  _applyRIGHT(List<Word> linewords, num slack) {
    for (Word word in linewords) word.x += slack;
  }

  // Justified text alignment
  _applyJUSTIFY(List<Word> linewords, num shift, num visibleLength) {
    if (visibleLength / _currArea.w > 0.8) {
      // Get the length of words that can be moved
      num used = 0;
      for (int n = 1; n < linewords.length; n++) used += linewords[n].width;
      // Now shift the words right by shift * word_length / used
      num pad = 0;
      for (int n = 1; n < linewords.length; n++) {
        pad += linewords[n].width * shift / used;
        linewords[n].x += pad;
      }
    }
  }

}


// ######################################################################
// ######################################################################
// Word
// ######################################################################
// ######################################################################

/**
 * Represents the text and the position of a word to be rendered
 */
class Word {
  String word;
  num width = 0;
  num x = 0;
  num y = 0;

  Word.string(CanvasRenderingContext2D context, this.word) {
    width = context.measureText(word).width;
  }

  String toString() {
    return "[$word $x  $width]";
  }
}


// ######################################################################
// ######################################################################
// Action
// ######################################################################
// ######################################################################

class Action {
  static Action WAITING = new Action(Action.TURN_WAITING, null, null);

  static const int TURN_BACK = -1;
  static const int TURN_FORWARD = 1;
  static const int TURN_DONE = 0;
  static const int GOTO_PAGE = -999;
  static const int TURN_WAITING = 999;

  bool isDONE() => type == TURN_DONE;
  bool isFORWARD() => type == TURN_FORWARD;
  bool isBACK() => type == TURN_BACK;

  int type = TURN_WAITING;
  int pageNo = 0;
  num turnTime = TURN_SLOW;

  Action(this.type, num ttime, num pg) {
    if (ttime != null) turnTime = ttime;
    if (pg != null) pageNo = pg.toInt();
  }
}


// ######################################################################
// ######################################################################
// PageTurnQueue
// ######################################################################
// ######################################################################

class PageTurnQueue {

  Queue<Action> q = new Queue<Action>();

  Action lastAction = new Action(Action.TURN_WAITING, null, null);

  addAction_tp(int type, num turnTime, int pageNo) {
    if (type == Action.TURN_DONE && lastAction.type == Action.TURN_DONE) return;
    lastAction.type = type;
    q.addLast(new Action(type, turnTime, pageNo));
  }

  addAction_t(int type, num turnTime) {
    addAction_tp(type, turnTime, null);
  }
  addAction_p(int type, int pageNo) {
    addAction_tp(type, null, pageNo);
  }

  addAction(int type) {
    addAction_tp(type, null, null);
  }

  addRefresh() {
    lastAction.type = Action.TURN_DONE;
    q.addLast(new Action(lastAction.type, null, null));
  }

  Action getAction() {
    switch (q.length) {
      case 0:
        return Action.WAITING;
      case 1:
        lastAction.type = Action.TURN_WAITING;
        return q.removeFirst();
      default:
        return q.removeFirst();
    }
  }

  clear() => q.clear();
  num length() => q.length;
  bool isEmpty() => q.isEmpty;
  bool isNotEmpty() => q.isNotEmpty;
}
