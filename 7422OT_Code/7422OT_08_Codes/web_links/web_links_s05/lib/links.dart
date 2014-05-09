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
}

class Model {
  var links = new List<Link>();

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

