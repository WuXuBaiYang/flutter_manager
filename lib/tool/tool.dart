// 扩展字符串
extension StringExtension on String {
  // 正则匹配第一个分组
  String regFirstGroup(String source, [int index = 0, bool trim = true]) {
    final match = RegExp(source).firstMatch(this);
    final result = match?.group(index) ?? '';
    if (!trim) return result;
    return result.trim();
  }
}