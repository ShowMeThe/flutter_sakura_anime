import '../util/base_export.dart';

// ignore: must_be_immutable
class ErrorView extends StatefulWidget {
  final VoidCallback onTry;
  late Color textColor;

   ErrorView(this.onTry, {super.key,this.textColor = Colors.black});

  @override
  State<StatefulWidget> createState() => _ErrorViewState();
}

class _ErrorViewState extends State<ErrorView> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: widget.onTry,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.rotate_left_rounded,
                size: 25.0,
                color: ColorRes.pink200,
              ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text(
                  "点击重试",
                  style: TextStyle(fontSize: 15,color: widget.textColor),
                ),
              )
            ],
          ),
        ));
  }
}
