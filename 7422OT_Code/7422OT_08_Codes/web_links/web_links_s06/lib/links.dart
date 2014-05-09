library links;

class Link {
  String name;
  Uri url;

  Link(this.name, String link) {
    url = Uri.parse(link);
  }

  Link.fromJson(Map<String, Object> linkMap) {
    name = linkMap['name'];
    url = Uri.parse(linkMap['url']);
  }

  Map<String, Object> toJson() {
    var linkMap = new Map<String, Object>();
    linkMap['name'] = name;
    linkMap['url'] = url.toString();
    return linkMap;
  }

  /**
   * Compares two links based on their names.
   * If the result is less than 0 then the first link is less than the second,
   * if it is equal to 0 they are equal and
   * if the result is greater than 0 then the first is greater than the second.
   */
  int compareTo(Link link) {
    if (name != null && link.name != null) {
      return name.compareTo(link.name);
    } else {
      throw new Exception('a link name must be present');
    }
  }
}

class Links {
  var _list = new List<Link>();

  Iterator<Link> get iterator => _list.iterator;
  bool get isEmpty => _list.isEmpty;

  List<Link> get internalList => _list;
  set internalList(List<Link> observableList) => _list = observableList;

  bool add(Link newLink) {
    if (newLink == null) {
      throw new Exception('a new link must be present');
    }
    for (Link link in this) {
      if (newLink.name == link.name) return false;
    }
    _list.add(newLink);
    return true;
  }

  Link find(String name) {
    for (Link link in _list) {
      if (link.name == name) return link;
    }
    return null;
  }

  bool remove(Link link) {
    return _list.remove(link);
  }

  order() {
    _list.sort((m,n) => m.compareTo(n));
  }

}

class Model {
  var links = new Links();

  // singleton design pattern: http://en.wikipedia.org/wiki/Singleton_pattern
  static Model model;
  Model.private();
  static Model get one {
    if (model == null) {
      model = new Model.private();
    }
    return model;
  }
  // singleton

  init() {
    var link1 = new Link('On Dart', 'http://ondart.me/');
    var link2 = new Link('Web UI', 'http://www.dartlang.org/articles/web-ui/');
    var link3 = new Link('Books To Read', 'http://www.goodreads.com/');
    Model.one.links.add(link1);
    Model.one.links.add(link2);
    Model.one.links.add(link3);
  }

  List<Map<String, Object>> toJson() {
    var linkList = new List<Map<String, Object>>();
    for (Link link in links) {
      linkList.add(link.toJson());
    }
    return linkList;
  }

  fromJson(List<Map<String, Object>> linkList) {
    if (!links.isEmpty) {
      throw new Exception('links are not empty');
    }
    for (Map<String, Object> linkMap in linkList) {
      Link link = new Link.fromJson(linkMap);
      links.add(link);
    }
  }
}
