import 'package:dtrs_survey/features/dashboard/data/repositories/dash_repository.dart';
import 'package:dtrs_survey/features/dashboard/presentation/bloc/dash_bloc.dart';
import 'package:dtrs_survey/features/dashboard/presentation/bloc/dash_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [AppHeader(), SizedBox(height: 24), _LoginFormCard()],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginFormCard extends StatefulWidget {
  const _LoginFormCard();

  @override
  State<_LoginFormCard> createState() => _LoginFormCardState();
}

class _LoginFormCardState extends State<_LoginFormCard> {
  final _identifierController = TextEditingController(
    text: '8712471189',
  ); /////// remove default login credentials
  final _passwordController = TextEditingController(text: '8712471189@#123');
  bool _obscureText = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login Successful!'),
                backgroundColor: AppColors.primaryGreen,
              ),
            );
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (context) =>
                      DashboardBloc(DashboardRepository())
                        ..add(LoadDashboardData(phone: state.user.phoneNumber)),
                  child: DashboardPage(user: state.user),
                ),
              ),
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: AppColors.errorRed,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Login',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),

              // USERNAME
              const _FieldLabel(label: 'USERNAME', isRequired: true),
              const SizedBox(height: 8),
              const Center(
                child: Icon(
                  Icons.person,
                  color: AppColors.iconPurple,
                  size: 32,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _identifierController,
                decoration: const InputDecoration(hintText: 'Enter Mobile No'),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 10,
              ),
              const SizedBox(height: 24),

              // Password field
              const _FieldLabel(label: 'PASSWORD', isRequired: true),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, color: AppColors.iconOrange, size: 28),
                  const SizedBox(width: 8),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  hintText: 'Enter Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.iconGrey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Sign In Button
              ElevatedButton(
                onPressed: state is AuthLoading
                    ? null
                    : () {
                        context.read<AuthBloc>().add(
                          LoginRequested(
                            identifier: _identifierController.text,
                            password: _passwordController.text,
                          ),
                        );
                      },
                child: state is AuthLoading
                    ? Row(
                        spacing: 8,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          Text('Signing In...'),
                        ],
                      )
                    : const Text('Sign In'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool isRequired;

  const _FieldLabel({required this.label, this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: AppColors.textDark,
          fontWeight: FontWeight.w900,
          fontSize: 14,
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: AppColors.errorRed, fontSize: 12),
            ),
        ],
      ),
    );
  }
}
