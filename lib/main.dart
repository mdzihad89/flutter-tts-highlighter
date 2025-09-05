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
    "ফ্লাটার একটি মুক্ত উন্মুক্ত সফটওয়্যার উন্নয়ন সরঞ্জাম যা গুগল তৈরি করেছে। এটি ব্যবহার করে একসাথে একাধিক প্ল্যাটফর্মের জন্য অ্যাপ্লিকেশন তৈরি করা যায়। একই কোড থেকে অ্যান্ড্রয়েড, আইফোন, লিনাক্স, ম্যাক, উইন্ডোজ এবং এমনকি ওয়েবেও চালানো যায় এমন অ্যাপ তৈরি সম্ভব। দুই হাজার আঠারো সালে যখন প্রথম ফ্লাটার প্রকাশিত হয় তখন মানুষ ভেবেছিল এটি শুধুমাত্র মোবাইলের জন্য ব্যবহার হবে। কিন্তু শুরু থেকেই এর লক্ষ্য ছিল অনেক বড়। এর উদ্দেশ্য হলো এমন একটি বহনযোগ্য সরঞ্জাম দেওয়া, যা দিয়ে যেকোনো যন্ত্রে সুন্দর ব্যবহারকারীর অভিজ্ঞতা তৈরি করা যায়। ফ্লাটারে রয়েছে আধুনিক প্রতিক্রিয়াশীল কাঠামো, শক্তিশালী অঙ্কন ইঞ্জিন এবং প্রচুর প্রস্তুত উপাদান, যা ব্যবহার করে সহজেই ব্যবহারকারীর জন্য আকর্ষণীয় নকশা তৈরি করা যায়।",
    "ডার্ট নামের প্রোগ্রামিং ভাষাটি ফ্লাটারের ভিতের মতো কাজ করে। ডার্ট হলো এমন একটি ভাষা যা দ্রুত এবং কার্যকরী অ্যাপ বানানোর জন্য বিশেষভাবে তৈরি। গুগল এই ভাষাটি তৈরি করেছে এবং এটি মোবাইল, কম্পিউটার, সার্ভার এমনকি ওয়েবেও ব্যবহার করা যায়। ডার্ট হলো অবজেক্ট ভিত্তিক ভাষা যেখানে শ্রেণি, উত্তরাধিকার, পুনর্ব্যবহারযোগ্য অংশ এবং স্বয়ংক্রিয় মেমরি পরিস্কার করার সুবিধা রয়েছে। এই ভাষা সরাসরি যন্ত্রের ভাষায় বা আবার প্রয়োজনে জাভাস্ক্রিপ্টে রূপান্তরিত হতে পারে। ডার্টের সবচেয়ে জনপ্রিয় বৈশিষ্ট্য হলো এটি একসাথে অনেক কাজ চালাতে পারে। ভবিষ্যত বা প্রবাহের মতো ধরণের বৈশিষ্ট্য ব্যবহার করে খুব সহজে এমন প্রোগ্রাম লেখা যায় যা একদিকে ব্যবহারকারীর আদেশে দ্রুত সাড়া দেয় আবার অন্যদিকে পিছনে জটিল কাজ চালিয়ে যায়।",
    "ফ্লাটারের সবচেয়ে শক্তিশালী দিক হলো এর বিশাল উপাদান ভান্ডার। এখানে প্রায় সবকিছুই একটি উপাদান, যেমন একটি সাধারণ লেখা, একটি বোতাম বা আবার অনেক জটিল নকশার কাঠামো। এই উপাদানগুলো একটি গাছের মতো সাজানো থাকে, যেখানে প্রতিটি শাখা একটি অংশকে উপস্থাপন করে। উপাদান দু’ধরনের হতে পারে। একটি হলো স্থির উপাদান, যা কখনো পরিবর্তন হয় না। আরেকটি হলো পরিবর্তনশীল উপাদান, যা সময়ের সাথে সাথে ভিন্ন হতে পারে। এই ধরনের ঘোষণামূলক পদ্ধতি ব্যবহার করে পুরো নকশা তৈরি করা হয়। এর ফলে ডেভেলপাররা ছোট ছোট অংশ জুড়ে খুব বড় নকশা তৈরি করতে পারে এবং পুরো কোড সহজে পড়া ও রক্ষণাবেক্ষণ করা যায়।"
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
    _flutterTts.setLanguage("bn-BD");
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setPitch(1.0);
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
