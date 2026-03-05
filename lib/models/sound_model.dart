class SoundModel {
  final String category;
  final int order;
  final List<SoundSubcategory> subcategories;

  SoundModel({
    required this.category,
    required this.order,
    required this.subcategories,
  });

  factory SoundModel.fromJson(Map<String, dynamic> json) {
    return SoundModel(
      category: json['category'] ?? '',
      order: json['order'] ?? 0,
      subcategories: (json['subcategories'] as List? ?? [])
          .map((e) => SoundSubcategory.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'order': order,
      'subcategories': subcategories.map((e) => e.toJson()).toList(),
    };
  }
}

class SoundSubcategory {
  final String name;
  final String ULR;
  final Links links;
  final Word? words;
  final List<SoundPractice>? soundsPractice;

  SoundSubcategory({
    required this.name,
    required this.ULR,
    required this.links,
    this.words,
    this.soundsPractice,
  });

  factory SoundSubcategory.fromJson(Map<String, dynamic> json) {
    final linksValue = json['links'];
    return SoundSubcategory(
      name: json['name'] ?? '',
      ULR: json['ULR'] ?? '',
      links: linksValue is Map
          ? Links.fromJson(Map<String, dynamic>.from(linksValue))
          : Links.empty(),
      words: json['words'] != null
          ? Word.fromJson(Map<String, dynamic>.from(json['words']))
          : null,
      soundsPractice: json['soundsPractice'] != null
          ? (json['soundsPractice'] as List)
              .map((e) => SoundPractice.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ULR': ULR,
      'links': links.toJson(),
      'words': words?.toJson(),
      'soundsPractice': soundsPractice?.map((e) => e.toJson()).toList(),
    };
  }
}

class Links {
  final String v1;
  final String v2;
  final String v3;
  final String v4;
  final String v5;

  Links({
    required this.v1,
    required this.v2,
    required this.v3,
    required this.v4,
    required this.v5,
  });

  factory Links.fromJson(Map<String, dynamic> json) => Links(
        v1: json['v1'] ?? '',
        v2: json['v2'] ?? '',
        v3: json['v3'] ?? '',
        v4: json['v4'] ?? '',
        v5: json['v5'] ?? '',
      );

  factory Links.empty() => Links(v1: '', v2: '', v3: '', v4: '', v5: '');

  Map<String, dynamic> toJson() {
    return {
      'v1': v1,
      'v2': v2,
      'v3': v3,
      'v4': v4,
      'v5': v5,
    };
  }
}

class Word {
  final String file;
  final String pronun;
  final String syllables;
  final String text;

  Word({
    required this.file,
    required this.pronun,
    required this.syllables,
    required this.text,
  });

  factory Word.fromJson(Map<String, dynamic> json) => Word(
        file: json['file'] ?? '',
        pronun: json['pronun'] ?? '',
        syllables: json['syllables'] ?? '',
        text: json['text'] ?? '',
      );

  Map<String, dynamic> toJson() {
    return {
      'file': file,
      'pronun': pronun,
      'syllables': syllables,
      'text': text,
    };
  }
}

class SoundPractice {
  final String file;
  final String pronun;
  final String syllables;
  final String text;
  bool downloadStatus;
  String localPath;

  SoundPractice({
    required this.file,
    required this.pronun,
    required this.syllables,
    required this.text,
    this.downloadStatus = false,
    this.localPath = "",
  });

  factory SoundPractice.fromJson(Map<String, dynamic> json) => SoundPractice(
        file: json['file'] ?? '',
        pronun: json['pronun'] ?? '',
        syllables: json['syllables'] ?? '',
        text: json['text'] ?? '',
        localPath: json['localPath'] ?? '',
        downloadStatus:
            json['downloadStatus'] == 1 || json['downloadStatus'] == true,
      );

  Map<String, dynamic> toJson() {
    return {
      'file': file,
      'pronun': pronun,
      'syllables': syllables,
      'text': text,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'file': file,
      'syllables': syllables,
      'text': text,
      'pronun': pronun,
      'downloadStatus': downloadStatus ? 1 : 0,
      'localPath': localPath,
    };
  }

  SoundPractice copyWith({
    bool? downloadStatus,
    String? localPath,
  }) {
    return SoundPractice(
        file: file,
        pronun: pronun,
        syllables: syllables,
        text: text,
        downloadStatus: downloadStatus ?? this.downloadStatus,
        localPath: localPath ?? this.localPath);
  }

  factory SoundPractice.fromMap(Map<String, dynamic> map) {
    return SoundPractice(
      file: map['file'] ?? '',
      syllables: map['syllables'] ?? '',
      text: map['text'] ?? '',
      pronun: map['pronun'] ?? '',
      downloadStatus: map['downloadStatus'] == 1,
      localPath: map['localPath'] ?? "",
    );
  }
}
