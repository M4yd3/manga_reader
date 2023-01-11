class Manga {
  String path;
  String title;
  String? author;
  String? series;

  int pageCount;
  int currentPage;

  bool favorite;
  bool toRead;
  bool haveRead;

  Manga({
    required this.path,
    required this.title,
    this.author,
    this.series,
    required this.pageCount,
    this.currentPage = 0,
    this.favorite = false,
    this.toRead = false,
    this.haveRead = false,
  });

  factory Manga.fromJson(Map<String, dynamic> json) => Manga(
        path: json['path'],
        title: json['title'],
        author: json['author'],
        series: json['series'],
        pageCount: json['pageCount'],
        currentPage: json['currentPage'],
        favorite: json['favorite'],
        toRead: json['toRead'],
        haveRead: json['haveRead'],
      );

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['path'] = path;
    data['title'] = title;
    data['author'] = author;
    data['series'] = series;
    data['pageCount'] = pageCount;
    data['currentPage'] = currentPage;
    data['favorite'] = favorite;
    data['toRead'] = toRead;
    data['haveRead'] = haveRead;
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
