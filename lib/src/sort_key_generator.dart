double? generateSortKeyDouble({
  double? previous,
  double? next,
}) =>
    switch ((previous, next)) {
      (null, null) => 0,
      (null, final next?) => next - 1,
      (final previous?, null) => previous + 1,
      (final previous?, final next?) => () {
          assert(
            previous < next,
            'next($next) should be larger than previous($previous)',
          );
          final ret = (previous + next) / 2;
          return (ret <= previous || ret >= next) ? null : ret;
        }(),
    };
