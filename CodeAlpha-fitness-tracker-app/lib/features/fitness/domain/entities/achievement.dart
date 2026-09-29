class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconKey,
    required this.unlocked,
    required this.progress,
  });

  final String id;
  final String title;
  final String description;
  final String iconKey;
  final bool unlocked;
  final double progress;
}
