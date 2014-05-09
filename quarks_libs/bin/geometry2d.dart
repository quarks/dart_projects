library geometry2d;

import "dart:math";
import "dart:typed_data";
import "vector2d.dart";

const num _G2D_ACCY       = 1E-9;

const int ON_PLANE        = 16;
const int PLANE_INSIDE    = 17;
const int PLANE_OUTSIDE   = 18;

const int _OUT_LEFT        = 1;
const int _OUT_TOP         = 2;
const int _OUT_RIGHT       = 4;
const int _OUT_BOTTOM      = 8;

double _NEARNESS           = 1.0;

/**
 * This sets the distance used to decide whether a point is 'near, a line. This
 * is initially set at 1.0
 * @param nearness must be >0 otherwise it is unchanged
 */
point_to_line_dist(double nearness){
  if(nearness > 0)
    _NEARNESS = nearness;
}

/**
 * See if point is near the a line of finite length.
 * 
 * v0, v1 the start and end coordinates for the line
 * p point to consider
 */
bool is_point_near_line(Vector2D v0, Vector2D v1, Vector2D p, [Vector2D vp = null]) {
  Vector2D pnl = point_nearest_line(v0, v1, p);
  if(pnl != null){
    double d = sqrt((p.x-pnl.x)*(p.x-pnl.x) +(p.y-pnl.y)*(p.y-pnl.y)); 
    if(vp != null)
      vp.setVector(pnl);
    if (d <= _NEARNESS)
      return true;
  }
  return false;
}

/**
 * See if point is near a line of infinite length. <br>
 * 
 * v0, v1 the infinite line passes through these points
 * p point to consider
 */
bool is_point_near_infinite_line(Vector2D v0, Vector2D v1, Vector2D p, [Vector2D vp = null]) {
  Vector2D pnl = point_nearest_infinite_line(v0, v1, p);
  if(pnl != null){
    double d = sqrt((p.x-pnl.x)*(p.x-pnl.x) +(p.y-pnl.y)*(p.y-pnl.y)); 
    if(vp != null)
      vp.setVector(pnl);
    if (d <= _NEARNESS)
      return true;
  }
  return false;
}

/**
 * For a point find the nearest position on a finite line.
 * 
 * v0, v1 the start and end coordinates for the line
 * p point to consider
 * If the line is undefined (v0 == v1) or if the normal from point 'p' does not fall on 
 * the line then return null, otherwise return the nearest point.
 */
Vector2D point_nearest_line(Vector2D v0, Vector2D v1, Vector2D p){
  Vector2D vp = null;
  Vector2D the_line =  v1 - v0;
  double lineMag = the_line.length();
  lineMag = lineMag * lineMag;
  if (lineMag > 0.0) {
    Vector2D pv0_line = p - v0;
    double t = pv0_line.dot(the_line)/lineMag;
    if (t >= 0 && t <= 1){
      vp = new Vector2D();
      vp.x = the_line.x * t + v0.x;
      vp.y = the_line.y * t + v0.y;
    }
  }
  return vp;
}

/**
 * For a point find the nearest position on an infinite line.
 * 
 * v0, v1 the infinite line passes through these points
 * p point to consider
 * If the line is undefined (v0 == v1) then return null, otherwise
 * return the nearest point.
 */
Vector2D point_nearest_infinite_line(Vector2D v0, Vector2D v1, Vector2D p){
  Vector2D vp = null;
  Vector2D the_line = v1 - v0;
  double lineMag = the_line.length();
  lineMag = lineMag * lineMag;
  if (lineMag > 0.0) {
    vp = new Vector2D();
    Vector2D pv0_line = p - v0;
    double t = pv0_line.dot(the_line)/lineMag;
    vp.x = the_line.x * t + v0.x;
    vp.y = the_line.y * t + v0.y;
  }
  return vp;
}

/**
 * Sees if a line intersects with the circumference of a circle.
 * Note if the line starts and ends inside the circle then 
 * there is no intersection.
 * [x0, y0] - [x1, y1] the line end coordinates 
 * [cx, cy] the centre of the circle
 * r the radius of the circle
 */
bool line_circle(num x0, num y0, num x1, num y1, num cx, num cy, num r){
  num f = (x1 - x0);
  num g = (y1 - y0);
  num fSQ = f*f;
  num gSQ = g*g;
  num fgSQ = fSQ + gSQ;
  num rSQ = r*r;

  num xc0 = cx - x0;
  num yc0 = cy - y0;
  num xc1 = cx - x1;
  num yc1 = cy - y1;

  bool lineInside = xc0*xc0 + yc0*yc0 < rSQ && xc1*xc1 + yc1*yc1 < rSQ;

  num fygx = f*yc0 - g*xc0;
  num root = r*r*fgSQ - fygx*fygx;

  if(root > _G2D_ACCY && !lineInside){
    num fxgy = f*xc0 + g*yc0;
    num t = fxgy / fgSQ;
    if(t >= 0 && t <= 1)
      return true;
    // Circle intersects with one end then return true
    if( (xc0*xc0 + yc0*yc0 < rSQ) || (xc1*xc1 + yc1*yc1 < rSQ) )
      return true;
  }
  return false;
}

/**
 * Calculate the points of intersection between a line and the
 * circumference of a circle.
 * [x0, y0] - [x1, y1] the line end coordinates 
 * [cx, cy] the centre of the circle
 * r the radius of the circle
 *
 * An array is returned that contains the intersection points in x, y order.
 * If the returned array is of length: <br>
 * 0 then there is no intersection <br>
 * 2 there is just one intersection (the line is a tangent to the circle) <br>
 * 4 there are two intersections <br>
 */
Float64List line_circle_p(num x0, num y0, num x1, num y1, num cx, num cy, num r){
  Float64List result = new Float64List(4);
  int np = 0;

  num f = x1 - x0;
  num g = y1 - y0;
  num fSQ = f*f;
  num gSQ = g*g;
  num fgSQ = fSQ + gSQ;

  num xc0 = cx - x0;
  num yc0 = cy - y0;

  num fygx = f*yc0 - g*xc0;
  num root = r*r*fgSQ - fygx*fygx;
  
  if(root > -_G2D_ACCY){
    num fxgy = f*xc0 + g*yc0;
    if(root < _G2D_ACCY){    // tangent so just one point
      num t = fxgy / fgSQ;
      if(t >= 0 && t <= 1){
        result[np++] = (x0 + f*t).toDouble();
        result[np++] = (y0 + g*t).toDouble();
      }
      np = 2;
    }
    else {  // possibly two intersections
      root = sqrt(root);
      num t = (fxgy - root)/fgSQ;
      if(t >= 0 && t <= 1){
        result[np++] = (x0 + f*t).toDouble();
        result[np++] = (y0 + g*t).toDouble();
      }
      t = (fxgy + root)/fgSQ;
      if(t >= 0 && t <= 1){
        result[np++] = (x0 + f*t).toDouble();
        result[np++] = (y0 + g*t).toDouble();
      }
    }
  }
  return (np < 4) ? result.sublist(0, np) : result;
}

/**
 * See if two finite lines intersect.
 * [x0, y0]-[x1, y1] start and end of the first line
 * [x2, y2]-[x3, y3] start and end of the second line
 */
bool line_line(num x0, num y0, num x1, num y1, num x2, num y2, num x3, num y3){
  num f1 = x1 - x0;
  num g1 = y1 - y0;
  num f2 = x3 - x2;
  num g2 = y3 - y2;
  num f1g2 = f1 * g2;
  num f2g1 = f2 * g1;
  num det = f2g1 - f1g2;
  
  if(det.abs() > _G2D_ACCY){
    num s = (f2*(y2 - y0) - g2*(x2 - x0))/ det;
    num t = (f1*(y2 - y0) - g1*(x2 - x0))/ det;
    return (s >= 0 && s <= 1 && t >= 0 && t <= 1);
  }
  return false;
}

/**
 * Find the point of intersection between two lines. <br>
 * This method uses PVector objects to represent the line end points.
 * [x0, y0]-[x1, y1] start and end of the first line
 * [x2, y2]-[x3, y3] start and end of the second line
 * if the two lines are parallel then null is returned, otherwise the intercept 
 * position is returned.
 */
Vector2D line_line_pv(Vector2D v0, Vector2D v1, Vector2D v2, Vector2D v3){
  Vector2D intercept = null;

  num f1 = v1.x - v0.x;
  num g1 = v1.y - v0.y;
  num f2 = v3.x - v2.x;
  num g2 = v3.y - v2.y;
  num f1g2 = f1 * g2;
  num f2g1 = f2 * g1;
  num det = f2g1 - f1g2;
 
  if(det.abs() > _G2D_ACCY){
    num s = (f2*(v2.y - v0.y) - g2*(v2.x - v0.x))/ det;
    num t = (f1*(v2.y - v0.y) - g1*(v2.x - v0.x))/ det;
    if(s >= 0 && s <= 1 && t >= 0 && t <= 1)
      intercept = new Vector2D.XY(v0.x + f1 * s, v0.y + g1 * s);
  }
  return intercept;
}

/**
 * Find the point of intersection between two lines. <br>
 * This method uses PVector objects to represent the line end points.
 * [x0, y0]-[x1, y1] start and end of the first line
 * [x2, y2]-[x3, y3] start and end of the second line
 * if the two lines are parallel then null is returned, otherwise the intercept 
 * position is returned as an array.
 * If the array is of length:
 * 0 then there is no intersection (i.e. parallel)
 * 2 these are the x/y coordinates of the intersection point.
 */
Float64List line_line_p(num x0, num y0, num x1, num y1, num x2, num y2, num x3, num y3){
  Float64List result = null;
  
  num f1 = x1 - x0;
  num g1 = y1 - y0;
  num f2 = x3 - x2;
  num g2 = y3 - y2;
  num f1g2 = f1 * g2;
  num f2g1 = f2 * g1;
  num det = f2g1 - f1g2;
  
  if(det.abs() > _G2D_ACCY){
    num s = (f2*(y2 - y0) - g2*(x2 - x0))/ det;
    num t = (f1*(y2 - y0) - g1*(x2 - x0))/ det;
    if(s >= 0 && s <= 1 && t >= 0 && t <= 1){
      result = new Float64List(2);
      result[0] = (x0 + f1 * s).toDouble();
      result[1] = (y0 + g1 * s).toDouble();
    }
  }
  return (result == null) ? new Float64List(0) : result;
}

/**
 * Find the intersection point between two infinite lines that 
 * pass through the points (v0,v1) and (v2,v3)
 * @return a Vector2D object of the intercept or null if parallel
 */
Vector2D line_line_infinite_pv(Vector2D v0, Vector2D v1, Vector2D v2, Vector2D v3){
  Vector2D intercept = null;

  num f1 = v1.x - v0.x;
  num g1 = v1.y - v0.y;
  num f2 = v3.x - v2.x;
  num g2 = v3.y - v2.y;
  num f1g2 = f1 * g2;
  num f2g1 = f2 * g1;
  num det = f2g1 - f1g2;

  if(det.abs() > _G2D_ACCY){
    num s = (f2*(v2.y - v0.y) - g2*(v2.x - v0.x))/ det;
    intercept = new Vector2D.XY(v0.x + f1 * s, v0.y + g1 * s);
  }
  return intercept;
}

/**
 * Find the point of intersection between two infinite lines that pass through the points
 * ([x0,y0],[x1,y1]) and ([x2,y2],[x3,y3]). <br>
 * An array is returned that contains the intersection points in x, y order.
 * If the array is of length: <br>
 * 0 then there is no intersection <br>
 * 2 these are the x/y coordinates of the intersection point. <br>
 * @return an array of coordinates for the intersection if any
 */
Float64List line_line_infinite_p(num x0, num y0, num x1, num y1, num x2, num y2, num x3, num y3){
  Float64List result = null;

  num f1 = x1 - x0;
  num g1 = y1 - y0;
  num f2 = x3 - x2;
  num g2 = y3 - y2;
  num f1g2 = f1 * g2;
  num f2g1 = f2 * g1;
  num det = f2g1 - f1g2;

  if(det.abs() > _G2D_ACCY){
    num s = (f2*(y2 - y0) - g2*(x2 - x0))/ det;
    result = new Float64List(2);
    result[0] = (x0 + f1 * s).toDouble();
    result[1] = (y0 + g1 * s).toDouble();
  }
  return (result == null) ? new Float64List(0) : result;
}

/**
 * Calculate the intersection points between a finite line and a collection of lines.
 * This will calculate all the intersection points between a given line
 * and the lines formed from the points in the array xy.
 * [x0, y0]-[x1, y1] start and end of the line to consider
 *
 * If the parameter continuous = true the points form a continuous line so the <br>
 * line 1 is from xy[0],xy[1] to xy[2],xy[3] and
 * line 2 is from xy[2],xy[3] to xy[4],xy[5] and so on
 * 
 * and if continuous is false then each set of four array elements form their 
 * own line
 * line 1 is from xy[0],xy[1] to xy[2],xy[3] and
 * line 2 is from xy[4],xy[5] to xy[6],xy[7] and so on.
 *
 * Any intersections are returned back as an array
 * If the array is of length:
 * 0 then there is no intersection (i.e. parallel)
 * 2 (or a multiple of 2) these are the x/y coordinates of the intersection point(s).
 */
Float64List line_lines_p(num x0, num y0, num x1, num y1, List<num> xy, bool continuous){
  List<double> result = new List<double>();
  int stride = continuous ? 2 : 4;
  num f2, g2, f1g2, f2g1, det;
  num f1 = x1 - x0;
  num g1 = y1 - y0;
  for(int i = 0; i < xy.length - 3; i += stride){
    f2 = xy[i+2] - xy[i];
    g2 = xy[i+3] - xy[i+1];
    f1g2 = f1 * g2;
    f2g1 = f2 * g1;
    det = f2g1 - f1g2;
    
    if(det.abs() > _G2D_ACCY){
      num s = (f2*(xy[i+1] - y0) - g2*(xy[i] - x0))/ det;
      num t = (f1*(xy[i+1] - y0) - g1*(xy[i] - x0))/ det;
      if(s >= 0 && s <= 1 && t >= 0 && t <= 1){
        result.add((x0 + f1 * s).toDouble());
        result.add((y0 + g1 * s).toDouble());
      }
    }
  }
  return new Float64List.fromList(result);
}

/**
 * Determine if two circles overlap. This happens only 
 * if the circumferences intersect.
 * [cx0, cy0] centre of the first circle
 * r0 radius of the first circle
 * [cx1 , cy1] centre of the second circle
 * r1 radius of the second circle
 */
bool circle_circle(num cx0, num cy0, num r0, num cx1, num cy1, num r1){
  num dxSQ = (cx1 - cx0)*(cx1 - cx0);
  num dySQ = (cy1 - cy0)*(cy1 - cy0);
  num rSQ = (r0 + r1)*(r0 + r1);
  num drSQ = (r0 - r1)*(r0 - r1);
  return (dxSQ + dySQ <= rSQ && dxSQ + dySQ >= drSQ);
}

/**
 * Calculate the intersection points between two circles.
 * [cx0, cy0] centre of the first circle
 * r0 radius of the first circle
 * [cx1 , cy1] centre of the second circle
 * r1 radius of the second circle
 *
 * If the array is of length:
 * 0 then there is no intersection
 * 2 there is just one intersection (the circles are touching)
 * 4 there are two intersections <br>
 */
Float64List circle_circle_p(num cx0, num cy0, num r0, num cx1, num cy1, num r1){
  Float64List result = null;

  num dx = cx1 - cx0;
  num dy = cy1 - cy0;
  num distSQ = dx*dx + dy*dy;

  if(distSQ > _G2D_ACCY){
    num r0SQ = r0 * r0;
    num r1SQ = r1 * r1;
    num diffRSQ = (r1SQ - r0SQ);
    num root = 2 * (r1SQ + r0SQ) * distSQ - distSQ * distSQ - diffRSQ * diffRSQ;
    if(root > -_G2D_ACCY){
      num distINV = 0.5 / distSQ;
      num scl = 0.5 - diffRSQ * distINV;
      num x = dx * scl + cx0;
      num y = dy * scl + cy0;
      if(root < _G2D_ACCY){
        result = new Float64List(2);
        result[0] = x.toDouble();
        result[1] = y.toDouble();
      }
      else {
        root = distINV * sqrt(root);
        num xfac = dx * root;
        num yfac = dy * root;
        result = new Float64List(4);
        result[0] = (x-yfac).toDouble();
        result[1] = (y+xfac).toDouble();
        result[2] = (x+yfac).toDouble();
        result[3] = (y-xfac).toDouble();
      }
    }
  }
  return (result == null) ? new Float64List(0) : result;
}

/**
 * Calculate the tangents from a point. <br>
 * [x, y] the coordinates of the point
 * [cx, cy] the centre of the circle
 * r the radius of the circle
 * If the array is of length: <br>
 * 0 then there is no tangent the point is inside the circle <br>
 * 2 there is just one intersection (the point is on the circumference) <br>
 * 4 there are two points.
 */
Float64List tangents_to_circle(num x, num y, num cx, num cy, num r){
  Float64List result = null;

  num dx = cx - x;
  num dy = cy - y;
  num dxSQ = dx * dx;
  num dySQ = dy * dy;
  num denom = dxSQ + dySQ;

  num root = denom - r*r;

  if(root > -_G2D_ACCY){
    num denomINV = 1/denom;
    num A, B;

    if(root < _G2D_ACCY){ // point is on circle
      A = -r*dx*denomINV;
      B = -r*dy*denomINV;
      result = new Float64List(2);
      result[0] = (cx + A*r).toDouble();
      result[1] = (cy + B*r).toDouble();
    }
    else {
      root = sqrt(root);
      result = new Float64List(4);
      A = (-dy*root - r*dx)*denomINV;
      B = (dx*root - r*dy)*denomINV;
      result[0] = (cx + A*r).toDouble();
      result[1] = (cy + B*r).toDouble();
      A = (dy*root - r*dx)*denomINV;
      B = (-dx*root - r*dy)*denomINV;
      result[2] = (cx + A*r).toDouble();
      result[3] = (cy + B*r).toDouble();
    }
  }
  return (result == null) ? new Float64List(0) : result;
}



/**
 * Will calculate the contact points for both outer and inner tangents. <br>
 * There are no tangents if one circle is completely inside the other.
 * If the circles interact only the outer tangents exist. When the circles
 * do not intersect there will be 4 tangents (outer and inner), the array
 * has the outer pair first.
 * 
 * [cx0, cy0] centre of the first circle
 * r0 radius of the first circle
 * [cx1 , cy1] centre of the second circle
 * r1 radius of the second circle
 */
Float64List tangents_between_circles(num cx0, num cy0, num r0, num cx1, num cy1, num r1) {
  Float64List result = new Float64List(16);
  int np = 0;

  num dxySQ = (cx0 - cx1) * (cx0 - cx1) + (cy0 - cy1) * (cy0 - cy1);

  if (dxySQ <= (r0-r1)*(r0-r1)) return result;

  num d = sqrt(dxySQ);
  num vx = (cx1 - cx0) / d;
  num vy = (cy1 - cy0) / d;

  num c, h, nx, ny;
  for (int sign1 = 1; sign1 >= -1; sign1 -= 2) {
    c = (r0 - sign1 * r1) / d;
    if (c*c > 1) continue;

    h = sqrt(max(0.0, 1.0 - c*c));

    for (int sign2 = 1; sign2 >= -1; sign2 -= 2) {
      nx = vx * c - sign2 * h * vy;
      ny = vy * c + sign2 * h * vx;

      result[np++] = (cx0 + r0 * nx).toDouble();
      result[np++] = (cy0 + r0 * ny).toDouble();
      result[np++] = (cx1 + sign1 * r1 * nx).toDouble();
      result[np++] = (cy1 + sign1 * r1 * ny).toDouble();
    }
  }
  return (np < 8) ? result.sublist(0, np) : result;
}

/**
 * Determines whether a point [px, py] is 'inside', 'outside' of on an  
 * infinite line that passes through the points [x0,y0] and [x1,y1].
 * The direction of a normal drawn from a point is considered 'outside'
 *
 * Returns either PLANE_INSIDE, PLANE_OUTSIDE or ON_PLANE
 */
int which_side_pp(num x0, num y0, num x1, num y1, num px, num py){
  int side;
  num dot = (y0 - y1)*(px - x0) + (x1 - x0)*(py - y0);

  if(dot < -_G2D_ACCY)
    side = PLANE_INSIDE;
  else if(dot > _G2D_ACCY)
    side = PLANE_OUTSIDE;
  else 
    side = ON_PLANE;
  return side;
}

/**
 * Determines whether a point [p] is 'inside', 'outside' of on an infinite line 
 * that passes through the points [start] and [end].
 * The direction of a normal drawn from a point is considered 'outside'
 *
 * Returns either PLANE_INSIDE, PLANE_OUTSIDE or ON_PLANE
 */
int which_side_ppv(Vector2D start, Vector2D end, Vector2D p) =>
  which_side_pp(start.x, start.y, end.x, end.y, p.x, p.y);

/**
 * Determines whether a point [px, py] is 'inside', 'outside' or on an infinite line 
 * that passes through the point [x0,y0] and the normal from [x0, y1] passes through
 * the point [xn, yn]. 
 * The direction of a normal drawn from a point is considered 'outside'
 *
 * Returns either PLANE_INSIDE, PLANE_OUTSIDE or ON_PLANE
 */
int which_side_pn(num x0, num y0, num nx, num ny, num px, num py){
  int side;
  num dot = nx*(px - x0) + ny*(py - y0);

  if(dot < -_G2D_ACCY)
    side = PLANE_INSIDE;
  else if(dot > _G2D_ACCY)
    side = PLANE_OUTSIDE;
  else 
    side = ON_PLANE;
  return side;
}

/**
 * Determines whether a point [p] is 'inside', 'outside' or on an infinite line 
 * that passes through the point [pos] and the normal from [norm] passes through
 * the point [xn, yn]. 
 * The direction of a normal drawn from a point is considered 'outside'
 *
 * Returns either PLANE_INSIDE, PLANE_OUTSIDE or ON_PLANE
 */
int which_side_pnv(Vector2D pos, Vector2D norm, Vector2D p) =>
  which_side_pn(pos.x, pos.y, norm.x, norm.y, p.x, p.y);

/**
 * Code copied from {@link java.awt.geom.Rectangle2D#intersectsLine(num, num, num, num)}
 */
int _outcode(num pX, num pY, num rectX, num rectY, num rectWidth, num rectHeight) {
  int out = 0;
  if (rectWidth <= 0) {
    out |= _OUT_LEFT | _OUT_RIGHT;
  } else if (pX < rectX) {
    out |= _OUT_LEFT;
  } else if (pX > rectX + rectWidth) {
    out |= _OUT_RIGHT;
  }
  if (rectHeight <= 0) {
    out |= _OUT_TOP | _OUT_BOTTOM;
  } else if (pY < rectY) {
    out |= _OUT_TOP;
  } else if (pY > rectY + rectHeight) {
    out |= _OUT_BOTTOM;
  }
  return out;
}

/**
 * Determine whether a line intersects with a box. <br>
 * The box is represented by the top-left and bottom-right corner coordinates. 
 * [lx0, ly0][lx1, ly1] start and end of the line
 * [rx0, ry0] top-left corner of the rectangle
 * [rx1, ry1] bottom-right corner of rectangle
 */
bool line_box_xyxy(num lx0, num ly0, num lx1, num ly1, num rx0, num ry0, num rx1, num ry1) {
  int out1, out2;
  num rectWidth = rx1 - rx0;
  num rectHeight = ry1 - ry0;
  
  if ((out2 = _outcode(lx1, ly1, rx0, ry0, rectWidth, rectHeight)) == 0) {
    return true;
  }
  while ((out1 = _outcode(lx0, ly0, rx0, ry0, rectWidth, rectHeight)) != 0) {
    if ((out1 & out2) != 0) {
      return false;
    }
    if ((out1 & (_OUT_LEFT | _OUT_RIGHT)) != 0) {
      num x = rx0;
      if ((out1 & _OUT_RIGHT) != 0) {
        x += rectWidth;
      }
      ly0 = ly0 + (x - lx0) * (ly1 - ly0) / (lx1 - lx0);
      lx0 = x;
    } else {
      num y = ry0;
      if ((out1 & _OUT_BOTTOM) != 0) {
        y += rectHeight;
      }
      lx0 = lx0 + (y - ly0) * (lx1 - lx0) / (ly1 - ly0);
      ly0 = y;
    }
  }
  return true;
}

/**
 * Determine whether a line intersects with a box. <br>
 * The box is represented by the top-left corner coordinates and the box width and height. 
 * [lx0, ly0][lx1, ly1] start and end of the line
 * [rx0, ry0] top-left corner of the rectangle
 * [rWidth] width of the rectangle
 * [rHeight] height of the rectangle
 */
bool line_box_xywh(num lx0, num ly0, num lx1, num ly1, num rx0, num ry0, num rWidth, num rHeight) {
  int out1, out2;
  if ((out2 = _outcode(lx1, ly1, rx0, ry0, rWidth, rHeight)) == 0) {
    return true;
  }
  while ((out1 = _outcode(lx0, ly0, rx0, ry0, rWidth, rHeight)) != 0) {
    if ((out1 & out2) != 0) {
      return false;
    }
    if ((out1 & (_OUT_LEFT | _OUT_RIGHT)) != 0) {
      num x = rx0;
      if ((out1 & _OUT_RIGHT) != 0) {
        x += rWidth;
      }
      ly0 = ly0 + (x - lx0) * (ly1 - ly0) / (lx1 - lx0);
      lx0 = x;
    } else {
      num y = ry0;
      if ((out1 & _OUT_BOTTOM) != 0) {
        y += rHeight;
      }
      lx0 = lx0 + (y - ly0) * (lx1 - lx0) / (ly1 - ly0);
      ly0 = y;
    }
  }
  return true;
}

/**
 * Determine whether two boxes intersect. <br>
 * The boxes are represented by the top-left and bottom-right corner coordinates. 
 * 
 * [ax0, ay0]/[ax1, ay1] top-left and bottom-right corners of rectangle A
 * [bx0, by0]/[bx1, by1] top-left and bottom-right corners of rectangle B
 */
bool box_box(num ax0, num ay0, num ax1, num ay1, num bx0, num by0, num bx1, num by1){
  num topA = min(ay0, ay1);
  num botA = max(ay0, ay1);
  num leftA = min(ax0, ax1);
  num rightA = max(ax0, ax1);
  num topB = min(by0, by1);
  num botB = max(by0, by1);
  num leftB = min(bx0, bx1);
  num rightB = max(bx0, bx1);

  return !(botA <= topB  || botB <= topA || rightA <= leftB || rightB <= leftA);
}

/**
 * If two boxes overlap then the overlap region is another box. This method is used to 
 * calculate the coordinates of the overlap. <br>
 * 
 * [ax0, ay0]/[ax1, ay1] top-left and bottom-right corners of rectangle A
 * [bx0, by0]/[bx1, by1] top-left and bottom-right corners of rectangle B
 *
 * If the returned array has a length:
 * 0 then they do not overlap <br>
 * 4 then these are the coordinates of the top-left and bottom-right corners of the overlap region.
 *  
 */
Float64List box_box_p(num ax0, num ay0, num ax1, num ay1, num bx0, num by0, num bx1, num by1){
  num topA = min(ay0, ay1);
  num botA = max(ay0, ay1);
  num leftA = min(ax0, ax1);
  num rightA = max(ax0, ax1);
  num topB = min(by0, by1);
  num botB = max(by0, by1);
  num leftB = min(bx0, bx1);
  num rightB = max(bx0, bx1);
  
  if(botA <= topB  || botB <= topA || rightA <= leftB || rightB <= leftA)
    return new Float64List(0);

  num leftO = (leftA < leftB) ? leftB : leftA;
  num rightO = (rightA > rightB) ? rightB : rightA;
  num botO = (botA > botB) ? botB : botA;
  num topO = (topA < topB) ? topB : topA;
  Float64List result = new Float64List(4);
  result[0] = (leftO).toDouble();
  result[1] = (topO).toDouble();
  result[2] = (rightO).toDouble();
  result[3] = (botO).toDouble();
  return result;
}

/**
 * Determine if the point pX/pY is inside triangle defined by triangle ABC whose
 * vertices are given by [ax,ay] [bx,by] [cx,cy]
 * @return true if the point is inside
 */
bool isInsideTriangle(num aX, num aY,
    num bX, num bY,
    num cX, num cY,
    num pX, num pY){
  num ax, ay, bx, by, cx, cy, apx, apy, bpx, bpy, cpx, cpy;
  num cCROSSap, bCROSScp, aCROSSbp;

  ax = cX - bX;  ay = cY - bY;
  bx = aX - cX;  by = aY - cY;
  cx = bX - aX;  cy = bY - aY;
  apx= pX - aX;  apy= pY - aY;
  bpx= pX - bX;  bpy= pY - bY;
  cpx= pX - cX;  cpy= pY - cY;

  aCROSSbp = ax*bpy - ay*bpx;
  cCROSSap = cx*apy - cy*apx;
  bCROSScp = bx*cpy - by*cpx;

  return ((aCROSSbp >= 0.0) && (bCROSScp >= 0.0) && (cCROSSap >= 0.0));
}

/**
 * Determine if the point (p) is inside triangle defined by triangle ABC
 * 
 * @param a triangle vertex 1
 * @param b triangle vertex 2
 * @param c triangle vertex 3
 * @param p point of interest
 * @return true if inside triangle else false
 */
bool isInsideTriangle_v(Vector2D a, Vector2D b, Vector2D c, Vector2D p)
  => isInsideTriangle(a.x, a.y, b.x, b.y, c.x, c.y, p.x, p.y);

/**
 * Determine if the point pX/pY is inside triangle defined by triangle ABC
 * 
 * @param a triangle vertex 1
 * @param b triangle vertex 2
 * @param c triangle vertex 3
 * @param pX x position for point of interest
 * @param pY y position for point of interest
 * @return true if inside triangle else false
 */
bool isInsideTriangle_xy(Vector2D a, Vector2D b, Vector2D c, num pX, num pY)
  => isInsideTriangle(a.x, a.y, b.x, b.y, c.x, c.y, pX, pY);

/**
 * See if a point is inside the rectangle defined by top-left and bottom right coordinates
 * @param x0 top-left corner of rectangle 
 * @param y0 top-left corner of rectangle 
 * @param x1 bottom-right corner of rectangle
 * @param y1 bottom-right corner of rectangle
 * @param pX x position of point of interest
 * @param pY y position of point of interest
 * @return true if inside rectangle else false
 */
bool isInsideRectangle_xyxy(num x0, num y0, num x1, num y1, num pX, num pY)
  => (pX >= x0 && pY >= y0 && pX <= x1 && pY <= y1);


/**
 * See if this a is inside the rectangle defined by top-left and bottom right coordinates
 * @param v0 top-left corner of rectangle 
 * @param v1 bottom-right corner of rectangle
 * @param p point of interest
 * @return true if inside rectangle else false
 */
bool isInsideRectangle_v(Vector2D v0, Vector2D v1, Vector2D p)
  => isInsideRectangle_xyxy(v0.x, v0.y, v1.x, v1.y, p.x, p.y);

/**
 * See if a point is inside the rectangle defined by top-left and bottom right coordinates
 * @param x0 top-left corner of rectangle 
 * @param y0 top-left corner of rectangle 
 * @param width width of rectangle
 * @param height height of rectangle
 * @param pX x position of point of interest
 * @param pY y position of point of interest
 * @return true if inside rectangle else false
 */
bool isInsideRectangle_xywh(num x0, num y0, num width, num height,
    num pX, num pY)
  => (pX >= x0 && pY >= y0 && pX <= x0 + width && pY <= y0 + height);


/**
 * See if a point is inside a circle.
 * [cx, cy] centre of the circle
 * r radius of the first circle
 * [pX, pY] the point to test
 */
bool isInsideCirle_xy(num cx, num cy, num r, num pX, num pY)
  => (cx-pX)*(cx-pX) + (cy-pY)*(cy-pY) <= r*r;


/**
 * See if the given point is inside a polygon defined by the vertices provided. 
 * 
 * @param verts the vertices of the shape
 * @param x0 
 * @param y0
 * @return true if x0, y0 is inside polygon else returns false
 */
bool isInsidePolygon(List<Vector2D> verts, num x0, num y0){
    bool oddNodes = false;
    for (int i = 0, j = verts.length - 1; i < verts.length; j = i, i++) {
      Vector2D vi = verts[i];
      Vector2D vj = verts[j];
      if ((vi.y < y0 && vj.y >= y0 || vj.y < y0 && vi.y >= y0) && (vi.x + (y0 - vi.y) / (vj.y - vi.y) * (vj.x - vi.x) < x0))
        oddNodes = !oddNodes;
    }
    return oddNodes;
}

/**
 * Calculates the squared distance between 2 points
 * @param x0 point 1
 * @param y0 point 1
 * @param x1 point 2
 * @param y1 point 2
 * @return the distance between the points squared
 */
num distance_sq(num x0, num y0, num x1, num y1)
    => (x1-x0)*(x1-x0) + (y1-y0)*(y1-y0);

/**
 * Calculates the distance between 2 points
 * @param x0 point 1
 * @param y0 point 1
 * @param x1 point 2
 * @param y1 point 2
 * @return the distance between the points squared
 */
num distance(num x0, num y0, num x1, num y1)
  => sqrt((x1-x0)*(x1-x0) + (y1-y0)*(y1-y0));

  