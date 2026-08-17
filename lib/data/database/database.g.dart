// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $BookmarkedFoldersTable extends BookmarkedFolders
    with TableInfo<$BookmarkedFoldersTable, BookmarkedFolder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarkedFoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _treeUriMeta = const VerificationMeta(
    'treeUri',
  );
  @override
  late final GeneratedColumn<String> treeUri = GeneratedColumn<String>(
    'tree_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateAddedMeta = const VerificationMeta(
    'dateAdded',
  );
  @override
  late final GeneratedColumn<DateTime> dateAdded = GeneratedColumn<DateTime>(
    'date_added',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, treeUri, displayName, dateAdded];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarked_folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookmarkedFolder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tree_uri')) {
      context.handle(
        _treeUriMeta,
        treeUri.isAcceptableOrUnknown(data['tree_uri']!, _treeUriMeta),
      );
    } else if (isInserting) {
      context.missing(_treeUriMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('date_added')) {
      context.handle(
        _dateAddedMeta,
        dateAdded.isAcceptableOrUnknown(data['date_added']!, _dateAddedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookmarkedFolder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookmarkedFolder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      treeUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tree_uri'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      dateAdded: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_added'],
      )!,
    );
  }

  @override
  $BookmarkedFoldersTable createAlias(String alias) {
    return $BookmarkedFoldersTable(attachedDatabase, alias);
  }
}

class BookmarkedFolder extends DataClass
    implements Insertable<BookmarkedFolder> {
  final String id;
  final String treeUri;
  final String displayName;
  final DateTime dateAdded;
  const BookmarkedFolder({
    required this.id,
    required this.treeUri,
    required this.displayName,
    required this.dateAdded,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tree_uri'] = Variable<String>(treeUri);
    map['display_name'] = Variable<String>(displayName);
    map['date_added'] = Variable<DateTime>(dateAdded);
    return map;
  }

  BookmarkedFoldersCompanion toCompanion(bool nullToAbsent) {
    return BookmarkedFoldersCompanion(
      id: Value(id),
      treeUri: Value(treeUri),
      displayName: Value(displayName),
      dateAdded: Value(dateAdded),
    );
  }

  factory BookmarkedFolder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookmarkedFolder(
      id: serializer.fromJson<String>(json['id']),
      treeUri: serializer.fromJson<String>(json['treeUri']),
      displayName: serializer.fromJson<String>(json['displayName']),
      dateAdded: serializer.fromJson<DateTime>(json['dateAdded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'treeUri': serializer.toJson<String>(treeUri),
      'displayName': serializer.toJson<String>(displayName),
      'dateAdded': serializer.toJson<DateTime>(dateAdded),
    };
  }

  BookmarkedFolder copyWith({
    String? id,
    String? treeUri,
    String? displayName,
    DateTime? dateAdded,
  }) => BookmarkedFolder(
    id: id ?? this.id,
    treeUri: treeUri ?? this.treeUri,
    displayName: displayName ?? this.displayName,
    dateAdded: dateAdded ?? this.dateAdded,
  );
  BookmarkedFolder copyWithCompanion(BookmarkedFoldersCompanion data) {
    return BookmarkedFolder(
      id: data.id.present ? data.id.value : this.id,
      treeUri: data.treeUri.present ? data.treeUri.value : this.treeUri,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      dateAdded: data.dateAdded.present ? data.dateAdded.value : this.dateAdded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkedFolder(')
          ..write('id: $id, ')
          ..write('treeUri: $treeUri, ')
          ..write('displayName: $displayName, ')
          ..write('dateAdded: $dateAdded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, treeUri, displayName, dateAdded);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookmarkedFolder &&
          other.id == this.id &&
          other.treeUri == this.treeUri &&
          other.displayName == this.displayName &&
          other.dateAdded == this.dateAdded);
}

class BookmarkedFoldersCompanion extends UpdateCompanion<BookmarkedFolder> {
  final Value<String> id;
  final Value<String> treeUri;
  final Value<String> displayName;
  final Value<DateTime> dateAdded;
  final Value<int> rowid;
  const BookmarkedFoldersCompanion({
    this.id = const Value.absent(),
    this.treeUri = const Value.absent(),
    this.displayName = const Value.absent(),
    this.dateAdded = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookmarkedFoldersCompanion.insert({
    required String id,
    required String treeUri,
    required String displayName,
    this.dateAdded = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       treeUri = Value(treeUri),
       displayName = Value(displayName);
  static Insertable<BookmarkedFolder> custom({
    Expression<String>? id,
    Expression<String>? treeUri,
    Expression<String>? displayName,
    Expression<DateTime>? dateAdded,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (treeUri != null) 'tree_uri': treeUri,
      if (displayName != null) 'display_name': displayName,
      if (dateAdded != null) 'date_added': dateAdded,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookmarkedFoldersCompanion copyWith({
    Value<String>? id,
    Value<String>? treeUri,
    Value<String>? displayName,
    Value<DateTime>? dateAdded,
    Value<int>? rowid,
  }) {
    return BookmarkedFoldersCompanion(
      id: id ?? this.id,
      treeUri: treeUri ?? this.treeUri,
      displayName: displayName ?? this.displayName,
      dateAdded: dateAdded ?? this.dateAdded,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (treeUri.present) {
      map['tree_uri'] = Variable<String>(treeUri.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (dateAdded.present) {
      map['date_added'] = Variable<DateTime>(dateAdded.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkedFoldersCompanion(')
          ..write('id: $id, ')
          ..write('treeUri: $treeUri, ')
          ..write('displayName: $displayName, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SongsTable extends Songs with TableInfo<$SongsTable, Song> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uriMeta = const VerificationMeta('uri');
  @override
  late final GeneratedColumn<String> uri = GeneratedColumn<String>(
    'uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bpmDetectedMeta = const VerificationMeta(
    'bpmDetected',
  );
  @override
  late final GeneratedColumn<double> bpmDetected = GeneratedColumn<double>(
    'bpm_detected',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bpmManualMeta = const VerificationMeta(
    'bpmManual',
  );
  @override
  late final GeneratedColumn<double> bpmManual = GeneratedColumn<double>(
    'bpm_manual',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateAddedMeta = const VerificationMeta(
    'dateAdded',
  );
  @override
  late final GeneratedColumn<DateTime> dateAdded = GeneratedColumn<DateTime>(
    'date_added',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _sourceFolderIdMeta = const VerificationMeta(
    'sourceFolderId',
  );
  @override
  late final GeneratedColumn<String> sourceFolderId = GeneratedColumn<String>(
    'source_folder_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bookmarked_folders (id)',
    ),
  );
  static const VerificationMeta _isHiddenMeta = const VerificationMeta(
    'isHidden',
  );
  @override
  late final GeneratedColumn<bool> isHidden = GeneratedColumn<bool>(
    'is_hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uri,
    title,
    artist,
    album,
    durationMs,
    bpmDetected,
    bpmManual,
    dateAdded,
    sourceFolderId,
    isHidden,
    isFavorite,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'songs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Song> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('uri')) {
      context.handle(
        _uriMeta,
        uri.isAcceptableOrUnknown(data['uri']!, _uriMeta),
      );
    } else if (isInserting) {
      context.missing(_uriMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('bpm_detected')) {
      context.handle(
        _bpmDetectedMeta,
        bpmDetected.isAcceptableOrUnknown(
          data['bpm_detected']!,
          _bpmDetectedMeta,
        ),
      );
    }
    if (data.containsKey('bpm_manual')) {
      context.handle(
        _bpmManualMeta,
        bpmManual.isAcceptableOrUnknown(data['bpm_manual']!, _bpmManualMeta),
      );
    }
    if (data.containsKey('date_added')) {
      context.handle(
        _dateAddedMeta,
        dateAdded.isAcceptableOrUnknown(data['date_added']!, _dateAddedMeta),
      );
    }
    if (data.containsKey('source_folder_id')) {
      context.handle(
        _sourceFolderIdMeta,
        sourceFolderId.isAcceptableOrUnknown(
          data['source_folder_id']!,
          _sourceFolderIdMeta,
        ),
      );
    }
    if (data.containsKey('is_hidden')) {
      context.handle(
        _isHiddenMeta,
        isHidden.isAcceptableOrUnknown(data['is_hidden']!, _isHiddenMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Song map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Song(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      uri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uri'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      ),
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      bpmDetected: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bpm_detected'],
      ),
      bpmManual: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bpm_manual'],
      ),
      dateAdded: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_added'],
      )!,
      sourceFolderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_folder_id'],
      ),
      isHidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_hidden'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
    );
  }

  @override
  $SongsTable createAlias(String alias) {
    return $SongsTable(attachedDatabase, alias);
  }
}

class Song extends DataClass implements Insertable<Song> {
  final String id;

  /// Filesystem path or content:// URI this song was imported from. Unique
  /// so the library scanner can safely re-run (including concurrently)
  /// without ever creating duplicate rows for the same file.
  final String uri;
  final String title;
  final String? artist;
  final String? album;
  final int? durationMs;

  /// BPM automatically detected by the on-device DSP pipeline.
  final double? bpmDetected;

  /// BPM manually entered/corrected by the user. Takes precedence over
  /// [bpmDetected] everywhere in the UI when present.
  final double? bpmManual;
  final DateTime dateAdded;

  /// Folder this song was discovered in, if it came from a bookmarked
  /// folder rather than being added directly to a playlist.
  final String? sourceFolderId;

  /// Hidden songs are excluded from the Library list by default (but still
  /// exist for playlists/sets that already reference them). Toggled from
  /// the Library's per-song menu; a "show hidden" filter reveals them again.
  final bool isHidden;

  /// Toggled from the Library/Playlist three-dot menu and the player's
  /// heart button. Drives the favorite-only filter in Library/Playlist
  /// views.
  final bool isFavorite;
  const Song({
    required this.id,
    required this.uri,
    required this.title,
    this.artist,
    this.album,
    this.durationMs,
    this.bpmDetected,
    this.bpmManual,
    required this.dateAdded,
    this.sourceFolderId,
    required this.isHidden,
    required this.isFavorite,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['uri'] = Variable<String>(uri);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(artist);
    }
    if (!nullToAbsent || album != null) {
      map['album'] = Variable<String>(album);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || bpmDetected != null) {
      map['bpm_detected'] = Variable<double>(bpmDetected);
    }
    if (!nullToAbsent || bpmManual != null) {
      map['bpm_manual'] = Variable<double>(bpmManual);
    }
    map['date_added'] = Variable<DateTime>(dateAdded);
    if (!nullToAbsent || sourceFolderId != null) {
      map['source_folder_id'] = Variable<String>(sourceFolderId);
    }
    map['is_hidden'] = Variable<bool>(isHidden);
    map['is_favorite'] = Variable<bool>(isFavorite);
    return map;
  }

  SongsCompanion toCompanion(bool nullToAbsent) {
    return SongsCompanion(
      id: Value(id),
      uri: Value(uri),
      title: Value(title),
      artist: artist == null && nullToAbsent
          ? const Value.absent()
          : Value(artist),
      album: album == null && nullToAbsent
          ? const Value.absent()
          : Value(album),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      bpmDetected: bpmDetected == null && nullToAbsent
          ? const Value.absent()
          : Value(bpmDetected),
      bpmManual: bpmManual == null && nullToAbsent
          ? const Value.absent()
          : Value(bpmManual),
      dateAdded: Value(dateAdded),
      sourceFolderId: sourceFolderId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceFolderId),
      isHidden: Value(isHidden),
      isFavorite: Value(isFavorite),
    );
  }

  factory Song.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Song(
      id: serializer.fromJson<String>(json['id']),
      uri: serializer.fromJson<String>(json['uri']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String?>(json['artist']),
      album: serializer.fromJson<String?>(json['album']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      bpmDetected: serializer.fromJson<double?>(json['bpmDetected']),
      bpmManual: serializer.fromJson<double?>(json['bpmManual']),
      dateAdded: serializer.fromJson<DateTime>(json['dateAdded']),
      sourceFolderId: serializer.fromJson<String?>(json['sourceFolderId']),
      isHidden: serializer.fromJson<bool>(json['isHidden']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'uri': serializer.toJson<String>(uri),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String?>(artist),
      'album': serializer.toJson<String?>(album),
      'durationMs': serializer.toJson<int?>(durationMs),
      'bpmDetected': serializer.toJson<double?>(bpmDetected),
      'bpmManual': serializer.toJson<double?>(bpmManual),
      'dateAdded': serializer.toJson<DateTime>(dateAdded),
      'sourceFolderId': serializer.toJson<String?>(sourceFolderId),
      'isHidden': serializer.toJson<bool>(isHidden),
      'isFavorite': serializer.toJson<bool>(isFavorite),
    };
  }

  Song copyWith({
    String? id,
    String? uri,
    String? title,
    Value<String?> artist = const Value.absent(),
    Value<String?> album = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    Value<double?> bpmDetected = const Value.absent(),
    Value<double?> bpmManual = const Value.absent(),
    DateTime? dateAdded,
    Value<String?> sourceFolderId = const Value.absent(),
    bool? isHidden,
    bool? isFavorite,
  }) => Song(
    id: id ?? this.id,
    uri: uri ?? this.uri,
    title: title ?? this.title,
    artist: artist.present ? artist.value : this.artist,
    album: album.present ? album.value : this.album,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    bpmDetected: bpmDetected.present ? bpmDetected.value : this.bpmDetected,
    bpmManual: bpmManual.present ? bpmManual.value : this.bpmManual,
    dateAdded: dateAdded ?? this.dateAdded,
    sourceFolderId: sourceFolderId.present
        ? sourceFolderId.value
        : this.sourceFolderId,
    isHidden: isHidden ?? this.isHidden,
    isFavorite: isFavorite ?? this.isFavorite,
  );
  Song copyWithCompanion(SongsCompanion data) {
    return Song(
      id: data.id.present ? data.id.value : this.id,
      uri: data.uri.present ? data.uri.value : this.uri,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      album: data.album.present ? data.album.value : this.album,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      bpmDetected: data.bpmDetected.present
          ? data.bpmDetected.value
          : this.bpmDetected,
      bpmManual: data.bpmManual.present ? data.bpmManual.value : this.bpmManual,
      dateAdded: data.dateAdded.present ? data.dateAdded.value : this.dateAdded,
      sourceFolderId: data.sourceFolderId.present
          ? data.sourceFolderId.value
          : this.sourceFolderId,
      isHidden: data.isHidden.present ? data.isHidden.value : this.isHidden,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Song(')
          ..write('id: $id, ')
          ..write('uri: $uri, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('durationMs: $durationMs, ')
          ..write('bpmDetected: $bpmDetected, ')
          ..write('bpmManual: $bpmManual, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('sourceFolderId: $sourceFolderId, ')
          ..write('isHidden: $isHidden, ')
          ..write('isFavorite: $isFavorite')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uri,
    title,
    artist,
    album,
    durationMs,
    bpmDetected,
    bpmManual,
    dateAdded,
    sourceFolderId,
    isHidden,
    isFavorite,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Song &&
          other.id == this.id &&
          other.uri == this.uri &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.album == this.album &&
          other.durationMs == this.durationMs &&
          other.bpmDetected == this.bpmDetected &&
          other.bpmManual == this.bpmManual &&
          other.dateAdded == this.dateAdded &&
          other.sourceFolderId == this.sourceFolderId &&
          other.isHidden == this.isHidden &&
          other.isFavorite == this.isFavorite);
}

class SongsCompanion extends UpdateCompanion<Song> {
  final Value<String> id;
  final Value<String> uri;
  final Value<String> title;
  final Value<String?> artist;
  final Value<String?> album;
  final Value<int?> durationMs;
  final Value<double?> bpmDetected;
  final Value<double?> bpmManual;
  final Value<DateTime> dateAdded;
  final Value<String?> sourceFolderId;
  final Value<bool> isHidden;
  final Value<bool> isFavorite;
  final Value<int> rowid;
  const SongsCompanion({
    this.id = const Value.absent(),
    this.uri = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.bpmDetected = const Value.absent(),
    this.bpmManual = const Value.absent(),
    this.dateAdded = const Value.absent(),
    this.sourceFolderId = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SongsCompanion.insert({
    required String id,
    required String uri,
    required String title,
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.bpmDetected = const Value.absent(),
    this.bpmManual = const Value.absent(),
    this.dateAdded = const Value.absent(),
    this.sourceFolderId = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       uri = Value(uri),
       title = Value(title);
  static Insertable<Song> custom({
    Expression<String>? id,
    Expression<String>? uri,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? album,
    Expression<int>? durationMs,
    Expression<double>? bpmDetected,
    Expression<double>? bpmManual,
    Expression<DateTime>? dateAdded,
    Expression<String>? sourceFolderId,
    Expression<bool>? isHidden,
    Expression<bool>? isFavorite,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uri != null) 'uri': uri,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
      if (durationMs != null) 'duration_ms': durationMs,
      if (bpmDetected != null) 'bpm_detected': bpmDetected,
      if (bpmManual != null) 'bpm_manual': bpmManual,
      if (dateAdded != null) 'date_added': dateAdded,
      if (sourceFolderId != null) 'source_folder_id': sourceFolderId,
      if (isHidden != null) 'is_hidden': isHidden,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SongsCompanion copyWith({
    Value<String>? id,
    Value<String>? uri,
    Value<String>? title,
    Value<String?>? artist,
    Value<String?>? album,
    Value<int?>? durationMs,
    Value<double?>? bpmDetected,
    Value<double?>? bpmManual,
    Value<DateTime>? dateAdded,
    Value<String?>? sourceFolderId,
    Value<bool>? isHidden,
    Value<bool>? isFavorite,
    Value<int>? rowid,
  }) {
    return SongsCompanion(
      id: id ?? this.id,
      uri: uri ?? this.uri,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      durationMs: durationMs ?? this.durationMs,
      bpmDetected: bpmDetected ?? this.bpmDetected,
      bpmManual: bpmManual ?? this.bpmManual,
      dateAdded: dateAdded ?? this.dateAdded,
      sourceFolderId: sourceFolderId ?? this.sourceFolderId,
      isHidden: isHidden ?? this.isHidden,
      isFavorite: isFavorite ?? this.isFavorite,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (uri.present) {
      map['uri'] = Variable<String>(uri.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (bpmDetected.present) {
      map['bpm_detected'] = Variable<double>(bpmDetected.value);
    }
    if (bpmManual.present) {
      map['bpm_manual'] = Variable<double>(bpmManual.value);
    }
    if (dateAdded.present) {
      map['date_added'] = Variable<DateTime>(dateAdded.value);
    }
    if (sourceFolderId.present) {
      map['source_folder_id'] = Variable<String>(sourceFolderId.value);
    }
    if (isHidden.present) {
      map['is_hidden'] = Variable<bool>(isHidden.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongsCompanion(')
          ..write('id: $id, ')
          ..write('uri: $uri, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('durationMs: $durationMs, ')
          ..write('bpmDetected: $bpmDetected, ')
          ..write('bpmManual: $bpmManual, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('sourceFolderId: $sourceFolderId, ')
          ..write('isHidden: $isHidden, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistsTable extends Playlists
    with TableInfo<$PlaylistsTable, Playlist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateCreatedMeta = const VerificationMeta(
    'dateCreated',
  );
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
    'date_created',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, dateCreated];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlists';
  @override
  VerificationContext validateIntegrity(
    Insertable<Playlist> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('date_created')) {
      context.handle(
        _dateCreatedMeta,
        dateCreated.isAcceptableOrUnknown(
          data['date_created']!,
          _dateCreatedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Playlist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Playlist(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      dateCreated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_created'],
      )!,
    );
  }

  @override
  $PlaylistsTable createAlias(String alias) {
    return $PlaylistsTable(attachedDatabase, alias);
  }
}

class Playlist extends DataClass implements Insertable<Playlist> {
  final String id;
  final String name;
  final DateTime dateCreated;
  const Playlist({
    required this.id,
    required this.name,
    required this.dateCreated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['date_created'] = Variable<DateTime>(dateCreated);
    return map;
  }

  PlaylistsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsCompanion(
      id: Value(id),
      name: Value(name),
      dateCreated: Value(dateCreated),
    );
  }

  factory Playlist.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Playlist(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
    };
  }

  Playlist copyWith({String? id, String? name, DateTime? dateCreated}) =>
      Playlist(
        id: id ?? this.id,
        name: name ?? this.name,
        dateCreated: dateCreated ?? this.dateCreated,
      );
  Playlist copyWithCompanion(PlaylistsCompanion data) {
    return Playlist(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      dateCreated: data.dateCreated.present
          ? data.dateCreated.value
          : this.dateCreated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Playlist(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dateCreated: $dateCreated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, dateCreated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Playlist &&
          other.id == this.id &&
          other.name == this.name &&
          other.dateCreated == this.dateCreated);
}

class PlaylistsCompanion extends UpdateCompanion<Playlist> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> dateCreated;
  final Value<int> rowid;
  const PlaylistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistsCompanion.insert({
    required String id,
    required String name,
    this.dateCreated = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Playlist> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? dateCreated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (dateCreated != null) 'date_created': dateCreated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? dateCreated,
    Value<int>? rowid,
  }) {
    return PlaylistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      dateCreated: dateCreated ?? this.dateCreated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistSongsTable extends PlaylistSongs
    with TableInfo<$PlaylistSongsTable, PlaylistSong> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistSongsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES playlists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES songs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sortIndexMeta = const VerificationMeta(
    'sortIndex',
  );
  @override
  late final GeneratedColumn<int> sortIndex = GeneratedColumn<int>(
    'sort_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [playlistId, songId, sortIndex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_songs';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistSong> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('sort_index')) {
      context.handle(
        _sortIndexMeta,
        sortIndex.isAcceptableOrUnknown(data['sort_index']!, _sortIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_sortIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playlistId, songId};
  @override
  PlaylistSong map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistSong(
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_id'],
      )!,
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      sortIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_index'],
      )!,
    );
  }

  @override
  $PlaylistSongsTable createAlias(String alias) {
    return $PlaylistSongsTable(attachedDatabase, alias);
  }
}

class PlaylistSong extends DataClass implements Insertable<PlaylistSong> {
  final String playlistId;
  final String songId;
  final int sortIndex;
  const PlaylistSong({
    required this.playlistId,
    required this.songId,
    required this.sortIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<String>(playlistId);
    map['song_id'] = Variable<String>(songId);
    map['sort_index'] = Variable<int>(sortIndex);
    return map;
  }

  PlaylistSongsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistSongsCompanion(
      playlistId: Value(playlistId),
      songId: Value(songId),
      sortIndex: Value(sortIndex),
    );
  }

  factory PlaylistSong.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistSong(
      playlistId: serializer.fromJson<String>(json['playlistId']),
      songId: serializer.fromJson<String>(json['songId']),
      sortIndex: serializer.fromJson<int>(json['sortIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<String>(playlistId),
      'songId': serializer.toJson<String>(songId),
      'sortIndex': serializer.toJson<int>(sortIndex),
    };
  }

  PlaylistSong copyWith({String? playlistId, String? songId, int? sortIndex}) =>
      PlaylistSong(
        playlistId: playlistId ?? this.playlistId,
        songId: songId ?? this.songId,
        sortIndex: sortIndex ?? this.sortIndex,
      );
  PlaylistSong copyWithCompanion(PlaylistSongsCompanion data) {
    return PlaylistSong(
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      songId: data.songId.present ? data.songId.value : this.songId,
      sortIndex: data.sortIndex.present ? data.sortIndex.value : this.sortIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistSong(')
          ..write('playlistId: $playlistId, ')
          ..write('songId: $songId, ')
          ..write('sortIndex: $sortIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playlistId, songId, sortIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistSong &&
          other.playlistId == this.playlistId &&
          other.songId == this.songId &&
          other.sortIndex == this.sortIndex);
}

class PlaylistSongsCompanion extends UpdateCompanion<PlaylistSong> {
  final Value<String> playlistId;
  final Value<String> songId;
  final Value<int> sortIndex;
  final Value<int> rowid;
  const PlaylistSongsCompanion({
    this.playlistId = const Value.absent(),
    this.songId = const Value.absent(),
    this.sortIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistSongsCompanion.insert({
    required String playlistId,
    required String songId,
    required int sortIndex,
    this.rowid = const Value.absent(),
  }) : playlistId = Value(playlistId),
       songId = Value(songId),
       sortIndex = Value(sortIndex);
  static Insertable<PlaylistSong> custom({
    Expression<String>? playlistId,
    Expression<String>? songId,
    Expression<int>? sortIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (songId != null) 'song_id': songId,
      if (sortIndex != null) 'sort_index': sortIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistSongsCompanion copyWith({
    Value<String>? playlistId,
    Value<String>? songId,
    Value<int>? sortIndex,
    Value<int>? rowid,
  }) {
    return PlaylistSongsCompanion(
      playlistId: playlistId ?? this.playlistId,
      songId: songId ?? this.songId,
      sortIndex: sortIndex ?? this.sortIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (sortIndex.present) {
      map['sort_index'] = Variable<int>(sortIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistSongsCompanion(')
          ..write('playlistId: $playlistId, ')
          ..write('songId: $songId, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PracticeSetsTable extends PracticeSets
    with TableInfo<$PracticeSetsTable, PracticeSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PracticeSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultTempoPercentMeta =
      const VerificationMeta('defaultTempoPercent');
  @override
  late final GeneratedColumn<int> defaultTempoPercent = GeneratedColumn<int>(
    'default_tempo_percent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
  );
  static const VerificationMeta _defaultPlayDurationSecondsMeta =
      const VerificationMeta('defaultPlayDurationSeconds');
  @override
  late final GeneratedColumn<int> defaultPlayDurationSeconds =
      GeneratedColumn<int>(
        'default_play_duration_seconds',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(105),
      );
  static const VerificationMeta _defaultBreakSecondsMeta =
      const VerificationMeta('defaultBreakSeconds');
  @override
  late final GeneratedColumn<int> defaultBreakSeconds = GeneratedColumn<int>(
    'default_break_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _repeatEnabledMeta = const VerificationMeta(
    'repeatEnabled',
  );
  @override
  late final GeneratedColumn<bool> repeatEnabled = GeneratedColumn<bool>(
    'repeat_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("repeat_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dateCreatedMeta = const VerificationMeta(
    'dateCreated',
  );
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
    'date_created',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    defaultTempoPercent,
    defaultPlayDurationSeconds,
    defaultBreakSeconds,
    repeatEnabled,
    dateCreated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'practice_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<PracticeSet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('default_tempo_percent')) {
      context.handle(
        _defaultTempoPercentMeta,
        defaultTempoPercent.isAcceptableOrUnknown(
          data['default_tempo_percent']!,
          _defaultTempoPercentMeta,
        ),
      );
    }
    if (data.containsKey('default_play_duration_seconds')) {
      context.handle(
        _defaultPlayDurationSecondsMeta,
        defaultPlayDurationSeconds.isAcceptableOrUnknown(
          data['default_play_duration_seconds']!,
          _defaultPlayDurationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('default_break_seconds')) {
      context.handle(
        _defaultBreakSecondsMeta,
        defaultBreakSeconds.isAcceptableOrUnknown(
          data['default_break_seconds']!,
          _defaultBreakSecondsMeta,
        ),
      );
    }
    if (data.containsKey('repeat_enabled')) {
      context.handle(
        _repeatEnabledMeta,
        repeatEnabled.isAcceptableOrUnknown(
          data['repeat_enabled']!,
          _repeatEnabledMeta,
        ),
      );
    }
    if (data.containsKey('date_created')) {
      context.handle(
        _dateCreatedMeta,
        dateCreated.isAcceptableOrUnknown(
          data['date_created']!,
          _dateCreatedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PracticeSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PracticeSet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      defaultTempoPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_tempo_percent'],
      )!,
      defaultPlayDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_play_duration_seconds'],
      )!,
      defaultBreakSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_break_seconds'],
      )!,
      repeatEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}repeat_enabled'],
      )!,
      dateCreated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_created'],
      )!,
    );
  }

  @override
  $PracticeSetsTable createAlias(String alias) {
    return $PracticeSetsTable(attachedDatabase, alias);
  }
}

class PracticeSet extends DataClass implements Insertable<PracticeSet> {
  final String id;
  final String name;

  /// Default tempo as a percentage of original speed (70-130).
  final int defaultTempoPercent;
  final int defaultPlayDurationSeconds;
  final int defaultBreakSeconds;

  /// When true, a session loops back to the first entry after the last one
  /// finishes (indefinitely) instead of completing. See
  /// [PracticeSessionController._advance].
  final bool repeatEnabled;
  final DateTime dateCreated;
  const PracticeSet({
    required this.id,
    required this.name,
    required this.defaultTempoPercent,
    required this.defaultPlayDurationSeconds,
    required this.defaultBreakSeconds,
    required this.repeatEnabled,
    required this.dateCreated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['default_tempo_percent'] = Variable<int>(defaultTempoPercent);
    map['default_play_duration_seconds'] = Variable<int>(
      defaultPlayDurationSeconds,
    );
    map['default_break_seconds'] = Variable<int>(defaultBreakSeconds);
    map['repeat_enabled'] = Variable<bool>(repeatEnabled);
    map['date_created'] = Variable<DateTime>(dateCreated);
    return map;
  }

  PracticeSetsCompanion toCompanion(bool nullToAbsent) {
    return PracticeSetsCompanion(
      id: Value(id),
      name: Value(name),
      defaultTempoPercent: Value(defaultTempoPercent),
      defaultPlayDurationSeconds: Value(defaultPlayDurationSeconds),
      defaultBreakSeconds: Value(defaultBreakSeconds),
      repeatEnabled: Value(repeatEnabled),
      dateCreated: Value(dateCreated),
    );
  }

  factory PracticeSet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PracticeSet(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      defaultTempoPercent: serializer.fromJson<int>(
        json['defaultTempoPercent'],
      ),
      defaultPlayDurationSeconds: serializer.fromJson<int>(
        json['defaultPlayDurationSeconds'],
      ),
      defaultBreakSeconds: serializer.fromJson<int>(
        json['defaultBreakSeconds'],
      ),
      repeatEnabled: serializer.fromJson<bool>(json['repeatEnabled']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'defaultTempoPercent': serializer.toJson<int>(defaultTempoPercent),
      'defaultPlayDurationSeconds': serializer.toJson<int>(
        defaultPlayDurationSeconds,
      ),
      'defaultBreakSeconds': serializer.toJson<int>(defaultBreakSeconds),
      'repeatEnabled': serializer.toJson<bool>(repeatEnabled),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
    };
  }

  PracticeSet copyWith({
    String? id,
    String? name,
    int? defaultTempoPercent,
    int? defaultPlayDurationSeconds,
    int? defaultBreakSeconds,
    bool? repeatEnabled,
    DateTime? dateCreated,
  }) => PracticeSet(
    id: id ?? this.id,
    name: name ?? this.name,
    defaultTempoPercent: defaultTempoPercent ?? this.defaultTempoPercent,
    defaultPlayDurationSeconds:
        defaultPlayDurationSeconds ?? this.defaultPlayDurationSeconds,
    defaultBreakSeconds: defaultBreakSeconds ?? this.defaultBreakSeconds,
    repeatEnabled: repeatEnabled ?? this.repeatEnabled,
    dateCreated: dateCreated ?? this.dateCreated,
  );
  PracticeSet copyWithCompanion(PracticeSetsCompanion data) {
    return PracticeSet(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      defaultTempoPercent: data.defaultTempoPercent.present
          ? data.defaultTempoPercent.value
          : this.defaultTempoPercent,
      defaultPlayDurationSeconds: data.defaultPlayDurationSeconds.present
          ? data.defaultPlayDurationSeconds.value
          : this.defaultPlayDurationSeconds,
      defaultBreakSeconds: data.defaultBreakSeconds.present
          ? data.defaultBreakSeconds.value
          : this.defaultBreakSeconds,
      repeatEnabled: data.repeatEnabled.present
          ? data.repeatEnabled.value
          : this.repeatEnabled,
      dateCreated: data.dateCreated.present
          ? data.dateCreated.value
          : this.dateCreated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PracticeSet(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('defaultTempoPercent: $defaultTempoPercent, ')
          ..write('defaultPlayDurationSeconds: $defaultPlayDurationSeconds, ')
          ..write('defaultBreakSeconds: $defaultBreakSeconds, ')
          ..write('repeatEnabled: $repeatEnabled, ')
          ..write('dateCreated: $dateCreated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    defaultTempoPercent,
    defaultPlayDurationSeconds,
    defaultBreakSeconds,
    repeatEnabled,
    dateCreated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PracticeSet &&
          other.id == this.id &&
          other.name == this.name &&
          other.defaultTempoPercent == this.defaultTempoPercent &&
          other.defaultPlayDurationSeconds == this.defaultPlayDurationSeconds &&
          other.defaultBreakSeconds == this.defaultBreakSeconds &&
          other.repeatEnabled == this.repeatEnabled &&
          other.dateCreated == this.dateCreated);
}

class PracticeSetsCompanion extends UpdateCompanion<PracticeSet> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> defaultTempoPercent;
  final Value<int> defaultPlayDurationSeconds;
  final Value<int> defaultBreakSeconds;
  final Value<bool> repeatEnabled;
  final Value<DateTime> dateCreated;
  final Value<int> rowid;
  const PracticeSetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.defaultTempoPercent = const Value.absent(),
    this.defaultPlayDurationSeconds = const Value.absent(),
    this.defaultBreakSeconds = const Value.absent(),
    this.repeatEnabled = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PracticeSetsCompanion.insert({
    required String id,
    required String name,
    this.defaultTempoPercent = const Value.absent(),
    this.defaultPlayDurationSeconds = const Value.absent(),
    this.defaultBreakSeconds = const Value.absent(),
    this.repeatEnabled = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<PracticeSet> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? defaultTempoPercent,
    Expression<int>? defaultPlayDurationSeconds,
    Expression<int>? defaultBreakSeconds,
    Expression<bool>? repeatEnabled,
    Expression<DateTime>? dateCreated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (defaultTempoPercent != null)
        'default_tempo_percent': defaultTempoPercent,
      if (defaultPlayDurationSeconds != null)
        'default_play_duration_seconds': defaultPlayDurationSeconds,
      if (defaultBreakSeconds != null)
        'default_break_seconds': defaultBreakSeconds,
      if (repeatEnabled != null) 'repeat_enabled': repeatEnabled,
      if (dateCreated != null) 'date_created': dateCreated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PracticeSetsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? defaultTempoPercent,
    Value<int>? defaultPlayDurationSeconds,
    Value<int>? defaultBreakSeconds,
    Value<bool>? repeatEnabled,
    Value<DateTime>? dateCreated,
    Value<int>? rowid,
  }) {
    return PracticeSetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      defaultTempoPercent: defaultTempoPercent ?? this.defaultTempoPercent,
      defaultPlayDurationSeconds:
          defaultPlayDurationSeconds ?? this.defaultPlayDurationSeconds,
      defaultBreakSeconds: defaultBreakSeconds ?? this.defaultBreakSeconds,
      repeatEnabled: repeatEnabled ?? this.repeatEnabled,
      dateCreated: dateCreated ?? this.dateCreated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (defaultTempoPercent.present) {
      map['default_tempo_percent'] = Variable<int>(defaultTempoPercent.value);
    }
    if (defaultPlayDurationSeconds.present) {
      map['default_play_duration_seconds'] = Variable<int>(
        defaultPlayDurationSeconds.value,
      );
    }
    if (defaultBreakSeconds.present) {
      map['default_break_seconds'] = Variable<int>(defaultBreakSeconds.value);
    }
    if (repeatEnabled.present) {
      map['repeat_enabled'] = Variable<bool>(repeatEnabled.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PracticeSetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('defaultTempoPercent: $defaultTempoPercent, ')
          ..write('defaultPlayDurationSeconds: $defaultPlayDurationSeconds, ')
          ..write('defaultBreakSeconds: $defaultBreakSeconds, ')
          ..write('repeatEnabled: $repeatEnabled, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SetEntriesTable extends SetEntries
    with TableInfo<$SetEntriesTable, SetEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SetEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setIdMeta = const VerificationMeta('setId');
  @override
  late final GeneratedColumn<String> setId = GeneratedColumn<String>(
    'set_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES practice_sets (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sortIndexMeta = const VerificationMeta(
    'sortIndex',
  );
  @override
  late final GeneratedColumn<int> sortIndex = GeneratedColumn<int>(
    'sort_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
    'playlist_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES playlists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tempoPercentMeta = const VerificationMeta(
    'tempoPercent',
  );
  @override
  late final GeneratedColumn<int> tempoPercent = GeneratedColumn<int>(
    'tempo_percent',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _playDurationSecondsMeta =
      const VerificationMeta('playDurationSeconds');
  @override
  late final GeneratedColumn<int> playDurationSeconds = GeneratedColumn<int>(
    'play_duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _breakSecondsMeta = const VerificationMeta(
    'breakSeconds',
  );
  @override
  late final GeneratedColumn<int> breakSeconds = GeneratedColumn<int>(
    'break_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    setId,
    sortIndex,
    label,
    playlistId,
    tempoPercent,
    playDurationSeconds,
    breakSeconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'set_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SetEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('set_id')) {
      context.handle(
        _setIdMeta,
        setId.isAcceptableOrUnknown(data['set_id']!, _setIdMeta),
      );
    } else if (isInserting) {
      context.missing(_setIdMeta);
    }
    if (data.containsKey('sort_index')) {
      context.handle(
        _sortIndexMeta,
        sortIndex.isAcceptableOrUnknown(data['sort_index']!, _sortIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_sortIndexMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    }
    if (data.containsKey('tempo_percent')) {
      context.handle(
        _tempoPercentMeta,
        tempoPercent.isAcceptableOrUnknown(
          data['tempo_percent']!,
          _tempoPercentMeta,
        ),
      );
    }
    if (data.containsKey('play_duration_seconds')) {
      context.handle(
        _playDurationSecondsMeta,
        playDurationSeconds.isAcceptableOrUnknown(
          data['play_duration_seconds']!,
          _playDurationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('break_seconds')) {
      context.handle(
        _breakSecondsMeta,
        breakSeconds.isAcceptableOrUnknown(
          data['break_seconds']!,
          _breakSecondsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SetEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SetEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      setId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_id'],
      )!,
      sortIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_index'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_id'],
      ),
      tempoPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tempo_percent'],
      ),
      playDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_duration_seconds'],
      ),
      breakSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}break_seconds'],
      ),
    );
  }

  @override
  $SetEntriesTable createAlias(String alias) {
    return $SetEntriesTable(attachedDatabase, alias);
  }
}

class SetEntry extends DataClass implements Insertable<SetEntry> {
  final String id;
  final String setId;
  final int sortIndex;

  /// Display label shown during practice (e.g. "Waltz"). Defaults to the
  /// source playlist's name if not set.
  final String label;
  final String? playlistId;
  final int? tempoPercent;
  final int? playDurationSeconds;
  final int? breakSeconds;
  const SetEntry({
    required this.id,
    required this.setId,
    required this.sortIndex,
    required this.label,
    this.playlistId,
    this.tempoPercent,
    this.playDurationSeconds,
    this.breakSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['set_id'] = Variable<String>(setId);
    map['sort_index'] = Variable<int>(sortIndex);
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || playlistId != null) {
      map['playlist_id'] = Variable<String>(playlistId);
    }
    if (!nullToAbsent || tempoPercent != null) {
      map['tempo_percent'] = Variable<int>(tempoPercent);
    }
    if (!nullToAbsent || playDurationSeconds != null) {
      map['play_duration_seconds'] = Variable<int>(playDurationSeconds);
    }
    if (!nullToAbsent || breakSeconds != null) {
      map['break_seconds'] = Variable<int>(breakSeconds);
    }
    return map;
  }

  SetEntriesCompanion toCompanion(bool nullToAbsent) {
    return SetEntriesCompanion(
      id: Value(id),
      setId: Value(setId),
      sortIndex: Value(sortIndex),
      label: Value(label),
      playlistId: playlistId == null && nullToAbsent
          ? const Value.absent()
          : Value(playlistId),
      tempoPercent: tempoPercent == null && nullToAbsent
          ? const Value.absent()
          : Value(tempoPercent),
      playDurationSeconds: playDurationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(playDurationSeconds),
      breakSeconds: breakSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(breakSeconds),
    );
  }

  factory SetEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SetEntry(
      id: serializer.fromJson<String>(json['id']),
      setId: serializer.fromJson<String>(json['setId']),
      sortIndex: serializer.fromJson<int>(json['sortIndex']),
      label: serializer.fromJson<String>(json['label']),
      playlistId: serializer.fromJson<String?>(json['playlistId']),
      tempoPercent: serializer.fromJson<int?>(json['tempoPercent']),
      playDurationSeconds: serializer.fromJson<int?>(
        json['playDurationSeconds'],
      ),
      breakSeconds: serializer.fromJson<int?>(json['breakSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'setId': serializer.toJson<String>(setId),
      'sortIndex': serializer.toJson<int>(sortIndex),
      'label': serializer.toJson<String>(label),
      'playlistId': serializer.toJson<String?>(playlistId),
      'tempoPercent': serializer.toJson<int?>(tempoPercent),
      'playDurationSeconds': serializer.toJson<int?>(playDurationSeconds),
      'breakSeconds': serializer.toJson<int?>(breakSeconds),
    };
  }

  SetEntry copyWith({
    String? id,
    String? setId,
    int? sortIndex,
    String? label,
    Value<String?> playlistId = const Value.absent(),
    Value<int?> tempoPercent = const Value.absent(),
    Value<int?> playDurationSeconds = const Value.absent(),
    Value<int?> breakSeconds = const Value.absent(),
  }) => SetEntry(
    id: id ?? this.id,
    setId: setId ?? this.setId,
    sortIndex: sortIndex ?? this.sortIndex,
    label: label ?? this.label,
    playlistId: playlistId.present ? playlistId.value : this.playlistId,
    tempoPercent: tempoPercent.present ? tempoPercent.value : this.tempoPercent,
    playDurationSeconds: playDurationSeconds.present
        ? playDurationSeconds.value
        : this.playDurationSeconds,
    breakSeconds: breakSeconds.present ? breakSeconds.value : this.breakSeconds,
  );
  SetEntry copyWithCompanion(SetEntriesCompanion data) {
    return SetEntry(
      id: data.id.present ? data.id.value : this.id,
      setId: data.setId.present ? data.setId.value : this.setId,
      sortIndex: data.sortIndex.present ? data.sortIndex.value : this.sortIndex,
      label: data.label.present ? data.label.value : this.label,
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      tempoPercent: data.tempoPercent.present
          ? data.tempoPercent.value
          : this.tempoPercent,
      playDurationSeconds: data.playDurationSeconds.present
          ? data.playDurationSeconds.value
          : this.playDurationSeconds,
      breakSeconds: data.breakSeconds.present
          ? data.breakSeconds.value
          : this.breakSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SetEntry(')
          ..write('id: $id, ')
          ..write('setId: $setId, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('label: $label, ')
          ..write('playlistId: $playlistId, ')
          ..write('tempoPercent: $tempoPercent, ')
          ..write('playDurationSeconds: $playDurationSeconds, ')
          ..write('breakSeconds: $breakSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    setId,
    sortIndex,
    label,
    playlistId,
    tempoPercent,
    playDurationSeconds,
    breakSeconds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SetEntry &&
          other.id == this.id &&
          other.setId == this.setId &&
          other.sortIndex == this.sortIndex &&
          other.label == this.label &&
          other.playlistId == this.playlistId &&
          other.tempoPercent == this.tempoPercent &&
          other.playDurationSeconds == this.playDurationSeconds &&
          other.breakSeconds == this.breakSeconds);
}

class SetEntriesCompanion extends UpdateCompanion<SetEntry> {
  final Value<String> id;
  final Value<String> setId;
  final Value<int> sortIndex;
  final Value<String> label;
  final Value<String?> playlistId;
  final Value<int?> tempoPercent;
  final Value<int?> playDurationSeconds;
  final Value<int?> breakSeconds;
  final Value<int> rowid;
  const SetEntriesCompanion({
    this.id = const Value.absent(),
    this.setId = const Value.absent(),
    this.sortIndex = const Value.absent(),
    this.label = const Value.absent(),
    this.playlistId = const Value.absent(),
    this.tempoPercent = const Value.absent(),
    this.playDurationSeconds = const Value.absent(),
    this.breakSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SetEntriesCompanion.insert({
    required String id,
    required String setId,
    required int sortIndex,
    required String label,
    this.playlistId = const Value.absent(),
    this.tempoPercent = const Value.absent(),
    this.playDurationSeconds = const Value.absent(),
    this.breakSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       setId = Value(setId),
       sortIndex = Value(sortIndex),
       label = Value(label);
  static Insertable<SetEntry> custom({
    Expression<String>? id,
    Expression<String>? setId,
    Expression<int>? sortIndex,
    Expression<String>? label,
    Expression<String>? playlistId,
    Expression<int>? tempoPercent,
    Expression<int>? playDurationSeconds,
    Expression<int>? breakSeconds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (setId != null) 'set_id': setId,
      if (sortIndex != null) 'sort_index': sortIndex,
      if (label != null) 'label': label,
      if (playlistId != null) 'playlist_id': playlistId,
      if (tempoPercent != null) 'tempo_percent': tempoPercent,
      if (playDurationSeconds != null)
        'play_duration_seconds': playDurationSeconds,
      if (breakSeconds != null) 'break_seconds': breakSeconds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SetEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? setId,
    Value<int>? sortIndex,
    Value<String>? label,
    Value<String?>? playlistId,
    Value<int?>? tempoPercent,
    Value<int?>? playDurationSeconds,
    Value<int?>? breakSeconds,
    Value<int>? rowid,
  }) {
    return SetEntriesCompanion(
      id: id ?? this.id,
      setId: setId ?? this.setId,
      sortIndex: sortIndex ?? this.sortIndex,
      label: label ?? this.label,
      playlistId: playlistId ?? this.playlistId,
      tempoPercent: tempoPercent ?? this.tempoPercent,
      playDurationSeconds: playDurationSeconds ?? this.playDurationSeconds,
      breakSeconds: breakSeconds ?? this.breakSeconds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (setId.present) {
      map['set_id'] = Variable<String>(setId.value);
    }
    if (sortIndex.present) {
      map['sort_index'] = Variable<int>(sortIndex.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (tempoPercent.present) {
      map['tempo_percent'] = Variable<int>(tempoPercent.value);
    }
    if (playDurationSeconds.present) {
      map['play_duration_seconds'] = Variable<int>(playDurationSeconds.value);
    }
    if (breakSeconds.present) {
      map['break_seconds'] = Variable<int>(breakSeconds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SetEntriesCompanion(')
          ..write('id: $id, ')
          ..write('setId: $setId, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('label: $label, ')
          ..write('playlistId: $playlistId, ')
          ..write('tempoPercent: $tempoPercent, ')
          ..write('playDurationSeconds: $playDurationSeconds, ')
          ..write('breakSeconds: $breakSeconds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BookmarkedFoldersTable bookmarkedFolders =
      $BookmarkedFoldersTable(this);
  late final $SongsTable songs = $SongsTable(this);
  late final $PlaylistsTable playlists = $PlaylistsTable(this);
  late final $PlaylistSongsTable playlistSongs = $PlaylistSongsTable(this);
  late final $PracticeSetsTable practiceSets = $PracticeSetsTable(this);
  late final $SetEntriesTable setEntries = $SetEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    bookmarkedFolders,
    songs,
    playlists,
    playlistSongs,
    practiceSets,
    setEntries,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'playlists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playlist_songs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'songs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playlist_songs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'practice_sets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('set_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'playlists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('set_entries', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$BookmarkedFoldersTableCreateCompanionBuilder =
    BookmarkedFoldersCompanion Function({
      required String id,
      required String treeUri,
      required String displayName,
      Value<DateTime> dateAdded,
      Value<int> rowid,
    });
typedef $$BookmarkedFoldersTableUpdateCompanionBuilder =
    BookmarkedFoldersCompanion Function({
      Value<String> id,
      Value<String> treeUri,
      Value<String> displayName,
      Value<DateTime> dateAdded,
      Value<int> rowid,
    });

final class $$BookmarkedFoldersTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $BookmarkedFoldersTable,
          BookmarkedFolder
        > {
  $$BookmarkedFoldersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$SongsTable, List<Song>> _songsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.songs,
    aliasName: 'bookmarked_folders__id__songs__source_folder_id',
  );

  $$SongsTableProcessedTableManager get songsRefs {
    final manager = $$SongsTableTableManager(
      $_db,
      $_db.songs,
    ).filter((f) => f.sourceFolderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_songsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BookmarkedFoldersTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarkedFoldersTable> {
  $$BookmarkedFoldersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get treeUri => $composableBuilder(
    column: $table.treeUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> songsRefs(
    Expression<bool> Function($$SongsTableFilterComposer f) f,
  ) {
    final $$SongsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.sourceFolderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableFilterComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BookmarkedFoldersTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarkedFoldersTable> {
  $$BookmarkedFoldersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get treeUri => $composableBuilder(
    column: $table.treeUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookmarkedFoldersTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarkedFoldersTable> {
  $$BookmarkedFoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get treeUri =>
      $composableBuilder(column: $table.treeUri, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateAdded =>
      $composableBuilder(column: $table.dateAdded, builder: (column) => column);

  Expression<T> songsRefs<T extends Object>(
    Expression<T> Function($$SongsTableAnnotationComposer a) f,
  ) {
    final $$SongsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.sourceFolderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableAnnotationComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BookmarkedFoldersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookmarkedFoldersTable,
          BookmarkedFolder,
          $$BookmarkedFoldersTableFilterComposer,
          $$BookmarkedFoldersTableOrderingComposer,
          $$BookmarkedFoldersTableAnnotationComposer,
          $$BookmarkedFoldersTableCreateCompanionBuilder,
          $$BookmarkedFoldersTableUpdateCompanionBuilder,
          (BookmarkedFolder, $$BookmarkedFoldersTableReferences),
          BookmarkedFolder,
          PrefetchHooks Function({bool songsRefs})
        > {
  $$BookmarkedFoldersTableTableManager(
    _$AppDatabase db,
    $BookmarkedFoldersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarkedFoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarkedFoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarkedFoldersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> treeUri = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<DateTime> dateAdded = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookmarkedFoldersCompanion(
                id: id,
                treeUri: treeUri,
                displayName: displayName,
                dateAdded: dateAdded,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String treeUri,
                required String displayName,
                Value<DateTime> dateAdded = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookmarkedFoldersCompanion.insert(
                id: id,
                treeUri: treeUri,
                displayName: displayName,
                dateAdded: dateAdded,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BookmarkedFoldersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({songsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (songsRefs) db.songs],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (songsRefs)
                    await $_getPrefetchedData<
                      BookmarkedFolder,
                      $BookmarkedFoldersTable,
                      Song
                    >(
                      currentTable: table,
                      referencedTable: $$BookmarkedFoldersTableReferences
                          ._songsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$BookmarkedFoldersTableReferences(
                            db,
                            table,
                            p0,
                          ).songsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.sourceFolderId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$BookmarkedFoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookmarkedFoldersTable,
      BookmarkedFolder,
      $$BookmarkedFoldersTableFilterComposer,
      $$BookmarkedFoldersTableOrderingComposer,
      $$BookmarkedFoldersTableAnnotationComposer,
      $$BookmarkedFoldersTableCreateCompanionBuilder,
      $$BookmarkedFoldersTableUpdateCompanionBuilder,
      (BookmarkedFolder, $$BookmarkedFoldersTableReferences),
      BookmarkedFolder,
      PrefetchHooks Function({bool songsRefs})
    >;
typedef $$SongsTableCreateCompanionBuilder =
    SongsCompanion Function({
      required String id,
      required String uri,
      required String title,
      Value<String?> artist,
      Value<String?> album,
      Value<int?> durationMs,
      Value<double?> bpmDetected,
      Value<double?> bpmManual,
      Value<DateTime> dateAdded,
      Value<String?> sourceFolderId,
      Value<bool> isHidden,
      Value<bool> isFavorite,
      Value<int> rowid,
    });
typedef $$SongsTableUpdateCompanionBuilder =
    SongsCompanion Function({
      Value<String> id,
      Value<String> uri,
      Value<String> title,
      Value<String?> artist,
      Value<String?> album,
      Value<int?> durationMs,
      Value<double?> bpmDetected,
      Value<double?> bpmManual,
      Value<DateTime> dateAdded,
      Value<String?> sourceFolderId,
      Value<bool> isHidden,
      Value<bool> isFavorite,
      Value<int> rowid,
    });

final class $$SongsTableReferences
    extends BaseReferences<_$AppDatabase, $SongsTable, Song> {
  $$SongsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BookmarkedFoldersTable _sourceFolderIdTable(_$AppDatabase db) => db
      .bookmarkedFolders
      .createAlias('songs__source_folder_id__bookmarked_folders__id');

  $$BookmarkedFoldersTableProcessedTableManager? get sourceFolderId {
    final $_column = $_itemColumn<String>('source_folder_id');
    if ($_column == null) return null;
    final manager = $$BookmarkedFoldersTableTableManager(
      $_db,
      $_db.bookmarkedFolders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceFolderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PlaylistSongsTable, List<PlaylistSong>>
  _playlistSongsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playlistSongs,
    aliasName: 'songs__id__playlist_songs__song_id',
  );

  $$PlaylistSongsTableProcessedTableManager get playlistSongsRefs {
    final manager = $$PlaylistSongsTableTableManager(
      $_db,
      $_db.playlistSongs,
    ).filter((f) => f.songId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_playlistSongsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SongsTableFilterComposer extends Composer<_$AppDatabase, $SongsTable> {
  $$SongsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uri => $composableBuilder(
    column: $table.uri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bpmDetected => $composableBuilder(
    column: $table.bpmDetected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bpmManual => $composableBuilder(
    column: $table.bpmManual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  $$BookmarkedFoldersTableFilterComposer get sourceFolderId {
    final $$BookmarkedFoldersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceFolderId,
      referencedTable: $db.bookmarkedFolders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarkedFoldersTableFilterComposer(
            $db: $db,
            $table: $db.bookmarkedFolders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> playlistSongsRefs(
    Expression<bool> Function($$PlaylistSongsTableFilterComposer f) f,
  ) {
    final $$PlaylistSongsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistSongs,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistSongsTableFilterComposer(
            $db: $db,
            $table: $db.playlistSongs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SongsTableOrderingComposer
    extends Composer<_$AppDatabase, $SongsTable> {
  $$SongsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uri => $composableBuilder(
    column: $table.uri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bpmDetected => $composableBuilder(
    column: $table.bpmDetected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bpmManual => $composableBuilder(
    column: $table.bpmManual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  $$BookmarkedFoldersTableOrderingComposer get sourceFolderId {
    final $$BookmarkedFoldersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceFolderId,
      referencedTable: $db.bookmarkedFolders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarkedFoldersTableOrderingComposer(
            $db: $db,
            $table: $db.bookmarkedFolders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SongsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SongsTable> {
  $$SongsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uri =>
      $composableBuilder(column: $table.uri, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<double> get bpmDetected => $composableBuilder(
    column: $table.bpmDetected,
    builder: (column) => column,
  );

  GeneratedColumn<double> get bpmManual =>
      $composableBuilder(column: $table.bpmManual, builder: (column) => column);

  GeneratedColumn<DateTime> get dateAdded =>
      $composableBuilder(column: $table.dateAdded, builder: (column) => column);

  GeneratedColumn<bool> get isHidden =>
      $composableBuilder(column: $table.isHidden, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  $$BookmarkedFoldersTableAnnotationComposer get sourceFolderId {
    final $$BookmarkedFoldersTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sourceFolderId,
          referencedTable: $db.bookmarkedFolders,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BookmarkedFoldersTableAnnotationComposer(
                $db: $db,
                $table: $db.bookmarkedFolders,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> playlistSongsRefs<T extends Object>(
    Expression<T> Function($$PlaylistSongsTableAnnotationComposer a) f,
  ) {
    final $$PlaylistSongsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistSongs,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistSongsTableAnnotationComposer(
            $db: $db,
            $table: $db.playlistSongs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SongsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SongsTable,
          Song,
          $$SongsTableFilterComposer,
          $$SongsTableOrderingComposer,
          $$SongsTableAnnotationComposer,
          $$SongsTableCreateCompanionBuilder,
          $$SongsTableUpdateCompanionBuilder,
          (Song, $$SongsTableReferences),
          Song,
          PrefetchHooks Function({bool sourceFolderId, bool playlistSongsRefs})
        > {
  $$SongsTableTableManager(_$AppDatabase db, $SongsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> uri = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<double?> bpmDetected = const Value.absent(),
                Value<double?> bpmManual = const Value.absent(),
                Value<DateTime> dateAdded = const Value.absent(),
                Value<String?> sourceFolderId = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SongsCompanion(
                id: id,
                uri: uri,
                title: title,
                artist: artist,
                album: album,
                durationMs: durationMs,
                bpmDetected: bpmDetected,
                bpmManual: bpmManual,
                dateAdded: dateAdded,
                sourceFolderId: sourceFolderId,
                isHidden: isHidden,
                isFavorite: isFavorite,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String uri,
                required String title,
                Value<String?> artist = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<double?> bpmDetected = const Value.absent(),
                Value<double?> bpmManual = const Value.absent(),
                Value<DateTime> dateAdded = const Value.absent(),
                Value<String?> sourceFolderId = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SongsCompanion.insert(
                id: id,
                uri: uri,
                title: title,
                artist: artist,
                album: album,
                durationMs: durationMs,
                bpmDetected: bpmDetected,
                bpmManual: bpmManual,
                dateAdded: dateAdded,
                sourceFolderId: sourceFolderId,
                isHidden: isHidden,
                isFavorite: isFavorite,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$SongsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({sourceFolderId = false, playlistSongsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (playlistSongsRefs) db.playlistSongs,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sourceFolderId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceFolderId,
                                    referencedTable: $$SongsTableReferences
                                        ._sourceFolderIdTable(db),
                                    referencedColumn: $$SongsTableReferences
                                        ._sourceFolderIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (playlistSongsRefs)
                        await $_getPrefetchedData<
                          Song,
                          $SongsTable,
                          PlaylistSong
                        >(
                          currentTable: table,
                          referencedTable: $$SongsTableReferences
                              ._playlistSongsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SongsTableReferences(
                                db,
                                table,
                                p0,
                              ).playlistSongsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.songId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SongsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SongsTable,
      Song,
      $$SongsTableFilterComposer,
      $$SongsTableOrderingComposer,
      $$SongsTableAnnotationComposer,
      $$SongsTableCreateCompanionBuilder,
      $$SongsTableUpdateCompanionBuilder,
      (Song, $$SongsTableReferences),
      Song,
      PrefetchHooks Function({bool sourceFolderId, bool playlistSongsRefs})
    >;
typedef $$PlaylistsTableCreateCompanionBuilder =
    PlaylistsCompanion Function({
      required String id,
      required String name,
      Value<DateTime> dateCreated,
      Value<int> rowid,
    });
typedef $$PlaylistsTableUpdateCompanionBuilder =
    PlaylistsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime> dateCreated,
      Value<int> rowid,
    });

final class $$PlaylistsTableReferences
    extends BaseReferences<_$AppDatabase, $PlaylistsTable, Playlist> {
  $$PlaylistsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlaylistSongsTable, List<PlaylistSong>>
  _playlistSongsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playlistSongs,
    aliasName: 'playlists__id__playlist_songs__playlist_id',
  );

  $$PlaylistSongsTableProcessedTableManager get playlistSongsRefs {
    final manager = $$PlaylistSongsTableTableManager(
      $_db,
      $_db.playlistSongs,
    ).filter((f) => f.playlistId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_playlistSongsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SetEntriesTable, List<SetEntry>>
  _setEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.setEntries,
    aliasName: 'playlists__id__set_entries__playlist_id',
  );

  $$SetEntriesTableProcessedTableManager get setEntriesRefs {
    final manager = $$SetEntriesTableTableManager(
      $_db,
      $_db.setEntries,
    ).filter((f) => f.playlistId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_setEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlaylistsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playlistSongsRefs(
    Expression<bool> Function($$PlaylistSongsTableFilterComposer f) f,
  ) {
    final $$PlaylistSongsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistSongs,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistSongsTableFilterComposer(
            $db: $db,
            $table: $db.playlistSongs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> setEntriesRefs(
    Expression<bool> Function($$SetEntriesTableFilterComposer f) f,
  ) {
    final $$SetEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.setEntries,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetEntriesTableFilterComposer(
            $db: $db,
            $table: $db.setEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaylistsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaylistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => column,
  );

  Expression<T> playlistSongsRefs<T extends Object>(
    Expression<T> Function($$PlaylistSongsTableAnnotationComposer a) f,
  ) {
    final $$PlaylistSongsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistSongs,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistSongsTableAnnotationComposer(
            $db: $db,
            $table: $db.playlistSongs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> setEntriesRefs<T extends Object>(
    Expression<T> Function($$SetEntriesTableAnnotationComposer a) f,
  ) {
    final $$SetEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.setEntries,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.setEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaylistsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistsTable,
          Playlist,
          $$PlaylistsTableFilterComposer,
          $$PlaylistsTableOrderingComposer,
          $$PlaylistsTableAnnotationComposer,
          $$PlaylistsTableCreateCompanionBuilder,
          $$PlaylistsTableUpdateCompanionBuilder,
          (Playlist, $$PlaylistsTableReferences),
          Playlist,
          PrefetchHooks Function({bool playlistSongsRefs, bool setEntriesRefs})
        > {
  $$PlaylistsTableTableManager(_$AppDatabase db, $PlaylistsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> dateCreated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistsCompanion(
                id: id,
                name: name,
                dateCreated: dateCreated,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<DateTime> dateCreated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistsCompanion.insert(
                id: id,
                name: name,
                dateCreated: dateCreated,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaylistsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({playlistSongsRefs = false, setEntriesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (playlistSongsRefs) db.playlistSongs,
                    if (setEntriesRefs) db.setEntries,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (playlistSongsRefs)
                        await $_getPrefetchedData<
                          Playlist,
                          $PlaylistsTable,
                          PlaylistSong
                        >(
                          currentTable: table,
                          referencedTable: $$PlaylistsTableReferences
                              ._playlistSongsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlaylistsTableReferences(
                                db,
                                table,
                                p0,
                              ).playlistSongsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.playlistId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (setEntriesRefs)
                        await $_getPrefetchedData<
                          Playlist,
                          $PlaylistsTable,
                          SetEntry
                        >(
                          currentTable: table,
                          referencedTable: $$PlaylistsTableReferences
                              ._setEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlaylistsTableReferences(
                                db,
                                table,
                                p0,
                              ).setEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.playlistId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PlaylistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistsTable,
      Playlist,
      $$PlaylistsTableFilterComposer,
      $$PlaylistsTableOrderingComposer,
      $$PlaylistsTableAnnotationComposer,
      $$PlaylistsTableCreateCompanionBuilder,
      $$PlaylistsTableUpdateCompanionBuilder,
      (Playlist, $$PlaylistsTableReferences),
      Playlist,
      PrefetchHooks Function({bool playlistSongsRefs, bool setEntriesRefs})
    >;
typedef $$PlaylistSongsTableCreateCompanionBuilder =
    PlaylistSongsCompanion Function({
      required String playlistId,
      required String songId,
      required int sortIndex,
      Value<int> rowid,
    });
typedef $$PlaylistSongsTableUpdateCompanionBuilder =
    PlaylistSongsCompanion Function({
      Value<String> playlistId,
      Value<String> songId,
      Value<int> sortIndex,
      Value<int> rowid,
    });

final class $$PlaylistSongsTableReferences
    extends BaseReferences<_$AppDatabase, $PlaylistSongsTable, PlaylistSong> {
  $$PlaylistSongsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlaylistsTable _playlistIdTable(_$AppDatabase db) =>
      db.playlists.createAlias('playlist_songs__playlist_id__playlists__id');

  $$PlaylistsTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<String>('playlist_id')!;

    final manager = $$PlaylistsTableTableManager(
      $_db,
      $_db.playlists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SongsTable _songIdTable(_$AppDatabase db) =>
      db.songs.createAlias('playlist_songs__song_id__songs__id');

  $$SongsTableProcessedTableManager get songId {
    final $_column = $_itemColumn<String>('song_id')!;

    final manager = $$SongsTableTableManager(
      $_db,
      $_db.songs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_songIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlaylistSongsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistSongsTable> {
  $$PlaylistSongsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnFilters(column),
  );

  $$PlaylistsTableFilterComposer get playlistId {
    final $$PlaylistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableFilterComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SongsTableFilterComposer get songId {
    final $$SongsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableFilterComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistSongsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistSongsTable> {
  $$PlaylistSongsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlaylistsTableOrderingComposer get playlistId {
    final $$PlaylistsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableOrderingComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SongsTableOrderingComposer get songId {
    final $$SongsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableOrderingComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistSongsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistSongsTable> {
  $$PlaylistSongsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get sortIndex =>
      $composableBuilder(column: $table.sortIndex, builder: (column) => column);

  $$PlaylistsTableAnnotationComposer get playlistId {
    final $$PlaylistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableAnnotationComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SongsTableAnnotationComposer get songId {
    final $$SongsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableAnnotationComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistSongsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistSongsTable,
          PlaylistSong,
          $$PlaylistSongsTableFilterComposer,
          $$PlaylistSongsTableOrderingComposer,
          $$PlaylistSongsTableAnnotationComposer,
          $$PlaylistSongsTableCreateCompanionBuilder,
          $$PlaylistSongsTableUpdateCompanionBuilder,
          (PlaylistSong, $$PlaylistSongsTableReferences),
          PlaylistSong,
          PrefetchHooks Function({bool playlistId, bool songId})
        > {
  $$PlaylistSongsTableTableManager(_$AppDatabase db, $PlaylistSongsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistSongsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistSongsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistSongsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> playlistId = const Value.absent(),
                Value<String> songId = const Value.absent(),
                Value<int> sortIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistSongsCompanion(
                playlistId: playlistId,
                songId: songId,
                sortIndex: sortIndex,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String playlistId,
                required String songId,
                required int sortIndex,
                Value<int> rowid = const Value.absent(),
              }) => PlaylistSongsCompanion.insert(
                playlistId: playlistId,
                songId: songId,
                sortIndex: sortIndex,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaylistSongsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistId = false, songId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (playlistId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.playlistId,
                                referencedTable: $$PlaylistSongsTableReferences
                                    ._playlistIdTable(db),
                                referencedColumn: $$PlaylistSongsTableReferences
                                    ._playlistIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (songId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.songId,
                                referencedTable: $$PlaylistSongsTableReferences
                                    ._songIdTable(db),
                                referencedColumn: $$PlaylistSongsTableReferences
                                    ._songIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistSongsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistSongsTable,
      PlaylistSong,
      $$PlaylistSongsTableFilterComposer,
      $$PlaylistSongsTableOrderingComposer,
      $$PlaylistSongsTableAnnotationComposer,
      $$PlaylistSongsTableCreateCompanionBuilder,
      $$PlaylistSongsTableUpdateCompanionBuilder,
      (PlaylistSong, $$PlaylistSongsTableReferences),
      PlaylistSong,
      PrefetchHooks Function({bool playlistId, bool songId})
    >;
typedef $$PracticeSetsTableCreateCompanionBuilder =
    PracticeSetsCompanion Function({
      required String id,
      required String name,
      Value<int> defaultTempoPercent,
      Value<int> defaultPlayDurationSeconds,
      Value<int> defaultBreakSeconds,
      Value<bool> repeatEnabled,
      Value<DateTime> dateCreated,
      Value<int> rowid,
    });
typedef $$PracticeSetsTableUpdateCompanionBuilder =
    PracticeSetsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> defaultTempoPercent,
      Value<int> defaultPlayDurationSeconds,
      Value<int> defaultBreakSeconds,
      Value<bool> repeatEnabled,
      Value<DateTime> dateCreated,
      Value<int> rowid,
    });

final class $$PracticeSetsTableReferences
    extends BaseReferences<_$AppDatabase, $PracticeSetsTable, PracticeSet> {
  $$PracticeSetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SetEntriesTable, List<SetEntry>>
  _setEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.setEntries,
    aliasName: 'practice_sets__id__set_entries__set_id',
  );

  $$SetEntriesTableProcessedTableManager get setEntriesRefs {
    final manager = $$SetEntriesTableTableManager(
      $_db,
      $_db.setEntries,
    ).filter((f) => f.setId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_setEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PracticeSetsTableFilterComposer
    extends Composer<_$AppDatabase, $PracticeSetsTable> {
  $$PracticeSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultTempoPercent => $composableBuilder(
    column: $table.defaultTempoPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultPlayDurationSeconds => $composableBuilder(
    column: $table.defaultPlayDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultBreakSeconds => $composableBuilder(
    column: $table.defaultBreakSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get repeatEnabled => $composableBuilder(
    column: $table.repeatEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> setEntriesRefs(
    Expression<bool> Function($$SetEntriesTableFilterComposer f) f,
  ) {
    final $$SetEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.setEntries,
      getReferencedColumn: (t) => t.setId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetEntriesTableFilterComposer(
            $db: $db,
            $table: $db.setEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PracticeSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $PracticeSetsTable> {
  $$PracticeSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultTempoPercent => $composableBuilder(
    column: $table.defaultTempoPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultPlayDurationSeconds => $composableBuilder(
    column: $table.defaultPlayDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultBreakSeconds => $composableBuilder(
    column: $table.defaultBreakSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get repeatEnabled => $composableBuilder(
    column: $table.repeatEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PracticeSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PracticeSetsTable> {
  $$PracticeSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get defaultTempoPercent => $composableBuilder(
    column: $table.defaultTempoPercent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultPlayDurationSeconds => $composableBuilder(
    column: $table.defaultPlayDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultBreakSeconds => $composableBuilder(
    column: $table.defaultBreakSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get repeatEnabled => $composableBuilder(
    column: $table.repeatEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => column,
  );

  Expression<T> setEntriesRefs<T extends Object>(
    Expression<T> Function($$SetEntriesTableAnnotationComposer a) f,
  ) {
    final $$SetEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.setEntries,
      getReferencedColumn: (t) => t.setId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.setEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PracticeSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PracticeSetsTable,
          PracticeSet,
          $$PracticeSetsTableFilterComposer,
          $$PracticeSetsTableOrderingComposer,
          $$PracticeSetsTableAnnotationComposer,
          $$PracticeSetsTableCreateCompanionBuilder,
          $$PracticeSetsTableUpdateCompanionBuilder,
          (PracticeSet, $$PracticeSetsTableReferences),
          PracticeSet,
          PrefetchHooks Function({bool setEntriesRefs})
        > {
  $$PracticeSetsTableTableManager(_$AppDatabase db, $PracticeSetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PracticeSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PracticeSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PracticeSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> defaultTempoPercent = const Value.absent(),
                Value<int> defaultPlayDurationSeconds = const Value.absent(),
                Value<int> defaultBreakSeconds = const Value.absent(),
                Value<bool> repeatEnabled = const Value.absent(),
                Value<DateTime> dateCreated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PracticeSetsCompanion(
                id: id,
                name: name,
                defaultTempoPercent: defaultTempoPercent,
                defaultPlayDurationSeconds: defaultPlayDurationSeconds,
                defaultBreakSeconds: defaultBreakSeconds,
                repeatEnabled: repeatEnabled,
                dateCreated: dateCreated,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int> defaultTempoPercent = const Value.absent(),
                Value<int> defaultPlayDurationSeconds = const Value.absent(),
                Value<int> defaultBreakSeconds = const Value.absent(),
                Value<bool> repeatEnabled = const Value.absent(),
                Value<DateTime> dateCreated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PracticeSetsCompanion.insert(
                id: id,
                name: name,
                defaultTempoPercent: defaultTempoPercent,
                defaultPlayDurationSeconds: defaultPlayDurationSeconds,
                defaultBreakSeconds: defaultBreakSeconds,
                repeatEnabled: repeatEnabled,
                dateCreated: dateCreated,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PracticeSetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({setEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (setEntriesRefs) db.setEntries],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (setEntriesRefs)
                    await $_getPrefetchedData<
                      PracticeSet,
                      $PracticeSetsTable,
                      SetEntry
                    >(
                      currentTable: table,
                      referencedTable: $$PracticeSetsTableReferences
                          ._setEntriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PracticeSetsTableReferences(
                            db,
                            table,
                            p0,
                          ).setEntriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.setId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PracticeSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PracticeSetsTable,
      PracticeSet,
      $$PracticeSetsTableFilterComposer,
      $$PracticeSetsTableOrderingComposer,
      $$PracticeSetsTableAnnotationComposer,
      $$PracticeSetsTableCreateCompanionBuilder,
      $$PracticeSetsTableUpdateCompanionBuilder,
      (PracticeSet, $$PracticeSetsTableReferences),
      PracticeSet,
      PrefetchHooks Function({bool setEntriesRefs})
    >;
typedef $$SetEntriesTableCreateCompanionBuilder =
    SetEntriesCompanion Function({
      required String id,
      required String setId,
      required int sortIndex,
      required String label,
      Value<String?> playlistId,
      Value<int?> tempoPercent,
      Value<int?> playDurationSeconds,
      Value<int?> breakSeconds,
      Value<int> rowid,
    });
typedef $$SetEntriesTableUpdateCompanionBuilder =
    SetEntriesCompanion Function({
      Value<String> id,
      Value<String> setId,
      Value<int> sortIndex,
      Value<String> label,
      Value<String?> playlistId,
      Value<int?> tempoPercent,
      Value<int?> playDurationSeconds,
      Value<int?> breakSeconds,
      Value<int> rowid,
    });

final class $$SetEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $SetEntriesTable, SetEntry> {
  $$SetEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PracticeSetsTable _setIdTable(_$AppDatabase db) =>
      db.practiceSets.createAlias('set_entries__set_id__practice_sets__id');

  $$PracticeSetsTableProcessedTableManager get setId {
    final $_column = $_itemColumn<String>('set_id')!;

    final manager = $$PracticeSetsTableTableManager(
      $_db,
      $_db.practiceSets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_setIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlaylistsTable _playlistIdTable(_$AppDatabase db) =>
      db.playlists.createAlias('set_entries__playlist_id__playlists__id');

  $$PlaylistsTableProcessedTableManager? get playlistId {
    final $_column = $_itemColumn<String>('playlist_id');
    if ($_column == null) return null;
    final manager = $$PlaylistsTableTableManager(
      $_db,
      $_db.playlists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SetEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SetEntriesTable> {
  $$SetEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tempoPercent => $composableBuilder(
    column: $table.tempoPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playDurationSeconds => $composableBuilder(
    column: $table.playDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get breakSeconds => $composableBuilder(
    column: $table.breakSeconds,
    builder: (column) => ColumnFilters(column),
  );

  $$PracticeSetsTableFilterComposer get setId {
    final $$PracticeSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.setId,
      referencedTable: $db.practiceSets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSetsTableFilterComposer(
            $db: $db,
            $table: $db.practiceSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlaylistsTableFilterComposer get playlistId {
    final $$PlaylistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableFilterComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SetEntriesTable> {
  $$SetEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tempoPercent => $composableBuilder(
    column: $table.tempoPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playDurationSeconds => $composableBuilder(
    column: $table.playDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get breakSeconds => $composableBuilder(
    column: $table.breakSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  $$PracticeSetsTableOrderingComposer get setId {
    final $$PracticeSetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.setId,
      referencedTable: $db.practiceSets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSetsTableOrderingComposer(
            $db: $db,
            $table: $db.practiceSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlaylistsTableOrderingComposer get playlistId {
    final $$PlaylistsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableOrderingComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SetEntriesTable> {
  $$SetEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sortIndex =>
      $composableBuilder(column: $table.sortIndex, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get tempoPercent => $composableBuilder(
    column: $table.tempoPercent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get playDurationSeconds => $composableBuilder(
    column: $table.playDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get breakSeconds => $composableBuilder(
    column: $table.breakSeconds,
    builder: (column) => column,
  );

  $$PracticeSetsTableAnnotationComposer get setId {
    final $$PracticeSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.setId,
      referencedTable: $db.practiceSets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.practiceSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlaylistsTableAnnotationComposer get playlistId {
    final $$PlaylistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableAnnotationComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SetEntriesTable,
          SetEntry,
          $$SetEntriesTableFilterComposer,
          $$SetEntriesTableOrderingComposer,
          $$SetEntriesTableAnnotationComposer,
          $$SetEntriesTableCreateCompanionBuilder,
          $$SetEntriesTableUpdateCompanionBuilder,
          (SetEntry, $$SetEntriesTableReferences),
          SetEntry,
          PrefetchHooks Function({bool setId, bool playlistId})
        > {
  $$SetEntriesTableTableManager(_$AppDatabase db, $SetEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SetEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SetEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SetEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> setId = const Value.absent(),
                Value<int> sortIndex = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String?> playlistId = const Value.absent(),
                Value<int?> tempoPercent = const Value.absent(),
                Value<int?> playDurationSeconds = const Value.absent(),
                Value<int?> breakSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SetEntriesCompanion(
                id: id,
                setId: setId,
                sortIndex: sortIndex,
                label: label,
                playlistId: playlistId,
                tempoPercent: tempoPercent,
                playDurationSeconds: playDurationSeconds,
                breakSeconds: breakSeconds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String setId,
                required int sortIndex,
                required String label,
                Value<String?> playlistId = const Value.absent(),
                Value<int?> tempoPercent = const Value.absent(),
                Value<int?> playDurationSeconds = const Value.absent(),
                Value<int?> breakSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SetEntriesCompanion.insert(
                id: id,
                setId: setId,
                sortIndex: sortIndex,
                label: label,
                playlistId: playlistId,
                tempoPercent: tempoPercent,
                playDurationSeconds: playDurationSeconds,
                breakSeconds: breakSeconds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SetEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({setId = false, playlistId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (setId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.setId,
                                referencedTable: $$SetEntriesTableReferences
                                    ._setIdTable(db),
                                referencedColumn: $$SetEntriesTableReferences
                                    ._setIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (playlistId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.playlistId,
                                referencedTable: $$SetEntriesTableReferences
                                    ._playlistIdTable(db),
                                referencedColumn: $$SetEntriesTableReferences
                                    ._playlistIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SetEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SetEntriesTable,
      SetEntry,
      $$SetEntriesTableFilterComposer,
      $$SetEntriesTableOrderingComposer,
      $$SetEntriesTableAnnotationComposer,
      $$SetEntriesTableCreateCompanionBuilder,
      $$SetEntriesTableUpdateCompanionBuilder,
      (SetEntry, $$SetEntriesTableReferences),
      SetEntry,
      PrefetchHooks Function({bool setId, bool playlistId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BookmarkedFoldersTableTableManager get bookmarkedFolders =>
      $$BookmarkedFoldersTableTableManager(_db, _db.bookmarkedFolders);
  $$SongsTableTableManager get songs =>
      $$SongsTableTableManager(_db, _db.songs);
  $$PlaylistsTableTableManager get playlists =>
      $$PlaylistsTableTableManager(_db, _db.playlists);
  $$PlaylistSongsTableTableManager get playlistSongs =>
      $$PlaylistSongsTableTableManager(_db, _db.playlistSongs);
  $$PracticeSetsTableTableManager get practiceSets =>
      $$PracticeSetsTableTableManager(_db, _db.practiceSets);
  $$SetEntriesTableTableManager get setEntries =>
      $$SetEntriesTableTableManager(_db, _db.setEntries);
}
