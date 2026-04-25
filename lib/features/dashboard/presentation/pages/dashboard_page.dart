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
      backgroundColor: AppColors.cardBackground,
      bottomNavigationBar: _buildBottomNavBar(),
      body: SafeArea(
        child: ListView(
          children: [
            const AppHeader(),
            const SizedBox(height: 10),
            // _buildNavigationBar(),
            _buildWelcomeSection(context),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedTabIndex,
      onTap: (index) {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          activeIcon: Icon(Icons.dashboard),
          icon: Icon(Icons.dashboard_outlined),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          activeIcon: Icon(Icons.manage_accounts),
          icon: Icon(Icons.manage_accounts_outlined),
          label: 'User Management',
        ),
      ],
    );
  }

  // Widget _buildNavigationBar() {
  //   return Container(
  //     color: AppColors.primaryGreen,
  //     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  //     child: Row(
  //       children: [
  //         _buildTabItem('Dashboard', 0),
  //         const SizedBox(width: 16),
  //         _buildTabItem('User Management', 1),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildTabItem(String title, int index) {
  //   bool isSelected = _selectedTabIndex == index;
  //   return GestureDetector(
  //     onTap: () {
  //       setState(() {
  //         _selectedTabIndex = index;
  //       });
  //     },
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  //       decoration: BoxDecoration(
  //         color: isSelected ? Colors.white : Colors.transparent,
  //         borderRadius: BorderRadius.circular(6),
  //       ),
  //       child: Text(
  //         title,
  //         style: TextStyle(
  //           color: isSelected ? Colors.black : Colors.black87,
  //           fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
  //           fontSize: 14,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // ------------logout button-----------------------
  // ElevatedButton.icon(
  //   onPressed: () {
  //     Navigator.of(context).pushReplacement(
  //       MaterialPageRoute(builder: (_) => const LoginPage()),
  //     );
  //   },
  //   style: ElevatedButton.styleFrom(
  //     backgroundColor: AppColors.buttonDark,
  //     foregroundColor: Colors.white,
  //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(6),
  //     ),
  //     minimumSize: const Size(0, 32),
  //   ),
  //   icon: const Icon(Icons.logout, size: 14, color: Colors.white),
  //   label: const Text(
  //     'Logout',
  //     style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
  //   ),
  // ),

  Widget _buildWelcomeSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 0,
        color: const Color(0xFFF3F5F7),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.person, color: AppColors.primaryGreen),
              SizedBox(width: 20),
              Text(
                'Welcome ${widget.user.username}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              // ElevatedButton.icon(
              //   onPressed: () {
              //     Navigator.of(context).pushReplacement(
              //       MaterialPageRoute(builder: (_) => const LoginPage()),
              //     );
              //   },
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: AppColors.buttonDark,
              //     foregroundColor: Colors.white,
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 8,
              //       vertical: 0,
              //     ),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(6),
              //     ),
              //     minimumSize: const Size(0, 32),
              //   ),
              //   icon: const Icon(Icons.logout, size: 14, color: Colors.white),
              //   label: const Text(
              //     'Logout',
              //     style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_selectedTabIndex == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state.isLoading) {
              return Center(child: const CircularProgressIndicator());
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agricultural Structures Survey',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 65, 109, 56),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StructuresListPage(
                          user: widget.user,
                          title: 'Total DTRs',
                        ),
                      ),
                    );
                  },
                  child: _buildStatCard(
                    title: 'Total DTRs',
                    value: state.total.toString(),
                    valueColor: Colors.blue,
                    icon: Icons.description,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StructuresListPage(
                          user: widget.user,
                          title: 'Survey Completed DTRs',
                        ),
                      ),
                    );
                  },
                  child: _buildStatCard(
                    title: 'Survey Completed DTRs',
                    value: state.completed.toString(),
                    valueColor: Colors.green,
                    icon: Icons.check_circle,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StructuresListPage(
                          user: widget.user,
                          title: 'Survey Pending DTRs',
                        ),
                      ),
                    );
                  },
                  child: _buildStatCard(
                    title: 'Survey Pending DTRs',
                    value: state.pending.toString(),
                    valueColor: Colors.orange,
                    icon: Icons.access_time,
                  ),
                ),
              ],
            );
          },
        ),
      );
    } else {
      return Center(
        child: ElevatedButton.icon(
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
      );
    }
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color valueColor,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 100,
            decoration: BoxDecoration(
              color: valueColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: valueColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: valueColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: valueColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.chevron_right, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
