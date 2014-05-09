library links;

class Link {
  String name;
  Uri url;

  Link(this.name, String link) {
    url = Uri.parse(link);
  }
}

