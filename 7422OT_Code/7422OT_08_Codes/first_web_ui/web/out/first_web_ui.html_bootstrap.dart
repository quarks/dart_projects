library bootstrap;

import 'package:web_ui/watcher.dart' as watcher;
import 'first_web_ui.dart' as userMain;

main() {
  watcher.useObservers = false;
  userMain.main();
  userMain.init_autogenerated();
}
