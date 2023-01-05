import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/widget/SearchAppBar.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  var editController = TextEditingController(text: "");
  final _opacityProvider = StateProvider.autoDispose((ref) => 0.0);


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    editController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchAppBar(
          paddingLeft: 15,
          controller: editController,
          onChange: (word) {
            if (word.isNotEmpty) {
              ref.read(_opacityProvider.state).update((state) => 1.0);
            } else {
              ref.read(_opacityProvider.state).update((state) => 0.0);
            }
          },
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
          ),
          suffix: Consumer(
            builder: (context, ref, _) {
              var opacity = ref.watch(_opacityProvider);
              return GestureDetector(
                onTap: () {
                  if (opacity != 0.0) {
                    editController.clear();
                    ref.read(_opacityProvider.state).update((state) => 0.0);
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
          ),
          (word) {
            debugPrint("word = $word");
          }),
      body: Text(""),
    );
  }
}
