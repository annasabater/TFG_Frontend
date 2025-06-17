import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../services/comment_service.dart';
import '../services/auth_service.dart';

class DroneCardRating extends StatefulWidget {
  final String droneId;
  const DroneCardRating({super.key, required this.droneId});

  @override
  State<DroneCardRating> createState() => _DroneCardRatingState();
}

class _DroneCardRatingState extends State<DroneCardRating> {
  Future<List<Comment>>? _commentsFuture;

  @override
  void initState() {
    super.initState();
    _commentsFuture = _fetchComments();
  }

  Future<List<Comment>> _fetchComments() async {
    final service = CommentService(AuthService().baseApiUrl);
    final data = await service.getComments(widget.droneId);
    return data.map<Comment>((e) => Comment.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.92)
          : Theme.of(context).colorScheme.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: Theme.of(context).brightness == Brightness.dark
            ? const BorderSide(color: Colors.white24, width: 1.2)
            : BorderSide.none,
      ),
      child: FutureBuilder<List<Comment>>(
        future: _commentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(height: 20);
          }
          if (snapshot.hasError || !(snapshot.hasData)) {
            return const SizedBox(height: 20);
          }
          final comments = snapshot.data ?? [];
          final rootComments =
              comments.where((c) => c.parentCommentId == null).toList();
          final ratings =
              rootComments
                  .where((c) => c.rating != null)
                  .map((c) => c.rating!)
                  .toList();
          double avg = 0;
          if (ratings.isNotEmpty) {
            avg = ratings.reduce((a, b) => a + b) / ratings.length;
          }
          return Row(
            children: [
              ...List.generate(5, (i) {
                if (avg >= i + 1) {
                  return const Icon(Icons.star, color: Colors.amber, size: 16);
                } else if (avg > i && avg < i + 1) {
                  return const Icon(
                    Icons.star_half,
                    color: Colors.amber,
                    size: 16,
                  );
                } else {
                  return const Icon(
                    Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }
              }),
              const SizedBox(width: 4),
              Text(avg.toStringAsFixed(1), style: const TextStyle(fontSize: 13)),
              if (ratings.isNotEmpty)
                Text(
                  ' (${ratings.length})',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          );
        },
      ),
    );
  }
}
