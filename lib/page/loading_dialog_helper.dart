import '../util/base_export.dart';

class LoadingDialogHelper {

  static void showLoading(BuildContext context, {bool dismissible = true}) {
    showDialog(
        barrierDismissible: dismissible,
        context: context,
        builder: (context) {
          return LoadingDialogWidget(
            dismissible: dismissible,
          );
        });
  }

  ///关闭弹窗
  static void dismissLoading(BuildContext context) {
    Navigator.pop(context);
  }
}

// ignore: must_be_immutable
class LoadingDialogWidget extends StatelessWidget {

  bool dismissible = false;

  LoadingDialogWidget({Key? key, required this.dismissible}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ///拦截返回导航
        PopScope(
            canPop: dismissible,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey[200]),
              padding: const EdgeInsets.all(20),
              height: 80,
              width: 80,
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
                backgroundColor: Colors.grey[300],
              ),
            ),
            onPopInvoked: (bool){

            },
        )
      ],
    );
  }
}


