
class Tag{
  final String name;
  final int color;

  Tag({required this.name, required this.color});

  factory Tag.fromJson(Map<String, dynamic> json){
    return Tag(
      name: json['name'],
      color: json['color']
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'name': name,
      'color': color
    };
  }

  factory Tag.fromMap(Map<String, dynamic> map){
    return Tag(name: map['name'], color: map['color']);
  }

  Map<String, dynamic> toMap(){
    return {
      'name': name,
      'color': color
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tag && runtimeType == other.runtimeType && name == other.name && color == other.color;

  @override
  int get hashCode => name.hashCode ^ color.hashCode;
}