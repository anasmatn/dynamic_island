import 'package:dynamin_island/models/team.dart';
import 'package:intl/intl.dart';
import 'package:live_activities/models/live_activity_image.dart';

class TeamResponse {
  final Team team1;
  final Team team2;
  final String heading;
  final String subHeading;

  TeamResponse(
      {required this.team1,
      required this.team2,
      required this.heading,
      required this.subHeading});

  factory TeamResponse.fromJson(Map<String, dynamic> json) => TeamResponse(
      team1:
          Team.fromJson(json['Events'][0]['T1'][0], json['Events'][0]['Tr1']),
      team2:
          Team.fromJson(json['Events'][0]['T2'][0], json['Events'][0]['Tr2']),
      heading: json['CompN'],
      subHeading: json['CompD']);

  toJson() => {
        "T1_name": team1.name,
        "T1_id": team1.id,
        "T1_image": LiveActivityImageFromUrl(team1.image, resizeFactor: 1),
        "T1_abr": team1.abr,
        "T1_score": team1.score,
        "T2_name": team2.name,
        "T2_id": team2.id,
        "T2_image": LiveActivityImageFromUrl(team2.image, resizeFactor: 1),
        "T2_abr": team2.abr,
        "T2_score": team2.score,
        "heading": heading,
        "subHeading": subHeading,
        "time": DateFormat("HH:mm:ss").format(DateTime.now())
      };

  DateTime get dateTime => DateTime.now();
}
