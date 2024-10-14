import 'package:jtech_base/jtech_base.dart';

@Entity()
class Package {
  int id = 0;

  // 创建时间
  @Property(type: PropertyType.date)
  DateTime createAt = DateTime.now();

  // 更新时间
  @Property(type: PropertyType.date)
  DateTime updateAt = DateTime.now();

  Package();

  Package.c({
    required this.createAt,
    required this.updateAt,
  });

  Package copyWith({
    DateTime? createAt,
    DateTime? updateAt,
  }) {
    return Package.c(
      createAt: createAt ?? this.createAt,
      updateAt: updateAt ?? this.updateAt,
    );
  }
}
