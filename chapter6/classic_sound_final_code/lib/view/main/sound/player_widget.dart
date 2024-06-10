import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:classicsound/data/local_database.dart';
import 'package:classicsound/data/music.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class PlayerWidget extends StatefulWidget {
  final AudioPlayer player;
  final Music music;
  final Database database;
  final Function callback;

  const PlayerWidget({
    required this.player,
    super.key,
    required this.music,
    required this.database,
    required this.callback,
  });

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState();
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  // 현재 플레이 상태
  PlayerState? _playerState;

  // 음악 시간 및 현재 재생 시간
  Duration? _duration;
  Duration? _position;

  late Music _currentMusic;

  // 시간과 slider가 지속적으로 변하기 위한 Stream
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  bool get _isPlaying => _playerState == PlayerState.playing;

  bool get _isPaused => _playerState == PlayerState.paused;

  String get _durationText => _duration?.toString().split('.').first ?? '';

  String get _positionText => _position?.toString().split('.').first ?? '';

  AudioPlayer get player => widget.player;

  bool _repeatCheck = false;
  bool _shuffleCheck = false;

  @override
  void initState() {
    super.initState();
    _currentMusic = widget.music;
    _playerState = player.state;
    player.getDuration().then(
          (value) => setState(() {
            _duration = value;
          }),
        );
    player.getCurrentPosition().then(
          (value) => setState(() {
            _position = value;
          }),
        );
    _initStreams();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Slider(
          onChanged: (v) {
            final duration = _duration;
            if (duration == null) {
              return;
            }
            final position = v * duration.inMilliseconds;
            player.seek(Duration(milliseconds: position.round()));
          },
          value: (_position != null &&
                  _duration != null &&
                  _position!.inMilliseconds > 0 &&
                  _position!.inMilliseconds < _duration!.inMilliseconds)
              ? _position!.inMilliseconds / _duration!.inMilliseconds
              : 0.0,
        ),
        Text(
          _position != null
              ? '$_positionText / $_durationText'
              : _duration != null
                  ? _durationText
                  : '',
          style: const TextStyle(fontSize: 16.0),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: const Key('prev_button'),
              onPressed: _prev,
              iconSize: 44.0,
              icon: const Icon(Icons.skip_previous),
              color: color,
            ),
            IconButton(
              key: const Key('play_button'),
              onPressed: _isPlaying ? null : _play,
              iconSize: 44.0,
              icon: const Icon(Icons.play_arrow),
              color: color,
            ),
            IconButton(
              key: const Key('pause_button'),
              onPressed: _isPlaying ? _pause : null,
              iconSize: 44.0,
              icon: const Icon(Icons.pause),
              color: color,
            ),
            IconButton(
              key: const Key('stop_button'),
              onPressed: _isPlaying || _isPaused ? _stop : null,
              iconSize: 44.0,
              icon: const Icon(Icons.stop),
              color: color,
            ),
            IconButton(
              key: const Key('next_button'),
              onPressed: _next,
              iconSize: 44.0,
              icon: const Icon(Icons.skip_next),
              color: color,
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              key: const Key('repeat_button'),
              onPressed: _repeat,
              iconSize: 44.0,
              icon: const Icon(Icons.repeat),
              color: _repeatCheck == true ? Colors.amberAccent : color ,
            ),
            IconButton(
              key: const Key('shuffle_button'),
              onPressed: _shuffle,
              iconSize: 44.0,
              icon: const Icon(Icons.shuffle),
              color: _shuffleCheck == true ? Colors.amberAccent : color ,
            ),
          ],
        ),
      ],
    );
  }

  void _initStreams() {
    _durationSubscription = player.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _positionSubscription = player.onPositionChanged.listen(
      (p) => setState(() => _position = p),
    );

    _playerCompleteSubscription = player.onPlayerComplete.listen((event) async {
      if (_repeatCheck) {
        var dir = await getApplicationDocumentsDirectory();
        setState(() {
          _position = const Duration(milliseconds: 1);
          var path = '${dir.path}/${_currentMusic.name}';
          player.setSourceDeviceFile(path).then((value) => player.resume());
        });
      } else {
        _position = const Duration(milliseconds: 1);
        _next().then((value) {
          player.resume();
        });
      }
    });

    _playerStateChangeSubscription =
        player.onPlayerStateChanged.listen((state) {
      setState(() {
        _playerState = state;
      });
    });
  }

  Future<void> _play() async {
    final position = _position;
    if (position != null && position.inMilliseconds > 0) {
      await player.seek(position);
    }

    await player.resume();
    setState(() => _playerState = PlayerState.playing);
  }

  Future<void> _pause() async {
    await player.pause();
    setState(() => _playerState = PlayerState.paused);
  }

  Future<void> _repeat() async {
    setState(() {
      if (_repeatCheck) {
        _repeatCheck = false;
      } else {
        _repeatCheck = true;
      }
    });
  }

  Future<void> _shuffle() async {
    setState(() {
      if (_shuffleCheck) {
        _shuffleCheck = false;
      } else {
        _shuffleCheck = true;
      }
    });
  }

  Future<void> _prev() async {
    // 이전곡 재생
    var musics = await MusicDatabase(widget.database).getMusic();
    var dir = await getApplicationDocumentsDirectory();
    for (int i = 0; i < musics.length; i++) {
      if (musics[i]['name'] == widget.music.name && i != 0) {
        setState(() {
          _currentMusic = Music(
              musics[i - 1]['name'],
              musics[i - 1]['composer'],
              musics[i - 1]['tag'],
              musics[i - 1]['category'],
              musics[i - 1]['size'],
              musics[i - 1]['type'],
              musics[i - 1]['downloadUrl'],
              musics[i - 1]['imageDownloadUrl']);
          var path = '${dir.path}/${_currentMusic.name}';
          player.setSourceDeviceFile(path);
          widget.callback(_currentMusic);
        });
        break;
      } else if (musics[i]['name'] == widget.music.name && i == 0) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('제일 처음 곡이예요')));
      }
    }
  }

  Future<void> _next() async {
    // 다음곡 재생
    var musics = await MusicDatabase(widget.database).getMusic();
    if(_shuffleCheck) {
      musics.shuffle();
    }
    var dir = await getApplicationDocumentsDirectory();
    for (int i = 0; i < musics.length; i++) {
      if (musics[i]['name'] == widget.music.name && i + 1 < musics.length) {
        setState(() {
          _currentMusic = Music(
              musics[i + 1]['name'],
              musics[i + 1]['composer'],
              musics[i + 1]['tag'],
              musics[i + 1]['category'],
              musics[i + 1]['size'],
              musics[i + 1]['type'],
              musics[i + 1]['downloadUrl'],
              musics[i + 1]['imageDownloadUrl']);
          var path = '${dir.path}/${_currentMusic.name}';
          player.setSourceDeviceFile(path);
          widget.callback(_currentMusic);
        });
        break;
      } else if (musics[i]['name'] == widget.music.name &&
          i + 1 == musics.length) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('제일 끝 곡이예요')));
      }
    }
  }

  Future<void> _stop() async {
    await player.stop();
    setState(() {
      _playerState = PlayerState.stopped;
      _position = Duration.zero;
    });
  }
}
