import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:survey_dogapp/components/City/Model/LocationModel.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    return _database ??= await initDB();
  }

  Future<String?> getLocationNameById(int id) async {
    final db = await database;
    final result = await db.query(
      'locations',
      where: 'location_id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first['location_name'] as String?;
    }
    return null;
  }


  // Clear all locations from the database
  Future<void> clearAllLocations() async {
    final db = await database;
    await db.delete('locations');  // Assuming your table name is 'locations'
  }
  Future<void> deleteLocation(int locationId) async {
    final db = await database;
    await db.delete(
      'locations', // your table name
      where: 'location_id = ?',
      whereArgs: [locationId],
    );
  }

  Future<void> updateLocation(int locationId, String locationName) async {
    final db = await database;

    await db.update(
      'locations',
      {
        'location_name': locationName,
      },
      where: 'location_id = ?',
      whereArgs: [locationId],
    );
  }

  Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'location_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE locations (
            location_id INTEGER PRIMARY KEY,
            parent_id INTEGER,
            location_name TEXT,
            location_type TEXT,
            latitude TEXT,
            longitude TEXT,
            ward_no TEXT,
            deletestatus INTEGER,
            user_id INTEGER,
            created_at TEXT,
            updated_at TEXT,
            dogtype_id TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertAll(List<LocationModel> locations) async {
    final db = await database;
    final batch = db.batch();

    for (var location in locations) {
      batch.insert(
        'locations',
        location.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<LocationModel>> getStates() async {
    final db = await database;
    final maps = await db.query(
      'locations',
      where: 'location_type = ? AND parent_id = ?',
      whereArgs: ['State', 0],
    );
    return maps.map((map) => LocationModel.fromMap(map)).toList();
  }

  Future<List<LocationModel>> getCitiesByState(int stateId) async {
    final db = await database;
    final maps = await db.query(
      'locations',
      where: 'location_type = ? AND parent_id = ?',
      whereArgs: ['City', stateId],
    );
    return maps.map((map) => LocationModel.fromMap(map)).toList();
  }

  Future<List<LocationModel>> getZonesByCity(int cityId) async {
    final db = await database;
    final maps = await db.query(
      'locations',
      where: 'location_type = ? AND parent_id = ?',
      whereArgs: ['Zone', cityId],
    );
    print("Zones fetched: ${maps.length}");
    return maps.map((map) => LocationModel.fromMap(map)).toList();
  }

  Future<List<LocationModel>> getWardsByZone(int zoneId) async {
    final db = await database;
    final maps = await db.query(
      'locations',
      where: 'location_type = ? AND parent_id = ?',
      whereArgs: ['Ward', zoneId],
    );
    return maps.map((map) => LocationModel.fromMap(map)).toList();
  }

  Future<List<LocationModel>> getAreaByWards(int areaId) async {
    final db = await database;
    final maps = await db.query(
      'locations',
      where: 'location_type = ? AND parent_id = ?',
      whereArgs: ['Area', areaId],
    );
    return maps.map((map) => LocationModel.fromMap(map)).toList();
  }

  Future<LocationModel?> getLocationById(int id) async {
    final db = await database;
    final result = await db.query(
      'locations',
      where: 'location_id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return LocationModel.fromMap(result.first);
    }
    return null;
  }

  Future<List<LocationModel>> getStatesList({List<int> parentIds = const [0]}) async {
    final db = await database;
    final inClause = _buildInClause(parentIds.length);

    final maps = await db.query(
      'locations',
      where: 'location_type = ? AND parent_id IN ($inClause)',
      whereArgs: ['State', ...parentIds],
    );

    return maps.map((map) => LocationModel.fromMap(map)).toList();
  }

  Future<List<LocationModel>> getCitiesByStates(List<int> stateIds) async {
    if (stateIds.isEmpty) return [];
    final db = await database;
    final inClause = _buildInClause(stateIds.length);

    final maps = await db.query(
      'locations',
      where: 'location_type = ? AND parent_id IN ($inClause)',
      whereArgs: ['City', ...stateIds],
    );

    return maps.map((map) => LocationModel.fromMap(map)).toList();
  }

  Future<List<LocationModel>> getZonesByCities(List<int> cityIds) async {
    if (cityIds.isEmpty) return [];
    final db = await database;
    final inClause = _buildInClause(cityIds.length);

    final maps = await db.query(
      'locations',
      where: 'location_type = ? AND parent_id IN ($inClause)',
      whereArgs: ['Zone', ...cityIds],
    );

    return maps.map((map) => LocationModel.fromMap(map)).toList();
  }

  Future<List<LocationModel>> getWardsByZones(List<int> zoneIds) async {
    if (zoneIds.isEmpty) return [];
    final db = await database;
    final inClause = _buildInClause(zoneIds.length);

    final maps = await db.query(
      'locations',
      where: 'location_type = ? AND parent_id IN ($inClause)',
      whereArgs: ['Ward', ...zoneIds],
    );

    return maps.map((map) => LocationModel.fromMap(map)).toList();
  }

  Future<List<LocationModel>> getAreasByWards(List<int> areaIds) async {
    if (areaIds.isEmpty) return [];
    final db = await database;
    final inClause = _buildInClause(areaIds.length);

    final maps = await db.query(
      'locations',
      where: 'location_type = ? AND parent_id IN ($inClause)',
      whereArgs: ['Area', ...areaIds],
    );

    return maps.map((map) => LocationModel.fromMap(map)).toList();
  }

  Future<List<LocationModel>> getLocationsByTypeAndParentIds({
    required String type,
    required List<int> parentIds,
  }) async {
    if (parentIds.isEmpty) return [];
    final db = await database;
    final inClause = _buildInClause(parentIds.length);

    final maps = await db.query(
      'locations',
      where: 'location_type = ? AND parent_id IN ($inClause)',
      whereArgs: [type, ...parentIds],
    );

    return maps.map((map) => LocationModel.fromMap(map)).toList();
  }

  String _buildInClause(int count) => List.filled(count, '?').join(', ');




}
