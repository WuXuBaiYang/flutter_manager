import 'package:isar/isar.dart';

/*
* 数据库管理
* @author wuxubaiyang
* @Time 2022/3/17 14:14
*/
abstract class BaseDatabase {
  // 数据库对象
  final Isar _isar;

  // 获取isar
  Isar get isar => _isar;

  BaseDatabase(List<CollectionSchema<dynamic>> schemas,
      {String directory = '', required String name})
      : _isar = Isar.openSync(schemas, directory: directory, name: name);

  // 事务写入
  Future<T> writeTxn<T>(Future<T> Function() callback, {bool silent = false}) =>
      _isar.writeTxn<T>(callback, silent: silent);
}
