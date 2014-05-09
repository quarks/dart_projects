import 'dart:html';
import 'dart:async';



var canvas, context, image;
var baseUrl;

void main() {
  canvas = document.querySelector('#picture');
  context = canvas.getContext("2d");
  
  test1();


}


void test1(){
  var a = new ImageElement(src: 'images/disneypic2.jpg');
  var futures = [a.onLoad.first];
  
  Future.wait(futures).then((_) => context.drawImage(a,0,0) );

}

void test2(){
  //loadImage('images/disneypic2.jpg', 'DISNEY');
//  ImageElement ie = null;
//  ie = getImage("DISNEY");
//  print(ie.toString());
//  context.drawImage(ie,0,0);
}


