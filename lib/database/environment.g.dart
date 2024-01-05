// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environment.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetEnvironmentCollection on Isar {
  IsarCollection<Environment> get environments => this.collection();
}

const EnvironmentSchema = CollectionSchema(
  name: r'Environment',
  id: -7344354649279055731,
  properties: {
    r'channel': PropertySchema(
      id: 0,
      name: r'channel',
      type: IsarType.string,
    ),
    r'dartVersion': PropertySchema(
      id: 1,
      name: r'dartVersion',
      type: IsarType.string,
    ),
    r'devToolsVersion': PropertySchema(
      id: 2,
      name: r'devToolsVersion',
      type: IsarType.string,
    ),
    r'engineReversion': PropertySchema(
      id: 3,
      name: r'engineReversion',
      type: IsarType.string,
    ),
    r'frameworkReversion': PropertySchema(
      id: 4,
      name: r'frameworkReversion',
      type: IsarType.string,
    ),
    r'gitUrl': PropertySchema(
      id: 5,
      name: r'gitUrl',
      type: IsarType.string,
    ),
    r'order': PropertySchema(
      id: 6,
      name: r'order',
      type: IsarType.long,
    ),
    r'path': PropertySchema(
      id: 7,
      name: r'path',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 8,
      name: r'updatedAt',
      type: IsarType.string,
    ),
    r'version': PropertySchema(
      id: 9,
      name: r'version',
      type: IsarType.string,
    )
  },
  estimateSize: _environmentEstimateSize,
  serialize: _environmentSerialize,
  deserialize: _environmentDeserialize,
  deserializeProp: _environmentDeserializeProp,
  idName: r'id',
  indexes: {
    r'path': IndexSchema(
      id: 8756705481922369689,
      name: r'path',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'path',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _environmentGetId,
  getLinks: _environmentGetLinks,
  attach: _environmentAttach,
  version: '3.1.0+1',
);

int _environmentEstimateSize(
  Environment object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.channel.length * 3;
  bytesCount += 3 + object.dartVersion.length * 3;
  bytesCount += 3 + object.devToolsVersion.length * 3;
  bytesCount += 3 + object.engineReversion.length * 3;
  bytesCount += 3 + object.frameworkReversion.length * 3;
  bytesCount += 3 + object.gitUrl.length * 3;
  bytesCount += 3 + object.path.length * 3;
  bytesCount += 3 + object.updatedAt.length * 3;
  bytesCount += 3 + object.version.length * 3;
  return bytesCount;
}

void _environmentSerialize(
  Environment object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.channel);
  writer.writeString(offsets[1], object.dartVersion);
  writer.writeString(offsets[2], object.devToolsVersion);
  writer.writeString(offsets[3], object.engineReversion);
  writer.writeString(offsets[4], object.frameworkReversion);
  writer.writeString(offsets[5], object.gitUrl);
  writer.writeLong(offsets[6], object.order);
  writer.writeString(offsets[7], object.path);
  writer.writeString(offsets[8], object.updatedAt);
  writer.writeString(offsets[9], object.version);
}

Environment _environmentDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Environment();
  object.channel = reader.readString(offsets[0]);
  object.dartVersion = reader.readString(offsets[1]);
  object.devToolsVersion = reader.readString(offsets[2]);
  object.engineReversion = reader.readString(offsets[3]);
  object.frameworkReversion = reader.readString(offsets[4]);
  object.gitUrl = reader.readString(offsets[5]);
  object.id = id;
  object.order = reader.readLong(offsets[6]);
  object.path = reader.readString(offsets[7]);
  object.updatedAt = reader.readString(offsets[8]);
  object.version = reader.readString(offsets[9]);
  return object;
}

P _environmentDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _environmentGetId(Environment object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _environmentGetLinks(Environment object) {
  return [];
}

void _environmentAttach(
    IsarCollection<dynamic> col, Id id, Environment object) {
  object.id = id;
}

extension EnvironmentByIndex on IsarCollection<Environment> {
  Future<Environment?> getByPath(String path) {
    return getByIndex(r'path', [path]);
  }

  Environment? getByPathSync(String path) {
    return getByIndexSync(r'path', [path]);
  }

  Future<bool> deleteByPath(String path) {
    return deleteByIndex(r'path', [path]);
  }

  bool deleteByPathSync(String path) {
    return deleteByIndexSync(r'path', [path]);
  }

  Future<List<Environment?>> getAllByPath(List<String> pathValues) {
    final values = pathValues.map((e) => [e]).toList();
    return getAllByIndex(r'path', values);
  }

  List<Environment?> getAllByPathSync(List<String> pathValues) {
    final values = pathValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'path', values);
  }

  Future<int> deleteAllByPath(List<String> pathValues) {
    final values = pathValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'path', values);
  }

  int deleteAllByPathSync(List<String> pathValues) {
    final values = pathValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'path', values);
  }

  Future<Id> putByPath(Environment object) {
    return putByIndex(r'path', object);
  }

  Id putByPathSync(Environment object, {bool saveLinks = true}) {
    return putByIndexSync(r'path', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPath(List<Environment> objects) {
    return putAllByIndex(r'path', objects);
  }

  List<Id> putAllByPathSync(List<Environment> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'path', objects, saveLinks: saveLinks);
  }
}

extension EnvironmentQueryWhereSort
    on QueryBuilder<Environment, Environment, QWhere> {
  QueryBuilder<Environment, Environment, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension EnvironmentQueryWhere
    on QueryBuilder<Environment, Environment, QWhereClause> {
  QueryBuilder<Environment, Environment, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Environment, Environment, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Environment, Environment, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Environment, Environment, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterWhereClause> pathEqualTo(
      String path) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'path',
        value: [path],
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterWhereClause> pathNotEqualTo(
      String path) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path',
              lower: [],
              upper: [path],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path',
              lower: [path],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path',
              lower: [path],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path',
              lower: [],
              upper: [path],
              includeUpper: false,
            ));
      }
    });
  }
}

extension EnvironmentQueryFilter
    on QueryBuilder<Environment, Environment, QFilterCondition> {
  QueryBuilder<Environment, Environment, QAfterFilterCondition> channelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'channel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      channelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'channel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> channelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'channel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> channelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'channel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      channelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'channel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> channelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'channel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> channelContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'channel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> channelMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'channel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      channelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'channel',
        value: '',
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      channelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'channel',
        value: '',
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      dartVersionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dartVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      dartVersionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dartVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      dartVersionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dartVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      dartVersionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dartVersion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      dartVersionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dartVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      dartVersionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dartVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      dartVersionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dartVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      dartVersionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dartVersion',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      dartVersionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dartVersion',
        value: '',
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      dartVersionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dartVersion',
        value: '',
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      devToolsVersionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'devToolsVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      devToolsVersionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'devToolsVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      devToolsVersionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'devToolsVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      devToolsVersionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'devToolsVersion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      devToolsVersionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'devToolsVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      devToolsVersionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'devToolsVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      devToolsVersionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'devToolsVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      devToolsVersionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'devToolsVersion',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      devToolsVersionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'devToolsVersion',
        value: '',
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      devToolsVersionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'devToolsVersion',
        value: '',
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      engineReversionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'engineReversion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      engineReversionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'engineReversion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      engineReversionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'engineReversion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      engineReversionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'engineReversion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      engineReversionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'engineReversion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      engineReversionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'engineReversion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      engineReversionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'engineReversion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      engineReversionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'engineReversion',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      engineReversionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'engineReversion',
        value: '',
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      engineReversionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'engineReversion',
        value: '',
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      frameworkReversionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'frameworkReversion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      frameworkReversionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'frameworkReversion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      frameworkReversionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'frameworkReversion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      frameworkReversionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'frameworkReversion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      frameworkReversionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'frameworkReversion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      frameworkReversionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'frameworkReversion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      frameworkReversionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'frameworkReversion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      frameworkReversionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'frameworkReversion',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      frameworkReversionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'frameworkReversion',
        value: '',
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      frameworkReversionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'frameworkReversion',
        value: '',
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> gitUrlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gitUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      gitUrlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gitUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> gitUrlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gitUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> gitUrlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gitUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      gitUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'gitUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> gitUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'gitUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> gitUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'gitUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> gitUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'gitUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      gitUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gitUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      gitUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'gitUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> orderEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      orderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> orderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> orderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'order',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> pathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> pathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> pathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> pathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'path',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> pathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> pathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> pathContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> pathMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'path',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> pathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'path',
        value: '',
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      pathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'path',
        value: '',
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      updatedAtEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      updatedAtGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      updatedAtLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      updatedAtBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      updatedAtStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'updatedAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      updatedAtEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'updatedAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      updatedAtContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'updatedAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      updatedAtMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'updatedAt',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      updatedAtIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: '',
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      updatedAtIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'updatedAt',
        value: '',
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> versionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'version',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      versionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'version',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> versionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'version',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> versionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'version',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      versionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'version',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> versionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'version',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> versionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'version',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition> versionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'version',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      versionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'version',
        value: '',
      ));
    });
  }

  QueryBuilder<Environment, Environment, QAfterFilterCondition>
      versionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'version',
        value: '',
      ));
    });
  }
}

extension EnvironmentQueryObject
    on QueryBuilder<Environment, Environment, QFilterCondition> {}

extension EnvironmentQueryLinks
    on QueryBuilder<Environment, Environment, QFilterCondition> {}

extension EnvironmentQuerySortBy
    on QueryBuilder<Environment, Environment, QSortBy> {
  QueryBuilder<Environment, Environment, QAfterSortBy> sortByChannel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'channel', Sort.asc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy> sortByChannelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'channel', Sort.desc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy> sortByDartVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dartVersion', Sort.asc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy> sortByDartVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dartVersion', Sort.desc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy> sortByDevToolsVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'devToolsVersion', Sort.asc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy>
      sortByDevToolsVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'devToolsVersion', Sort.desc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy> sortByEngineReversion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'engineReversion', Sort.asc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy>
      sortByEngineReversionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'engineReversion', Sort.desc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy>
      sortByFrameworkReversion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frameworkReversion', Sort.asc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy>
      sortByFrameworkReversionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frameworkReversion', Sort.desc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy> sortByGitUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gitUrl', Sort.asc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy> sortByGitUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gitUrl', Sort.desc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy> sortByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy> sortByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy> sortByPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.asc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy> sortByPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.desc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy> sortByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy> sortByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension EnvironmentQuerySortThenBy
    on QueryBuilder<Environment, Environment, QSortThenBy> {
  QueryBuilder<Environment, Environment, QAfterSortBy> thenByChannel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'channel', Sort.asc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy> thenByChannelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'channel', Sort.desc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy> thenByDartVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dartVersion', Sort.asc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy> thenByDartVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dartVersion', Sort.desc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy> thenByDevToolsVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'devToolsVersion', Sort.asc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy>
      thenByDevToolsVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'devToolsVersion', Sort.desc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy> thenByEngineReversion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'engineReversion', Sort.asc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy>
      thenByEngineReversionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'engineReversion', Sort.desc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy>
      thenByFrameworkReversion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frameworkReversion', Sort.asc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy>
      thenByFrameworkReversionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frameworkReversion', Sort.desc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy> thenByGitUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gitUrl', Sort.asc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy> thenByGitUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gitUrl', Sort.desc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy> thenByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy> thenByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy> thenByPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.asc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy> thenByPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.desc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy> thenByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<Environment, Environment, QAfterSortBy> thenByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension EnvironmentQueryWhereDistinct
    on QueryBuilder<Environment, Environment, QDistinct> {
  QueryBuilder<Environment, Environment, QDistinct> distinctByChannel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'channel', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Environment, Environment, QDistinct> distinctByDartVersion(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dartVersion', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Environment, Environment, QDistinct> distinctByDevToolsVersion(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'devToolsVersion',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Environment, Environment, QDistinct> distinctByEngineReversion(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'engineReversion',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Environment, Environment, QDistinct>
      distinctByFrameworkReversion({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'frameworkReversion',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Environment, Environment, QDistinct> distinctByGitUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gitUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Environment, Environment, QDistinct> distinctByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'order');
    });
  }

  QueryBuilder<Environment, Environment, QDistinct> distinctByPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'path', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Environment, Environment, QDistinct> distinctByUpdatedAt(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Environment, Environment, QDistinct> distinctByVersion(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'version', caseSensitive: caseSensitive);
    });
  }
}

extension EnvironmentQueryProperty
    on QueryBuilder<Environment, Environment, QQueryProperty> {
  QueryBuilder<Environment, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Environment, String, QQueryOperations> channelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'channel');
    });
  }

  QueryBuilder<Environment, String, QQueryOperations> dartVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dartVersion');
    });
  }

  QueryBuilder<Environment, String, QQueryOperations>
      devToolsVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'devToolsVersion');
    });
  }

  QueryBuilder<Environment, String, QQueryOperations>
      engineReversionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'engineReversion');
    });
  }

  QueryBuilder<Environment, String, QQueryOperations>
      frameworkReversionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'frameworkReversion');
    });
  }

  QueryBuilder<Environment, String, QQueryOperations> gitUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gitUrl');
    });
  }

  QueryBuilder<Environment, int, QQueryOperations> orderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'order');
    });
  }

  QueryBuilder<Environment, String, QQueryOperations> pathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'path');
    });
  }

  QueryBuilder<Environment, String, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<Environment, String, QQueryOperations> versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'version');
    });
  }
}
