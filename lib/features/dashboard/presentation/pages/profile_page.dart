import 'package:dtrs_survey/core/constants/colors.dart';
import 'package:dtrs_survey/features/auth/presentation/pages/login_page.dart';
import 'package:dtrs_survey/features/dashboard/presentation/bloc/profile_bloc/profile_bloc.dart';
import 'package:dtrs_survey/features/dashboard/presentation/bloc/profile_bloc/profile_event.dart';
import 'package:dtrs_survey/features/dashboard/presentation/bloc/profile_bloc/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state.isLoading && state.profile == null) {
          return const ProfileSkeleton();
        }

        if (state.error != null) {
          return Center(child: Text(state.error!));
        }

        final p = state.profile;
        if (p == null) {
          return const ProfileSkeleton();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "My Profile",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 65, 109, 56),
                ),
              ),
              const SizedBox(height: 12),

              _buildCard(
                title: "PERSONAL INFORMATION",
                children: [
                  _field("Name", p.name ?? "N/A"),
                  _field("Employee Code", p.employeeCode ?? "N/A"),
                  _field("Mobile Number", p.mobile),
                ],
              ),

              const SizedBox(height: 16),

              _buildCard(
                title: "WORK LOCATION",
                children: [
                  _field("Circle Code", p.circleCode),
                  _field("Circle Name", p.circleName),
                  _field("Division Code", p.divisionCode),
                  _field("Division Name", p.divisionName),
                  _field("Subdivision Code", p.subdivisionCode),
                  _field("Subdivision Name", p.subdivisionName),
                  _field("Section Code", p.sectionCode),
                  _field("Section Name", p.sectionName),
                ],
              ),
              const SizedBox(height: 16),
              BlocListener<ProfileBloc, ProfileState>(
                listener: (context, state) {
                  if (state.isUpdateSuccess) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Password updated successfully"),
                        backgroundColor: AppColors.primaryGreen,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }

                  if (state.updateError != null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.updateError!)));
                  }
                },
                child: _buildUpdatePassword(context, p.mobile),
              ),
              const SizedBox(height: 16),
              _buildLogout(context),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 2),
          const Divider(thickness: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _field(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

Widget _field(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(value),
        ),
      ],
    ),
  );
}

Widget _buildLogout(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),

    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          showLogoutDialog(context);
        },
        icon: const Icon(Icons.logout, color: Colors.white, size: 18),
        label: const Text(
          'Logout',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.errorRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ),
  );
}

void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.logout, size: 40, color: Colors.red),
              const SizedBox(height: 10),

              const Text(
                "Confirm Logout",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              const Text(
                "Are you sure you want to logout?",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(color: AppColors.primaryGreen),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text("Logout"),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildUpdatePassword(BuildContext context, String mobileNo) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          showUpdatePasswordDialog(context, mobileNo);
        },
        icon: const Icon(Icons.logout, color: Colors.white, size: 18),
        label: const Text(
          'Update Password',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonDark,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ),
  );
}

void showUpdatePasswordDialog(BuildContext context, String mobileNo) {
  final oldController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();

  showDialog(
    context: context,
    builder: (_) {
      return BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_reset, size: 40, color: Colors.green),
                  const SizedBox(height: 10),

                  const Text(
                    "Update Password",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),
                  _field("Mobile Number", mobileNo),
                  _passwordField("Current Password", oldController),
                  const SizedBox(height: 8),
                  _passwordField("New Password", newController),
                  const SizedBox(height: 8),
                  _passwordField("Confirm New Password", confirmController),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 38,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: BorderSide(color: AppColors.primaryGreen),
                            ),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 38,
                          child: ElevatedButton(
                            onPressed: state.isUpdatingPassword
                                ? null
                                : () {
                                    if (newController.text !=
                                        confirmController.text) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Passwords do not match",
                                          ),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );

                                      return;
                                    }
                                    if (oldController.text ==
                                        newController.text) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "New password must be different from current password",
                                          ),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );

                                      return;
                                    }
                                    if (oldController.text.length < 6 ||
                                        newController.text.length < 6 ||
                                        confirmController.text.length < 6) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Password should be at least 6 characters long",
                                          ),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );

                                      return;
                                    }
                                    context.read<ProfileBloc>().add(
                                      UpdatePassword(
                                        mobile: mobileNo,
                                        currentPassword: oldController.text,
                                        newPassword: newController.text,
                                      ),
                                    );
                                    oldController.clear();
                                    newController.clear();
                                    confirmController.clear();
                                    Navigator.pop(context);
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.buttonDark,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: state.isUpdatingPassword
                                ? SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Update",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _passwordField(String hint, TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.password_rounded, size: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 34, 16, 16),

      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          children: List.generate(6, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 32),
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        ),
      ),
    );
  }
}
