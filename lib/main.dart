import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const MyApp());
}

enum TtsState { playing, stopped, paused }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final FlutterTts _flutterTts = FlutterTts();
  final ScrollController _scrollController = ScrollController();
  final List<String> _sampleTexts = [
    "Flutter is an open-source UI software development kit created by Google. It is used to develop cross-platform applications for Android, iOS, Linux, macOS, Windows, Google Fuchsia, and the web from a single codebase. When Flutter 1.0 was introduced at the Flutter Live event in 2018, it was initially perceived primarily as a mobile framework. However, the vision for Flutter has always been much broader. The goal is to provide a portable toolkit for building beautiful user experiences wherever you might want to paint pixels on the screen. This includes mobile, web, desktop, and even embedded devices. The Flutter framework contains a modern reactive framework, a 2D rendering engine, and a rich set of widgets for building UIs.",
    "The Dart programming language is the foundation of Flutter. Dart is a client-optimized language for fast apps on any platform. It is developed by Google and is used to build mobile, desktop, server, and web applications. Dart is an object-oriented, class-based, garbage-collected language with C-style syntax. It can compile to either native code or JavaScript. The language supports interfaces, mixins, abstract classes, reified generics, and type inference. One of the most appreciated features of Dart is its support for asynchronous programming, with features like Futures and Streams, which are essential for building responsive and non-blocking applications that provide a smooth user experience.",
    "A key feature of Flutter is its extensive library of pre-built widgets. In Flutter, almost everything is a widget, from a simple button or text element to a complex layout structure. Widgets are organized in a tree hierarchy. Each widget is an immutable declaration of part of the user interface. Widgets can be divided into two main categories: stateless and stateful. A stateless widget is one that does not require mutable state. A stateful widget, on the other hand, maintains state that might change during the lifetime of the widget. This declarative approach to UI development, inspired by React, allows developers to build complex UIs by composing simple widgets, leading to a more predictable and maintainable codebase."
  ];
  late String _text;
  int _currentSampleIndex = 0;
  int _currentWordStart = 0;
  int _currentWordEnd = 0;
  int _pausedOffset = 0;
  TtsState _ttsState = TtsState.stopped;
  double _textContainerWidth = 0;

  @override
  void initState() {
    super.initState();
    _text = _sampleTexts[_currentSampleIndex];
    _initTts();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _flutterTts.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _pause();
    }
  }

  void _loadSample(int index) {
    _stop();
    setState(() {
      _currentSampleIndex = index;
      _text = _sampleTexts[index];
    });
  }

  void _initTts() {
    _flutterTts.setStartHandler(() {
      setState(() {
        _ttsState = TtsState.playing;
      });
    });

    _flutterTts.setProgressHandler((String text, int startOffset, int endOffset, String word) {
      setState(() {
        _currentWordStart = startOffset + _pausedOffset;
        _currentWordEnd = endOffset + _pausedOffset;
      });

      final textSpan = TextSpan(
        text: _text.substring(0, startOffset + _pausedOffset),
        style: const TextStyle(fontSize: 20.0),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: _textContainerWidth);

      final scrollOffset = textPainter.height;
      if (scrollOffset > 100) {
        final targetOffset = scrollOffset - 100;
        if (targetOffset > _scrollController.position.maxScrollExtent) {
          if (_scrollController.offset < _scrollController.position.maxScrollExtent) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        } else {
          _scrollController.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _ttsState = TtsState.stopped;
        _currentWordStart = 0;
        _currentWordEnd = 0;
        _pausedOffset = 0;
      });
    });

    _flutterTts.setErrorHandler((msg) {
      setState(() {
        _ttsState = TtsState.stopped;
        _currentWordStart = 0;
        _currentWordEnd = 0;
        _pausedOffset = 0;
      });
    });
  }

  Future<void> _speak() async {
    if (_ttsState == TtsState.paused) {
      setState(() {
        _ttsState = TtsState.playing;
      });
      await _flutterTts.speak(_text.substring(_pausedOffset));
    } else {
      _scrollController.jumpTo(0);
      setState(() {
        _pausedOffset = 0;
      });
      await _flutterTts.speak(_text);
    }
  }

  Future<void> _stop() async {
    await _flutterTts.stop();
    setState(() {
      _ttsState = TtsState.stopped;
      _currentWordStart = 0;
      _currentWordEnd = 0;
      _pausedOffset = 0;
    });
  }

  Future<void> _pause() async {
    await _flutterTts.pause();
    setState(() {
      _ttsState = TtsState.paused;
      _pausedOffset = _currentWordEnd;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Text-to-Speech', style:  TextStyle(fontSize: 20.0, color: Colors.white,fontWeight: FontWeight.bold),),
            const Text('Realtime word highlighting', style:  TextStyle(fontSize: 14.0, color: Colors.white),),
          ],
        ),
        elevation: 5,
        backgroundColor: Color(0xFF6750a6),

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 20,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _loadSample(0),
                  style: TextButton.styleFrom(
                    backgroundColor: _currentSampleIndex == 0 ? Color(0xFF6750a6) : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text("Sample 1"),
                ),
                ElevatedButton(
                  onPressed: () => _loadSample(1),
                  style: TextButton.styleFrom(
                    backgroundColor: _currentSampleIndex == 1 ? Color(0xFF6750a6) : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text("Sample 2"),
                ),
                ElevatedButton(
                  onPressed: () => _loadSample(2),
                  style: TextButton.styleFrom(
                    backgroundColor: _currentSampleIndex == 2 ? Color(0xFF6750a6) : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text("Sample 3"),
                )
              ],
            ),
            Container(
              height: 250,
              padding:  EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:  Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
                boxShadow:  [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 10,
                    spreadRadius: 5,
                    offset: const Offset(5, 5),
                  )


                ]

              ),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  _textContainerWidth = constraints.maxWidth;
                  return Column(
                    children: [
                      
                      Row(
                        children: [
                          Text("Live Speech",style: const TextStyle(fontSize: 18.0, color: Color(0xFF6750a6),fontWeight: FontWeight.bold),),
                          Spacer(),
                          Icon( _ttsState == TtsState.stopped ?Icons.volume_off_sharp: _ttsState == TtsState.paused?Icons.pause: Icons.volume_up,color: _ttsState == TtsState.stopped ?  Color(0xFF665e6b):_ttsState == TtsState.paused?Color(0xFFd15f02):Colors.green,),
                          SizedBox(width: 10,),
                          Text(_ttsState == TtsState.stopped?"Ready":_ttsState == TtsState.paused?"Paused": "Speaking",style:  TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0, color: _ttsState == TtsState.stopped?  Color(0xFF665e6b):_ttsState == TtsState.paused?Color(0xFFd15f02):Colors.green)),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 20.0, color: Color(0xFF665e6b)),
                              children: <TextSpan>[
                                TextSpan(text: _text.substring(0, _currentWordStart)),
                                TextSpan(
                                  text: _text.substring(_currentWordStart, _currentWordEnd),
                                  style: const TextStyle(
                                    backgroundColor: Color(0xFFd0bee6),
                                    fontWeight: FontWeight.bold,
                                    color:   Color(0xFF6750a6),
                                  ),
                                ),
                                TextSpan(text: _text.substring(_currentWordEnd)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _ttsState == TtsState.stopped ? _speak : null,
                  style: TextButton.styleFrom(backgroundColor:_ttsState == TtsState.stopped ?Color(0xFF6750a6): Colors.black26,fixedSize:  Size(120, 30)),
                  label: Text("Play",style: TextStyle(color: Colors.white)),
                  icon: Icon(Icons.play_arrow,color: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: _ttsState == TtsState.playing ? _pause : null,
                  style: TextButton.styleFrom(backgroundColor: _ttsState == TtsState.playing ?Color(0xFFd15f02):Colors.black26,fixedSize:  Size(120, 30)),
                  label: Text("Pause",style: TextStyle(color: Colors.white)),
                  icon: Icon(Icons.pause,color: Colors.white),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _ttsState == TtsState.paused ? _speak : null,
                  style: TextButton.styleFrom(backgroundColor:_ttsState == TtsState.paused ?Colors.green: Colors.black26,fixedSize:  Size(120, 30)),
                  label: Text("Resume",style: TextStyle(color: Colors.white)),
                  icon: Icon(Icons.play_arrow,color: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: _ttsState == TtsState.playing || _ttsState == TtsState.paused
                      ? _stop
                      : null,
                  style: TextButton.styleFrom(backgroundColor:_ttsState == TtsState.playing || _ttsState == TtsState.paused?Colors.red: Colors.black26,fixedSize:  Size(120, 30)),
                  label: Text("Stop",style: TextStyle(color: Colors.white),),
                  icon: Icon(Icons.stop,color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
