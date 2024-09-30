import 'package:flutter_sakura_anime/util/base_export.dart';
import '../widget/ball_cliprotate_pulse.dart';

Widget showImage(String url, double width, double height,
    {BoxFit boxFit = BoxFit.cover}) {
  var headers = <String,String>{};
  if(url.contains(Api.newBaseRefer)){
    headers["Referer"] = Api.newBaseUrl;
  }
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
            color: ColorRes.mainColor,
            width: width,
            height: height,
            child: RepaintBoundary(
              child: BallClipRotatePulse(color: ColorRes.pink50,),
            ),
          );
        case LoadState.failed:
          return Container(
            color: ColorRes.mainColor,
            width: width,
            height: width,
            child: Image.asset(
              A.assets_ic_photo_error,
              color: ColorRes.pink50,
            ),
          );
        case LoadState.completed:
          return state.completedWidget;
      }
    },
  );
}
