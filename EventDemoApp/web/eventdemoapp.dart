import 'dart:html';

void main() {
  DivElement element = query('#sandbox');
  element.on.mouseDown.add((MouseEvent event) => drawEvent(event));
  element.on.mouseMove.add((MouseEvent event) => drawEvent(event));
  element.on.mouseOut.add((MouseEvent event) => drawEvent(event));
  element.on.mouseOver.add((MouseEvent event) => drawEvent(event));
  element.on.mouseUp.add((MouseEvent event) => drawEvent(event));
  element.on.mouseWheel.add((MouseEvent event) => drawEvent(event));
}

void drawEvent(MouseEvent event) {
  print(event.type);
 
  if (event.type == "mousedown" && !isChecked("mousedown")) {
    return;
  } else if (event.type == "mousemove" && !isChecked("mousemove")) {
    return;
  } else if (event.type == "mouseout" && !isChecked("mouseout")) {
    return;
  } else if (event.type == "mouseover" && !isChecked("mouseover")) {
    return;
  } else if (event.type == "mouseup" && !isChecked("mouseup")) {
    return;
  } else if (event.type == "mousewheel" && !isChecked("mousewheel")) {
    return;
  }
 
  drawMouseEventProperties(event);
}

void drawMouseEventProperties(MouseEvent event) {
  query('#PropertyList').nodes.clear();
 
  drawItem("type", event.type);
 
  drawItem("", "");
  drawItem("x", event.x);  
  drawItem("y", event.y);
  drawItem("clientX", event.clientX);
  drawItem("clientY", event.clientY);
  drawItem("layerX", event.layerX);  
  drawItem("layerY", event.layerY);
  drawItem("offsetX", event.offsetX);
  drawItem("offsetY", event.offsetY);  
  drawItem("pageX", event.pageX);
  drawItem("pageY", event.pageY);
  drawItem("screenX", event.screenX);
  drawItem("screenY", event.screenY);
  drawItem("webkitMovementX", event.webkitMovementX);
  drawItem("webkitMovementY;", event.webkitMovementY);  
 
  if (event is WheelEvent) {  
    drawItem("wheelDelta", event.wheelDelta);  
    drawItem("wheelDeltaX", event.wheelDeltaX);
    drawItem("wheelDeltaY", event.wheelDeltaY);
    drawItem("webkitDirectionInvertedFromDevice", event.webkitDirectionInvertedFromDevice);
  } else {
    drawItem("", "");
    drawItem("", "");
    drawItem("", "");
    drawItem("", "");
  }
 
  drawItem("timeStamp", event.timeStamp);
 
  drawItem("", "");
  drawItem("altKey", event.altKey);
  drawItem("charCode", event.charCode);
  drawItem("ctrlKey", event.ctrlKey);
  drawItem("keyCode", event.keyCode);
  drawItem("metaKey", event.metaKey);
  drawItem("shiftKey", event.shiftKey);
 
  drawItem("", "");
  drawItem("bubbles", event.bubbles);
  drawItem("button", event.button);
  drawItem("cancelable", event.cancelable);
  drawItem("cancelBubble", event.cancelBubble);
  drawItem("defaultPrevented", event.defaultPrevented);
  drawItem("detail", event.detail);
  drawItem("eventPhase", event.eventPhase);
  drawItem("returnValue", event.returnValue);
  drawItem("which", event.which);
 
  drawItem("", "");
  drawItem("currentTarget", event.currentTarget);
  drawItem("fromElement", event.fromElement);
  drawItem("relatedTarget", event.relatedTarget);
  drawItem("srcElement", event.srcElement);
  drawItem("target", event.target);
  drawItem("view", event.view);
  drawItem("dataTransfer", event.dataTransfer);
  drawItem("dynamic", event.dynamic);
  //drawItem("event.clipboardData", event.clipboardData);
}

void drawItem(String name, var value) {
  DivElement divName = new DivElement();
  divName.classes.add("name");
  divName.innerHTML = name;

  DivElement divValue = new DivElement();
  divValue.classes.add("value");
  divValue.innerHTML = value.toString();
 
  DivElement divRow = new DivElement();
  divRow.classes.add("row");
  divRow.nodes.add(divName);
  divRow.nodes.add(divValue);
 
  query('#PropertyList').nodes.add(divRow);
}

bool isChecked(String id) {
  InputElement checkbox = query("#$id");
  if (checkbox.checked) {
    return true;
  }
  return false;
}
