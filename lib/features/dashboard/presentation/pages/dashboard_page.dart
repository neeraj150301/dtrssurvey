import 'package:dtrs_survey/features/auth/data/models/auth_models.dart';
import 'package:dtrs_survey/features/dashboard/presentation/bloc/dash_bloc.dart';
import 'package:dtrs_survey/features/dashboard/presentation/bloc/dash_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../auth/presentation/pages/login_page.dart';
import 'structures_list_page.dart';

class DashboardPage extends StatefulWidget {
  final User user;
  const DashboardPage({super.key, required this.user});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGreen,
      body: SafeArea(
        child: ListView(
          children: [
            const AppHeader(),
            _buildNavigationBar(),
            _buildWelcomeSection(context),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      color: AppColors.primaryGreen,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          _buildTabItem('Dashboard', 0),
          const SizedBox(width: 16),
          _buildTabItem('User Management', 1),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Container(
      color: AppColors.cardBackground,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Welcome ${widget.user.username}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              minimumSize: const Size(0, 32),
            ),
            icon: const Icon(Icons.logout, size: 14, color: Colors.white),
            label: const Text(
              'Logout',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_selectedTabIndex == 0) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state.isLoading) {
              return Center(child: const CircularProgressIndicator());
            }

            return Column(
              spacing: 10,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StructuresListPage(user: widget.user, title: 'Total DTRs'),
                      ),
                    );
                  },
                  child: _buildStatCard(
                    title: 'Total DTRs',
                    value: state.total.toString(),
                    valueColor: Colors.blue,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StructuresListPage(user: widget.user, title: 'Survey Completed DTRs'),
                      ),
                    );
                  },
                  child: _buildStatCard(
                    title: 'Survey Completed DTRs',
                    value: state.completed.toString(),
                    valueColor: Colors.green,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StructuresListPage(user: widget.user, title: 'Survey Pending DTRs'),
                      ),
                    );
                  },
                  child: _buildStatCard(
                    title: 'Survey Pending DTRs',
                    value: state.pending.toString(),
                    valueColor: Colors.orange,
                  ),
                ),
              ],
            );
          },
        ),
      );
    } else {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Text(
            'User Management Content',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF5A6B7C),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: valueColor,
              decoration: TextDecoration.underline,
              decorationColor: valueColor,
              decorationThickness: 2,
            ),
          ),
        ],
      ),
    );
  }
}
