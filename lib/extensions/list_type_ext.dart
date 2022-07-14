import '../models/types.dart';

extension ToListBlockStyle on String {
  ListBlockStyle toListStyle() {
    switch (this) {
      case 'unordered':
        return ListBlockStyle.unordered;
      case 'ordered':
        return ListBlockStyle.ordered;
      default:
        throw UnimplementedError('Not supported list style: $this');
    }
  }
}
