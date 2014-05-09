part of dartlero_category_links;

class CategoryLinksModel extends ConceptModel {
  static final String category = 'Category';

  Map<String, ConceptEntities> newEntries() {
    var categories = new Categories();
    var map = new Map<String, ConceptEntities>();
    map[category] = categories;
    return map;
  }

  Categories get categories => getEntry(category);

  init() {
    var webCategory = new Category();
    webCategory.code = 'Web';
    webCategory.description = 'Web design and technologies.';
    categories.add(webCategory);

    var webCategoryLinks = webCategory.links;
    var webCategoryHtml5Link = new Link();
    webCategoryHtml5Link.code = 'HTML5';
    webCategoryHtml5Link.url =
        Uri.parse('http://www.html5rocks.com/');
    webCategoryHtml5Link.description =
        'HTML5 is the ubiquitous platform for the web.';
    webCategoryLinks.add(webCategoryHtml5Link);

    var webCategoryCss3Link = new Link();
    webCategoryCss3Link.code = 'CSS3';
    webCategoryCss3Link.url = Uri.parse('http://www.css3.info/');
    webCategoryCss3Link.description =
        'CSS3 is the new kid in the stylesheet family.';
    webCategoryLinks.add(webCategoryCss3Link);

    var dartCategory = new Category();
    dartCategory.code = 'Dart';
    dartCategory.description = 'Web programming language, tools and how to.';
    categories.add(dartCategory);

    var dartCategoryLinks = dartCategory.links;
    var dartCategoryPubLink = new Link();
    dartCategoryPubLink.code = 'Pub';
    dartCategoryPubLink.url = Uri.parse('http://pub.dartlang.org/');
    dartCategoryPubLink.description =
        'A repository of software packages for Dart';
    dartCategoryLinks.add(dartCategoryPubLink);

    var dartCategoryDartLink = new Link();
    dartCategoryDartLink.code = 'Dart';
    dartCategoryDartLink.url = Uri.parse('http://www.dartlang.org/');
    dartCategoryDartLink.description =
        'Dart addresses issues with traditional web programming '
        'languages while remaining easy to learn.';
    dartCategoryLinks.add(dartCategoryDartLink);
  }

  display() {
    print('Category Links Model');
    print('====================');
    for (var category in categories) {
      print('  Category');
      print('  --------');
      print(category.toString());
      print('    Links');
      print('    -----');
      for (var link in category.links) {
        print(link.toString());
      }
    }
    print(
      '============= ============= ============= '
      '============= ============= ============= '
    );
  }
}
