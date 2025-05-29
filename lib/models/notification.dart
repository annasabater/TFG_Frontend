// lib/models/notification.dart

class NotificationItem {
  final String id;
  final String type;        // 'like','comment','follow','new_post'
  final String fromUserId;
  final String? postId;
  bool read;                
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.type,
    required this.fromUserId,
    this.postId,
    required this.read,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String,dynamic> j) {
    return NotificationItem(
      id          : j['_id'] as String,
      type        : j['type'] as String,
      fromUserId  : (j['from'] is Map) ? j['from']['_id'] as String : j['from'] as String,
      postId      : j['post'] != null 
                     ? ((j['post'] is Map) ? j['post']['_id'] as String : j['post'] as String)
                     : null,
      read        : j['read'] as bool,
      createdAt   : DateTime.parse(j['createdAt'] as String),
    );
  }

  String get message {
    switch (type) {
      case 'like':     return 'li ha agradat un post';
      case 'comment':  return 't\'ha comentat el post';
      case 'follow':   return 'ha començat a seguir-te';
      case 'new_post': return 'ha ha publicat un nou post';
      default:         return '';
    }
  }
}

