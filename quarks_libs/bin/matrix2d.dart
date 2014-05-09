library matrix2d;

import "dart:math";
import "vector2d.dart";

/**
 * Class to represent a 2D matrix that can be used to create transformed Vector2D
 * objects.
 * 
 * @author Peter Lager
 *
 */
class Matrix2D {

  _Matrix matrix;

  Matrix2D(){
    matrix = new _Matrix();
    matrix.identity();
  }

/**
 * Multiply this matrix by another
 * @param mIn the multiplying matrix
 */
void matrixMultiply(_Matrix mIn){
  _Matrix mat = new _Matrix();
  // Row 1
  mat._11 = (matrix._11*mIn._11) + (matrix._12*mIn._21) + (matrix._13*mIn._31);
  mat._12 = (matrix._11*mIn._12) + (matrix._12*mIn._22) + (matrix._13*mIn._32);
  mat._13 = (matrix._11*mIn._13) + (matrix._12*mIn._23) + (matrix._13*mIn._33);
  // Row 2
  mat._21 = (matrix._21*mIn._11) + (matrix._22*mIn._21) + (matrix._23*mIn._31);
  mat._22 = (matrix._21*mIn._12) + (matrix._22*mIn._22) + (matrix._23*mIn._32);
  mat._23 = (matrix._21*mIn._13) + (matrix._22*mIn._23) + (matrix._23*mIn._33);
  // Row 3
  mat._31 = (matrix._31*mIn._11) + (matrix._32*mIn._21) + (matrix._33*mIn._31);
  mat._32 = (matrix._31*mIn._12) + (matrix._32*mIn._22) + (matrix._33*mIn._32);
  mat._33 = (matrix._31*mIn._13) + (matrix._32*mIn._23) + (matrix._33*mIn._33);
  matrix = mat;
}


/**
 * Create a new list of vectors from the provided list after being transformed
 * by this matrix.
 * 
 * @param vList the original list of vectors
 * @return a list of transformed vectors.
 */
List<Vector2D> transformVector2Ds(List<Vector2D> vList){
  List<Vector2D> transformed = new List<Vector2D>();
  for(Vector2D v in vList){
    num x = (matrix._11 * v.x) + (matrix._21 * v.y) + (matrix._31);
    num y = (matrix._12 * v.x) + (matrix._22 * v.y) + (matrix._32);
    transformed.add(new Vector2D.XY(x,y));
  }
  return transformed;
}

/**
 * Create a new vector from the provided vector after being transformed 
 * by the matrix.
 * 
 * @param vPoint the original vector
 * @return the transformed vector
 */
Vector2D transformVector2D(Vector2D vPoint){
  num x = (matrix._11*vPoint.x) + (matrix._21*vPoint.y) + (matrix._31);
  num y = (matrix._12*vPoint.x) + (matrix._22*vPoint.y) + (matrix._32);
  return new Vector2D.XY(x, y);
}

/**
 * Initialise the matrix to the identity matrix. This will erase the previous
 * matrix element data.
 */
identity(){
  matrix._11 = 1; matrix._12 = 0; matrix._13 = 0;
  matrix._21 = 0; matrix._22 = 1; matrix._23 = 0;
  matrix._31 = 0; matrix._32 = 0; matrix._33 = 1;
}

/**
 * Translate the matrix by the amount specified in
 * x and y.
 * 
 * @param x x-translation value
 * @param y y-translation value
 */
translate(num x, num y){
  _Matrix mat = new _Matrix();
  mat._11 = 1;  mat._12 = 0;    mat._13 = 0;
  mat._21 = 0;  mat._22 = 1;    mat._23 = 0;
  mat._31 = x;    mat._32 = y;  mat._33 = 1;
  matrixMultiply(mat);
}

/**
 * Scale the matrix in the x and y directions. 
 * @param xScale scale x by this
 * @param yScale scale y by this
 */
scale(num xScale, num yScale){
  _Matrix mat = new _Matrix();    
  mat._11 = xScale;   mat._12 = 0;        mat._13 = 0;
  mat._21 = 0;        mat._22 = yScale;   mat._23 = 0;
  mat._31 = 0;        mat._32 = 0;        mat._33 = 1;
  matrixMultiply(mat);
}

/**
 * Rotate the matrix.
 * 
 * @param rot angle in radians.
 */
rotateAngle(num rot){
  _Matrix mat = new _Matrix();
  num sinA = sin(rot);
  num cosA = cos(rot);

  mat._11 = cosA;   mat._12 = sinA;   mat._13 = 0;
  mat._21 = -sinA;  mat._22 = cosA;   mat._23 = 0;
  mat._31 = 0;      mat._32 = 0;      mat._33 = 1;
  matrixMultiply(mat);
}

/**
 * Rotate the matrix based an entity's heading and side vectors
 * @param fwd
 * @param side
 */
rotate(Vector2D fwd, Vector2D side){
  _Matrix mat = new _Matrix();
  mat._11 = fwd.x;    mat._12 = fwd.y;    mat._13 = 0;
  mat._21 = side.x;   mat._22 = side.y;   mat._23 = 0;
  mat._31 = 0;        mat._32 = 0;        mat._33 = 1;
  matrixMultiply(mat);
}


// setters for the matrix elements
set c11(num val){ matrix._11 = val; }
set c12(num val){ matrix._12 = val; }
set c13(num val){ matrix._13 = val; }

set c21(num val){ matrix._21 = val; }
set c22(num val){ matrix._22 = val; }
set c23(num val){ matrix._23 = val; }

set c31(num val){ matrix._31 = val; }
set c32(num val){ matrix._32 = val; }
set c33(num val){ matrix._33 = val; }

}

/**
 * Handy inner class to hold the intermediate transformation matrices.
 * 
 */

class _Matrix {
  num _11, _12, _13;
  num _21, _22, _23;
  num _31, _32, _33;

  /**
   * Ctor initialises to the zero matrix
   */
  _Matrix(){
    _11=0.0;  _12=0.0;  _13=0.0;
    _21=0.0;  _22=0.0;  _23=0.0;
    _31=0.0;  _32=0.0;  _33=0.0;
  }

  /**
   * Set to the identity matrix. Erases previous matrix data.
   */
  identity(){
    _11=1.0;  _12=0.0;  _13=0.0;
    _21=0.0;  _22=1.0;  _23=0.0;
    _31=0.0;  _32=0.0;  _33=1.0;
  }

}

