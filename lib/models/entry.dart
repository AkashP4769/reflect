class Entry{
  final String title;
  final String content;
  final DateTime date = DateTime.now();

  Entry({required this.title, required this.content});
}