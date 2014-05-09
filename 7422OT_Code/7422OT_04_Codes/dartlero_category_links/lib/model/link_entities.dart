part of dartlero_category_links;

class Link extends ConceptEntity<Link> {

  Uri url;
  String description;

  Link newEntity() => new Link();

  String toString() {
    return '    {\n '
           '      ${super.toString()}, \n '
           '      link: ${url}, \n '
           '      description: ${description}\n'
           '    }\n';
  }

  Map<String, Object> toJson() {
    Map<String, Object> entityMap = super.toJson();
    entityMap['url'] = url.toString();
    entityMap['description'] = description;
    return entityMap;
  }

  fromJson(Map<String, Object> entityMap) {
    super.fromJson(entityMap);
    url = Uri.parse(entityMap['url']);
    description = entityMap['description'];
  }

  bool get onProgramming =>
      description.contains('programming') ? true : false;

}

class Links extends ConceptEntities<Link> {

  Links newEntities() => new Links();
  Link newEntity() => new Link();

}

