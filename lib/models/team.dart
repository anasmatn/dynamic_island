import 'package:live_activities/models/live_activity_image.dart';

class Team {
  final String name;
  final String id;
  final String image;
  final String abr;
  final String score;

  Team({
    required this.name,
    required this.id,
    required this.image,
    required this.abr,
    required this.score,
  });

  factory Team.fromJson(Map json, score) => Team(
      name: json['Nm'],
      id: json['ID'],
      image: "https://lsm-static-prod.livescore.com/medium/${json['Img']}",
      abr: json['Abr'],
      score: score);
}
