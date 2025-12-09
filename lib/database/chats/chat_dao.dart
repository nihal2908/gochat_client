part of 'package:whatsapp_clone/database/db_helper.dart';

extension ChatDao on DBHelper{
  Future<List<Chat>> getChats({bool archived = false}) async {
    final db = await database;
    final whereClause = archived ? "WHERE Chat.is_archived = 1" : "";

    final queryResult = await db.rawQuery("""
    SELECT 
      Chat.*, 
      COALESCE(Contact.name, User.title) AS title, 
      User.name,
      User.phone, 
      User.country_code, 
      User.profile_picture_url, 
      User.status_message, 
      User.last_seen, 
      User.is_online, 
      User.created_at, 
      User.updated_at,
      LastMessage.*
    FROM Chat 
    LEFT JOIN User ON Chat.user_id = User._id 
    LEFT JOIN Contact ON Contact.user_id = User._id
    LEFT JOIN (
      SELECT 
        Message.*
      FROM Message
      WHERE Message.timestamp IN (
        SELECT MAX(timestamp)
        FROM Message
        GROUP BY chat_id
      )
    ) AS LastMessage ON Chat.id = LastMessage.chat_id
    $whereClause
    ORDER BY Chat.updated_at DESC;
  """);

    return queryResult.map((result) => Chat.fromMap(result)).toList();
  }
}
