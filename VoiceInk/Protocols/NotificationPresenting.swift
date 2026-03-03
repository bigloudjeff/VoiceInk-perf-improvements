import Foundation

@MainActor
protocol NotificationPresenting {
 func showNotification(
  title: String,
  type: AppNotificationView.NotificationType,
  duration: TimeInterval,
  onTap: (() -> Void)?
 )
}
