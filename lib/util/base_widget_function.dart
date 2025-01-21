import 'package:flutter_sakura_anime/util/base_export.dart';
import '../widget/ball_cliprotate_pulse.dart';

Widget showImage(BuildContext context,String url, double width, double height,
    {BoxFit boxFit = BoxFit.cover}) {
  var headers = <String,String>{};
  var theme = Theme.of(context);
  var backgroundColor = theme.primaryColor;
  var progressColor = theme.colorScheme.primary;
  return ExtendedImage.network(
    url,
    headers: headers,
    width: width,
    height: height,
    fit: boxFit,
    cache: true,
    loadStateChanged: (state) {
      switch (state.extendedImageLoadState) {
        case LoadState.loading:
          return Container(
            color: backgroundColor,
            width: width,
            height: height,
            child: RepaintBoundary(
              child: BallClipRotatePulse(color: progressColor,),
            ),
          );
        case LoadState.failed:
          return Container(
            color: backgroundColor,
            width: width,
            height: width,
            child: Image.asset(
              A.assets_ic_photo_error,
              color: progressColor.withAlpha(125),
            ),
          );
        case LoadState.completed:
          return state.completedWidget;
      }
    },
  );
}
