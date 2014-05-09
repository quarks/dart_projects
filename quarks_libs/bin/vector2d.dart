library vector2d;

import 'dart:math';


const num _MIN_VALUE = 4.9e-324;

/**
 * This 2D vector class uses the num data type throughout. <br>
 * 
 */
class Vector2D {

  static final int CLOCKWISE = 1;
  static final int ANTI_CLOCKWISE = -1;

  double _x;
  double _y;

  set x(num value) => _x = value.toDouble(); 
  get x => _x;
  
  set y(num value) => _y = value.toDouble(); 
  get y => _y;
  
  
  String toString() => "[ $_x, $_y ]";
 
  /// Vectors are equal when 
  bool operator == (Vector2D rhs) => (_x == rhs._x) && (_y == rhs._y);
   
  bool operator > (Vector2D rhs) => lengthSq() > rhs.lengthSq();
   
  bool operator >= (Vector2D rhs) => lengthSq() >= rhs.lengthSq();
   
  bool operator < (Vector2D rhs) => lengthSq() < rhs.lengthSq();
   
  bool operator <= (Vector2D rhs) => lengthSq() <= rhs.lengthSq();

   
  Vector2D operator + (Vector2D rhs) => new Vector2D.XY(_x + rhs._x, _y + rhs._y);
   
  Vector2D operator - (Vector2D rhs) => new Vector2D.XY(_x - rhs._x, _y - rhs._y);
   
  Vector2D operator * (num n) => new Vector2D.XY(_x * n, _y * n);
   
  Vector2D operator / (num n) => new Vector2D.XY(_x / n, _y / n);
   
  get hashCode => (_x.hashCode - _y.hashCode);

  /**
   * Default to the zero vector
   */
   Vector2D() {
     this._x = 0.0;
     this._y = 0.0;
   }

  /**
   * Create a vector based on parameter values.
   * @param x
   * @param y
   */
   Vector2D.XY(num x, num y){
     _x = x.toDouble();
     _y = y.toDouble();
   }

  /**
   * Copy constructor
   * @param v the vector to copy
   */
  Vector2D.Vector(Vector2D v){
    this._x = v._x;
    this._y = v._y;
  }

  Vector2D.random([num size = 1]){
     num angle = new Random().nextDouble() * 2 * PI;
     _x = size * cos(angle);
     _y = size * sin(angle);
  }
   
  setVector(Vector2D v){
    this._x = v._x;
    this._y = v._y;   
  }
  
  setXY(num x, num y) {
    this._x = x;
    this._y = y;
  }

  /**
   * Get the vector length squared
   */
  num lengthSq() => _x*_x + _y*_y;

  /**
   * Get the vector length
   */
  num length() => sqrt(_x*_x + _y*_y);
  
  /**
   * Calculate the dot product between two un-normalised vectors.
   * @param v the other vector
   * @return the dot product
   */
  num dot(Vector2D v) => (_x*v._x + _y*v._y);

  /**
   * Calculate the dot product between two vectors using normalised values 
   * i.e. the cosine of the angle between them
   * @param v the other vector
   * @return the cosine of angle between them
   */
  num dotNorm(final Vector2D v) =>
       (_x*v._x + _y*v._y)/(sqrt(_x*_x + _y*_y) * sqrt(v._x*v._x + v._y*v._y));
  

  /**
   * Calculate the angle between this and another vector.
   * @param v the other vector
   * @return the angle between in radians
   */
  num angleBetween(final Vector2D v){
    num denom = sqrt(_x * _x + _y * _y) * sqrt(v._x * v._x + v._y * v._y);
    if(denom > _MIN_VALUE){
      num a = acos((_x*v._x + _y*v._y) / denom);
      if(a.isNaN) // angle is NaN
        return 0;
      else
        return a;
    }
    return 0;   
  }

  /**
   * Determines whether vector v is clockwise of this vector. <br>
   * @param v a vector
   * @return positive (+1) if clockwise else negative (-1)
   */
  int sign(Vector2D v) => (_y*v._x > _x*v._y) ? CLOCKWISE : ANTI_CLOCKWISE;

  /**
   * Get a copy (new object) of this vector.
   * @return a perpendicular vector
   */
  Vector2D get() => new Vector2D.XY(_x, _y);

  /**
   * Get a vector perpendicular to this one.
   * @return a perpendicular vector
   */
  Vector2D getPerp() => new Vector2D.XY(-_y, _x);

  /**
   * Get the distance squared between this and another
   * point.
   * @param v the other point
   * @return distance to other point squared
   */
  num distanceSq(Vector2D v){
    num dx = v._x - _x;
    num dy = v._y - _y;
    return dx*dx + dy*dy;
  }

  /**
   * Get the distance between this and an other point.
   * @param v the other point
   * @return distance to other point
   */
  num distance(final Vector2D v){
    num dx = v._x - _x;
    num dy = v._y - _y;
    return sqrt(dx*dx + dy*dy);
  }

  /**
   * Normalise this vector
   */
  normalize(){
    num mag = sqrt(_x * _x + _y * _y);
    if(mag < _MIN_VALUE){
      _x = _y = 0.0;
    }
    else {
      _x /= mag;
      _y /= mag;
    }
  }

  /**
   * Truncate this vector so its length is no greater than
   * the value provided.
   * @param max maximum size for this vector
   */
  truncate(num max){
    num mag = sqrt(_x * _x + _y * _y);
    if(mag > _MIN_VALUE && mag > max){
      num f = max / mag;
      _x *= f;
      _y *= f;   
    }
  }

  /**
   * Get a vector that is the reverse of this vector
   * @return the reverse vector
   */
  Vector2D getReverse() => new Vector2D.XY(-_x, -_y);

  /**
   * Return the reflection vector about the norm
   * @param norm
   * @return the reflected vector
   */
  Vector2D getReflect(final Vector2D norm){
    num dot = this.dot(norm);
    num nx = _x + (-2 * dot * norm._x);
    num ny = _y + (-2 * dot * norm._y);
    return new Vector2D.XY(nx, ny);
  }

  /**
   * Add a vector to this one
   * @param v the vector to add
   */
  addVec(Vector2D v){
    _x += v._x;
    _y += v._y;
  }

  /**
   * Change the vector by adding the values specified
   * @param dx
   * @param dy
   */
  addXY(num dx, num dy){
    _x += dx;
    _y += dy;
  }

  /**
   * Subtract a vector from this one
   * @param v the vector to subtract
   */
  subVec(Vector2D v){
    _x -= v._x;
    _y -= v._y;
  }

  /**
   * Change the vector by the subtracting values specified
   * @param dx
   * @param dy
   */
  subXY(num dx, num dy){
    _x -= dx;
    _y -= dy;
  }

  /**
   * Multiply the vector by a scalar
   * @param d
   */
  mult(num d){
    _x *= d;
    _y *= d;
  }

  /**
   * Divide the vector by a scalar
   * @param d
   */
  div(num d){
    _x /= d;
    _y /= d;
  }

} // end of Vector2D class



/**
 * Get a new vector that is the sum of 2 vectors.
 * @param v0 first vector
 * @param v1 second vector
 * @return the sum of the 2 vectors
 */
Vector2D add(final Vector2D v0, final Vector2D v1){
  return new Vector2D.XY(v0._x + v1._x, v0._y + v1._y);
}

/**
 * Get a new vector that is the difference between the
 * 2 vectors.
 * @param v0 first vector
 * @param v1 second vector
 * @return the difference between the 2 vectors
 */
Vector2D sub(final Vector2D v0, final Vector2D v1){
  return new Vector2D.XY(v0._x - v1._x, v0._y - v1._y);
}

/**
 * Get a new vector that is the product of a vector and a scalar
 * @param v the original vector
 * @param d the multiplier
 * @return the calculated vector
 */
Vector2D mult(final Vector2D v, num d){
  return new Vector2D.XY(v._x * d, v._y * d);
}

/**
 * Get a new vector that is a vector divided by a scalar
 * @param v the original vector
 * @param d the divisor
 * @return the calculated vector
 */
Vector2D div(final Vector2D v, num d){
  return new Vector2D.XY(v._x / d, v._y / d);
}

/**
 * The square of the distance between two vectors
 * 
 * @param v0 the first vector
 * @param v1 the second vector
 * @return square of the distance between them
 */
num distSq(final Vector2D v0, final Vector2D v1){
  num dx = v1._x - v0._x;
  num dy = v1._y - v0._y;
  return dx*dx + dy*dy;
}

/**
 * The distance between two vectors
 * 
 * @param v0 the first vector
 * @param v1 the second vector
 * @return the distance between them
 */
num dist(final Vector2D v0, final Vector2D v1){
  num dx = v1._x - v0._x;
  num dy = v1._y - v0._y;
  return sqrt(dx*dx + dy*dy);
}


/**
 * Get a new vector that is the given vector normalised
 * @param v the original vector
 * @return the normalised vector
 */
Vector2D normalize(final Vector2D v){
  Vector2D n;
  num mag = v.length();
  if(mag < _MIN_VALUE)
    n = new Vector2D.XY(0,0);
  else
    n = new Vector2D.XY(v._x / mag, v._y / mag);
  return n;
}

/**
 * Calculate the angle between two vectors.
 * @param v0 first vector
 * @param v1 second vector
 * @return the angle between in radians
 */
num angleBetween(Vector2D v0, Vector2D v1){
  num denom = sqrt(v0._x * v0._x + v0._y * v0._y) * sqrt(v1._x * v1._x + v1._y * v1._y);
  if(denom > _MIN_VALUE){
    num a = acos((v0._x*v1._x + v0._y*v1._y) / denom);
    if( a != a ) // angle is NaN
      return 0;
    else
      return a;
  }
  return 0;   
}

/**
 * Determines whether entity 2 is visible from entity 1.
 * 
 * @param posFirst position of first entity
 * @param facingFirst direction first entity is facing
 * @param fovFirst field of view (radians)
 * @param posSecond position of second entity
 * @return true if second entity is inside 'visible' to the first entity
 */
bool isSecondInFOVofFirst(final Vector2D posFirst, final Vector2D facingFirst, final num fovFirst, final Vector2D posSecond){
  Vector2D toTarget = posSecond - posFirst;
  num dd = toTarget.length() * facingFirst.length();
  num angle = facingFirst.dot(toTarget) / dd;
  return angle >= cos(fovFirst / 2);
}