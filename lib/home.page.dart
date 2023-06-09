import 'package:elgomusic/colors.dart';
import 'package:elgomusic/config.dart';
import 'package:elgomusic/darkmode.extension.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconly/iconly.dart';
import 'package:ionicons/ionicons.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rxdart/rxdart.dart';
import 'package:smooth_widgets/widgets/buttons/icon.button.dart';
import 'package:smooth_widgets/widgets/skeletons/button.listtile.skeleton.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool islist = false;

  // Define on audio plugin
  final OnAudioQuery _audioQuery = OnAudioQuery();

  // Player
  final AudioPlayer _player = AudioPlayer();

  List<SongModel> songs = [];
  String currentSongTitle = "نام آهنگ";
  int currentIndex = 0;

  bool isPlayerViewVisible = false;

  // Define a method to set the player view visibility
  void _changePlayerViewVisibility() {
    isPlayerViewVisible = !isPlayerViewVisible;
  }

  // Duration state stream
  Stream<DurationState> get _durationStateStream =>
      Rx.combineLatest2<Duration, Duration?, DurationState>(
        _player.positionStream,
        _player.durationStream,
        (position, duration) =>
            DurationState(position: position, total: duration ?? Duration.zero),
      );

  @override
  void initState() {
    super.initState();

    requestStoragePermission();

    // Update the current playing song index listener
    _player.currentIndexStream.listen((index) {
      if (index != null) {
        _updateCurrentPlayingSongDetails(index);
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isPlayerViewVisible) {
      print("Song: $currentSongTitle");
      return Scaffold(
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
            decoration: BoxDecoration(color: Colors.white),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _changePlayerViewVisibility();
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          decoration: getDecoration(
                            BoxShape.circle,
                            const Offset(2, 2),
                            2.0,
                            0.0,
                          ),
                          child: Icon(
                            IconlyLight.arrow_left,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Text(
                        currentSongTitle,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        "نام آهنگ: $currentSongTitle",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 30),

                  // Artwork container
                  Container(
                    width: 300,
                    height: 300,
                    decoration:
                        getDecoration(BoxShape.circle, Offset(2, 2), 2.0, 0.0),
                    child: QueryArtworkWidget(
                      id: 2,
                      type: ArtworkType.AUDIO,
                      artworkBorder: SmoothBorderRadius(
                        cornerRadius: 12,
                        cornerSmoothing: 0.5,
                      ),
                      nullArtworkWidget: Icon(
                        Ionicons.musical_notes_outline,
                        size: 150,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Padding(
          padding: EdgeInsets.only(top: 55, bottom: 10, left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                Config.appName,
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
              SmoothIconButton(
                icon: islist
                    ? IconlyLight.category
                    : Ionicons.reorder_two_outline,
                onPressed: () {
                  setState(() {
                    islist = !islist;
                  });
                },
              )
            ],
          ),
        ),
      ),
      body: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: bgColor,
            border: Border.all(
              width: 1,
              color: Colors.black.withOpacity(0.03),
            ),
          ),
          child: FutureBuilder<List<SongModel>>(
            future: _audioQuery.querySongs(
                sortType: null,
                orderType: OrderType.ASC_OR_SMALLER,
                uriType: UriType.EXTERNAL,
                ignoreCase: true),
            builder: (context, item) {
              if (item.data == null) {
                return Column(
                  children: [
                    SizedBox(height: 20),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 150,
                            height: 10,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.black.withOpacity(0.01),
                            ),
                          ),
                          Container(
                            width: 50,
                            height: 10,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.black.withOpacity(0.01),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return SmoothButtonListTileSkeleton();
                        },
                      ),
                    ),
                  ],
                );
              }

              if (item.data!.isEmpty) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/svg/not_found.svg",
                          color:
                              !context.isDarkMode ? Colors.black : Colors.white,
                          width: 250,
                        ),
                        const SizedBox(height: 25),
                        Text(
                          "هنوز هیچ موزیکی اینجا نیست!",
                          style: TextStyle(
                            fontSize: 18,
                            color: !context.isDarkMode
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView(
                shrinkWrap: true,
                physics: BouncingScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
                children: [
                  // Listview
                  if (islist) ...[
                    SizedBox(height: 20),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("تعداد موزیک ها"),
                          Text("${item.data?.length}"),
                        ],
                      ),
                    ),
                    ListView.builder(
                      key: PageStorageKey<String>("musics-list"),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: item.data!.length,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.symmetric(
                              horizontal: BorderSide(
                                width: 1,
                                color: Colors.black.withOpacity(0.01),
                              ),
                            ),
                          ),
                          child: ListTile(
                            title: Text(
                              item.data![index].title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              item.data![index].displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.black.withOpacity(0.02),
                              ),
                              child: Icon(
                                Ionicons.play,
                                size: 12,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            leading: AspectRatio(
                              aspectRatio: 1 / 1,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: SmoothBorderRadius(
                                    cornerRadius: 12,
                                    cornerSmoothing: 0.5,
                                  ),
                                  color: Colors.black.withOpacity(0.02),
                                ),
                                child: QueryArtworkWidget(
                                  id: item.data![index].id,
                                  type: ArtworkType.AUDIO,
                                  artworkFit: BoxFit.contain,
                                  artworkBorder: SmoothBorderRadius(
                                    cornerRadius: 12,
                                    cornerSmoothing: 0.5,
                                  ),
                                  nullArtworkWidget: Icon(
                                    Ionicons.musical_note_outline,
                                    size: 25,
                                    color: Colors.black.withOpacity(0.9),
                                  ),
                                ),
                              ),
                            ),
                            onTap: () async {
                              //
                              setState(() {
                                _changePlayerViewVisibility();
                              });

                              //
                              // String? uri = item.data![index].uri;

                              //
                              // await _player.setAudioSource(
                              //     AudioSource.uri(Uri.parse(uri!)));
                              await _player.setAudioSource(
                                createPlaylist(item.data!),
                                initialIndex: index,
                              );
                              await _player.play();
                            },
                          ),
                        );
                      },
                    ),
                  ],

                  // Grid
                  if (!islist) ...[
                    SizedBox(height: 20),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("تعداد موزیک ها"),
                          Text("${item.data?.length}"),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: StaggeredGridView.countBuilder(
                          key: PageStorageKey<String>("musics-grid"),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          crossAxisCount: 4,
                          itemCount: item.data?.length,
                          itemBuilder: (BuildContext context, int index) =>
                              Column(
                            children: [
                              AspectRatio(
                                aspectRatio: 1 / 1,
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.01),
                                    borderRadius: SmoothBorderRadius(
                                      cornerRadius: 20,
                                      cornerSmoothing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 15),
                              Text(
                                "${item.data?[index].displayName}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 15),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "${item.data?[index].artist}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          staggeredTileBuilder: (int index) =>
                              StaggeredTile.count(2, 3),
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                      ),
                    ),
                  ]
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void requestStoragePermission() async {
    if (!kIsWeb) {
      bool permissionStatus = await _audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await _audioQuery.permissionsRequest();
      }

      setState(() {
        //
      });
    }
  }

  ConcatenatingAudioSource createPlaylist(List<SongModel> songs) {
    //
    List<AudioSource> sources = [];
    for (var song in songs) {
      sources.add(AudioSource.uri(Uri.parse(song.uri!)));
    }
    return ConcatenatingAudioSource(children: sources);
  }

  // Updage playing song details
  void _updateCurrentPlayingSongDetails(int index) {
    setState(() {
      if (songs.isNotEmpty) {
        currentSongTitle = songs[index].title;
        currentIndex = index;
      }
    });
  }

  //
  getDecoration(
      BoxShape shape, Offset offset, double blurRadius, double spreadRadius) {
    return BoxDecoration(
        color: Colors.black.withOpacity(0.01),
        shape: shape,
        boxShadow: [
          BoxShadow(
            offset: -offset,
            color: Colors.white24,
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
          )
        ]);
  }
}

// Duration class
class DurationState {
  DurationState({
    this.position = Duration.zero,
    this.total = Duration.zero,
  });
  Duration position, total;
}
