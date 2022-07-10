import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:weaver_editor/models/types.dart';
import 'package:weaver_editor/utils/helper.dart';

class MaterialPasteControls extends MaterialTextSelectionControls
    with SelectionControlHandler {
  @override
  final BlockConverterCallback buildBlockFromClipboard;

  MaterialPasteControls(this.buildBlockFromClipboard) : super();
}

class CupertinoPasteControls extends CupertinoTextSelectionControls
    with SelectionControlHandler {
  @override
  final BlockConverterCallback buildBlockFromClipboard;
  CupertinoPasteControls(this.buildBlockFromClipboard) : super();
}

typedef BlockConverterCallback = bool Function(ClipboardUrl);

mixin SelectionControlHandler on TextSelectionControls {
  BlockConverterCallback get buildBlockFromClipboard;
  @override
  Future<void> handlePaste(TextSelectionDelegate delegate) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);

    final clipboardUrl = StringUtil.tryExtractUrl(data?.text);

    print('pasted text: ${data?.text}, clipboard url: $clipboardUrl');

    if (clipboardUrl.hasValidUrl) {
      // TODO: convert the url to an embed block
      final isConverted = buildBlockFromClipboard(clipboardUrl);

      if (isConverted) return;
    }
    return super.handlePaste(delegate);
  }
}

class PasteControlFactory {
  static TextSelectionControls? platform(
    TargetPlatform platform, {
    required BlockConverterCallback blockConverter,
  }) {
    switch (platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return MaterialPasteControls(blockConverter);
      case TargetPlatform.iOS:
        return CupertinoPasteControls(blockConverter);
      default:
        return null;
    }
  }
}
