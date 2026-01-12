// FILE: lib/helpers/database_helper.dart

import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

// This is the 'Job' class that your files can't find
class Job {
  final int? id; // Nullable for insertion, as DB will assign it
  final String title;
  final String company;
  final String location;
  final String logo; // We'll store the logo icon's name or a key

  Job({
    this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.logo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'logo': logo,
    };
  }

  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      id: map['id'],
      title: map['title'],
      company: map['company'],
      location: map['location'],
      logo: map['logo'],
    );
  }
}

class DatabaseHelper {
  static const _databaseName = "JobPortal.db";
  static const _databaseVersion = 1;

  static const table = 'saved_jobs';
  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnCompany = 'company';
  static const columnLocation = 'location';
  static const columnLogo = 'logo'; // To store the icon

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTitle TEXT NOT NULL,
        $columnCompany TEXT NOT NULL,
        $columnLocation TEXT NOT NULL,
        $columnLogo TEXT NOT NULL
      )
      ''');
  }

  Future<int> insertJob(Job job) async {
    Database db = await instance.database;
    return await db.insert(table, job.toMap());
  }

  Future<List<Job>> getAllSavedJobs() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(table);

    return List.generate(maps.length, (i) {
      return Job.fromMap(maps[i]);
    });
  }

  Future<int> deleteJob(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}
