library transform2d;

import "vector2d.dart";
import "matrix2d.dart";


//--------------------------- WorldTransform -----------------------------
//
//given a List of 2D vectors, a position and  orientation
// forward and side should be normalised before calling this method
//this function transforms the 2D vectors into the object's world space
//------------------------------------------------------------------------

List<Vector2D> worldTransform(final List<Vector2D> points,
    Vector2D   pos,
    Vector2D   forward,
    Vector2D   side,
    [Vector2D   scale = null]){

  if(scale == null)
    scale = new Vector2D.XY(1, 1);
  
  //create a transformation matrix
  Matrix2D matTransform = new Matrix2D();

  //scale
  if ( (scale.x != 1.0) || (scale.y != 1.0) ) 
    matTransform.scale(scale.x, scale.y);
  //rotate
  matTransform.rotate(forward, side);
  //and translate
  matTransform.translate(pos.x, pos.y);

  //now transform the object's vertices
  return matTransform.transformVector2Ds(points);
}


//--------------------- PointToWorldSpace --------------------------------
// agentHeading and agentSide should be normalised first
//Transforms a point from the agent's local space into world space
//------------------------------------------------------------------------
Vector2D pointToWorldSpace(Vector2D point,
                                         Vector2D AgentHeading,
                                         Vector2D AgentSide,
                                         Vector2D AgentPosition)
{
  
  //create a transformation matrix
  Matrix2D matTransform = new Matrix2D();

  //rotate
  matTransform.rotate(AgentHeading, AgentSide);

  //and translate
  matTransform.translate(AgentPosition.x, AgentPosition.y);

  //now transform the vertices
  return matTransform.transformVector2D(point);
}


//--------------------- VectorToWorldSpace --------------------------------
//
//Transforms a vector from the agent's local space into world space
//------------------------------------------------------------------------
Vector2D vectorToWorldSpace(Vector2D vec, Vector2D AgentHeading,
                                          Vector2D AgentSide) {
  //create a transformation matrix
  Matrix2D matTransform = new Matrix2D();

  //rotate
  matTransform.rotate(AgentHeading, AgentSide);

  //now transform and return the vertices
  return matTransform.transformVector2D(vec);
}


//--------------------- PointToLocalSpace --------------------------------
// agentHeading and agentSide should be normalised
//------------------------------------------------------------------------
Vector2D pointToLocalSpace( Vector2D point,
                                          Vector2D agentHeading,
                                          Vector2D agentSide,
                                          Vector2D agentPosition)
{
  //create a transformation matrix
  Matrix2D matTransform = new Matrix2D();

  double tx = -agentPosition.dot(agentHeading);
  double ty = -agentPosition.dot(agentSide);

  //create the transformation matrix
  matTransform.c11 = agentHeading.x;  matTransform.c12 = agentSide.x;
  matTransform.c21 = agentHeading.y;  matTransform.c22 = agentSide.y;
  matTransform.c31 = tx;              matTransform.c32 = ty;

  //now transform the vertices
  return matTransform.transformVector2D(point);
}

//--------------------- VectorToLocalSpace --------------------------------
//
//------------------------------------------------------------------------
Vector2D vectorToLocalSpace(Vector2D vec, Vector2D agentHeading,
                                          Vector2D agentSide)
{ 
  //create a transformation matrix
  Matrix2D matTransform = new Matrix2D();

  //create the transformation matrix
  matTransform.c11 = agentHeading.x;  matTransform.c12 = agentSide.x;
  matTransform.c21 = agentHeading.y;  matTransform.c22 = agentSide.y;

  //now transform the vertices
  return matTransform.transformVector2D(vec);
}

//-------------------------- Vec2DRotateAroundOrigin --------------------------
// v is unchanged
//rotates a vector ang rads around the origin
//-----------------------------------------------------------------------------
Vector2D vec2DRotateAroundOrigin(Vector2D v, double ang)
{
  //create a transformation matrix
  Matrix2D mat = new Matrix2D();

  //rotate
  mat.rotateAngle(ang);

  //now transform the object's vertices
  return mat.transformVector2D(v);
}
