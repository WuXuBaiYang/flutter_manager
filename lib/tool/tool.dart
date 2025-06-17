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

// 扩展工具方法
class XTool {
  // 判断输入字符串是否为路径
  static bool isPath(String path) =>
      path.startsWith('/') || path.startsWith('\\');

  // 判断输入字符串是否为ip地址
  static bool isIP(String ip) => RegExp(
    r'^((2[0-4]\d|25[0-5]|[01]?\d\d?)\.){3}(2[0-4]\d|25[0-5]|[01]?\d\d?)$',
  ).hasMatch(ip);

  // 判断输入字符串是否为http/https地址
  static bool isHttp(String url) => RegExp(
    r'^https?:\/\/(([a-zA-Z0-9_-])+(\.)?)*(:\d+)?(\/((\.)?(\?)?=?&?[a-zA-Z0-9_-](\?)?)*)*$/i',
  ).hasMatch(url);
}
