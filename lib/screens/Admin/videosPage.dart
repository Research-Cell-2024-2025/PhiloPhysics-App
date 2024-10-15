// import 'package:ephysicsapp/globals/colors.dart';
// import 'package:ephysicsapp/services/authentication.dart';
// import 'package:ephysicsapp/services/general.dart';
// import 'package:ephysicsapp/widgets/popUps.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:pod_player/pod_player.dart';

// class VideosListPage extends StatelessWidget {
//   final String section;
//   final String moduleID;

//   VideosListPage({
//     required this.section,
//     required this.moduleID,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final databaseReference = FirebaseDatabase.instance;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Videos'),
//       ),
//       body: StreamBuilder<DatabaseEvent>(
//         stream: databaseReference
//             .ref()
//             .child(section)
//             .child(moduleID)
//             .child("videos")
//             .onValue,
//         builder: (context, AsyncSnapshot<DatabaseEvent> snap) {
//           if (snap.hasData) {
//             final dataSnapshot = snap.data!.snapshot;

//             if (!snap.hasError && dataSnapshot.value != null) {
//               Map<dynamic, dynamic>? data;
//               if (dataSnapshot.value != null) {
//                 data = dataSnapshot.value as Map<dynamic, dynamic>;
//               }
//               var videos = sortMap(data!, "videoName").values.toList();

//               return ListView.builder(
//                 itemCount: videos.length,
//                 itemBuilder: (context, index) {
//                   return !isLoggedIn()
//                       ? videoUserCard(
//                           index: index,
//                           videoDetails: videos[index],
//                           context: context,
//                           section: section,
//                           moduleID: moduleID,
//                         )
//                       : videoCard(
//                           index: index,
//                           videoDetails: videos[index],
//                           context: context,
//                           section: section,
//                           moduleID: moduleID,
//                         );
//                 },
//               );
//             } else if (!snap.hasError && dataSnapshot.value == null) {
//               return Center(child: Text("No videos found"));
//             } else {
//               return Center(child: Text("Error: ${snap.error}"));
//             }
//           } else {
//             return Center(child: Text("Loading...")); // Or a loading indicator
//           }
//         },
//       ),
//     );
//   }

//   Widget videoUserCard({
//     required int index,
//     required Map<dynamic, dynamic> videoDetails,
//     required BuildContext context,
//     required String section,
//     required String moduleID,
//   }) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => VideoDetailPage(
//               section: section,
//               moduleID: moduleID,
//               videoDetails: videoDetails,
//             ),
//           ),
//         );
//       },
//       child: Container(
//         margin: EdgeInsets.fromLTRB(10, 7, 10, 7),
//         child: Card(
//           shadowColor: Colors.black,
//           elevation: 3,
//           color: color1,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Thumbnail image
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Container(
//                   height: MediaQuery.of(context).size.height / 5,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.black, width: 2.5),
//                     borderRadius:
//                         BorderRadius.vertical(top: Radius.circular(10)),
//                     image: DecorationImage(
//                       image: NetworkImage(
//                           videoDetails['thumbnailDownloadUrl'] ??
//                               videoDetails['videoName']),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               ),
//               // Video title
//               Padding(
//                 padding: const EdgeInsets.only(left: 8.0, top: 5.0),
//                 child: Text(
//                   videoDetails['videoName'] ?? 'No Name',
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: color5,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18.5,
//                   ),
//                 ),
//               ),
//               // Icon button to navigate to the video details page
//               Align(
//                 alignment: Alignment.topRight,
//                 child: IconButton(
//                   icon: Icon(Icons.play_arrow, color: color5, size: 30.0),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => VideoDetailPage(
//                           section: section,
//                           moduleID: moduleID,
//                           videoDetails: videoDetails,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// Widget videoCard({
//   required int index,
//   required Map<dynamic, dynamic> videoDetails,
//   required BuildContext context,
//   required String section,
//   required String moduleID,
// }) {
//   return GestureDetector(
//     onTap: () {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => VideoDetailPage(
//             section: section,
//             moduleID: moduleID,
//             videoDetails: videoDetails,
//           ),
//         ),
//       );
//     },
//     child: Container(
//       margin: EdgeInsets.fromLTRB(10, 7, 10, 7),
//       child: Card(
//         elevation: 3,
//         color: color2,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Thumbnail image
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Container(
//                 height: MediaQuery.of(context).size.height / 5,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
//                   border: Border.all(color: Colors.black, width: 2.5),
//                   image: DecorationImage(
//                     image: NetworkImage(videoDetails['thumbnailDownloadUrl'] ??
//                         videoDetails['videoName']),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             ),
//             // Video title
//             Padding(
//               padding: const EdgeInsets.only(left: 8.0, top: 5.0),
//               child: Text(
//                 videoDetails['videoName'] ?? 'No Name',
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   color: color5,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                 ),
//               ),
//             ),
//             // Icon button to navigate to the video details page
//             Align(
//               alignment: Alignment.topRight,
//               child: IconButton(
//                 icon: Icon(Icons.delete),
//                 color: color5,
//                 onPressed: () {
//                   onDeleteVideo(
//                       id: moduleID,
//                       section: section,
//                       context: context,
//                       videoDetails: videoDetails);
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }

// class VideoDetailPage extends StatefulWidget {
//   final String section;
//   final String moduleID;
//   final Map<dynamic, dynamic> videoDetails;

//   VideoDetailPage({
//     required this.section,
//     required this.moduleID,
//     required this.videoDetails,
//   });

//   @override
//   _VideoDetailPageState createState() => _VideoDetailPageState();
// }

// class _VideoDetailPageState extends State<VideoDetailPage> {
//   late final PodPlayerController controller;

//   @override
//   void initState() {
//     super.initState();
//     print("Initializing video player");
//     print("Video details: ${widget.videoDetails}");

//     String videoUrl = widget.videoDetails["videoDownloadUrl"];
//     print("Video URL: $videoUrl");
//     try {
//       controller = PodPlayerController(
//         playVideoFrom: PlayVideoFrom.youtube(videoUrl),
//         podPlayerConfig: const PodPlayerConfig(
//           autoPlay: true,
//           forcedVideoFocus: true,
//           isLooping: false,
//           wakelockEnabled: true,
//           videoQualityPriority: [720, 360],
//         ),
//       )..initialise().then((_) {
//           print("Video player initialized successfully");
//         }).catchError((error) {
//           print("Error initializing video player: $error");
//         });
//     } catch (e) {
//       print("Exception while creating PodPlayerController: $e");
//     }
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           widget.videoDetails['videoName'] ?? 'Video Details',
//           style: TextStyle(overflow: TextOverflow.ellipsis),
//         ),
//       ),
//       body: Center(
//         child: PodVideoPlayer(
//           controller: controller,
//           videoThumbnail: DecorationImage(
//             image: NetworkImage(widget.videoDetails['thumbnailDownloadUrl']),
//             fit: BoxFit.cover,
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:ephysicsapp/globals/colors.dart';
import 'package:ephysicsapp/services/authentication.dart';
import 'package:ephysicsapp/services/general.dart';
import 'package:ephysicsapp/widgets/popUps.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideosListPage extends StatelessWidget {
  final String section;
  final String moduleID;

  VideosListPage({
    required this.section,
    required this.moduleID,
  });

  @override
  Widget build(BuildContext context) {
    final databaseReference = FirebaseDatabase.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text('Videos'),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: databaseReference
            .ref()
            .child(section)
            .child(moduleID)
            .child("videos")
            .onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snap) {
          if (snap.hasData) {
            final dataSnapshot = snap.data!.snapshot;

            if (!snap.hasError && dataSnapshot.value != null) {
              Map<dynamic, dynamic>? data =
                  dataSnapshot.value as Map<dynamic, dynamic>?;
              if (data != null) {
                var videos = sortMap(data, "videoName").values.toList();

                return ListView.builder(
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    return !isLoggedIn()
                        ? videoUserCard(
                            index: index,
                            videoDetails: videos[index],
                            context: context,
                            section: section,
                            moduleID: moduleID,
                          )
                        : videoCard(
                            index: index,
                            videoDetails: videos[index],
                            context: context,
                            section: section,
                            moduleID: moduleID,
                          );
                  },
                );
              }
            }
            return Center(child: Text("No videos found"));
          } else if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget videoUserCard({
    required int index,
    required Map<dynamic, dynamic> videoDetails,
    required BuildContext context,
    required String section,
    required String moduleID,
  }) {
    return GestureDetector(
      onTap: () {
        navigateToVideoDetailPage(context, videoDetails);
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 7, 10, 7),
        child: Card(
          shadowColor: Colors.black,
          elevation: 3,
          color: color1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail image
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: MediaQuery.of(context).size.height / 5,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2.5),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(10)),
                    image: DecorationImage(
                      image: NetworkImage(
                          videoDetails['thumbnailDownloadUrl'] ?? ''),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // Video title
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 5.0),
                child: Text(
                  videoDetails['videoName'] ?? 'No Name',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color5,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.5,
                  ),
                ),
              ),
              // Icon button to navigate to the video details page
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.play_arrow, color: color5, size: 30.0),
                  onPressed: () {
                    navigateToVideoDetailPage(context, videoDetails);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget videoCard({
    required int index,
    required Map<dynamic, dynamic> videoDetails,
    required BuildContext context,
    required String section,
    required String moduleID,
  }) {
    return GestureDetector(
      onTap: () {
        navigateToVideoDetailPage(context, videoDetails);
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 7, 10, 7),
        child: Card(
          elevation: 3,
          color: color2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail image
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: MediaQuery.of(context).size.height / 5,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(10)),
                    border: Border.all(color: Colors.black, width: 2.5),
                    image: DecorationImage(
                      image: NetworkImage(
                          videoDetails['thumbnailDownloadUrl'] ?? ''),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // Video title
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 5.0),
                child: Text(
                  videoDetails['videoName'] ?? 'No Name',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color5,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              // Icon button to delete the video
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.delete),
                  color: color5,
                  onPressed: () {
                    onDeleteVideo(
                        id: moduleID,
                        section: section,
                        context: context,
                        videoDetails: videoDetails);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void navigateToVideoDetailPage(
      BuildContext context, Map<dynamic, dynamic> videoDetails) {
    String videoId =
        YoutubePlayer.convertUrlToId(videoDetails['videoDownloadUrl']) ?? '';
    if (videoId.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoDetailPage(
            videoId: videoId,
            videoName: videoDetails['videoName'] ?? 'Video',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid YouTube URL")),
      );
    }
  }
}

class VideoDetailPage extends StatefulWidget {
  final String videoId;
  final String videoName;

  VideoDetailPage({required this.videoId, required this.videoName});

  @override
  _VideoDetailPageState createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blueAccent,
        progressColors: ProgressBarColors(
          playedColor: Colors.blue,
          handleColor: Colors.blueAccent,
        ),
      ),
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.videoName),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                _controller.pause();
                Navigator.of(context).pop();
              },
            ),
          ),
          body: Center(
            child: player,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
