part of dartlero_category_links;

class Category extends ConceptEntity<Category> {

  String description;
  Links links = new Links();

  Category newEntity() => new Category();

  String toString() {
    return '  {\n '
           '    ${super.toString()}, \n '
           '    description: ${description}\n'
           '  }\n';
  }

  Map<String, Object> toJson() {
    Map<String, Object> entityMap = super.toJson();
    entityMap['description'] = description;
    entityMap['links'] = links.toJson();
    return entityMap;
  }

  fromJson(Map<String, Object> entityMap) {
    super.fromJson(entityMap);
    description = entityMap['description'];
    links.fromJson(entityMap['links']);
  }

  bool get onProgramming =>
      description.contains('programming') ? true : false;
}

class Categories extends ConceptEntities<Category> {

  Categories newEntities() => new Categories();
  Category newEntity() => new Category();
}
