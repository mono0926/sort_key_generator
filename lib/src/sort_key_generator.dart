double? generateSortKeyDouble({
  double? previous,
  double? next,
}) {
  if (previous == null) {
    if (next == null) {
      return 0;
    }
    return next - 1;
  }
  if (next == null) {
    return previous + 1;
  }
  assert(
    previous < next,
    'next($next) should be larger than previous($previous',
  );
  final ret = (previous + next) / 2;
  if (ret <= previous) {
    print('ret($ret) is smaller than or equal to previous($previous)');
    return null;
  }
  if (ret >= next) {
    print('ret($ret) is bigger than or equal to next($next)');
    return null;
  }
  return ret;
}
