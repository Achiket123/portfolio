class BlogPost extends BlogPostList {
  BlogPost(
    this.content,
    slug,
    title,
    tags,
    description,
    readingTimeMinutes,
    date,
  ) : super(
        slug: slug,
        title: title,
        tags: tags,
        description: description,
        readingTimeMinutes: readingTimeMinutes,
        date: date,
      );

  final String content;

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    print(json);
    //
    //{slug: building-a-shazam-clone-in-go, title: Building a Shazam Clone in Go, date: 2026-04-15, description: How I built an audio fingerprinting engine from scratch using Go, FFT, and a PostgreSQL spectrogram store., tags: [go, audio, backend, open-source], readingTimeMinutes: 2}
    //

    return BlogPost(
      json['content'],
      json['slug'] as String,
      json['title'] as String,
      List<String>.from(json['tags'] as List),
      json['description'] as String,
      json['readingTimeMinutes'] as int,
      json['date'],
    );
  }

  Map<String, dynamic> toJson() => {
    'slug': slug,
    'title': title,
    'date': date,
    'tags': tags,
    'description': description,
    'readingTimeMinutes': readingTimeMinutes,
    'content': content,
  };
}

class BlogPostList {
  BlogPostList({
    required this.slug,
    required this.title,
    required this.tags,
    required this.description,
    required this.readingTimeMinutes,
    required this.date,
  });

  final String slug;
  final String title;
  final String date;
  final List<String> tags;
  final String description;
  final int readingTimeMinutes;

  factory BlogPostList.fromJson(Map<String, dynamic> json) {
    print(json);
    //
    //{slug: building-a-shazam-clone-in-go, title: Building a Shazam Clone in Go, date: 2026-04-15, description: How I built an audio fingerprinting engine from scratch using Go, FFT, and a PostgreSQL spectrogram store., tags: [go, audio, backend, open-source], readingTimeMinutes: 2}
    //
    return BlogPostList(
      slug: json['slug'] as String,
      title: json['title'] as String,
      date: json['date'],
      tags: List<String>.from(json['tags'] as List),
      description: json['description'] as String,
      readingTimeMinutes: json['readingTimeMinutes'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'slug': slug,
    'title': title,
    // 'date': date,
    // 'tags': tags,
    'description': description,
    'readingTimeMinutes': readingTimeMinutes,
  };
}
