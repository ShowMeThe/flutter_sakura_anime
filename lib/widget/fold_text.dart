import 'package:flutter_sakura_anime/util/base_export.dart';
import 'dart:ui' as ui;

class FoldTextView extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle textStyle;
  final double maxWidth;
  final Color? moreBgColor;
  final Color? moreTxColor;

  const FoldTextView(this.text, this.maxLines, this.textStyle, this.maxWidth,
      {super.key, this.moreBgColor, this.moreTxColor});

  @override
  State<StatefulWidget> createState() => _FoldTextViewState();
}

const _kMoreWidth = 70.0;

class _FoldTextViewState extends State<FoldTextView> {
  bool _isOverFlow = false;
  Color _bgColor = Colors.transparent;
  String _textStr = '';
  var _maxLines, _temLines;
  List<ui.LineMetrics> _lines = [];

  @override
  void initState() {
    super.initState();
    _bgColor = widget.moreBgColor == null
        ? Colors.grey.withAlpha(65)
        : widget.moreBgColor!;
    _textStr = widget.text;
    _maxLines = widget.maxLines;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, size) {
      _isOverFlow = _checkOverMaxLines01(_maxLines, widget.maxWidth);
      _temLines = _checkOverMaxLines02(widget.maxWidth)?.length;
      return (_temLines < _maxLines)
          ? _itemText()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[_itemText(), _moreText()]);
    });
  }

  _itemText() => SizedBox(
      width: widget.maxWidth,
      child: Text(_textStr,
          style: widget.textStyle,
          maxLines: _maxLines,
          overflow: TextOverflow.visible));

  _moreText() => GestureDetector(
      child: _transparentWid01(),
      onTap: () => setState(() {
            if (_temLines > _maxLines) {
              if (_lines.last.width + _kMoreWidth > widget.maxWidth) {
                _maxLines = _temLines + 1;
                _textStr = '${widget.text}\n';
              } else {
                _maxLines = _temLines;
              }
            } else if (_temLines == _maxLines) {
              _maxLines = widget.maxLines;
            }
          }));

  _transparentWid01() => Container(
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [_bgColor.withValues(alpha: 0.0), _bgColor],
              end: const FractionalOffset(0.5, 0.5))),
      width: _kMoreWidth,
      child: Text((_temLines > _maxLines) ? '展开' : '收起',
          style: TextStyle(
              color:
                  widget.moreTxColor ?? Theme.of(context).colorScheme.primary,
              fontSize: widget.textStyle.fontSize ?? 14.0)));

  _checkOverMaxLines01(maxLines, maxWidth) {
    final textSpan = TextSpan(text: _textStr, style: widget.textStyle);
    final textPainter = TextPainter(
        text: textSpan, textDirection: TextDirection.ltr, maxLines: maxLines);
    textPainter.layout(
        maxWidth: widget.maxWidth);
    return textPainter.didExceedMaxLines;
  }

  _checkOverMaxLines02(maxWidth) {
    final textSpan = TextSpan(text: _textStr, style: widget.textStyle);
    final textPainter =
        TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout(
        maxWidth: widget.maxWidth);
    _lines = textPainter.computeLineMetrics();
    return _lines;
  }
}
