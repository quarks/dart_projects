import 'package:unittest/unittest.dart';
import 'package:dartlero/dartlero.dart';
import 'package:dartlero_category_links/dartlero_category_links.dart';

testCategories() {
  Categories categories;
  group("Testing Categories: ", () {
    setUp(() {
      CategoryLinksModel categoryLinksModel = new CategoryLinksModel();
      categoryLinksModel.init();
      categories = categoryLinksModel.categories;
    });
    tearDown(() {
      categories.clear();
      expect(categories.isEmpty, isTrue);
    });
    test('Add category', () {
      var category = new Category();
      category.code = 'JavaScript';
      categories.add(category);
      categories.display('Add category');
    });
    test('Add category without data', () {
      var category = new Category();
      expect(category, isNotNull);
      var added = categories.add(category);
      expect(added, isTrue);
      categories.display('Add category without data');
    });
    test('Add not unique category', () {
      var category = new Category();
      category.code = 'Dart';
      var added = categories.add(category);
      expect(added, isFalse);
      categories.display('Add not unique category');
    });
    test('Find category by Dart code', () {
      var searchCode = 'Dart';
      var category = categories.find(searchCode);
      expect(category, isNotNull);
      expect(category.code, equals(searchCode));
      category.display('Find category by Dart code');
    });
    test('Order categories by code', () {
      categories.order();
      categories.display('Order categories by code');
    });
    test('Select categories by programming in description', () {
      var programmingCategories =
          categories.select((category) => category.onProgramming);
      expect(programmingCategories.isEmpty, isFalse);
      expect(programmingCategories.length, equals(1));
      programmingCategories.display(
          'Select categories by programming in description');
    });
    test('From categories to JSON', () {
      List<Map<String, Object>> json = categories.toJson();
      expect(json, isNotNull);
      print(json);
    });
    test('From JSON to categories', () {
      List<Map<String, Object>> json = categories.toJson();
      categories.clear();
      expect(categories.isEmpty, isTrue);
      categories.fromJson(json);
      expect(categories.isEmpty, isFalse);
      categories.display('From JSON to categories');
    });
  });
}

main() {
  testCategories();
}