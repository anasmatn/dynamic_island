import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamin_island/models/football_game_live_activity_model.dart';
import 'package:dynamin_island/views/scoreboard/widgets/score_widget.dart';
import 'package:flutter/material.dart';
import 'package:live_activities/live_activities.dart';
import 'package:live_activities/models/live_activity_image.dart';
import 'package:live_activities/models/url_scheme_data.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print(message.data);
  // teamAName = message.data['0']['full_name'];
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print("token => $token");
  }

  @override
  void initState() {
    getToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _liveActivitiesPlugin = LiveActivities();
  String? _latestActivityId;
  StreamSubscription<UrlSchemeData>? urlSchemeSubscription;
  FootballGameLiveActivityModel? _footballGameLiveActivityModel;
  final docRef = FirebaseFirestore.instance;
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection('users')
      .snapshots(includeMetadataChanges: true);
  String? deviceId;

  getUpdateTeamsNames() async {
    // FirebaseMessaging.instance.subscribeToTopic('updates');
    docRef.collection('users').snapshots().listen(
      (event) {
        teamAName = event.docs[0]['full_name'];
        print(event.docs[0]['full_name']);
        setState(() {
          _updateScore();
        });
      },
    );
  }

  // Future<void> getDeviceId() async {
  //   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //   try {
  //     if (Platform.isAndroid) {
  //       AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //       deviceId = androidInfo.id;
  //     } else if (Platform.isIOS) {
  //       IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
  //       deviceId = iosInfo.identifierForVendor ?? '';
  //     }
  //   } on PlatformException {
  //     deviceId =
  //         ''; // Use a default value or handle the exception case accordingly
  //   }
  // }

  int teamAScore = 0;
  int teamBScore = 0;

  String teamAName = 'PSG';
  String teamBName = 'Chelsea';
  String activityId = '';
  @override
  void initState() {
    super.initState();
    getUpdateTeamsNames();

    _liveActivitiesPlugin.init(
      appGroupId: 'group.com.anasamer.dynaminIsland',
      urlScheme: 'la',
    );

    // to get the activites status and id and token for each activity
    _liveActivitiesPlugin.activityUpdateStream.listen((event) {
      event.mapOrNull(active: (val) async {
        // print('active => ${val.activityToken}');
        // print('active id => ${val.activityId}');
      });
    });

    urlSchemeSubscription =
        _liveActivitiesPlugin.urlSchemeStream().listen((schemeData) {
      setState(() {
        if (schemeData.path == '/stats') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Stats 📊'),
                content: Text(
                  'Now playing final world cup between $teamAName and $teamBName\n\n$teamAName score: $teamAScore\n$teamBName score: $teamBScore',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              );
            },
          );
        }
      });
    }, onError: (e) {
      print('schema error $e');
    });
  }

  @override
  void dispose() {
    urlSchemeSubscription?.cancel();
    _liveActivitiesPlugin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dynamic island (Flutter)',
          style: TextStyle(
            fontSize: 19,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: _usersStream,
          builder: (context, snapshot) {
            return SizedBox.expand(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_latestActivityId != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Card(
                          child: SizedBox(
                            width: double.infinity,
                            height: 120,
                            child: Row(
                              children: [
                                Expanded(
                                  child: ScoreWidget(
                                    score: teamAScore,
                                    teamName: teamAName,
                                    onScoreChanged: (score) {
                                      setState(() {
                                        teamAScore = score < 0 ? 0 : score;
                                      });
                                      _updateScore();
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: ScoreWidget(
                                    score: teamBScore,
                                    teamName: teamBName,
                                    onScoreChanged: (score) {
                                      setState(() {
                                        teamBScore = score < 0 ? 0 : score;
                                      });
                                      _updateScore();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (_latestActivityId == null)
                      TextButton(
                        onPressed: () async {
                          _footballGameLiveActivityModel =
                              FootballGameLiveActivityModel(
                            matchName: 'World cup ⚽️',
                            teamAName: 'PSG',
                            teamAState: 'Home',
                            teamALogo: LiveActivityImageFromAsset(
                              'assets/images/psg.png',
                            ),
                            teamBLogo: LiveActivityImageFromAsset(
                              'assets/images/chelsea.png',
                            ),
                            teamBName: 'Chelsea',
                            teamBState: 'Guest',
                            matchStartDate: DateTime.now(),
                            matchEndDate: DateTime.now().add(
                              const Duration(
                                minutes: 6,
                                seconds: 30,
                              ),
                            ),
                          );

                          final activityId =
                              await _liveActivitiesPlugin.createActivity(
                            _footballGameLiveActivityModel!.toMap(),
                          );
                          setState(() => _latestActivityId = activityId);
                        },
                        child: const Column(
                          children: [
                            Text('Start football match ⚽️'),
                            Text(
                              '(start a new live activity)',
                              style: TextStyle(
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_latestActivityId == null)
                      TextButton(
                        onPressed: () async {
                          final supported = await _liveActivitiesPlugin
                              .areActivitiesEnabled();
                          if (context.mounted) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: Text(
                                    supported ? 'Supported' : 'Not supported',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        child: const Text('Is live activities supported ? 🤔'),
                      ),
                    if (_latestActivityId != null)
                      TextButton(
                        onPressed: () {
                          _liveActivitiesPlugin.endAllActivities();
                          _latestActivityId = null;
                          setState(() {});
                        },
                        child: const Column(
                          children: [
                            Text('Stop match ✋'),
                            Text(
                              '(end all live activities)',
                              style: TextStyle(
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  Future _updateScore() async {
    if (_footballGameLiveActivityModel == null) {
      return;
    }

    final data = _footballGameLiveActivityModel!.copyWith(
      teamAScore: teamAScore,
      teamBScore: teamBScore,
      teamAName: teamAName,
    );
    return _liveActivitiesPlugin.updateActivity(
      _latestActivityId!,
      data.toMap(),
    );
  }
}
