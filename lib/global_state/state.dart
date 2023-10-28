part of 'bloc.dart';

final class GlobalState extends Equatable {
  ///
  const GlobalState({
    this.themeMode = ThemeMode.system,
    this.lemmyAccounts = const [],
    this.lemmySelectedAccount = -1,
    this.lemmyDefaultHomeServer = 'https://lemmy.ml',
    this.useDynamicColorScheme = true,
    this.seedColor = Colors.blueGrey,
    this.showNsfw = false,
    this.blurNsfw = true,
    this.defaultSortType = LemmySortType.active,
    this.textScaleFactor = 1.0,
  });

  factory GlobalState.fromMap(Map<String, dynamic> map) {
    return GlobalState(
      lemmyAccounts: List.generate(
        (map['lemmyAccounts'] as List).length,
        (index) => LemmyAccountData.fromMap(map['lemmyAccounts'][index]),
      ),
      lemmySelectedAccount: map['lemmySelectedAccount'] as int,
      lemmyDefaultHomeServer: map['lemmyDefaultHomeServer'],
      themeMode: ThemeMode.values[map['themeMode']],
      useDynamicColorScheme: map['useDynamicColorScheme'] as bool,
      seedColor: Color(map['seedColor'] as int),
      showNsfw: map['showNsfw'],
      blurNsfw: map['blurNsfw'],
      defaultSortType: LemmySortType.values[map['defaultSortType']],
      textScaleFactor: map['textScaleFactor'],
    );
  }

  bool isLoggedIn() => lemmySelectedAccount != -1;

  /// All the lemmy accounts the user has added
  final List<LemmyAccountData> lemmyAccounts;

  /// the index of the selected account on lemmyAccounts
  /// -1 mean anonymous/no account
  final int lemmySelectedAccount;

  /// the home server used if no account selected
  final String lemmyDefaultHomeServer;

  /// Whether the app is in dark or light mode
  final ThemeMode themeMode;

  final bool useDynamicColorScheme;

  /// The color used to generate the apps color scheme
  final Color seedColor;

  /// whether to show or hide nsfw posts
  final bool showNsfw;

  /// whether to blur nsfw posts
  final bool blurNsfw;

  final LemmySortType defaultSortType;

  final double textScaleFactor;

  @override
  List<Object?> get props => [
        lemmyAccounts,
        lemmySelectedAccount,
        lemmyDefaultHomeServer,
        themeMode,
        useDynamicColorScheme,
        seedColor,
        showNsfw,
        blurNsfw,
        defaultSortType,
        textScaleFactor,
      ];

  Map<String, dynamic> toMap() {
    return {
      'lemmyAccounts': List.generate(
        lemmyAccounts.length,
        (index) => lemmyAccounts[index].toMap(),
      ),
      'lemmySelectedAccount': lemmySelectedAccount,
      'lemmyDefaultHomeServer': lemmyDefaultHomeServer,
      'themeMode': themeMode.index,
      'useDynamicColorScheme': useDynamicColorScheme,
      'seedColor': seedColor.value,
      'showNsfw': showNsfw,
      'blurNsfw': blurNsfw,
      'defaultSortType': defaultSortType.index,
      'textScaleFactor': textScaleFactor,
    };
  }

  GlobalState copyWith({
    List<LemmyAccountData>? lemmyAccounts,
    int? lemmySelectedAccount,
    String? lemmyDefaultHomeServer,
    ThemeMode? themeMode,
    bool? useDynamicColorScheme,
    Color? seedColor,
    bool? showNsfw,
    bool? blurNsfw,
    LemmySortType? defaultSortType,
    double? textScaleFactor,
  }) {
    return GlobalState(
      lemmyDefaultHomeServer:
          lemmyDefaultHomeServer ?? this.lemmyDefaultHomeServer,
      lemmyAccounts: lemmyAccounts ?? this.lemmyAccounts,
      lemmySelectedAccount: lemmySelectedAccount ?? this.lemmySelectedAccount,
      themeMode: themeMode ?? this.themeMode,
      useDynamicColorScheme:
          useDynamicColorScheme ?? this.useDynamicColorScheme,
      seedColor: seedColor ?? this.seedColor,
      showNsfw: showNsfw ?? this.showNsfw,
      blurNsfw: blurNsfw ?? this.blurNsfw,
      defaultSortType: defaultSortType ?? this.defaultSortType,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
    );
  }
}

final class LemmyAccountData extends Equatable {
  LemmyAccountData(
      {required this.jwt, required this.homeServer, required this.userName});

  factory LemmyAccountData.fromMap(Map<String, dynamic> map) {
    return LemmyAccountData(
      jwt: map['jwt'] as String,
      homeServer: map['homeServer'] as String,
      userName: map['userName'] as String,
    );
  }

  final String jwt;

  /// home server should include the "https://" and not end with "/"
  final String homeServer;
  final String userName;

  Map<String, dynamic> toMap() {
    return {
      'jwt': this.jwt,
      'homeServer': this.homeServer,
      'userName': this.userName,
    };
  }

  @override
  List<Object?> get props => [
        jwt,
        homeServer,
        userName,
      ];
}
