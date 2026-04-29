import 'package:shared_preferences/shared_preferences.dart';
import 'package:dtrs_survey/core/utils/location_service.dart';
import 'package:dtrs_survey/features/auth/presentation/pages/login_footer.dart';
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
      child: Scaffold(
        backgroundColor: AppColors.cardBackground,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      AppHeader(),
                      SizedBox(height: 24),
                      _LoginFormCard(),
                    ],
                  ),
                ),
              ),
              LoginFooter(),
            ],
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
  final _identifierController = TextEditingController(text: "8712471189");
  final _passwordController = TextEditingController();
  final _forgotMobileController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isFlipped = false;
  bool _obscureText = true;
  bool _isOtpSent = false;
  // int _secondsLeft = 0;
  // Timer? _timer;
  bool _isVerifySent = false;
  String? _resetToken;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LocationService.checkLocationRequirements(context);
    });
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthSuccess) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('phoneNumber', state.user.phoneNumber);
            await prefs.setString('username', state.user.username);
            await prefs.setInt('id', state.user.id);
            await prefs.setString('role', state.user.role);
            await prefs.setBool('isActive', state.user.isActive);
            await prefs.setString('fullName', state.user.fullName);
            if (!context.mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login Successful!'),
                backgroundColor: AppColors.primaryGreen,
                duration: Duration(seconds: 2),
              ),
            );

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => DashboardPage(user: state.user),
              ),
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: AppColors.errorRed,
              ),
            );
          } else if (state is OtpSent) {
            setState(() {
              _isOtpSent = true;
              // _secondsLeft = state.expiresIn; // 300 sec
            });

            // _startTimer();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.primaryGreen,
                duration: Duration(seconds: 2),
              ),
            );
          } else if (state is VerifySent) {
            setState(() {
              _isVerifySent = true;
              _resetToken = state.resetToken;
            });

            // _startTimer();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.primaryGreen,
                duration: Duration(seconds: 2),
              ),
            );
          } else if (state is ResetPasswordSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );

            // RESET FLOW
            setState(() {
              _isFlipped = false;
              _isOtpSent = false;
              _isVerifySent = false;
              _resetToken = null;
              _forgotMobileController.clear();
              _newPasswordController.clear();
              _confirmPasswordController.clear();
            });
          }
        },
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) {
              final rotate = Tween(begin: 3.14, end: 0.0).animate(animation);

              return AnimatedBuilder(
                animation: rotate,
                child: child,
                builder: (context, child) {
                  final isUnder = (ValueKey(_isFlipped) != child!.key);
                  var value = rotate.value;

                  if (isUnder) {
                    value = 3.14 - value;
                  }

                  return Transform(
                    transform: Matrix4.rotationY(value),
                    alignment: Alignment.center,
                    child: child,
                  );
                },
              );
            },
            child: _isFlipped
                ? _buildForgotCard() // BACK SIDE
                : _buildLoginCard(state), // FRONT SIDE
          );
        },
      ),
    );
  }

  // void _startTimer() {
  //   _timer?.cancel();
  //   _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //     if (_secondsLeft == 0) {
  //       timer.cancel();
  //     } else {
  //       setState(() {
  //         _secondsLeft--;
  //       });
  //     }
  //   });
  // }

  Widget _buildForgotCard() {
    //     final mobileController = TextEditingController();
    // final otpController = TextEditingController();
    return Container(
      key: const ValueKey(true),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 15,
            offset: Offset(0, 6),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Forgot Password",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Enter your registered phone number",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          const _FieldLabel(label: 'MOBILE NO', isRequired: true),
          const SizedBox(height: 8),
          TextField(
            controller: _forgotMobileController,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 10,
            decoration: InputDecoration(
              counterText: "",
              prefixIcon: const Icon(Icons.phone, color: Colors.green),
              hintText: 'Enter Mobile Number',
              filled: true,
              fillColor: const Color(0xFFF2F4F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.green, width: 1),
              ),
            ),
          ),

          const SizedBox(height: 20),
          if (_isOtpSent && !_isVerifySent) ...[
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 4,
              decoration: InputDecoration(
                counterText: "",
                prefixIcon: const Icon(
                  Icons.password_outlined,
                  color: Colors.green,
                ),
                hintText: 'Enter OTP',
                filled: true,
                fillColor: const Color(0xFFF2F4F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.green, width: 1),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.zero,
              ),
              onPressed: () {
                context.read<AuthBloc>().add(
                  VerifyOtpRequested(
                    phoneNumber: _forgotMobileController.text,
                    otp: _otpController.text,
                  ),
                );
              },
              child: const Text("Verify OTP"),
            ),
            const SizedBox(height: 16),
          ],

          /// SEND / RESEND BUTTON
          if (!_isOtpSent)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.zero,
              ),
              onPressed: () {
                context.read<AuthBloc>().add(
                  SendOtpRequested(_forgotMobileController.text),
                );
              },
              child: Text("Send OTP"),
            ),
          const SizedBox(height: 10),
          if (_isVerifySent) ...[
            TextField(
              controller: _newPasswordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock, color: Colors.green),
                hintText: 'Enter New Password',
                filled: true,
                fillColor: const Color(0xFFF2F4F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.green, width: 1),
                ),

                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _obscureText = !_obscureText);
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock, color: Colors.green),
                hintText: 'Enter Confirm Password',
                filled: true,
                fillColor: const Color(0xFFF2F4F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.green, width: 1),
                ),

                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _obscureText = !_obscureText);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.zero,
              ),
              onPressed: () {
                if (_resetToken == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Something went wrong")),
                  );
                  return;
                }

                context.read<AuthBloc>().add(
                  ResetPasswordRequested(
                    phoneNumber: _forgotMobileController.text,
                    resetToken: _resetToken!,
                    newPassword: _newPasswordController.text,
                    confirmPassword: _confirmPasswordController.text,
                  ),
                );
              },
              child: Text("Reset Password"),
            ),
          ],
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              setState(() {
                _isFlipped = false;
                _isOtpSent = false;
                // _secondsLeft = 0;
                _isVerifySent = false;
                _resetToken = '';
                _obscureText = false;
                _newPasswordController.clear();
                _confirmPasswordController.clear();
                _forgotMobileController.clear();
              });
            },
            child: const Text("Back to Login"),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard(AuthState state) {
    return Container(
      key: const ValueKey(false),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 15,
            offset: Offset(0, 6),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Login",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Agricultural Structures Survey",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          /// MOBILE FIELD
          const _FieldLabel(label: 'MOBILE NO', isRequired: true),
          const SizedBox(height: 8),

          TextField(
            controller: _identifierController,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 10,
            decoration: InputDecoration(
              counterText: "",
              prefixIcon: const Icon(Icons.person, color: Colors.green),
              hintText: 'Enter Mobile Number',
              filled: true,
              fillColor: const Color(0xFFF2F4F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.green, width: 1),
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// PASSWORD FIELD
          const _FieldLabel(label: 'PASSWORD', isRequired: true),
          const SizedBox(height: 8),

          TextField(
            controller: _passwordController,
            obscureText: _obscureText,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock, color: Colors.green),
              hintText: 'Enter Password',
              filled: true,
              fillColor: const Color(0xFFF2F4F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.green, width: 1),
              ),

              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() => _obscureText = !_obscureText);
                },
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// FORGOT PASSWORD
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                setState(() => _isFlipped = true);
              },
              child: const Text(
                "Forgot Password?",
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// SIGN IN BUTTON
          SizedBox(
            height: 50,
            child: ElevatedButton(
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
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Ink(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: Center(
                  child: state is AuthLoading
                      ? Row(
                          spacing: 8,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            Text(
                              'Signing In...',
                              style: TextStyle(
                                color: AppColors.textFieldBackground,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          "Sign In",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),
        ],
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
