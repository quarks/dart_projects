import 'dart:html';
import 'dart:json';

import 'package:web_ui/web_ui.dart';
import 'package:web_links/links.dart';

class WebLinks extends WebComponent {
  Links webLinks = Model.one.links;

  add() {
    InputElement name = query("#name");
    InputElement url = query("#url");
    LabelElement message = query("#message");
    var error = false;
    message.text = '';
    if (name.value.trim() == '') error = true;
    if (url.value.trim() == '') error = true;
    if (!error) {
      var webLink = new Link(name.value, url.value);
      if (webLinks.add(webLink)) {
        webLinks.order();
        save();
      } else {
        message.text = 'web link with that name already exists';
      }
    }
  }

  remove() {
    InputElement name = query("#name");
    InputElement url = query("#url");
    LabelElement message = query("#message");
    message.text = '';
    Link link = webLinks.find(name.value);
    if (link == null) {
      message.text = 'web link with this name does not exist';
    } else {
      url.value = link.url.toString();
      if (webLinks.remove(link)) save();
    }
  }

  save() {
    window.localStorage['web_links'] =
        stringify(Model.one.toJson());
  }
}