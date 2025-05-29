import 'package:intl/intl.dart';
import '../services/notification_service.dart';
import '../services/social_service.dart'; 

class NotificationItem {
  final String id;
  final String type;         // 'like','comment','follow','new_post'
  final String fromUserId;
  final String fromUserName; 
  final String? postId;
  final String? postMediaUrl; 
  bool read;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.type,
    required this.fromUserId,
    required this.fromUserName,
    this.postId,
    this.postMediaUrl,
    required this.read,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String,dynamic> j) {
    final from = j['from'];
    final post = j['post'];
    return NotificationItem(
      id           : j['_id'] as String,
      type         : j['type'] as String,
      fromUserId   : from is Map ? from['_id'] as String : from as String,
      fromUserName : from is Map ? from['userName'] as String : '',
      postId       : post != null
                       ? (post is Map ? post['_id'] as String : post as String)
                       : null,
      // Aquí convertim la ruta relativa a absoluta:
      postMediaUrl : (post is Map && post['mediaUrl'] != null)
                       ? SocialService.absolute(post['mediaUrl'] as String)
                       : null,
      read         : j['read'] as bool,
      createdAt    : DateTime.parse(j['createdAt'] as String),
    );
  }

  String get message {
    switch (type) {
      case 'like':     return 'li ha agradat un post';
      case 'comment':  return 't\'ha comentat el post';
      case 'follow':   return 'ha començat a seguir-te';
      case 'new_post': return 'ha publicat un nou post';
      default:         return '';
    }
  }

  String get title => '$fromUserName $message';

  String get timeFormatted => DateFormat('HH:mm').format(createdAt);
}
