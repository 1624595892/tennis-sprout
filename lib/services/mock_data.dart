import 'dart:math';
import '../models/vocabulary.dart';
import '../models/skill_tree.dart';
import '../models/practice_log.dart';
import '../models/match_record.dart';
import '../models/coach_feedback.dart';
import '../models/daily_status.dart';

class MockData {
  MockData._();

  static List<TennisVocabulary> generateVocabulary() {
    return [
      TennisVocabulary(
        id: 'v001',
        wordEn: 'Forehand',
        wordZh: '正手击球',
        illustrationAsset: 'assets/images/illustrations/forehand.png',
        pronunciationUrl: 'mock://forehand.mp3',
        principleEn:
            'The forehand is executed by swinging the racket across the body with the dominant hand. Power comes from hip rotation and weight transfer from back foot to front foot.',
        principleZh:
            '正手击球是用持拍手将球拍在身体一侧挥出，力量来自于髋部旋转和重心从后脚转移到前脚。',
        triviaEn:
            'Roger Federer\'s forehand is nicknamed "The Liquid Whip" for its smooth, whip-like acceleration.',
        triviaZh:
            '费德勒的正手被称为"液态鞭子"，因其像鞭子一样流畅的加速而得名。',
        category: VocabCategory.technique,
      ),
      TennisVocabulary(
        id: 'v002',
        wordEn: 'Backhand',
        wordZh: '反手击球',
        illustrationAsset: 'assets/images/illustrations/backhand.png',
        pronunciationUrl: 'mock://backhand.mp3',
        principleEn:
            'A shot hit with the back of the dominant hand facing the ball. Can be one-handed (more reach) or two-handed (more stability).',
        principleZh:
            '用持拍手背面对球击球。单反（更大范围）或双反（更稳定）。',
        triviaEn:
            'Stan Wawrinka\'s one-handed backhand is considered one of the most powerful in tennis history.',
        triviaZh:
            '瓦林卡的单手反拍被认为是网球史上最有力的反拍之一。',
        category: VocabCategory.technique,
      ),
      TennisVocabulary(
        id: 'v003',
        wordEn: 'Volley',
        wordZh: '截击',
        illustrationAsset: 'assets/images/illustrations/volley.png',
        pronunciationUrl: 'mock://volley.mp3',
        principleEn:
            'A shot hit before the ball bounces on the ground, usually executed near the net with a short punch motion.',
        principleZh:
            '在球落地之前击出的球，通常在网前用短促的推击动作完成。',
        triviaEn:
            'The serve-and-volley style dominated Wimbledon throughout the \'80s and \'90s.',
        triviaZh:
            '发球上网打法在80-90年代统治着温布尔登。',
        category: VocabCategory.technique,
      ),
      TennisVocabulary(
        id: 'v004',
        wordEn: 'Topspin',
        wordZh: '上旋球',
        illustrationAsset: 'assets/images/illustrations/topspin.png',
        pronunciationUrl: 'mock://topspin.mp3',
        principleEn:
            'Forward rotation applied to the ball by brushing upward at contact. Causes the ball to dip sharply and bounce high.',
        principleZh:
            '通过向上刷球施加的前旋转，使球急速下坠并高高弹起。',
        triviaEn:
            'Rafael Nadal\'s topspin forehand generates over 3,200 RPM — more than double the ATP average.',
        triviaZh:
            '纳达尔的正手上旋球转速超过3200 RPM — 是ATP球员平均水平的两倍多。',
        category: VocabCategory.technique,
      ),
      TennisVocabulary(
        id: 'v005',
        wordEn: 'Ace',
        wordZh: 'Ace球',
        illustrationAsset: 'assets/images/illustrations/ace.png',
        pronunciationUrl: 'mock://ace.mp3',
        principleEn:
            'A legal serve not touched by the returner, winning the point instantly. Requires precise placement and high speed.',
        principleZh:
            '合法发球未被接发方触及，直接得分。需要精准的落点和高速的发球。',
        triviaEn:
            'Ivo Karlovic holds the record for most aces in a best-of-3 match: 45 aces in Halle 2015.',
        triviaZh:
            '卡洛维奇保持着三盘两胜制比赛Ace球纪录：2015年哈雷站发出45记Ace。',
        category: VocabCategory.technique,
      ),
      TennisVocabulary(
        id: 'v006',
        wordEn: 'Approach Shot',
        wordZh: '随球上网',
        illustrationAsset: 'assets/images/illustrations/approach.png',
        pronunciationUrl: 'mock://approach_shot.mp3',
        principleEn:
            'A shot hit while moving toward the net, setting up a volley. Typically hit deep to the opponent\'s weaker side.',
        principleZh:
            '在向网前移动时击出的球，为随后的截击做准备。通常会打向对手较弱的一侧深区。',
        triviaEn:
            'Pete Sampras built his entire net game around a devastating running forehand approach.',
        triviaZh:
            '桑普拉斯整个网前体系都建立在毁灭性的跑动正手随球上网之上。',
        category: VocabCategory.tactics,
      ),
      TennisVocabulary(
        id: 'v007',
        wordEn: 'Drop Shot',
        wordZh: '放小球',
        illustrationAsset: 'assets/images/illustrations/dropshot.png',
        pronunciationUrl: 'mock://dropshot.mp3',
        principleEn:
            'A softly hit shot that barely clears the net and lands short. Best disguised with a normal backswing.',
        principleZh:
            '轻柔击打、勉强过网且落在前场的球。最好用正常的引拍动作来伪装。',
        triviaEn:
            'Carlos Alcaraz\'s drop shot is already legendary — he used it masterfully to win Wimbledon 2023.',
        triviaZh:
            '阿尔卡拉斯的放小球已经成了传说级别 — 他用这招在2023温网决赛中出神入化。',
        category: VocabCategory.tactics,
      ),
      TennisVocabulary(
        id: 'v008',
        wordEn: 'Tiebreak',
        wordZh: '抢七局',
        illustrationAsset: 'assets/images/illustrations/tiebreak.png',
        pronunciationUrl: 'mock://tiebreak.mp3',
        principleEn:
            'A game played when the set score reaches 6-6. Players alternate serves, first to 7 points (win by 2) wins the set.',
        principleZh:
            '当局分达到6-6时进行的决胜局。球员交替发球，先得7分且领先2分者赢得本盘。',
        triviaEn:
            'The longest tiebreak in Grand Slam history: 20-18, John McEnroe vs. Bjorn Borg, 1980 Wimbledon final.',
        triviaZh:
            '大满贯史上最长的抢七：20-18，麦肯罗 vs 博格，1980年温网决赛。',
        category: VocabCategory.rules,
      ),
      TennisVocabulary(
        id: 'v009',
        wordEn: 'Sweet Spot',
        wordZh: '甜区',
        illustrationAsset: 'assets/images/illustrations/sweetspot.png',
        pronunciationUrl: 'mock://sweetspot.mp3',
        principleEn:
            'The optimal area on the racket string bed that produces maximum power, control, and minimal vibration on impact.',
        principleZh:
            '球拍线床上最理想的击球区域，能产生最大的力量和控球，同时振动最小。',
        triviaEn:
            'Modern rackets have sweet spots up to 40% larger than wooden rackets from the 1970s.',
        triviaZh:
            '现代球拍的甜区比1970年代木质球拍大了多达40%。',
        category: VocabCategory.equipment,
      ),
      TennisVocabulary(
        id: 'v010',
        wordEn: 'Grand Slam',
        wordZh: '大满贯',
        illustrationAsset: 'assets/images/illustrations/grandslam.png',
        pronunciationUrl: 'mock://grandslam.mp3',
        principleEn:
            'The four most prestigious annual tennis tournaments: Australian Open, Roland Garros, Wimbledon, and US Open.',
        principleZh:
            '每年四项最负盛名的网球赛事：澳网、法网、温网和美网。',
        triviaEn:
            'A "Calendar Grand Slam" — winning all 4 in a single year — has only been achieved 6 times in history (most recently by Steffi Graf in 1988).',
        triviaZh:
            '"年度全满贯"——一年内赢下全部四项大满贯——历史上仅完成过6次（最近一次是1988年格拉芙）。',
        category: VocabCategory.culture,
      ),
      TennisVocabulary(
        id: 'v011',
        wordEn: 'Lob',
        wordZh: '挑高球',
        illustrationAsset: 'assets/images/illustrations/lob.png',
        pronunciationUrl: 'mock://lob.mp3',
        principleEn:
            'A high-arcing shot hit over the net player\'s head. Defensive lob when stretched wide; offensive lob to surprise an opponent at net.',
        principleZh:
            '弧线高高划过网前对手头顶的球。防守性挑高球用于被拉开时；进攻性挑高球用于出其不意地过顶。',
        triviaEn:
            'Andy Murray\'s defensive lob is widely considered the best in the modern game.',
        triviaZh:
            '安迪·穆雷的防守挑高球被广泛认为是现代网球中最出色的。',
        category: VocabCategory.technique,
      ),
      TennisVocabulary(
        id: 'v012',
        wordEn: 'Slice',
        wordZh: '切削球',
        illustrationAsset: 'assets/images/illustrations/slice.png',
        pronunciationUrl: 'mock://slice.mp3',
        principleEn:
            'A shot hit with backspin by cutting under the ball. Slice stays low, skids off the court, and is great for approach shots.',
        principleZh:
            '通过从球下方切削施加下旋的击球。切削球低平滑行，非常适合随球上网。',
        triviaEn:
            'Ash Barty\'s backhand slice was her secret weapon — it neutralized power hitters throughout her career.',
        triviaZh:
            '巴蒂的反手切削是她的秘密武器——整个职业生涯中都靠它化解力量型选手的攻势。',
        category: VocabCategory.technique,
      ),
    ];
  }

  static SkillTree generateSkillTree() {
    return SkillTree(branches: [
      SkillBranch(
        id: 'baseline',
        nameKey: 'baseline',
        leaves: [
          SkillLeaf(id: 'forehand', nameKey: 'forehand', level: 5.5),
          SkillLeaf(id: 'backhand', nameKey: 'backhand', level: 4.5),
        ],
      ),
      SkillBranch(
        id: 'net_play',
        nameKey: 'net_play',
        leaves: [
          SkillLeaf(id: 'volley', nameKey: 'volley', level: 3.5),
          SkillLeaf(id: 'overhead', nameKey: 'overhead', level: 4.0),
          SkillLeaf(id: 'approach_shot', nameKey: 'approach_shot', level: 3.0),
        ],
      ),
      SkillBranch(
        id: 'serve_return',
        nameKey: 'serve_return',
        leaves: [
          SkillLeaf(id: 'serve', nameKey: 'serve', level: 5.0),
          SkillLeaf(id: 'return', nameKey: 'return', level: 4.0),
        ],
      ),
    ]);
  }

  static List<PracticeLog> generatePractices() {
    final rand = Random(42);
    return List.generate(5, (i) {
      return PracticeLog(
        id: 'p${i + 1}',
        drillType: ['Forehand', 'Backhand', 'Serve', 'Volley', 'Footwork'][i],
        durationMinutes: [60, 45, 90, 30, 75][i],
        selfRating: rand.nextDouble() * 4 + 6, // 6-10
        notes: [
          'Focused on topspin consistency, felt good rhythm',
          'Still working on backhand down the line',
          'Serve toss is getting higher and more consistent',
          'Net approach timing needs improvement',
          'Ladder drills helped foot speed noticeably',
        ][i],
        createdAt: DateTime.now().subtract(Duration(days: i * 2)),
      );
    });
  }

  static List<MatchRecord> generateMatches() {
    return [
      MatchRecord(
        id: 'm001',
        opponentName: 'David Chen',
        scoreDisplay: '6-4, 3-6, 6-2',
        gamesWon: 15,
        gamesLost: 12,
        surface: CourtSurface.hard,
        winners: 18,
        unforcedErrors: 22,
        doubleFaults: 3,
        playedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      MatchRecord(
        id: 'm002',
        opponentName: 'Mike Li',
        scoreDisplay: '6-3, 6-4',
        gamesWon: 12,
        gamesLost: 7,
        surface: CourtSurface.clay,
        winners: 14,
        unforcedErrors: 15,
        doubleFaults: 2,
        playedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      MatchRecord(
        id: 'm003',
        opponentName: 'Sarah Wang',
        scoreDisplay: '4-6, 6-7',
        gamesWon: 10,
        gamesLost: 13,
        surface: CourtSurface.hard,
        winners: 12,
        unforcedErrors: 28,
        doubleFaults: 5,
        playedAt: DateTime.now().subtract(const Duration(days: 14)),
      ),
    ];
  }

  static List<CoachFeedback> generateCoachFeedbacks() {
    return [
      CoachFeedback(
        id: 'cf001',
        coachId: 'coach_001',
        coachName: 'Coach Emily',
        audioPath: 'mock://feedback1.mp3',
        audioDuration: const Duration(seconds: 45),
        transcriptText:
            'Great forehand rotation today! Your hip drive has improved a lot. Next session, focus on follow-through height for more topspin.',
        type: FeedbackType.technique,
        relatedLogId: 'p1',
      ),
      CoachFeedback(
        id: 'cf002',
        coachId: 'coach_001',
        coachName: 'Coach Emily',
        audioPath: 'mock://feedback2.mp3',
        audioDuration: const Duration(seconds: 32),
        transcriptText:
            'Match analysis: in the second set, you backed up too far behind the baseline against deep shots. Try stepping in and taking the ball on the rise to control the point.',
        type: FeedbackType.tactics,
        relatedLogId: 'm001',
        timedComments: [
          TimedComment(
            videoTimestamp: const Duration(seconds: 15),
            audioPath: 'mock://timed_comment_1.mp3',
            transcriptText: 'See your footwork here? Split step came too late.',
            audioDuration: const Duration(seconds: 8),
          ),
        ],
      ),
    ];
  }

  static List<DailyStatus> generateDailyHistory() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      return DailyStatus(
        date: date,
        photoPath: i == 1 ? 'mock://photo_${i + 1}.jpg' : null,
        isLivePhoto: i == 1,
        mood: Mood.values[i % Mood.values.length],
        checkedIn: i < 5, // last 5 days checked in
      );
    });
  }
}
