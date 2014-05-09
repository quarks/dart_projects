part of dartlero_example;

class ProjectModel extends ConceptModel {

  static final String project = 'Project';

  Map<String, ConceptEntities> newEntries() {
    var projects = new Projects();
    var map = new Map<String, ConceptEntities>();
    map[project] = projects;
    return map;
  }

  Projects get projects => getEntry(project);

  init() {
    var design = new Project();
    design.name = 'Dartling Design';
    design.description =
        'Creating a model of Dartling concepts based on MagicBoxes.';
    projects.add(design);

    var prototype = new Project();
    prototype.name = 'Dartling Prototype';
    prototype.description =
        'Programming the meta model and the generic model.';
    projects.add(prototype);

    var production = new Project();
    production.name = 'Dartling';
    production.description =
        'Programming Dartling.';
    projects.add(production);
  }

  display() {
    print('Project Model');
    print('=============');
    projects.display('Projects');
    print(
      '============= ============= ============= '
      '============= ============= ============= '
    );
  }
}


