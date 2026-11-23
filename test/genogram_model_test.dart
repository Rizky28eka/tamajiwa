import 'package:flutter_test/flutter_test.dart';
import 'package:tamajiwa/models/genogram_member.dart';

void main() {
  group('GenogramMember', () {
    test('round-trips through JSON', () {
      final member = GenogramMember(
        name: 'Siti',
        age: 48,
        gender: Gender.female,
        relationship: 'Ibu',
        generation: -1,
      );
      final copy = GenogramMember.fromJson(member.toJson());
      expect(copy.id, member.id);
      expect(copy.name, 'Siti');
      expect(copy.gender, Gender.female);
      expect(copy.generation, -1);
    });

    test('accepts numeric ids and text ages from older data', () {
      final member = GenogramMember.fromJson({'id': 7, 'name': 'Budi', 'age': '55'});
      expect(member.id, '7');
      expect(member.age, 55);
      expect(member.gender, Gender.other);
    });
  });

  group('GenogramRelationship', () {
    test('reads both fromId/toId and legacy from/to keys', () {
      final modern = GenogramRelationship.fromJson({'fromId': 'a', 'toId': 'b', 'type': 'marriage'});
      final legacy = GenogramRelationship.fromJson({'id': 3, 'from': 1, 'to': 2, 'type': 'sibling'});
      expect(modern.fromId, 'a');
      expect(modern.type, RelType.marriage);
      expect(legacy.id, '3');
      expect(legacy.toId, '2');
      expect(legacy.type, RelType.sibling);
    });

    test('unknown relationship types fall back to other', () {
      final rel = GenogramRelationship.fromJson({'fromId': 'a', 'toId': 'b', 'type': 'nope'});
      expect(rel.type, RelType.other);
    });
  });
}
