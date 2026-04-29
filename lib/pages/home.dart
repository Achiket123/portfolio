import 'dart:convert';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:http/http.dart' as http;
import 'package:jaspr/server.dart';
import 'package:jaspr_content/jaspr_content.dart';

@client
class Home extends StatefulComponent {
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  static const _githubUser = 'Achiket123';

  bool _loadingRepos = true;
  String? _repoError;
  List<_Repo> _repos = const [];

  final _featured = const [
    (
      title: 'Soundsalike',
      subtitle: 'Shazam Clone',
      description:
          'Audio-fingerprinting engine with Go backend and Flutter UI, handling 100+ concurrent identification requests.',
      tech: 'Go, Flutter, PostgreSQL',
      aliases: ['soundsalike', 'shazam-clone'],
    ),
    (
      title: 'InkBattle',
      subtitle: 'Scrabble-style Word Game',
      description:
          'Real-time 2-player game with matchmaking, leaderboard, and WebSocket sync averaging 300+ daily matches.',
      tech: 'Flutter, Node.js, PostgreSQL, WebSockets',
      aliases: ['inkbattle', 'ink-battle', 'scrabble'],
    ),
    (
      title: 'Mushin',
      subtitle: 'Productivity App Locker',
      description: 'Geo-aware app locker using Android location APIs that unlocks in greenery/outdoor contexts.',
      tech: 'Flutter, Android APIs, Geofencing',
      aliases: ['mushin'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadRepos();
  }

  Future<void> _loadRepos() async {
    final uri = Uri.parse(
      'https://api.github.com/users/$_githubUser/repos?sort=updated&per_page=100',
    );

    try {
      final response = await http.get(
        uri,
        headers: const {'Accept': 'application/vnd.github+json'},
      );

      if (response.statusCode != 200) {
        setState(() {
          _loadingRepos = false;
          _repoError = 'GitHub API returned ${response.statusCode}';
        });
        return;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        setState(() {
          _loadingRepos = false;
          _repoError = 'Unexpected API response format';
        });
        return;
      }

      final repos = decoded.map((item) => _Repo.fromJson(item)).whereType<_Repo>().where((repo) => !repo.fork).toList()
        ..sort((a, b) => b.stars.compareTo(a.stars));

      setState(() {
        _repos = repos;
        _loadingRepos = false;
      });
    } catch (_) {
      setState(() {
        _loadingRepos = false;
        _repoError = 'Unable to fetch GitHub repositories right now.';
      });
    }
  }

  String _resolveFeaturedUrl(String title, List<String> aliases) {
    String normalize(String value) => value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

    final target = normalize(title);
    final aliasTargets = aliases.map(normalize).toList();

    for (final repo in _repos) {
      final name = normalize(repo.name);
      if (name == target || aliasTargets.contains(name)) {
        return repo.url;
      }
    }

    return 'https://github.com/$_githubUser?tab=repositories&q=${Uri.encodeComponent(title)}';
  }

  @override
  Component build(BuildContext context) {
    final topRepos = _repos.toList();

    return main_([
    
      section(id: 'home', classes: 'hero', [
        p(classes: 'eyebrow', [.text('FULL STACK DEVELOPER/ENGINEER')]),
          img(
    src:  '/assets/achiket.png',
    alt: 'Achiket Kumar',
    classes: 'profile-pic',
  ),
        h1(classes: 'name-row', [
  .text('Achiket Kumar'),
  
]),
        p(classes: 'lead', [
          .text(
            'I build fast Flutter + Go/Node products with real-time systems, clean UX, and production-first execution.',
          ),
        ]),

        div(classes: "pic",[
         p([  .text('👋',)],classes: "pic")
       ]),
        div(classes: 'hero-actions', [
          a(
            href: 'mailto:achiketkuma@gmail.com',
            classes: 'btn btn-primary',
            [.text('Email Me')],
          ),
          a(
            href: 'https://github.com/Achiket123',
            target: Target.blank,
            classes: 'btn btn-ghost',
            [.text('GitHub')],
          ),
          a(
            href: 'https://linkedin.com/in/achiket-kumar',
            target: Target.blank,
            classes: 'btn btn-ghost',
            [.text('LinkedIn')],
          ),
          a(href: "https://drive.google.com/file/d/13KtJgodJv8Hmrm2_Bw1QdAZJoJAO53Hy/view?usp=sharing", classes: 'btn btn-ghost', [.text('Resume')]),
        ]),
      ]),
      section(id: 'experience', classes: 'panel', [
        h2([.text('Work Experience')]),
        div(classes: 'timeline', [
          article(classes: 'card', [
            h3([.text('Full Stack Developer Intern · DST HUB LLP')]),
            p(classes: 'meta', [.text('Aug 2024 - Jul 2025 · Virtual')]),
            ul([
              li([.text('Optimized authentication flow, cutting login time by around 40%.')]),
              li([.text('Built real-time chat with file sharing for 200+ concurrent users.')]),
              li([.text('Developed CRM reducing manual data entry by 60%.')]),
            ]),
          ]),
          article(classes: 'card', [
            h3([.text('Flutter Developer Intern · Ricoz.in')]),
            p(classes: 'meta', [.text('Mar 2024 - Jul 2024 · Virtual')]),
            ul([
              li([.text('Built 2 end-to-end apps with Node.js backends, each onboarding 500+ users.')]),
              li([.text('Integrated Razorpay and real-time chat across both apps.')]),
              li([.text('Deployed apps to Play Store with 4.2+ average ratings.')]),
            ]),
          ]),
        ]),
      ]),
      section(id: 'projects', classes: 'panel', [
        h2([.text('Featured Projects')]),
        div(classes: 'grid', [
          for (final item in _featured)
            article(classes: 'card project', [
              p(classes: 'meta', [.text(item.subtitle)]),
              h3([.text(item.title)]),
              p([.text(item.description)]),
              p(classes: 'stack', [.text(item.tech)]),
              a(
                href: _resolveFeaturedUrl(item.title, item.aliases),
                target: Target.blank,
                classes: 'inline-link',
                [.text('Open Project')],
              ),
            ]),
        ]),
        h3([.text('Live GitHub Repositories')]),
        if (_loadingRepos)
          p([.text('Loading repositories...')])
        else if (_repoError != null)
          p([.text(_repoError!)])
        else
          div(classes: 'grid', [
            for (final repo in topRepos)
              article(classes: 'card repo', [
                h4([.text(repo.name)]),
                if (repo.description.isNotEmpty) p([.text(repo.description)]),
                p(classes: 'meta', [
                  .text('★ ${repo.stars}'),
                  .text(' · '),
                  .text(repo.language.isEmpty ? 'Codebase' : repo.language),
                ]),
                a(
                  href: repo.url,
                  target: Target.blank,
                  classes: 'inline-link',
                  [.text('View on GitHub')],
                ),
              ]),
          ]),
      ]),
      section(id: 'skills', classes: 'panel', [
        h2([.text('Skills')]),
        div(classes: 'chips', [
          for (final item in const [
            'Flutter',
            'Dart',
            'Python',
            'Go',
            'Node.js',
            'PostgreSQL',
            'MySQL',
            'Firebase',
            'Supabase',
            'WebSockets/WebRTC',
            'gRPC',
            'REST APIs',
            'Redis',
            'C/C++',
            'Linux CLI',
            'Git/GitHub',
            'Razorpay',
            'S.O.L.I.D',
            "Clean Architecture",
            "Test-Driven Development",
            "Docker",
            "CI/CD",
            "Shell Scripting",
          ])
            span(classes: 'chip', [.text(item)]),
        ]),
      ]),
      section(id: 'contact', classes: 'panel contact', [
        h2([.text('Let\'s Build Something Sharp')]),
        p([.text('Jaipur, India · Open to internships, freelance, and product collaborations.')]),
        div(classes: 'hero-actions', [
          a(
            href: 'mailto:achiketkuma@gmail.com',
            classes: 'btn btn-primary',
            [.text('achiketkuma@gmail.com')],
          ),
          a(
            href: 'tel:+917355139678',
            classes: 'btn btn-ghost',
            [.text('+91 7355139678')],
          ),
        ]),
      ]),
      section(
        classes: 'center',
        [
          
        p([.text('Made with '), .text('❤️'), .text(' by Achiket Kumar')], classes: 'meta'),
      ]),
       div(classes: "center" ,[ .text("&",)]),
       div(classes: "center" ,[JasprBadge.darkTwoTone(),])
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.center').styles(
      display: .flex,
      alignItems: .center,
      justifyContent: .center,
      // padding: .symmetric(vertical: 2.rem),

    ),
    css('main').styles(width: 100.percent),
    css('.hero, .panel').styles(
      width: 100.percent,
      maxWidth: 1120.px,
      margin: .symmetric(horizontal: .auto),
      padding: .symmetric(horizontal: 1.2.rem, vertical: 2.4.rem),
    ),
    css('.name-row').styles(
    display: .flex,
    alignItems: .center,
    gap: Gap(row: 1.rem),
    flexWrap: .wrap,
  ),
  css('.profile-pic').styles(
    width: 80.px,
    height: 80.px,
    alignContent: AlignContent.end,
    radius: .all(.circular(40.px)), // circular avatar
    border: Border.all(color: const Color('#6EA8FF'), width: 2.px),
    boxSizing: BoxSizing.contentBox
  ),
    css('.eyebrow').styles(
      color: const Color('#A6C4FF'),
      letterSpacing: 1.5.px,
      fontWeight: .w600,
      fontSize: 0.8.rem,
    ),
    css('pic').styles(
      width: 1.2.rem,
      height: 1.2.rem,
      color: const Color('#F4F7FF'),
      fontSize: 200.px,
      backgroundColor: Colors.red,
      border: Border.all(color: Colors.red),
      radius: .all(.circular(12.px)),
    ),
    css('.lead').styles(color: const Color('#D6DDF7')),
    css('.hero-actions').styles(display: .flex, flexWrap: .wrap),
    css('.btn').styles(
      display: .inlineBlock,
      padding: .symmetric(horizontal: 1.rem, vertical: 0.7.rem),
      textDecoration: TextDecoration(line: .none),
      border: Border.all(color: const Color('rgba(255,255,255,0.2)')),
      radius: .all(.circular(12.px)),
      fontWeight: .w600,
    ),
    css('.btn-primary').styles(backgroundColor: const Color('#6EA8FF'), color: const Color('#0A1020')),
    css('.btn-ghost').styles(color: const Color('#E8EEFF')),
    css('.timeline, .grid').styles(
      display: .grid,
    ),
    css('.card').styles(
      backgroundColor: const Color('rgba(14,20,34,0.82)'),
      border: Border.all(color: const Color('rgba(255,255,255,0.12)')),
      radius: .all(.circular(18.px)),
      padding: .all(1.rem),
    ),
    css('h2').styles(margin: .only(bottom: 1.rem)),
    css('.meta').styles(color: const Color('#9FB1DC'), fontSize: 0.9.rem),
    css('.stack').styles(color: const Color('#C7D5F5'), fontWeight: .w600),
    css('.inline-link').styles(
      color: const Color('#9FCCFF'),
      textDecoration: TextDecoration(line: .none),
      fontWeight: .w600,
    ),
    css('.chips').styles(display: .flex, flexWrap: .wrap),
    css('.chip').styles(
      padding: .symmetric(horizontal: 0.8.rem, vertical: 0.45.rem),
      backgroundColor: const Color('rgba(151,188,255,0.16)'),
      border: Border.all(color: const Color('rgba(151,188,255,0.35)')),
      radius: .all(.circular(999.px)),
      color: const Color('#EAF1FF'),
    ),
    css('ul').styles(margin: .only(left: 1.1.rem)),
    css.media(MediaQuery.screen(maxWidth: 760.px), [
      css('.hero, .panel').styles(
        padding: .symmetric(horizontal: 0.9.rem, vertical: 1.6.rem),
      ),
    ]),
  ];
}

class _Repo {
  const _Repo({
    required this.name,
    required this.url,
    required this.description,
    required this.language,
    required this.stars,
    required this.fork,
  });

  final String name;
  final String url;
  final String description;
  final String language;
  final int stars;
  final bool fork;

  static _Repo? fromJson(dynamic raw) {
    if (raw is! Map<String, dynamic>) return null;

    return _Repo(
      name: raw['name'] is String ? raw['name'] as String : 'Repository',
      url: raw['html_url'] is String ? raw['html_url'] as String : 'https://github.com',
      description: raw['description'] is String ? raw['description'] as String : '',
      language: raw['language'] is String ? raw['language'] as String : '',
      stars: raw['stargazers_count'] is int ? raw['stargazers_count'] as int : 0,
      fork: raw['fork'] is bool ? raw['fork'] as bool : false,
    );
  }
}
