class MjCategoryData {
  List<MjCategoryItem> list = [];
  bool hasNextPage = false;

  MjCategoryData(this.list, this.hasNextPage);
}

class MjCategoryItem {
  final String url;
  final String logo;
  final String title;
  final String state;
  final String realName;
  final String otherName;
  final String time;

  MjCategoryItem(this.url, this.logo, this.title, this.state, this.realName,
      this.otherName, this.time);

  @override
  String toString() {
    return 'MjCategoryItem{url: $url, logo: $logo, title: $title, state: $state, realName: $realName, otherName: $otherName, time: $time}';
  }
}
