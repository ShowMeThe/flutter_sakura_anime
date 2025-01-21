import 'package:flutter_sakura_anime/style/database/PlayUrlHistory.dart';
import 'package:flutter_sakura_anime/style/router/AppRouter.gr.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';

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
  late final _hisStateProvider =
      StateProvider.autoDispose((ref) => <SearchHistory>[]);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initSearchFlow();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _focusNode.dispose();
    editController.dispose();
  }

  void _initSearchFlow() {
    DatabaseManager.getSearchHistoryFlow().listen((onData) {
       ref.watch(_hisStateProvider.notifier).update((cb)=>onData);
    });
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
            DatabaseManager.insertSearchHistory(word);
          }
        }, onChange: (word) {
          if (word.isNotEmpty) {
            ref.refresh(_opacityProvider.notifier).update((state) => 1.0);
          } else {
            ref.refresh(_opacityProvider.notifier).update((state) => 0.0);
          }
        }, controller: editController),
        body: _buildSearchBody(),
      ),
    );
  }

  Widget _buildSearchBody() {
    return Consumer(builder: (context, ref, _) {
      var list = ref.watch(_hisStateProvider);
      if (list.isEmpty) {
        return Container();
      } else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildWrap(list),
            GestureDetector(
              onTap: () {
                DatabaseManager.deleteAllSearchHistory();
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete),
                  Padding(
                    padding: EdgeInsets.only(left: 2.0,right: 8.0),
                    child: Text(
                      "删除记录",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ],
        );
      }
    });
  }

  Widget buildWrap(List<SearchHistory> list) {
    var children = list.map((element) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: (){
            context.navigateTo(NetFlexSearchResultRoute(keyWord: element.title));
          },
          child: Chip(label: Text(element.title,style: const TextStyle(color: Colors.yellow),),onDeleted: (){
            DatabaseManager.deleteSearchHistory(element);
          },),
        ),
      );
    }).toList();
    return Wrap(
      alignment: WrapAlignment.start,
      children: children,
    );
  }
}
