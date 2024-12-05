class Activity {
  final String id;
  final String userId;
  final String username;
  final String? userPhoto;
  final String title;
  final DateTime dateTime;
  final String venue;
  final int minPeople;
  final int maxPeople;
  final double guysFee;
  final double ladiesFee;
  final bool isCourtBooked;
  final bool isPayBeforeJoin;
  final bool isRestrictBySkillLevel;
  final String skillLevel;
  final String gameType;
  final String activityType;
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.userId,
    required this.username,
    this.userPhoto,
    required this.title,
    required this.dateTime,
    required this.venue,
    required this.minPeople,
    required this.maxPeople,
    required this.guysFee,
    required this.ladiesFee,
    required this.isCourtBooked,
    required this.isPayBeforeJoin,
    required this.isRestrictBySkillLevel,
    required this.skillLevel,
    required this.gameType,
    required this.activityType,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'username': username,
        'userPhoto': userPhoto,
        'title': title,
        'dateTime': dateTime.toIso8601String(),
        'venue': venue,
        'minPeople': minPeople,
        'maxPeople': maxPeople,
        'guysFee': guysFee,
        'ladiesFee': ladiesFee,
        'isCourtBooked': isCourtBooked,
        'isPayBeforeJoin': isPayBeforeJoin,
        'isRestrictBySkillLevel': isRestrictBySkillLevel,
        'skillLevel': skillLevel,
        'gameType': gameType,
        'activityType': activityType,
        'createdAt': createdAt,
      };
}
