import 'package:expense_tracker/services/native_transactions.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NotificationModel {
  final String id;
  final String title;
  final String time;
  final String rawMessage;
  final DateTime dateTime;
  final Map fullData;

  NotificationModel({
    required this.id,
    required this.title,
    required this.time,
    required this.rawMessage,
    required this.dateTime,
    required this.fullData,
  });
}

class NotificationController extends GetxController {
  final notifications = <NotificationModel>[].obs;
  final groupedNotifications = <String, List<NotificationModel>>{}.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      final List<Map> data = await NativeTransactions.getTransactions();
      
      final List<NotificationModel> fetchedList = data.map((e) {
        DateTime dt;
        final rawDate = e['dateTime'];
        if (rawDate != null) {
          final str = rawDate.toString();
          if (RegExp(r'^\d+$').hasMatch(str)) {
            dt = DateTime.fromMillisecondsSinceEpoch(int.parse(str));
          } else {
            dt = DateTime.tryParse(str) ?? DateTime.now();
          }
        } else {
          dt = DateTime.now();
        }

        // Use category as title (e.g., "Cash", "Food")
        String displayTitle = e['title'] ?? e['category'] ?? "Transaction";
        // String displayTitle = e['category'] ?? e['title'] ?? "Transaction";

        return NotificationModel(
          id: e['id'].toString(),
          title: displayTitle,
          time: DateFormat('hh:mm a').format(dt),
          rawMessage: e['rawSms'] ?? "",
          dateTime: dt,
          fullData: e,
        );
      }).toList();

      // Sort by date descending
      fetchedList.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      
      notifications.assignAll(fetchedList);
      _groupNotifications();
    } catch (e) {
      print("Error fetching notifications: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _groupNotifications() {
    final Map<String, List<NotificationModel>> groups = {};
    for (var notification in notifications) {
      final dateStr = _getDateHeader(notification.dateTime);
      if (groups.containsKey(dateStr)) {
        groups[dateStr]!.add(notification);
      } else {
        groups[dateStr] = [notification];
      }
    }
    groupedNotifications.assignAll(groups);
  }

  String _getDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final notificationDate = DateTime(date.year, date.month, date.day);

    if (notificationDate == today) {
      return "Today";
    } else if (notificationDate == yesterday) {
      return "Yesterday";
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  Future<void> deleteNotification(int id) async {
    await NativeTransactions.deleteTransaction(id);
    fetchNotifications();
  }
}
