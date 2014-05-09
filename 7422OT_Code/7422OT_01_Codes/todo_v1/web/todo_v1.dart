import 'dart:html';

InputElement task;
UListElement list;

main() {
  task = query('#task');
  list = query('#list');
  task.onChange.listen( (e) => addItem() );
}

void addItem() {
  var newTask = new LIElement();
  newTask.text = task.value;
  task.value = '';
  list.children.add(newTask);
}

