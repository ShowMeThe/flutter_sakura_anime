import '../util/base_export.dart';

class ErrorView extends StatefulWidget {
  final VoidCallback onTry;

  const ErrorView(this.onTry, {super.key});

  @override
  State<StatefulWidget> createState() => _ErrorViewState();
}

class _ErrorViewState extends State<ErrorView> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: widget.onTry,
        child: const SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.rotate_left_rounded,
                size: 25.0,
                color: ColorRes.pink200,
              ),
              Padding(
                padding: EdgeInsets.all(18.0),
                child: Text(
                  "点击重试",
                  style: TextStyle(fontSize: 15),
                ),
              )
            ],
          ),
        ));
  }
}
