import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:whatsapp_clone/features/auth/current_user/user_manager.dart';
import 'package:whatsapp_clone/models/call.dart';
import 'package:whatsapp_clone/models/chat.dart';
import 'package:whatsapp_clone/models/contact.dart';
import 'package:http/http.dart' as http;
import 'package:whatsapp_clone/models/group.dart';
import 'package:whatsapp_clone/models/message.dart';
import 'package:whatsapp_clone/secrets/secrets.dart';

part 'package:whatsapp_clone/database/users/user_dao.dart';
part 'package:whatsapp_clone/database/contacts/contact_dao.dart';
part 'package:whatsapp_clone/database/status/status_dao.dart';
part 'package:whatsapp_clone/database/chats/chat_dao.dart';
part 'package:whatsapp_clone/database/messages/message_dao.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._();
  static Database? _database;

  final StreamController<void> _updateStreamController =
      StreamController<void>.broadcast();

  DBHelper._();

  factory DBHelper() => _instance;

  Stream<void> get updateStream => _updateStreamController.stream;

  Future<void> notifyChanges() async {
    _updateStreamController.add(null);
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'whatsapp_clone.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> saveCurrentUser(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(
      'User',
      data['user'],
    );
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final db = await database;
    final result = await db.query(
      'User',
      where: '_id = ?',
      whereArgs: [CurrentUser.userId],
    );
    return result.first;
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    final db = await database;
    final result = await db.query(
      'User',
      where: '_id = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getCallerUserById(String userId) async {
    final db = await database;
    final user = await db.query(
      'User',
      where: '_id = ?',
      whereArgs: [userId],
    );
    if (user.isEmpty) {
      try {
        // Fetch user data from the backend
        final response = await http.get(
          Uri.parse(
            '${Secrets.serverUrl}/userdata?userId=$userId',
          ),
        );

        if (response.statusCode == 200) {
          final userData = jsonDecode(response.body) as Map<String, dynamic>;
          await db.insert('User', userData);
        } else {
          throw Exception('Failed to fetch user data');
        }
      } catch (error) {
        if (kDebugMode) {
          print('Error fetching user data: $error');
        }
        return null;
      }
    } else {
      return user.first;
    }
  }

  Future<Map<String, dynamic>?> getContactById(String userId) async {
    final db = await database;
    final result = await db.query(
      'Contact',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getGroupById(String groupId) async {
    final db = await database;
    final result = await db.query(
      'Groups',
      where: '_id = ?',
      whereArgs: [groupId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getMessageById(String messageId) async {
    final db = await database;
    final result = await db.query(
      'Message',
      where: '_id = ?',
      whereArgs: [messageId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> insertMessage(Map<String, dynamic> message, bool sent) async {
    final db = await database;

    final String? chatId = message['chat_id'];
    final String senderId = message['sender_id'];
    final String? receiverId = message['receiver_id'];
    final String? groupId = message['group_id'];

    // if it is a received msg, check if user exist in DB
    // if not, retrieve from server
    if (!sent) {
      // check if the user exists in DB
      final user = await db.rawQuery(
        'SELECT _id FROM User WHERE _id = ?',
        [senderId],
      );

      // if user is not found in DB
      if (user.isEmpty) {
        try {
          // Fetch user data from the backend
          final response = await http.get(
            Uri.parse(
              '${Secrets.serverUrl}/userdata?userId=$senderId',
            ),
          );

          if (response.statusCode == 200) {
            final userData = jsonDecode(response.body) as Map<String, dynamic>;
            await db.insert('User', userData);
          } else {
            throw Exception('Failed to fetch user data');
          }
        } catch (error) {
          if (kDebugMode) {
            print('Error fetching user data: $error');
          }
          return; // Exit if unable to fetch user data
        }
      }
    }

    // if the message is a group msg
    if (groupId != null) {
      await db.transaction((txn) async {
        // if received msg
        if (!sent) {
          // find the group with the id in DB
          final groupRow = await txn.rawQuery(
            'SELECT unread_count FROM Groups WHERE _id = ?',
            [groupId],
          );

          // if no group found return
          if (groupRow.isEmpty) return;

          // update the unread count
          final newUnreadCount =
              (groupRow.first['unread_count'] as int? ?? 0) + 1;

          await txn.rawUpdate(
            '''
            UPDATE Groups
            SET unread_count = ?
            WHERE _id = ?;
            ''',
            [
              newUnreadCount,
              groupId,
            ],
          );
        }

        // insert msg in DB
        await txn.insert('Message', message);
      });
    }

    // if it is a chat msg
    else {
      await db.transaction((txn) async {
        // find the chat in DB
        final chatRow = await txn.rawQuery(
          'SELECT unread_count FROM Chat WHERE id = ?',
          [chatId],
        );

        // if received msg and chat exists
        if (!sent && chatRow.isNotEmpty) {
          // ff the chat exists, update unread count
          final newUnreadCount =
              (chatRow.first['unread_count'] as int? ?? 0) + 1;

          await txn.rawUpdate(
            '''
            UPDATE Chat
            SET unread_count = ?
            WHERE id = ?;
            ''',
            [
              newUnreadCount,
              chatId,
            ],
          );
        }

        // if chat does not exist
        else if (chatRow.isEmpty) {
          // insert a new chat row
          await txn.rawInsert(
            '''
            INSERT INTO Chat (
              id, 
              user_id, 
              unread_count, 
              is_archived, 
              created_at
            ) VALUES (?, ?, ?, ?, ?)
            ''',
            [
              chatId,
              sent ? receiverId : senderId,
              sent ? 0 : 1,
              0,
              DateTime.now().toIso8601String(),
            ],
          );
        }

        // insert msg in DB
        await txn.insert(
          'Message',
          message,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }

    await notifyChanges();
  }

  Future<void> insertMediaMessage(
      Map<String, dynamic> message, String path) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert(
        'Message',
        message,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      await txn.insert(
        'Media',
        {
          'id': message['_id'],
          'message_id': message['_id'],
          'url': message['content'],
          'path': path,
          'size': message['size'],
          'type': message['type'],
          'created_at': message['timestamp'],
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    });

    notifyChanges();
  }

  Future<void> deleteMedia(String messageId) async {
    final db = await database;
    await db.delete(
      'Media',
      where: '_id = ?',
      whereArgs: [messageId],
    );
  }

  Future<void> updateMessage(
      String messageId, Map<String, dynamic> data) async {
    final db = await database;
    final foundMessage = await db.query(
      'Message',
      where: '_id = ?',
      whereArgs: [messageId],
    );
    if (foundMessage.isEmpty) return;
    await db.update(
      'Message',
      data,
      where: '_id = ?',
      whereArgs: [messageId],
    );

    await notifyChanges();
  }

  Future<void> deleteMultipleMessages(List<String> messageIds) async {
    final db = await database;
    await db.delete(
      'Message',
      where: '_id IN (${messageIds.map((_) => '?').join(', ')})',
      whereArgs: messageIds,
    );

    await notifyChanges();
  }

  Future<void> clearChat(String chatId) async {
    final db = await database;
    await db.delete(
      'Message',
      where: 'chat_id = ? OR group_id = ?',
      whereArgs: [chatId, chatId],
    );

    await notifyChanges();
  }

  Future<void> deleteChat(List<String> chatIds) async {
    final db = await database;
    for (String chatId in chatIds) {
      await db.delete(
        'Message',
        where: 'chat_id = ? OR group_id = ?',
        whereArgs: [chatId, chatId],
      );
      await db.delete(
        'Chat',
        where: 'id = ?',
        whereArgs: [chatId],
      );
    }

    await notifyChanges();
  }

  Future<void> archiveChats(List<String> chatIds) async {
    final db = await database;
    await db.update(
      'Chat',
      {'is_archived': 1},
      where: 'id IN (${chatIds.map((_) => '?').join(', ')})',
      whereArgs: chatIds,
    );

    await notifyChanges();
  }

  Future<void> unarchiveChats(List<String> chatIds) async {
    final db = await database;
    await db.update(
      'Chat',
      {'is_archived': 0},
      where: 'id IN (${chatIds.map((_) => '?').join(', ')})',
      whereArgs: chatIds,
    );

    await notifyChanges();
  }

  Future<void> insertUsers(List<Map<String, dynamic>> users) async {
    final db = await database;
    final Batch batch = db.batch();

    for (var user in users) {
      batch.insert(
        'User',
        user,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(
        noResult: true); // `noResult: true` for better performance

    await notifyChanges();
  }

  Future<void> insertContacts(List<Map<String, dynamic>> contacts) async {
    final db = await database;
    final Batch batch = db.batch();

    for (var contact in contacts) {
      batch.insert(
        'Contact',
        contact,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(
        noResult: true); // `noResult: true` for better performance

    await notifyChanges();
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('User');
  }

  Future<int> updateMessageStatus(
      String messageId, String? groupId, String status) async {
    final db = await database;
    final rowsAffected = await db.update(
      'Message',
      {'status': status},
      where: '_id = ?',
      whereArgs: [messageId],
    );
    await notifyChanges();
    return rowsAffected;
  }

  Future<void> ackReadAllMessages(String chatId) async {
    final db = await database;
    await db.update(
      'Message',
      {
        'status': 'read',
      },
      where: 'chat_id = ? AND sender_id = ?',
      whereArgs: [chatId, CurrentUser.userId],
    );

    await notifyChanges();
  }

  Future<void> marksAllMessagesRead(String chatId) async {
    final db = await database;
    await db.update(
      'Chat',
      {
        'unread_count': 0,
      },
      where: 'id = ?',
      whereArgs: [chatId],
    );

    await db.update(
      'Message',
      {
        'status': 'read',
      },
      where: 'chat_id = ? AND receiver_id = ?',
      whereArgs: [chatId, CurrentUser.userId],
    );

    await notifyChanges();
  }

  Future<void> addGroup(Map<String, dynamic> group) async {
    final db = await database;
    final members = (group['members'] as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();

    await db.transaction((txn) async {
      for (var member in members) {
        final result = await txn.query(
          'User',
          where: '_id = ?',
          whereArgs: [member['user_id']],
        );

        if (result.isEmpty) {
          try {
            final response = await http.get(
              Uri.parse(
                '${Secrets.serverUrl}/userdata?userId=${member['user_id']}',
              ),
            );

            if (response.statusCode == 200) {
              final userData =
                  jsonDecode(response.body) as Map<String, dynamic>;
              await txn.insert('User', userData);
            } else {
              throw Exception('Failed to fetch user data');
            }
          } catch (error) {
            if (kDebugMode) {
              print('Error fetching user data: $error');
            }
            return; // Exit if unable to fetch user data
          }
        }

        await txn.insert(
          'GroupMember',
          {
            'user_id': member['user_id'],
            'is_admin': member['is_admin'] ? 1 : 0,
            'joined_at': member['joined_at'],
            'id': '${group['_id']}_${member['user_id']}',
          },
        );
      }

      await txn.insert(
        'Groups',
        {
          '_id': group['_id'],
          'title': group['title'],
          'description': group['description'],
          'group_icon': group['group_icon'],
          'created_by': group['created_by'],
          'created_at': group['created_at'],
          'updated_at': group['updated_at'],
          'disappearing_msg': group['disappearing_msg'],
          'member_can_edit': group['member_can_edit'] ? 1 : 0,
          'member_can_send': group['member_can_send'] ? 1 : 0,
          'member_can_add': group['member_can_add'] ? 1 : 0,
          'admin_approve': group['admin_approve'] ? 1 : 0,
        },
      );
    });

    await notifyChanges();
  }

  Future<List<Contact>> getContacts() async {
    final db = await database;
    final queryResult = await db.rawQuery("""
      SELECT 
        Contact.*,
        User._id,
        User.title,
        User.name,
        User.phone, 
        User.country_code, 
        User.profile_picture_url, 
        User.status_message, 
        User.last_seen, 
        User.is_online, 
        User.created_at, 
        User.updated_at 
      FROM Contact 
      LEFT JOIN User ON Contact.user_id = User._id
      ORDER BY Contact.name ASC;
      """);
    return queryResult.map((result) => Contact.fromMap(result)).toList();
  }

  Future<List<Map<String, dynamic>>> getPendingMessages() async {
    final db = await database;
    return await db.query(
      'Message',
      where: 'status = ? AND sender_id = ?',
      whereArgs: ['pending', CurrentUser.userId],
      orderBy: 'timestamp ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getMessagesByChatId(String chatId) async {
    final db = await database;
    return await db.query(
      'Message',
      where: 'chat_id = ? OR group_id = ?',
      whereArgs: [chatId, chatId],
      orderBy: 'timestamp DESC',
    );
  }

  Future<Map<String, dynamic>?> loadMediaMessage(String messageId) async {
    final db = await database;
    final result = await db.query(
      'Media',
      where: 'message_id = ?',
      whereArgs: [messageId],
    );
    return result.isEmpty ? null : result.first;
  }

  Future<void> updateMediaMessage(Message message, String path) async {
    final db = await database;
    await db.insert(
      'Media',
      {
        'id': message.Id,
        'message_id': message.Id,
        'url': message.Content,
        'path': path,
        'type': message.Type,
        'size': message.Size,
        'created_at': message.Timestamp.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Call>> getCalls() async {
    final db = await database;
    final queryResult = await db.rawQuery("""
      SELECT 
        CallLog.*, 
        COALESCE(Contact.name, Caller.name) AS caller_name, 
        Caller.phone AS caller_phone, 
        Caller.country_code AS caller_country_code, 
        Caller.profile_picture_url AS caller_profile_picture_url, 
        Caller.status_message AS caller_status_message, 
        Caller.last_seen AS caller_last_seen, 
        Caller.is_online AS caller_is_online, 
        Caller.created_at AS caller_created_at, 
        Caller.updated_at AS caller_updated_at 
      FROM CallLog 
      LEFT JOIN User AS Caller ON CallLog.caller_id = Caller._id 
      LEFT JOIN Contact ON Contact.user_id = Caller._id
      ORDER BY CallLog.start_time DESC;
      """);
    return queryResult.map((result) => Call.fromMap(result)).toList();
  }

  // add a function to get the chats in the databse using a complex sql query.
  // Just like the getCalls function above.
  // the output should be a list of chats according to the chat model.
  Future<List<Chat>> getChats({bool archived = false}) async {
    final db = await database;

    final whereClause = archived ? "WHERE Chat.is_archived = 1" : "";

    final queryResult = await db.rawQuery("""
      SELECT
        Chat.id,
        Chat.user_id,
        COALESCE(Contact.name, User.title) AS title,
        User.profile_picture_url,
        LM.*,
        Chat.unread_count,
        Chat.is_archived
      FROM Chat
      LEFT JOIN User ON Chat.user_id = User._id
      LEFT JOIN Contact ON Contact.phone = User.phone
      LEFT JOIN (
        SELECT m.*
        FROM Message m
        INNER JOIN (
          SELECT chat_id, MAX(timestamp) AS max_ts
          FROM Message
          GROUP BY chat_id
        ) mm ON m.chat_id = mm.chat_id AND m.timestamp = mm.max_ts
      ) AS LM ON Chat.id = LM.chat_id
      ${archived ? "WHERE Chat.is_archived = 1" : ""}
      ORDER BY LM.timestamp DESC, Chat.updated_at DESC;
    """);

    return queryResult.map((result) => Chat.fromMap(result)).toList();
  }

  Future<List<Group>> getGroupChats() async {
    final db = await database;
    final queryResult = await db.rawQuery("""
    SELECT 
      Groups.title AS title,
      Groups.group_icon,
      Groups._id AS id,
      LastMessage.*,
      User.title AS last_sender_title
    FROM Groups
    LEFT JOIN (
      SELECT 
        Message.*
      FROM Message
      WHERE Message.timestamp IN (
        SELECT MAX(timestamp)
        FROM Message
        WHERE group_id IS NOT NULL
        GROUP BY group_id
      )
    ) AS LastMessage ON Groups._id = LastMessage.group_id
    LEFT JOIN User ON User._id = LastMessage.sender_id
    ORDER BY Groups.updated_at DESC;
  """);

    return queryResult.map((group) => Group.fromMap(group)).toList();
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE User (
        _id TEXT PRIMARY KEY,
        title TEXT,
        name TEXT,
        phone TEXT UNIQUE,
        country_code TEXT,
        profile_picture_url TEXT,
        status_message TEXT,
        last_seen TEXT,
        is_online INTEGER,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE Contact (
        user_id TEXT,
        name TEXT,
        phone TEXT PRIMARY KEY,
        FOREIGN KEY(user_id) REFERENCES User(_id)
      )
    ''');
    await db.execute('''
      CREATE TABLE Groups (
        _id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        group_icon TEXT,
        created_at TEXT,
        updated_at TEXT,
        created_by TEXT,
        unread_count INTEGER,
        disappearing_msg INTEGER,
        member_can_edit INTEGER,
        member_can_send INTEGER,
        member_can_add INTEGER,
        admin_approve INTEGER,
        FOREIGN KEY(created_by) REFERENCES User(_id)
      )
    ''');
    await db.execute('''
      CREATE TABLE Message (
        _id TEXT PRIMARY KEY,
        sender_id TEXT,
        receiver_id TEXT,
        group_id TEXT,
        chat_id TEXT,
        content TEXT,
        caption TEXT,
        size REAL,
        type TEXT,
        timestamp TEXT,
        status TEXT,
        edited INTEGER,
        deleted_for_everyone INTEGER,
        FOREIGN KEY(sender_id) REFERENCES User(_id),
        FOREIGN KEY(receiver_id) REFERENCES User(_id),
        FOREIGN KEY(group_id) REFERENCES Groups(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE GroupMember (
        id TEXT PRIMARY KEY,
        group_id TEXT,
        user_id TEXT,
        is_admin TEXT,
        joined_at TEXT,
        FOREIGN KEY(group_id) REFERENCES Groups(_id),
        FOREIGN KEY(user_id) REFERENCES User(_id)
      )
    ''');
    await db.execute('''
      CREATE TABLE Status (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        content TEXT,
        type TEXT,
        visibility TEXT,
        created_at TEXT,
        expires_at TEXT,
        FOREIGN KEY(user_id) REFERENCES User(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE CallLog (
        id TEXT PRIMARY KEY,
        caller_id TEXT,
        receiver_id TEXT,
        call_type TEXT,
        start_time TEXT,
        end_time TEXT,
        status TEXT,
        FOREIGN KEY(caller_id) REFERENCES User(id),
        FOREIGN KEY(receiver_id) REFERENCES User(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE Media (
        id TEXT PRIMARY KEY,
        message_id TEXT,
        url TEXT,
        path TEXT,
        size REAL,
        type TEXT,
        created_at TEXT,
        FOREIGN KEY(message_id) REFERENCES Message(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE Notification (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        content TEXT,
        type TEXT,
        is_read INTEGER,
        created_at TEXT,
        FOREIGN KEY(user_id) REFERENCES User(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE Chat (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        group_id TEXT,
        last_message_id TEXT,
        unread_count INTEGER,
        is_archived INTEGER,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY(user_id) REFERENCES User(id),
        FOREIGN KEY(group_id) REFERENCES Groups(id),
        FOREIGN KEY(last_message_id) REFERENCES Message(id)
      )
    ''');
  }
}
