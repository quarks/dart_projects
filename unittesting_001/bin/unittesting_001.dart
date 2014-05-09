

import "package:unittest/unittest.dart"; 
import "../../quarks_libs/bin/vector2d.dart";

void main() {
  print("Hello, World!");
  vtest1();
  vtest2();
}


void vtest1(){
  Vector2D v = new Vector2D.XY(3,4);
  num mag = v.length();
  print("$v length is $mag");

  test('Testing length() with 3,4', () {
    expect(mag, equals(5.0) );
  });
  
}

void vtest2(){
  Vector2D v = new Vector2D();
  v.x = 12;
  v.y = 5;
  
  num mag = v.length();
  print("$v length is $mag");

  test('Testing length() with 12,5', () {
    expect(mag, equals(13) );
  });
  
}