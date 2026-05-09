import 'package:portfolio/models/blog_post.dart';

class PortfolioData {
  final List<BlogPostList> blog;
  final GithubData github;
  final LinkedinData linkedin;
  final List<Tweet> twitter;

  PortfolioData({
    required this.blog,
    required this.github,
    required this.linkedin,
    required this.twitter,
  });

  factory PortfolioData.fromJson(Map json) {
    return PortfolioData(
      blog: (json['blog'] as List? ?? []).map((e) => BlogPostList.fromJson(e)).toList(),
      github: GithubData.fromJson(json['github'] as Map? ?? {}),
      linkedin: LinkedinData.fromJson(json['linkedin'] as Map? ?? {}),
      twitter: (json['twitter'] as List? ?? []).map((e) => Tweet.fromJson(e as Map)).toList(),
    );
  }
}

class LinkedinData {
  // Empty for now as per data
  LinkedinData();
  factory LinkedinData.fromJson(Map json) => LinkedinData();
}

class Tweet {
  final String id;
  final String text;
  final String date;
  final String url;
  final List<String> images;

  Tweet({
    required this.id,
    required this.text,
    required this.date,
    required this.url,
    required this.images,
  });

  factory Tweet.fromJson(Map json) {
    return Tweet(
      id: json['ID'] ?? '',
      text: json['Text'] ?? '',
      date: json['Date'] ?? '',
      url: json['URL'] ?? '',
      images: (json['Images'] as List? ?? []).cast<String>(),
    );
  }
}

class GithubData {
  final GithubUser? user;

  GithubData({this.user});

  factory GithubData.fromJson(Map json) {
    return GithubData(
      user: json['user'] != null ? GithubUser.fromJson(json['user'] as Map) : null,
    );
  }
}

class GithubUser {
  final ContributionsCollection contributionsCollection;
  final List<GithubPinnedItem> pinnedItems;
  final List<GithubRepo> repositories;

  GithubUser({
    required this.contributionsCollection,
    required this.pinnedItems,
    required this.repositories,
  });

  factory GithubUser.fromJson(Map json) {
    return GithubUser(
      contributionsCollection: ContributionsCollection.fromJson(json['contributionsCollection'] as Map? ?? {}),
      pinnedItems: (json['pinnedItems']?['nodes'] as List? ?? [])
          .map((e) => GithubPinnedItem.fromJson(e as Map))
          .toList(),
      repositories: (json['repositories']?['nodes'] as List? ?? []).map((e) => GithubRepo.fromJson(e as Map)).toList(),
    );
  }
}

class ContributionsCollection {
  final List<CommitContributionByRepo> commitContributionsByRepository;
  final ContributionCalendar contributionCalendar;
  final List<PullRequestContribution> pullRequestContributions;

  ContributionsCollection({
    required this.commitContributionsByRepository,
    required this.contributionCalendar,
    required this.pullRequestContributions,
  });

  factory ContributionsCollection.fromJson(Map json) {
    return ContributionsCollection(
      commitContributionsByRepository: (json['commitContributionsByRepository'] as List? ?? [])
          .map((e) => CommitContributionByRepo.fromJson(e as Map))
          .toList(),
      contributionCalendar: ContributionCalendar.fromJson(json['contributionCalendar'] as Map? ?? {}),
      pullRequestContributions: (json['pullRequestContributions']?['nodes'] as List? ?? [])
          .map((e) => PullRequestContribution.fromJson(e as Map))
          .toList(),
    );
  }
}

class CommitContributionByRepo {
  final List<DateTime> occurredAt;
  final String repoName;
  final String repoUrl;

  CommitContributionByRepo({
    required this.occurredAt,
    required this.repoName,
    required this.repoUrl,
  });

  factory CommitContributionByRepo.fromJson(Map json) {
    return CommitContributionByRepo(
      occurredAt: (json['contributions']?['nodes'] as List? ?? []).map((e) => DateTime.parse(e['occurredAt'])).toList(),
      repoName: json['repository']?['nameWithOwner'] ?? '',
      repoUrl: json['repository']?['url'] ?? '',
    );
  }
}

class ContributionCalendar {
  final int totalContributions;
  final List<ContributionWeek> weeks;

  ContributionCalendar({
    required this.totalContributions,
    required this.weeks,
  });

  factory ContributionCalendar.fromJson(Map json) {
    return ContributionCalendar(
      totalContributions: json['totalContributions'] ?? 0,
      weeks: (json['weeks'] as List? ?? []).map((e) => ContributionWeek.fromJson(e as Map)).toList(),
    );
  }
}

class ContributionWeek {
  final List<ContributionDay> contributionDays;

  ContributionWeek({required this.contributionDays});

  factory ContributionWeek.fromJson(Map json) {
    return ContributionWeek(
      contributionDays: (json['contributionDays'] as List? ?? [])
          .map((e) => ContributionDay.fromJson(e as Map))
          .toList(),
    );
  }
}

class ContributionDay {
  final String color;
  final int contributionCount;
  final String date;

  ContributionDay({
    required this.color,
    required this.contributionCount,
    required this.date,
  });

  factory ContributionDay.fromJson(Map json) {
    return ContributionDay(
      color: json['color'] ?? '',
      contributionCount: json['contributionCount'] ?? 0,
      date: json['date'] ?? '',
    );
  }
}

class PullRequestContribution {
  final DateTime createdAt;
  final String repoName;
  final String repoUrl;
  final String state;
  final String title;
  final String url;

  PullRequestContribution({
    required this.createdAt,
    required this.repoName,
    required this.repoUrl,
    required this.state,
    required this.title,
    required this.url,
  });

  factory PullRequestContribution.fromJson(Map json) {
    final pr = json['pullRequest'] as Map? ?? {};
    return PullRequestContribution(
      createdAt: DateTime.parse(pr['createdAt']),
      repoName: pr['repository']?['nameWithOwner'] ?? '',
      repoUrl: pr['repository']?['url'] ?? '',
      state: pr['state'] ?? '',
      title: pr['title'] ?? '',
      url: pr['url'] ?? '',
    );
  }
}

class GithubPinnedItem {
  final String description;
  final int forkCount;
  final String name;
  final String primaryLanguageName;
  final String primaryLanguageColor;
  final int stargazerCount;
  final String url;

  GithubPinnedItem({
    required this.description,
    required this.forkCount,
    required this.name,
    required this.primaryLanguageName,
    required this.primaryLanguageColor,
    required this.stargazerCount,
    required this.url,
  });

  factory GithubPinnedItem.fromJson(Map json) {
    return GithubPinnedItem(
      description: json['description'] ?? '',
      forkCount: json['forkCount'] ?? 0,
      name: json['name'] ?? '',
      primaryLanguageName: json['primaryLanguage']?['name'] ?? '',
      primaryLanguageColor: json['primaryLanguage']?['color'] ?? '',
      stargazerCount: json['stargazerCount'] ?? 0,
      url: json['url'] ?? '',
    );
  }
}

class GithubRepo {
  final String description;
  final int forkCount;
  final String name;
  final String primaryLanguageName;
  final String primaryLanguageColor;
  final int stargazerCount;
  final String url;

  GithubRepo({
    required this.description,
    required this.forkCount,
    required this.name,
    required this.primaryLanguageName,
    required this.primaryLanguageColor,
    required this.stargazerCount,
    required this.url,
  });

  factory GithubRepo.fromJson(Map json) {
    return GithubRepo(
      description: json['description'] ?? '',
      forkCount: json['forkCount'] ?? 0,
      name: json['name'] ?? '',
      primaryLanguageName: json['primaryLanguage']?['name'] ?? '',
      primaryLanguageColor: json['primaryLanguage']?['color'] ?? '',
      stargazerCount: json['stargazerCount'] ?? 0,
      url: json['url'] ?? '',
    );
  }
}
