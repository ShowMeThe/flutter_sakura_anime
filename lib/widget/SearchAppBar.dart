import '../util/base_export.dart';

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  SearchAppBar(this.onSearch,
      {super.key,
      required this.controller,
      this.leading,
      this.suffix,
      this.onChange,
      this.hintText,
      this.hintTextColor,
      this.cursorColor,
      this.textColor,
      this.paddingLeft = 45,
      this.paddingRight = 45,
      this.textSize = 18,
      this.autoFocus = true,
      this.appBarElevation = 5,
      this.appBarHeight = 100,
      this.appBarBackgroundColor});

  late TextEditingController controller;
  ValueChanged<String>? onChange;
  late ValueChanged<String> onSearch;
  late double paddingLeft;
  late double paddingRight;
  late double appBarElevation;
  late double appBarHeight;
  late double textSize;
  Color? cursorColor;
  Color? hintTextColor;
  Color? textColor;
  Color? appBarBackgroundColor;
  String? hintText;
  late bool autoFocus;
  Widget? leading;
  Widget? suffix;

  @override
  State<StatefulWidget> createState() => _SearchAppBarState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(appBarHeight);
}

class _SearchAppBarState extends State<SearchAppBar> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    widget.appBarBackgroundColor =
        widget.appBarBackgroundColor ?? theme.colorScheme.primary;
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light));
    var statusBarHeight = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: widget.appBarHeight,
      child: Material(
        elevation: 2,
        color: widget.appBarBackgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
                padding: EdgeInsets.only(top: statusBarHeight),
                child: widget.leading ?? Container()),
            Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.only(
                      top: statusBarHeight,
                      left: widget.paddingLeft,
                      right: widget.paddingRight),
                  child: TextField(
                    controller: widget.controller,
                    onChanged: widget.onChange,
                    onSubmitted: widget.onSearch,
                    cursorColor:
                        widget.cursorColor ?? Colors.white.withAlpha(125),
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: widget.hintText ?? '??????????????????',
                      hintStyle: TextStyle(
                          fontSize: widget.textSize,
                          color: widget.hintTextColor ??
                              Colors.white.withAlpha(125)),
                    ),
                    textInputAction: TextInputAction.search,
                    style: TextStyle(
                        fontSize: widget.textSize,
                        color: widget.textColor ?? Colors.white),
                    autofocus: widget.autoFocus,
                  ),
                )),
            Padding(
              padding: EdgeInsets.only(top: statusBarHeight),
              child: widget.suffix ?? Container(),
            )
          ],
        ),
      ),
    );
  }
}
