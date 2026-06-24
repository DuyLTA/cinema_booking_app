String formatVnd(num amount) {
  final value = amount.round().toString();
  final buffer = StringBuffer();

  for (var index = 0; index < value.length; index++) {
    final reverseIndex = value.length - index;
    buffer.write(value[index]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write(',');
    }
  }

  return '${buffer.toString()} VND';
}
