enum Gender { male, female, notAvailable }

/// 1. People Tier Buckets (`people.tier` integer column)
enum PersonTier {
  sTier(3, 'S-Tier', 'Superstars'),
  aTier(2, 'A-Tier', 'A-List Stars'),
  bTier(1, 'B-Tier', 'Popular'),
  cTier(0, 'C-Tier', 'General');

  final int value;
  final String code;
  final String label;

  const PersonTier(this.value, this.code, this.label);

  static PersonTier fromValue(int? value) {
    return PersonTier.values.firstWhere(
          (e) => e.value == value,
      orElse: () => PersonTier.cTier,
    );
  }
}

/// 2. Movie Franchises (`movies.franchise` integer column)
enum MovieFranchise {
  residentEvil(1010, 'Resident Evil'),
  evilDead(1020, 'Evil Dead'),
  theConjuringUniverse(1030, 'The Conjuring Universe'),
  insidious(1040, 'Insidious'),
  fearStreet(1050, 'Fear Street'),
  smile(1060, 'Smile'),
  godzilla(2010, 'Godzilla'),
  monsterVerse(2020, 'MonsterVerse'),
  mcu(3010, 'MCU');

  final int id;
  final String displayName;

  const MovieFranchise(this.id, this.displayName);

  static MovieFranchise? fromId(int? id) {
    if (id == null) return null;
    for (final franchise in MovieFranchise.values) {
      if (franchise.id == id) return franchise;
    }
    return null;
  }
}

/// 3. Movie Themes (`movies.theme` varchar column)
enum MovieTheme {
  monster('monster', 'Monster');

  final String value;
  final String displayName;

  const MovieTheme(this.value, this.displayName);

  static MovieTheme? fromValue(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final theme in MovieTheme.values) {
      if (theme.value == value) return theme;
    }
    return null;
  }
}

/// 4. Blog Categories (`blogs.category` varchar column)
enum BlogCategory {
  review('review', 'Review'),
  news('news', 'News'),
  listicle('listicle', 'List'),
  theory('theory', 'Fan Theory'),
  boxOffice('box_office', 'Box Office'),
  interview('interview', 'Interview');

  final String value;
  final String label;

  const BlogCategory(this.value, this.label);

  static BlogCategory fromValue(String? value) {
    return BlogCategory.values.firstWhere(
          (e) => e.value == value,
      orElse: () => BlogCategory.news,
    );
  }
}

/// 5. Blog Publication Status (`blogs.status` varchar column)
enum BlogStatus {
  draft('draft', 'Draft'),
  published('published', 'Published'),
  archived('archived', 'Archived');

  final String value;
  final String label;

  const BlogStatus(this.value, this.label);

  static BlogStatus fromValue(String? value) {
    return BlogStatus.values.firstWhere(
          (e) => e.value == value,
      orElse: () => BlogStatus.draft,
    );
  }
}