abstract class DashboardEvent {}

class LoadDashboardData extends DashboardEvent {
  final String phone;

  LoadDashboardData({required this.phone});
}
