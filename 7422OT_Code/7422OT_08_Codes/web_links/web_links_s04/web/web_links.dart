import 'package:web_links/links.dart';
import 'package:web_ui/web_ui.dart';

final links = toObservable(new List<Link>());

/**
 * Learn about the Web UI package by visiting
 * http://www.dartlang.org/articles/web-ui/ .
 */
void main() {
  // create several links
  var link1 = new Link('On Dart', 'http://ondart.me/');
  var link2 = new Link('Web UI', 'http://www.dartlang.org/articles/web-ui/');
  var link3 = new Link('Books To Read', 'http://www.goodreads.com/');
  links.add(link1);
  links.add(link2);
  links.add(link3);
}
