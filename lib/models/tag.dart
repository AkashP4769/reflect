
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
}