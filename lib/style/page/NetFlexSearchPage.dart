import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sakura_anime/style/router/AppRouter.gr.dart';
import 'package:flutter_sakura_anime/widget/search_app_bar.dart';

import '../../util/style.dart';

@RoutePage()
class NetFlexSearchPage extends ConsumerStatefulWidget {
  const NetFlexSearchPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NetFlexSearchPageState();
}

class _NetFlexSearchPageState extends ConsumerState<NetFlexSearchPage> {
  late final FocusNode _focusNode = FocusNode();
  late final editController = TextEditingController(text: "");
  late final _opacityProvider = StateProvider.autoDispose((ref) => 0.0);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _focusNode.dispose();
    editController.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: setSystemUi(),
      child: Scaffold(
          appBar: SearchAppBar(
              focusNode: _focusNode,
              leading: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Padding(
                  padding: EdgeInsets.only(left: 12.0),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
              ), suffix: Consumer(
        builder: (context, ref, _) {
          var opacity = ref.watch(_opacityProvider);
          return GestureDetector(
            onTap: () {
              if (opacity != 0.0) {
                editController.clear();
                ref.refresh(_opacityProvider.notifier).update((state) => 0.0);
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: opacity,
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ), (word) {
        if (word.isNotEmpty) {
          context.navigateTo(NetFlexSearchResultRoute(keyWord: word));
        }
      }, onChange: (word) {
        if (word.isNotEmpty) {
          ref.refresh(_opacityProvider.notifier).update((state) => 1.0);
        } else {
          ref.refresh(_opacityProvider.notifier).update((state) => 0.0);
        }
      }, controller: editController)),
    );
  }
}
