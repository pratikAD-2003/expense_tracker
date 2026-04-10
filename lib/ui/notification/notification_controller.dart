import 'package:get/get.dart';

class NotificationModel {
  final String title;
  final String description;
  final String time;
  final bool isRead;

  NotificationModel({
    required this.title,
    required this.description,
    required this.time,
    this.isRead = false,
  });
}

class NotificationController extends GetxController {
  final notifications = <NotificationModel>[
    NotificationModel(
      title: 'Monthly Budget Exceeded',
      description: 'You have exceeded your food budget by \$50.',
      time: '2 hours ago',
    ),
    NotificationModel(
      title: 'New Transaction',
      description: 'A transaction of \$120 was added to Entertainment.',
      time: '5 hours ago',
      isRead: true,
    ),
    NotificationModel(
      title: 'Bill Reminder',
      description: 'Your electricity bill is due in 2 days.',
      time: '1 day ago',
      isRead: true,
    ),
    NotificationModel(
      title: 'Savings Goal Reached',
      description: 'Congratulations! You reached your savings goal for this month.',
      time: '2 days ago',
      isRead: true,
    ),
  ].obs;

  void markAsRead(int index) {
    // In a real app, this would update the backend/database
    final notification = notifications[index];
    notifications[index] = NotificationModel(
      title: notification.title,
      description: notification.description,
      time: notification.time,
      isRead: true,
    );
  }
}
