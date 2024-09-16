class Entry{
  final String title;
  final String content;
  final DateTime date = DateTime.now();

  Entry({required this.title, required this.content});

  factory Entry.fromMap(Map<String, dynamic> data){
    return Entry(
      title: data['title'],
      content: data['content']
    );
  }
}