class LevelData {
  final int id;
  final String category;
  final String imagePath;
  bool isUnlocked;
  bool isCompleted;

  LevelData({
    required this.id,
    required this.category,
    required this.imagePath,
    this.isUnlocked = false,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'imagePath': imagePath,
        'isUnlocked': isUnlocked,
        'isCompleted': isCompleted,
      };

  factory LevelData.fromJson(Map<String, dynamic> json) {
    return LevelData(
      id: json['id'],
      category: json['category'],
      imagePath: json['imagePath'],
      isUnlocked: json['isUnlocked'] ?? false,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
