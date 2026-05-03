import 'dart:convert';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:http/http.dart' as http;

import '../components/sketch_box.dart';
import '../components/sketch_timeline.dart';

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
      tech: ['Go', 'Flutter', 'PostgreSQL'],
      aliases: ['soundsalike', 'shazam-clone'],
    ),
    (
      title: 'InkBattle',
      subtitle: 'Scrabble-style Word Game',
      description:
          'Real-time 2-player game with matchmaking, leaderboard, and WebSocket sync averaging 300+ daily matches.',
      tech: ['Flutter', 'Node.js', 'PostgreSQL', 'WebSockets'],
      aliases: ['inkbattle', 'ink-battle', 'scrabble'],
    ),
    (
      title: 'Mushin',
      subtitle: 'Productivity App Locker',
      description: 'Geo-aware app locker using Android location APIs that unlocks in greenery or outdoor contexts.',
      tech: ['Flutter', 'Android APIs', 'Geofencing'],
      aliases: ['mushin'],
    ),
  ];

  final _experience = const [
    (
      role: 'Full Stack Developer Intern',
      company: 'DST HUB LLP',
      period: 'Aug 2024 - Jul 2025',
      location: 'Virtual',
      points: [
        'Optimized authentication flow, cutting login time by around 40%.',
        'Built real-time chat with file sharing for 200+ concurrent users.',
        'Developed CRM reducing manual data entry by 60%.',
      ],
    ),
    (
      role: 'Flutter Developer Intern',
      company: 'Ricoz.in',
      period: 'Mar 2024 - Jul 2024',
      location: 'Virtual',
      points: [
        'Built 2 end-to-end apps with Node.js backends, each onboarding 500+ users.',
        'Integrated Razorpay and real-time chat across both apps.',
        'Deployed apps to Play Store with 4.2+ average ratings.',
      ],
    ),
  ];

  final _skills = const [
    'Flutter',
    'Dart',
    'Python',
    'Go',
    'Node.js',
    'PostgreSQL',
    'MySQL',
    'Firebase',
    'Supabase',
    'WebSockets',
    'WebRTC',
    'gRPC',
    'REST APIs',
    'Redis',
    'C/C++',
    'Linux CLI',
    'Git/GitHub',
    'Razorpay',
    'S.O.L.I.D',
    'Clean Architecture',
    'Test-Driven Development',
    'Docker',
    'CI/CD',
    'MongoDB',
    'Shell Scripting',
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
        _repoError = 'Unable to fetch repositories right now.';
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

  Component _sketchCard({
    required List<Component> children,
    String extraClass = '',
    String? strokeColor,
    String? padding,
  }) {
    return SketchBox(
      classes: extraClass,
      strokeColor: strokeColor,
      padding: padding ?? '2rem',
      children: children,
    );
  }

  @override
  Component build(BuildContext context) {
    final topRepos = _repos.toList();

    return main_([
      // hero section
      section(id: 'home', classes: 'section hero-section', [
        div(classes: 'hero-eyebrow', [
          span(classes: 'eyebrow-tag', [.text('System.init(portfolio)')]),
        ]),
        div(classes: 'hero-content', [
          div(classes: 'hero-left', [
            h1(classes: 'hero-title', [
              .text('Crafting '),
              span(classes: 'accent-text', [.text('Digital Blueprints')]),
              br(),
              .text('from Messy Thoughts.'),
            ]),
            p(classes: 'hero-desc', [
              .text(
                'Full-stack engineer building tools that feel like hand-crafted machines. '
                'Currently exploring the intersection of creative coding and brutalist UI.',
              ),
            ]),
            div(classes: 'hero-cta-row', [
              a(
                href: '#projects',
                classes: 'sketch-btn sketch-btn-accent',
                [.text('View the Lab')],
              ),
              a(
                href: 'https://drive.google.com/file/d/13KtJgodJv8Hmrm2_Bw1QdAZJoJAO53Hy/view?usp=sharing',
                target: Target.blank,
                classes: 'sketch-btn sketch-btn-ghost',
                [.text('Download Journal_')],
              ),
            ]),
          ]),
          div(classes: 'hero-right', [
            _sketchCard(
              extraClass: 'availability-card',
              strokeColor: 'var(--bg)',
              children: [
                p(classes: 'availability-label', [.text('Availability')]),
                h2(classes: 'availability-status', [.text('OPEN FOR COLLAB')]),
                p(classes: 'availability-desc', [
                  .text('Looking for projects that challenge the status quo of web design.'),
                ]),
              ],
            ),
          ]),
        ]),
        div(classes: 'quote-strip', [
          p(classes: 'quote-text', [
            .text('"The best code is the one that looks like it was sketched by a human, executed by a machine."'),
          ]),
        ]),
      ]),

      // projects section
      section(id: 'projects', classes: 'section', [
        div(classes: 'section-header', [
          span(classes: 'section-label', [.text('My Lab Experiments_')]),
          h2(classes: 'section-title', [
            .text('A collection of '),
            span(classes: 'underline-sketch', [.text('unconventional prototypes')]),
            .text(' and production-grade tools designed in the middle of the night.'),
          ]),
        ]),
        div(classes: 'projects-grid', [
          for (final item in _featured)
            _sketchCard(
              extraClass: 'project-card',
              children: [
                div(classes: 'project-card-top', [
                  p(classes: 'project-subtitle', [.text(item.subtitle)]),
                  span(classes: 'project-icon', [.text('[/]')]),
                ]),
                h3(classes: 'project-title', [.text(item.title)]),
                p(classes: 'project-desc', [.text(item.description)]),
                div(classes: 'tech-tags', [
                  for (final t in item.tech) span(classes: 'tech-tag', [.text(t)]),
                ]),
                div(classes: 'project-actions', [
                  a(
                    href: _resolveFeaturedUrl(item.title, item.aliases),
                    target: Target.blank,
                    classes: 'sketch-btn sketch-btn-accent',
                    [.text('Launch Experiment')],
                  ),
                  a(
                    href: 'https://github.com/$_githubUser',
                    target: Target.blank,
                    classes: 'sketch-btn sketch-btn-ghost',
                    [.text('View Source')],
                  ),
                ]),
              ],
            ),
        ]),

        // github repos
        div(classes: 'repos-section', [
          h3(classes: 'repos-title', [.text('Live GitHub Repositories')]),
          if (_loadingRepos)
            p(classes: 'loading-text', [.text('Fetching repositories...')])
          else if (_repoError != null)
            p(classes: 'error-text', [.text(_repoError!)])
          else
            div(classes: 'repos-grid', [
              for (final repo in topRepos)
                _sketchCard(
                  extraClass: 'repo-card',
                  children: [
                    div(classes: 'repo-card-inner', [
                      h4(classes: 'repo-name', [.text(repo.name)]),
                      if (repo.description.isNotEmpty) p(classes: 'repo-desc', [.text(repo.description)]),
                      div(classes: 'repo-meta', [
                        span(classes: 'repo-stars', [
                          .text('* ${repo.stars}'),
                        ]),
                        span(classes: 'repo-lang', [
                          .text(repo.language.isEmpty ? 'Code' : repo.language),
                        ]),
                      ]),
                      a(
                        href: repo.url,
                        target: Target.blank,
                        classes: 'repo-link',
                        [.text('View on GitHub ->>')],
                      ),
                    ]),
                  ],
                ),
            ]),
        ]),

        div(classes: 'cta-footer', [
          p(classes: 'cta-text', [.text('Have a weird idea for a collab?')]),
          div(classes: 'cta-actions', [
            a(
              href: 'mailto:achiketkuma@gmail.com',
              classes: 'sketch-btn sketch-btn-accent',
              [.text('Say Hi_')],
            ),
            a(
              href: 'https://drive.google.com/file/d/13KtJgodJv8Hmrm2_Bw1QdAZJoJAO53Hy/view?usp=sharing',
              target: Target.blank,
              classes: 'sketch-btn sketch-btn-ghost',
              [.text('Download Logs_')],
            ),
          ]),
        ]),
      ]),

      // experience section
      section(id: 'experience', classes: 'section', [
        div(classes: 'section-header', [
          span(classes: 'section-label', [.text('Work Logs_')]),
          h2(classes: 'section-title', [.text('Experience')]),
        ]),
        SketchTimeline(children: [
          for (final job in _experience)
            div(classes: 'timeline-entry', [
              div(classes: 'timeline-dot', []),
              _sketchCard(
                extraClass: 'timeline-card',
                children: [
                  div(classes: 'timeline-header', [
                    div(classes: 'timeline-info', [
                      h3(classes: 'timeline-role', [.text(job.role)]),
                      p(classes: 'timeline-company', [.text(job.company)]),
                    ]),
                    span(classes: 'timeline-period', [.text(job.period)]),
                  ]),
                  ul(classes: 'timeline-points', [
                    for (final point in job.points)
                      li(classes: 'timeline-point', [
                        span(classes: 'point-marker', [.text('+')]),
                        .text(point),
                      ]),
                  ]),
                ],
              ),
            ]),
        ]),
      ]),

      // skills section
      section(id: 'skills', classes: 'section', [
        div(classes: 'section-header', [
          span(classes: 'section-label', [.text('Tech Stack_')]),
          h2(classes: 'section-title', [.text('Skills')]),
        ]),
        div(classes: 'skills-grid', [
          for (final skill in _skills) span(classes: 'skill-chip', [.text(skill)]),
        ]),
      ]),

      // contact / footer
      section(id: 'contact', classes: 'section contact-section', [
        h2(classes: 'contact-title', [.text("Let's build something raw.")]),
        p(classes: 'contact-sub', [
          .text('achiketkuma@gmail.com  //  #achiket_kumar'),
        ]),
        div(classes: 'contact-links', [
          a(
            href: 'mailto:achiketkuma@gmail.com',
            classes: 'contact-icon-link',
            [.text('@')],
          ),
          a(
            href: 'https://github.com/Achiket123',
            target: Target.blank,
            classes: 'contact-icon-link',
            [.text('[/]')],
          ),
          a(
            href: 'https://linkedin.com/in/achiket-kumar',
            target: Target.blank,
            classes: 'contact-icon-link',
            [.text('<->')],
          ),
        ]),
        p(classes: 'footer-credit', [
          .text('Made with care and code.  //  Achiket Kumar 2025'),
        ]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('main').styles(width: 100.percent),

    css('.section').styles(
      width: 100.percent,
      maxWidth: 1120.px,
      margin: .symmetric(horizontal: .auto),
      padding: .symmetric(horizontal: 2.rem, vertical: 4.rem),
    ),

    // hero
    css('.hero-section').styles(
      padding: .symmetric(horizontal: 2.rem, vertical: 5.rem),
    ),
    css('.hero-eyebrow').styles(
      margin: Spacing.only(bottom: 2.rem),
    ),
    css('.eyebrow-tag').styles(
      fontFamily: const .list([FontFamily('Just Another Hand'), FontFamilies.cursive]),
      fontSize: 1.1.rem,
      color: const Color('var(--accent)'),
      raw: {
        'border': '1.5px solid var(--accent)',
        'padding': '2px 12px',
        'border-radius': 'var(--chaos-radius-3)',
        'clip-path': 'var(--chaos-path-2)',
      },
    ),
    css('.hero-content').styles(
      display: .flex,
      gap: Gap(column: 4.rem),
      alignItems: .center,
      flexWrap: .wrap,
    ),
    css('.hero-left').styles(
      flex: Flex(grow: 1),
      raw: {'min-width': '280px'},
    ),
    css('.hero-right').styles(
      display: .flex,
      flexDirection: .column,
      gap: Gap(row: 1.5.rem),
      raw: {'min-width': '220px'},
      // backgroundColor: Colors.black,
    ),
    css('.hero-title').styles(
      fontSize: 4.5.rem,
      lineHeight: 1.25.em,
      margin: Spacing.only(bottom: 1.5.rem),
    ),
    css('.accent-text').styles(
      color: const Color('var(--accent)'),
    ),
    css('.hero-desc').styles(
      color: const Color('var(--text-muted)'),
      fontSize: 1.1.rem,
      lineHeight: 1.6.rem,
      margin: Spacing.only(bottom: 2.5.rem),
      raw: {'max-width': '580px'},
    ),
    css('.hero-cta-row').styles(
      display: .flex,
      gap: Gap(column: 1.5.rem),
      flexWrap: .wrap,
    ),
    css('.availability-card').styles(
      backgroundColor: const Color('var(--text)'),
      margin: .all(12.px),
      raw: {
        'position': 'relative',
        'overflow': 'visible',
      },
    ),
    css('.availability-card .availability-label').styles(
      fontFamily: const .list([FontFamily('Just Another Hand'), FontFamilies.cursive]),
      fontSize: 1.1.rem,
      color: const Color('var(--bg)'),
      letterSpacing: 1.px,
    ),
    css('.availability-card .availability-status').styles(
      fontFamily: const .list([FontFamily('Just Another Hand'), FontFamilies.cursive]),
      fontSize: 3.2.rem,
      color: const Color('var(--bg)'),
      lineHeight: 1.25.em,
      margin: Spacing.only(top: 0.5.rem, bottom: 1.rem),
    ),
    css('.availability-card .availability-desc').styles(
      fontSize: 0.95.rem,
      color: const Color('var(--bg)'),
      lineHeight: 1.4.rem,
    ),
    css('.quote-strip').styles(
      margin: Spacing.only(top: 5.rem),
      padding: .symmetric(vertical: 2.rem, horizontal: 0.rem),
      raw: {
        'border-top': '2px dashed var(--border)',
        'border-bottom': '2px dashed var(--border)',
      },
    ),
    css('.quote-text').styles(
      fontFamily: const .list([FontFamily('Just Another Hand'), FontFamilies.cursive]),
      fontSize: 2.rem,
      color: const Color('var(--text-muted)'),
      textAlign: .center,
      raw: {
        'background-image': 'linear-gradient(var(--accent-dim) 1px, transparent 1px)',
        'background-size': '100% 1.2em',
      },
    ),

    // section common
    css('.section-header').styles(
      margin: Spacing.only(bottom: 3.rem),
    ),
    css('.section-label').styles(
      fontFamily: const .list([FontFamily('Just Another Hand'), FontFamilies.cursive]),
      fontSize: 1.2.rem,
      color: const Color('var(--accent)'),
      display: .block,
      margin: Spacing.only(bottom: 0.8.rem),
      letterSpacing: 1.px,
    ),
    css('.section-title').styles(
      fontSize: 2.8.rem,
      lineHeight: 2.rem,
      raw: {'max-width': '850px'},
    ),
    css('.underline-sketch').styles(
      backgroundColor: const Color('var(--accent-dim)'),
      raw: {
        'padding': '0 4px',
        'border-bottom': '2px solid var(--accent)',
      },
    ),

    // sketch card (applies to project-card, repo-card, etc)
    css('.sketch-box-container').styles(
      margin: .all(1.2.rem),
      raw: {
        'transition': 'transform 0.2s ease',
      },
    ),
    css('.sketch-box-container:hover').styles(
      raw: {
        'transform': 'translateY(-5px) rotate(-1deg)',
      },
    ),

    // buttons
    css('.sketch-btn').styles(
      display: .inlineBlock,
      fontFamily: const .list([FontFamily('Just Another Hand'), FontFamilies.cursive]),
      fontSize: 1.4.rem,
      padding: .symmetric(horizontal: 1.5.rem, vertical: 0.6.rem),
      cursor: .pointer,
      raw: {
        'border-radius': 'var(--chaos-radius-2)',
        'transition': 'opacity 0.2s, transform 0.2s',
      },
    ),
    css('.sketch-btn:hover').styles(
      raw: {
        'opacity': '0.9',
        'transform': 'scale(1.02) rotate(-1deg)',
      },
    ),
    css('.sketch-btn-accent').styles(
      backgroundColor: const Color('var(--accent)'),
      color: const Color('var(--bg)'),
      raw: {'border': 'none'},
    ),
    css('.sketch-btn-ghost').styles(
      backgroundColor: Colors.transparent,
      color: const Color('var(--text)'),
      raw: {'border': '2.5px solid var(--border)'},
    ),

    // projects
    css('.projects-grid').styles(
      display: .grid,
      gap: Gap(row: 2.rem, column: 2.rem),
      raw: {'grid-template-columns': 'repeat(auto-fill, minmax(340px, 1fr))'},
    ),
    css('.project-card').styles(
      display: .flex,
      flexDirection: .column,
      gap: Gap(row: 1.rem),
    ),
    css('.project-card-top').styles(
      display: .flex,
      justifyContent: .spaceBetween,
      alignItems: .center,
    ),
    css('.project-subtitle').styles(
      fontFamily: const .list([FontFamily('Just Another Hand'), FontFamilies.cursive]),
      fontSize: 1.1.rem,
      color: const Color('var(--accent)'),
    ),
    css('.project-icon').styles(
      color: const Color('var(--text-muted)'),
      fontSize: 1.2.rem,
    ),
    css('.project-title').styles(
      fontSize: 2.2.rem,
    ),
    css('.project-desc').styles(
      color: const Color('var(--text-muted)'),
      fontSize: 1.rem,
      lineHeight: 1.6.rem,
      raw: {'flex': '1'},
    ),
    css('.tech-tags').styles(
      display: .flex,
      flexWrap: .wrap,
      gap: Gap(row: 0.5.rem, column: 0.5.rem),
    ),
    css('.tech-tag').styles(
      fontFamily: const .list([FontFamily('Just Another Hand'), FontFamilies.cursive]),
      fontSize: 1.1.rem,
      padding: .symmetric(horizontal: 0.8.rem, vertical: 0.25.rem),
      raw: {
        'border': '1px solid var(--border)',
        'border-radius': '3px',
      },
    ),
    css('.project-actions').styles(
      display: .flex,
      gap: Gap(column: 1.rem),
      flexWrap: .wrap,
      margin: Spacing.only(top: 0.8.rem),
    ),

    // timeline (logs)
    css('.timeline-entry').styles(
      position: Position.relative(),
    ),
    css('.timeline-dot').styles(
      width: 14.px,
      height: 14.px,
      backgroundColor: const Color('var(--bg)'),
      radius: .all(Radius.circular(7.px)),
      raw: {
        'position': 'absolute',
        'left': '-3.15rem',
        'top': '2rem',
        'border': '2px solid var(--accent)',
        'box-shadow': '0 0 8px var(--accent)',
        'z-index': '5',
      },
    ),
    css('.timeline-card').styles(
      display: .flex,
      flexDirection: .column,
      gap: Gap(row: 1.rem),
      margin: .all(12.px),
      raw: {
        'position': 'relative',
      },
    ),
    css('.timeline-card::before').styles(
      display: .none,
    ),
    css('.timeline-header').styles(
      display: .flex,
      justifyContent: .spaceBetween,
      alignItems: .center,
      flexWrap: .wrap,
      gap: Gap(row: 0.5.rem, column: 0.5.rem),
    ),
    css('.timeline-role').styles(
      fontSize: 1.6.rem,
    ),
    css('.timeline-company').styles(
      color: const Color('var(--accent)'),
      fontFamily: const .list([FontFamily('Just Another Hand'), FontFamilies.cursive]),
      fontSize: 1.2.rem,
    ),
    css('.timeline-period').styles(
      color: const Color('var(--text-muted)'),
      fontFamily: const .list([FontFamily('Special Elite'), FontFamilies.serif]),
      fontSize: 0.85.rem,
      raw: {'white-space': 'nowrap'},
    ),
    css('.timeline-point').styles(
      color: const Color('var(--text-muted)'),
      fontSize: 0.95.rem,
      lineHeight: 1.5.rem,
      margin: Spacing.only(bottom: 0.4.rem),
    ),

    // skills
    css('.skills-grid').styles(
      display: .flex,
      flexWrap: .wrap,
      gap: Gap(row: 0.8.rem, column: 0.8.rem),
    ),
    css('.skill-chip').styles(
      fontFamily: const .list([FontFamily('Just Another Hand'), FontFamilies.cursive]),
      fontSize: 1.2.rem,
      padding: .symmetric(horizontal: 1.2.rem, vertical: 0.4.rem),
      raw: {
        'border': '1.5px solid var(--border)',
        'border-radius': 'var(--chaos-radius-2)',
        'transition': 'all 0.2s',
      },
    ),
    css('.skill-chip:hover').styles(
      color: const Color('var(--accent)'),
      raw: {
        'border-color': 'var(--accent)',
        'transform': 'rotate(-2deg) scale(1.05)',
      },
    ),

    // contact
    css('.contact-section').styles(
      textAlign: .center,
      padding: .symmetric(horizontal: 2.rem, vertical: 6.rem),
    ),
    css('.contact-title').styles(
      fontSize: 3.5.rem,
      margin: Spacing.only(bottom: 1.rem),
    ),
    css('.contact-sub').styles(
      color: const Color('var(--text-muted)'),
      fontFamily: const .list([FontFamily('Just Another Hand'), FontFamilies.cursive]),
      fontSize: 1.4.rem,
      margin: Spacing.only(bottom: 2.5.rem),
    ),
    css('.contact-links').styles(
      display: .flex,
      gap: Gap(column: 2.rem),
      justifyContent: .center,
      margin: Spacing.only(bottom: 4.rem),
    ),
    css('.contact-icon-link').styles(
      fontSize: 1.8.rem,
      color: const Color('var(--text-muted)'),
      width: 60.px,
      height: 60.px,
      display: .flex,
      alignItems: .center,
      justifyContent: .center,
      raw: {
        'border': '2px solid var(--border)',
        'border-radius': 'var(--chaos-radius-3)',
        'transition': 'all 0.2s',
      },
    ),
    css('.contact-icon-link:hover').styles(
      color: const Color('var(--accent)'),
      raw: {
        'border-color': 'var(--accent)',
        'transform': 'scale(1.1) rotate(15deg)',
      },
    ),
    css('.footer-credit').styles(
      color: const Color('var(--text-muted)'),
      fontSize: 0.85.rem,
      letterSpacing: 1.px,
    ),

    // responsive
    css.media(MediaQuery.screen(maxWidth: 760.px), [
      css('.section').styles(
        padding: .symmetric(horizontal: 1.5.rem, vertical: 3.rem),
      ),
      css('.hero-title').styles(fontSize: 3.2.rem),
      css('.section-title').styles(fontSize: 2.2.rem),
      css('.projects-grid').styles(
        raw: {'grid-template-columns': '1fr'},
      ),
      css('.contact-title').styles(fontSize: 2.6.rem),
      css('.timeline').styles(
        raw: {'padding-left': '2rem'},
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
