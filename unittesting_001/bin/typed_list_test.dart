
//import "dart:typed_data";
import "../../quarks_libs/bin/geometry2d.dart";

void main(){
  List result = line_circle_p(-100, 0, 100, 0, 50, 50, 50);

  print("\n\nNo intersection ");
  result = line_circle_p(-100, -10, 100, -10, 50, 50, 50);
  for(num n in result) print("$n");
      
  print("\n\nTangent ");
  result = line_circle_p(-100, 0, 100, 0, 50, 50, 50);
  for(num n in result) print("$n");
 
  print("\n\nIntersects ");
  result = line_circle_p(-100, 50, 100, 50, 50, 50, 50);
  for(num n in result) print("$n");

}

