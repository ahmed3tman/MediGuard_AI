/// Developer social/contact links for About Developer page.
class AboutDeveloperLinks {
  static const List<AboutLink> links = [
    AboutLink(
      name: 'LinkedIn',
      url: 'https://linkedin.com/in/ahmed3tman',
      icon: 'linkedin',
    ),
    AboutLink(
      name: 'GitHub',
      url: 'https://github.com/ahmed3tman',
      icon: 'github',
    ),
    AboutLink(
      name: 'TikTok',
      url: 'https://tiktok.com/@ahmed3tman',
      icon: 'tiktok',
    ),
    AboutLink(
      name: 'Instagram',
      url: 'https://instagram.com/i3tman',
      icon: 'instagram',
    ),
    AboutLink(
      name: 'YouTube',
      url: 'https://youtube.com/@i3tman',
      icon: 'youtube',
    ),
  ];
}

class AboutLink {
  final String name;
  final String url;
  final String icon; // Use icon name for custom rendering
  const AboutLink({required this.name, required this.url, required this.icon});
}
