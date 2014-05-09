part of magazine;

class PageBase {
  CanvasElement canvas;
  CanvasRenderingContext2D context;
  
  Book book;
  // starts at 0 but display pageNo + 1
  int _pageNo;
  String _pageNoText;
  num _pageNoTextWidth;

  var backColor = 'rgb(200,200,200)', foreColor = 'rgb(100,100,100)';
  var pnColor = 'rgb(0,0,0)';
  var pnFont = "8pt Arial";
  
  PageBase(){ }
  
  PageBase.dummy(this.book, this._pageNo){
    canvas = document.createElement('canvas'); 
    canvas.width = book.pageW.toInt();
    canvas.height = book.pageH.toInt();
    context = canvas.getContext("2d");
    _pageNoText = "- $_pageNo -";
    blankPic(backColor, foreColor);
  }
  
  // override in other page types  
  blankPic(var fcol, var bcol){
    backColor = bcol;
    foreColor = fcol;
    num delta = 12, p = 6;
    num limit = max(book.pageW, book.pageH);
    context
    ..fillStyle = backColor
    ..strokeStyle = foreColor
    ..lineWidth = 1.5
    ..fillRect(0, 0, book.pageW, book.pageH)
    ..beginPath();
    while(p < limit){
      context..moveTo(0,p)..lineTo(book.pageW, p);
      context..moveTo(p,0)..lineTo(p, book.pageH);
      context.stroke();
      delta += 2;
      p += delta;
    }
    displayPageNo();
  }
  
  displayPageNo(){
    context
    ..fillStyle = 'rgb(0,0,0)'
    ..font = pnFont;
    num offset = context.measureText(_pageNoText).width;
    context.fillText(_pageNoText, (book.pageW - offset)/2, book.pageH - 6);    
  }
  
  // override in other page types
  render(){
    blankPic(backColor, foreColor);
  }
  
}

class Page extends PageBase {
  
  List<ImageElement> images = new List<ImageElement>();
  InputElement t;
  String text;
  FileReader reader;
  File file;
  
  Page(Book book, int pageNo, List imageFiles, String layoutFile){
    this.book = book;
    this._pageNo = pageNo;
    canvas = document.createElement('canvas'); 
    canvas.width = book.pageW.toInt();
    canvas.height = book.pageH.toInt();
    context = canvas.getContext("2d");
    _pageNoText = "- $_pageNo -";
    blankPic(backColor, foreColor);
    
    // Load page content
    var futures = [];   
    // Setup loading the images
    for(int i = 0; i < imageFiles.length; i++){
      images.add(new ImageElement(src: '${imageFiles[i]}'));
      futures.add(images[i].onLoad.first);
    }
    // Set up reading the 
    if(layoutFile != null && layoutFile.length > 0){
      futures.add( HttpRequest.getString(layoutFile).then(processString));     
    }
    
    Future.wait(futures).then((_) => render());
  }
  
  render(){
    context
    ..fillStyle = backColor
    ..clearRect(0, 0, book.pageW, book.pageH)
    ..drawImage(images[0], 0, 0)
    ..drawImage(images[1], 30, 60);
     displayPageNo();
    book.queue.add(Book.DONE);    
  }
  
  processString(String s){
    text = s;
    var d = document.querySelector('#description');
    d.innerHtml = text;

  }
}

class MyImagePage extends PageBase {
  
  var imgA;
  
  MyImagePage(Book book, int pageNo, String imagefile){
    this.book = book;
    this._pageNo = pageNo;
    canvas = document.createElement('canvas'); 
    canvas.width = book.pageW.toInt();
    canvas.height = book.pageH.toInt();
    context = canvas.getContext("2d");
    _pageNoText = "- $_pageNo -";
    blankPic(backColor, foreColor);
    
    imgA = new ImageElement(src: '$imagefile');
    var futures = [imgA.onLoad.first];
    Future.wait(futures).then((_) => render());   
  }

  render(){
    context
    ..fillStyle = backColor
    ..rect(0, 0, book.pageW, book.pageH)
    ..fill()
    ..drawImage(imgA, 0, 0);
    displayPageNo();
    book.queue.add(Book.DONE);
  }
  
}