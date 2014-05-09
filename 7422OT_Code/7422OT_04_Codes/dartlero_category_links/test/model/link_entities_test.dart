import 'dart:uri';

import 'package:unittest/unittest.dart';
import 'package:dartlero/dartlero.dart';
import 'package:dartlero_category_links/dartlero_category_links.dart';

testCategoryLinks() {
  Category category;
  group("Testing Category Links: ", () {
    setUp(() {
      CategoryLinksModel categoryLinksModel = new CategoryLinksModel();
      categoryLinksModel.init();
      Categories categories = categoryLinksModel.categories;
      category = categories.find('Dart');
    });
    tearDown(() {
      category.links.clear();
      expect(category.links.isEmpty, isTrue);
    });
    test('Add Dart category link', () {
      var link = new Link();
      link.code = 'Dart Editor';
      link.url = new Uri.fromString('http://www.dartlang.org/docs/editor/');
      category.links.add(link);
      category.links.display('Add Dart category link');
    });
    test('Add Dart category link without data', () {
      var link = new Link();
      expect(link, isNotNull);
      var added = category.links.add(link);
      expect(added, isTrue);
      category.links.display('Add Dart category link without data');
    });
    test('Add Dart category link that is not unique', () {
      var link = new Link();
      link.code = 'Dart';
      link.url = new Uri.fromString('http://www.dartlang.org/');
      var added = category.links.add(link);
      expect(added, isFalse);
      category.links.display('Add Dart category link that is not unique');
    });
    test('Find Dart category link by Dart code', () {
      var searchCode = 'Dart';
      var link = category.links.find(searchCode);
      expect(link, isNotNull);
      expect(link.code, equals(searchCode));
      link.display('Find Dart category link by Dart code');
    });
    test('Order Dart category links by code', () {
      category.links.order();
      category.links.display('Order Dart category links by code');
    });
    test('Select Dart category links by programming in description', () {
      var programmingLinks = category.links.select((link) => link.onProgramming);
      expect(programmingLinks.isEmpty, isFalse);
      expect(programmingLinks.length, equals(1));
      programmingLinks.display(
          'Select Dart category links by programming in description');
    });
  });
}

main() {
  testCategoryLinks();
}