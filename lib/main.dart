// 🔧 最初に必要なimport（すべてファイルの先頭）
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 🔧 main関数とルーティング処理
void main() {
  runApp(
    MaterialApp(
      title: 'おっぴろゲーム',
      theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: _handleInitialRoute(),
    ),
  );
}

Widget _handleInitialRoute() {
  final uri = Uri.base;
  final dataParam = uri.queryParameters['data'];

  if (uri.path == '/result' && dataParam != null) {
    try {
      final decoded = utf8.decode(base64Url.decode(dataParam));
      final resultMap = jsonDecode(decoded);

      final List<String> playerNames = List<String>.from(resultMap['players']);
      final List<String> selectedTraits = List<String>.from(
        resultMap['traits'],
      );

      final selfRatings = (resultMap['self'] as List)
          .map<List<double>>(
            (row) => (row as List).map((v) => (v as num).toDouble()).toList(),
          )
          .toList();

      final otherRatings = (resultMap['other'] as List)
          .map<List<List<double>>>(
            (outer) => (outer as List)
                .map<List<double>>(
                  (inner) => (inner as List)
                      .map((v) => (v as num).toDouble())
                      .toList(),
                )
                .toList(),
          )
          .toList();

      return ResultScreen(
        playerNames: playerNames,
        selectedTraits: selectedTraits,
        selfRatings: selfRatings,
        otherRatings: otherRatings,
      );
    } catch (e) {
      return _errorScreen('URLのデータが読み取れませんでした。');
    }
  } else {
    return OppiroGameApp();
  }
}

Widget _errorScreen(String message) {
  return Scaffold(
    appBar: AppBar(title: Text('エラー')),
    body: Center(child: Text(message)),
  );
}

// 🔧 通常時のアプリ起動用
class OppiroGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'おっぴろゲーム',
      theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: TopScreen(), // ← ここはあなたのトップ画面に合わせて
    );
  }
}

final Map<String, List<String>> traitCategories = {
  '基本性格': [
    '内向的 ↔ 外交的',
    '控えめ ↔ 自己主張強め',
    '慎重派 ↔ チャレンジ精神旺盛',
    'のんびり屋 ↔ テキパキ派',
    '空気読む ↔ 自由人',
    '一人好き ↔ みんなといたい',
    '負けず嫌い ↔ 譲るタイプ',
    '受け身 ↔ 主導的',
    '感情隠す ↔ 表情豊か',
    '冷静沈着 ↔ 感情的になりがち',
    '我慢強い ↔ すぐ爆発する',
    '細かい ↔ おおらか',
    'ルール重視 ↔ 自由重視',
    '他人優先 ↔ 自分優先',
    '黙ってる ↔ よくしゃべる',
    '好きなこと優先 ↔ やるべきこと優先',
    '安定志向 ↔ 変化を楽しむ',
    '白黒つけたい ↔ どっちでもいい派',
    '競争好き ↔ 協力好き',
    '一気にやる ↔ ちょっとずつ派',
    '人に流されやすい ↔ 自分を貫く',
    '完璧目指す ↔ 7割で満足',
    '短期集中 ↔ 長期勝負',
    'なんとかなる派 ↔ 準備しないと不安',
    '正面突破 ↔ うまく立ち回る',
    '一人で抱える ↔ すぐ相談する',
    '余白あると安心 ↔ 詰め込みたい',
    '気にしすぎ ↔ 気にしなさすぎ',
    'すぐ行動 ↔ まず情報収集',
    '安心第一 ↔ ドキドキ重視',
  ],
  '思考タイプ': [
    '理論派 ↔ 感覚派',
    '思考型 ↔ 直感型',
    '知識重視 ↔ 経験重視',
    '計画的 ↔ 行き当たりばったり',
    '正論派 ↔ 共感派',
    'リアリスト ↔ ロマンチスト',
    '順応型 ↔ 自己表現型',
    '論破好き ↔ 話し合い派',
    '失敗気にする ↔ 気にしない',
    '自信ない ↔ 自信満々',
    '直感ひらめき型 ↔ 理屈で詰める型',
    '数値重視 ↔ 雰囲気重視',
    '情報集めてから考える ↔ とりあえず考え始める',
    '話して整理 ↔ 書いて整理',
    '先を見て動く ↔ 今を大事に動く',
    '考えすぎて動けない ↔ 考えないで突っ走る',
    '正解を探す ↔ 自分の納得を探す',
    '思い立ったらすぐメモ ↔ 脳内保存派',
    '論理で説得 ↔ 熱意で説得',
    '多数派参考にする ↔ 少数派でも関係なし',
  ],
  '対人関係': [
    '人見知り ↔ 初対面OK',
    '話し好き ↔ 聞き上手',
    '遠慮がち ↔ イジリ全開',
    'マイペース ↔ 思いやり派',
    '黙ってられる ↔ すぐ言いたがる',
    '素で面白い ↔ 狙ってスベる',
    '自然体 ↔ キャラ作り気味',
    '飲み会静か ↔ ムードメーカー',
    '一匹狼 ↔ 群れがち',
    '共感薄い ↔ すぐ感情移入',
    'S ↔ M',
    '手繋ぐ ↔ 繋がない',
    '人前でイチャつける ↔ むり',
    '相手の買い物付き合える ↔ むり',
    '映画泣く ↔ 我慢する',
    '仲良くなるのに時間かかる ↔ 一瞬で仲良くなる',
    '相談されやすい ↔ 話しかけにくい',
    '褒められると伸びる ↔ 指摘されると伸びる',
    '場を和ませるタイプ ↔ 緊張感あるタイプ',
    '感情移入しやすい ↔ 一歩引いて見てる',
    '人の話すぐ信じる ↔ 疑ってかかる',
    '距離を保ちたい ↔ 距離つめたい',
    'LINE長文派 ↔ 一言派',
    '敬語でいたい ↔ すぐタメ口',
    '聞き役に回りがち ↔ 話す側になりがち',
    '気まずくても話す ↔ 無言で察する',
    '自分の話から入る ↔ 相手の話を先に聞く',
    '仲裁役になりがち ↔ 火種になるほう',
    'テンション高めで近づく ↔ 静かに仲良くなる',
    '八方美人になりがち ↔ 好き嫌いはっきり派',
  ],
  'ユーモア': [
    'ツッコミ派 ↔ ボケ倒す派',
    '引き笑い ↔ 大爆笑',
    '怒っても無表情 ↔ すぐ顔に出る',
    '一人ツッコミ ↔ 人にすぐツッコミ',
    '冷静キャラ ↔ やらかしキャラ',
    'せっかち ↔ まったり',
    'おしゃれ重視 ↔ 実用重視',
    '多趣味 ↔ 一極集中型',
    '話題提供派 ↔ 雰囲気担当',
    'カメラ係 ↔ 映え担当',
    'ボケたがる ↔ ツッコみたがる',
    '沈黙が耐えられない ↔ 無言もOK',
    'ネタ仕込む派 ↔ アドリブ派',
    '恥を笑いにできる ↔ 恥は封印したい',
    'テンションで笑い取る ↔ 間と表情で勝負',
    '人の笑いに乗るの得意 ↔ 自分で沸かせたい',
    'ノリツッコミやる ↔ 見てる派',
    'モノマネ得意 ↔ 無理無理無理',
    'イジられ上手 ↔ イジる側専門',
    '変顔いける ↔ 無理（死ぬ）',
  ],
  'デートタイプ': [
    '車は運転すき ↔ 助手席',
    '夜景すき ↔ きらい',
    '夜デート ↔ 昼間デート', // ← ここに移動！
    '山派 ↔ 海派',
    'ジェットコースター ↔ 観覧車',
    '京都チック ↔ ディズニーチック',
    '写真とる ↔ とらない',
    '長電話できる ↔ 苦手',
    '先に好きって言いたい ↔ 言われたい',
    'LINE毎日したい ↔ 用があるときだけ',
    '別行動OK派 ↔ 常に一緒がいい',
    '待ち合わせ早めに着く ↔ ギリ派',
    'イベントは大事にする ↔ ふつうの日でいい',
    '外食多め ↔ おうち派',
    'ペアルックOK ↔ 絶対ムリ',
    '匂いフェチ ↔ 声フェチ',
    'ハグ好き ↔ ハグ苦手',
  ],
};

// ---------------- トップ画面 ----------------
class TopScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/title_image.png', width: 300),
              SizedBox(height: 24),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🕹 バージョン履歴',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('25/07/06 ver1.0.0 初期版'),
                      Text('25/07/07 ver1.1.0 結果表示＆採点方法を改善'),
                      Text('25/07/11 ver1.2.0 カテゴリ選択及び項目数追加'),
                      Text('25/07/14 ver1.2.1 プレイヤー設定画面配置変更'),
                      Text('25/07/19 ver1.3.0 結果URL共有機能を追加'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NameInputScreen()),
                  );
                },
                child: Text('スタート', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- 名前入力画面 ----------------
class NameInputScreen extends StatefulWidget {
  @override
  _NameInputScreenState createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  int playerCount = 2;
  int traitCount = 10;
  List<TextEditingController> controllers = [];

  // カテゴリ選択状態
  Map<String, bool> selectedCategories = {
    '基本性格': true,
    '思考タイプ': true,
    '対人関係': true,
    'ユーモア': true,
    'デートタイプ': true,
  };

  @override
  void initState() {
    super.initState();
    updateControllers(playerCount);
  }

  void updateControllers(int count) {
    setState(() {
      playerCount = count;
      controllers = List.generate(count, (index) => TextEditingController());
    });
  }

  // 選ばれたカテゴリからランダムに性格項目を抽出
  List<String> getRandomTraits(int count) {
    final selectedTraits = selectedCategories.entries
        .where((entry) => entry.value)
        .expand((entry) => traitCategories[entry.key]!)
        .toList();

    selectedTraits.shuffle();
    return selectedTraits.take(count).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('プレイヤー設定'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 人数選択
            Row(
              children: [
                Text('参加人数を選んでね:'),
                SizedBox(width: 16),
                DropdownButton<int>(
                  value: playerCount,
                  items: [2, 3, 4, 5].map((num) {
                    return DropdownMenuItem(value: num, child: Text('$num 人'));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) updateControllers(value);
                  },
                ),
              ],
            ),
            SizedBox(height: 16),

            // 2. 名前入力欄
            Text('プレイヤー名を入力してね:'),
            ...List.generate(playerCount, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: controllers[index],
                  decoration: InputDecoration(
                    labelText: 'プレイヤー ${index + 1} の名前',
                    border: OutlineInputBorder(),
                  ),
                ),
              );
            }),
            SizedBox(height: 24),

            // 3. 項目数選択
            Row(
              children: [
                Text('項目数を選んでね:'),
                SizedBox(width: 16),
                DropdownButton<int>(
                  value: traitCount,
                  items: List.generate(6, (i) => i + 5).map((num) {
                    return DropdownMenuItem(value: num, child: Text('$num 項目'));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        traitCount = value;
                      });
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 16),

            // 4. カテゴリ選択チェックボックス
            Text('カテゴリを選んでね（複数選択可能）:'),
            ...selectedCategories.keys.map((category) {
              return CheckboxListTile(
                title: Text(category),
                value: selectedCategories[category],
                onChanged: (bool? value) {
                  setState(() {
                    selectedCategories[category] = value ?? false;
                  });
                },
              );
            }).toList(),
            SizedBox(height: 24),

            // 5. 次へボタン
            Center(
              child: ElevatedButton(
                onPressed: () {
                  List<String> names = controllers.map((c) => c.text).toList();
                  List<String> selectedTraits = getRandomTraits(traitCount);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelfRatingScreen(
                        playerNames: names,
                        selectedTraits: selectedTraits,
                      ),
                    ),
                  );
                },
                child: Text('次へ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- 自己評価画面 ----------------
class SelfRatingScreen extends StatefulWidget {
  final List<String> playerNames;
  final List<String> selectedTraits; // ← 追加

  const SelfRatingScreen({
    required this.playerNames,
    required this.selectedTraits, // ← 追加
  });

  @override
  _SelfRatingScreenState createState() => _SelfRatingScreenState();
}

class _SelfRatingScreenState extends State<SelfRatingScreen> {
  int currentIndex = 0;
  List<List<double>> selfRatings = [];

  late List<double> currentRatings;

  @override
  void initState() {
    super.initState();
    currentRatings = List.filled(widget.selectedTraits.length, 5.0);
  }

  void onNext() {
    selfRatings.add(List.from(currentRatings));
    if (currentIndex + 1 < widget.playerNames.length) {
      setState(() {
        currentIndex++;
        currentRatings = List.filled(widget.selectedTraits.length, 5.0);
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtherRatingFlowScreen(
            playerNames: widget.playerNames,
            selfRatings: selfRatings,
            selectedTraits: widget.selectedTraits, // ← 追加
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String name = widget.playerNames[currentIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text('$name の自己評価'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.selectedTraits.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.selectedTraits[index],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Slider(
                        value: currentRatings[index],
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: currentRatings[index].round().toString(),
                        onChanged: (value) {
                          setState(() {
                            currentRatings[index] = value;
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: onNext,
              child: Text('決定'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- 他者評価の流れ管理 ----------------
class OtherRatingFlowScreen extends StatefulWidget {
  final List<String> playerNames;
  final List<List<double>> selfRatings;
  final List<String> selectedTraits;

  const OtherRatingFlowScreen({
    required this.playerNames,
    required this.selfRatings,
    required this.selectedTraits,
  });

  @override
  _OtherRatingFlowScreenState createState() => _OtherRatingFlowScreenState();
}

class _OtherRatingFlowScreenState extends State<OtherRatingFlowScreen> {
  List<Map<String, int>> otherRatingQueue = [];
  int currentStep = 0;

  late List<List<List<double>>> otherRatings;

  @override
  void initState() {
    super.initState();

    int n = widget.playerNames.length;
    int t = widget.selectedTraits.length;

    // 他者評価キュー作成（自分自身を除く組み合わせ）
    for (int target = 0; target < n; target++) {
      for (int rater = 0; rater < n; rater++) {
        if (rater != target) {
          otherRatingQueue.add({'target': target, 'rater': rater});
        }
      }
    }

    // 評価結果の初期化 [n][n][t]
    otherRatings = List.generate(
      n,
      (_) => List.generate(n, (_) => List.filled(t, 0.0)),
    );
  }

  void onRated(List<double> ratings) {
    int target = otherRatingQueue[currentStep]['target']!;
    int rater = otherRatingQueue[currentStep]['rater']!;
    otherRatings[target][rater] = ratings;

    if (currentStep + 1 < otherRatingQueue.length) {
      setState(() {
        currentStep++;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            playerNames: widget.playerNames,
            selfRatings: widget.selfRatings,
            otherRatings: otherRatings,
            selectedTraits: widget.selectedTraits, // ← ここで渡す！
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var current = otherRatingQueue[currentStep];
    return OtherRatingScreen(
      key: UniqueKey(),
      playerNames: widget.playerNames,
      targetIndex: current['target']!,
      raterIndex: current['rater']!,
      onRated: onRated,
      selectedTraits: widget.selectedTraits, // ← 修正ポイント！
    );
  }
}

// ---------------- 他者評価画面 ----------------
class OtherRatingScreen extends StatefulWidget {
  final List<String> playerNames;
  final int targetIndex;
  final int raterIndex;
  final void Function(List<double>) onRated;
  final List<String> selectedTraits; // ⭐ 選ばれた性格項目を受け取る

  const OtherRatingScreen({
    Key? key,
    required this.playerNames,
    required this.targetIndex,
    required this.raterIndex,
    required this.onRated,
    required this.selectedTraits,
  }) : super(key: key);

  @override
  _OtherRatingScreenState createState() => _OtherRatingScreenState();
}

class _OtherRatingScreenState extends State<OtherRatingScreen> {
  late List<double> ratings;

  @override
  void initState() {
    super.initState();
    ratings = List.filled(widget.selectedTraits.length, 5.0);
  }

  @override
  Widget build(BuildContext context) {
    String target = widget.playerNames[widget.targetIndex];
    String rater = widget.playerNames[widget.raterIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('$rater が $target を評価中'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.selectedTraits.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.selectedTraits[index],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Slider(
                        value: ratings[index],
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: ratings[index].round().toString(),
                        onChanged: (value) {
                          setState(() {
                            ratings[index] = value;
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                widget.onRated(ratings);
              },
              child: Text('決定'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- 結果画面 ----------------
class ResultScreen extends StatelessWidget {
  final List<String> playerNames;
  final List<List<double>> selfRatings;
  final List<List<List<double>>> otherRatings;
  final List<String> selectedTraits;

  ResultScreen({
    required this.playerNames,
    required this.selfRatings,
    required this.otherRatings,
    required this.selectedTraits,
  });

  @override
  Widget build(BuildContext context) {
    final int playerCount = playerNames.length;
    final int traitCount = selectedTraits.length;

    List<double> selfScores = List.filled(playerCount, 0);
    List<double> understandScores = List.filled(playerCount, 0);

    // スコア計算
    for (int i = 0; i < playerCount; i++) {
      double selfDiffTotal = 0;
      double understandDiffTotal = 0;

      for (int k = 0; k < traitCount; k++) {
        for (int j = 0; j < playerCount; j++) {
          if (j == i) continue;
          // 自己開示差
          selfDiffTotal += (selfRatings[i][k] - otherRatings[i][j][k]).abs();
          // 他者理解差
          understandDiffTotal += (selfRatings[j][k] - otherRatings[j][i][k])
              .abs();
        }
      }

      double maxDiff = 9.0 * (playerCount - 1) * traitCount;
      selfScores[i] = (1 - (selfDiffTotal / maxDiff)) * 100;
      understandScores[i] = (1 - (understandDiffTotal / maxDiff)) * 100;
    }

    int bestSelf = selfScores.indexWhere((s) => s == selfScores.reduce(max));
    int bestUnderstand = understandScores.indexWhere(
      (s) => s == understandScores.reduce(max),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('結果発表'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              '✨ 自己開示王: ${playerNames[bestSelf]}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '✨ 他者理解王: ${playerNames[bestUnderstand]}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('🔍 各プレイヤーのスコア', style: TextStyle(fontSize: 18)),
            ...List.generate(playerCount, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playerNames[i],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('自己開示スコア: ${selfScores[i].toStringAsFixed(1)}%'),
                    Text('他者理解スコア: ${understandScores[i].toStringAsFixed(1)}%'),
                    SizedBox(height: 4),
                    Text(
                      '「自己評価と他者評価の比較」',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...List.generate(traitCount, (k) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Text('${k + 1}. ${selectedTraits[k]}'),
                          Row(
                            children: [
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: selfRatings[i][k] / 10,
                                  color: Colors.blue,
                                  backgroundColor: Colors.blue.shade100,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '自分: ${selfRatings[i][k].toStringAsFixed(1)}',
                              ),
                            ],
                          ),
                          ...List.generate(playerCount, (j) {
                            if (j == i) return SizedBox.shrink();
                            return Row(
                              children: [
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: otherRatings[i][j][k] / 10,
                                    color: Colors.orange,
                                    backgroundColor: Colors.orange.shade100,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '${playerNames[j]}: ${otherRatings[i][j][k].toStringAsFixed(1)}',
                                ),
                              ],
                            );
                          }),
                        ],
                      );
                    }),
                  ],
                ),
              );
            }),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final url = generateResultUrl(
                    playerNames: playerNames,
                    selfRatings: selfRatings,
                    otherRatings: otherRatings,
                    selectedTraits: selectedTraits,
                  );

                  await Clipboard.setData(ClipboardData(text: url));
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('結果URLをコピーしました！')));
                },
                child: Text('結果を共有（URLコピー）'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 12),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: Text('トップに戻る'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// URLを生成する関数（ResultScreenの下に追加！）
String generateResultUrl({
  required List<String> playerNames,
  required List<List<double>> selfRatings,
  required List<List<List<double>>> otherRatings,
  required List<String> selectedTraits,
}) {
  final data = {
    'players': playerNames,
    'traits': selectedTraits,
    'self': selfRatings,
    'other': otherRatings,
  };

  final jsonString = jsonEncode(data);
  final encoded = base64Url.encode(utf8.encode(jsonString));
  return 'https://tohhidockson.github.io/oppiro_game_web/result?data=$encoded';
}
