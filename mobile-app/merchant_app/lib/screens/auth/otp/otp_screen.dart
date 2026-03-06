import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants.dart';
import '../../../services/auth_service.dart';
import '../../registration/registration_screen.dart';
import '../../home/home_screen.dart';

// Arguments passed from PhoneEntryScreen
class OtpArgs {
  final String phone;
  final bool   isNewUser;
  OtpArgs({required this.phone, required this.isNewUser});
}

class OtpScreen extends StatefulWidget {
  static const routeName = '/otp';
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(4, (_) => FocusNode());

  int   _remainingSeconds = 60;
  bool  _canResend        = false;
  bool  _isLoading        = false;
  Timer? _timer;

  late OtpArgs _args;
  bool _argsLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argsLoaded) {
      _args = ModalRoute.of(context)!.settings.arguments as OtpArgs;
      _argsLoaded = true;
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes)   f.dispose();
    super.dispose();
  }

  void _startTimer() {
    _remainingSeconds = 60;
    _canResend        = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        setState(() => _canResend = true);
        t.cancel();
      }
    });
  }

  Future<void> _handleResend() async {
    if (!_canResend) return;
    final result = await AuthService.sendOtp(_args.phone);
    if (result.success) {
      _startTimer();
      setState(() {});
      _showSnack('OTP code sent!', kSuccessColor);
    } else {
      _showSnack(result.message ?? 'Failed to resend.', kErrorColor);
    }
  }

  Future<void> _handleVerify() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length != 4) {
      _showSnack(kOtpNullError, kErrorColor);
      return;
    }

    setState(() => _isLoading = true);
    final result = await AuthService.verifyOtp(_args.phone, otp);
    setState(() => _isLoading = false);

    if (!result.success) {
      _showSnack(result.message ?? 'Invalid OTP.', kErrorColor);
      return;
    }

    if (!mounted) return;

    if (result.isNewUser == true) {
      // New merchant → go to registration
      Navigator.pushReplacementNamed(
        context,
        RegistrationScreen.routeName,
        arguments: _args.phone,
      );
    } else {
      // Existing merchant → go home
      Navigator.pushNamedAndRemoveUntil(
        context,
        HomeScreen.routeName,
        (_) => false,
      );
    }
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    // Auto-submit when all 4 digits filled
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == 4) _handleVerify();
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_argsLoaded) return const Scaffold();

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        leading: BackButton(color: kTextColor),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Header
              const Text(
                'Verify your number',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: kTextColor,
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 15, color: kSubTextColor),
                  children: [
                    const TextSpan(text: 'Code sent to '),
                    TextSpan(
                      text: _args.phone,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: kTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // OTP boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (i) {
                  return _OtpBox(
                    controller: _controllers[i],
                    focusNode:  _focusNodes[i],
                    onChanged:  (v) => _onOtpChanged(i, v),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // Timer / Resend
              Center(
                child: _canResend
                    ? GestureDetector(
                        onTap: _handleResend,
                        child: const Text(
                          'Resend code',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: kPrimaryColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      )
                    : RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              fontSize: 14, color: kSubTextColor),
                          children: [
                            const TextSpan(text: 'Resend code in '),
                            TextSpan(
                              text: '${_remainingSeconds}s',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: kPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const Spacer(),

              // Verify button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleVerify,
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width:  22,
                        child:  CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Verify'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Single OTP Box ───────────────────────────────────────
class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode             focusNode;
  final ValueChanged<String>  onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: TextField(
        controller:     controller,
        focusNode:      focusNode,
        keyboardType:   TextInputType.number,
        textAlign:      TextAlign.center,
        maxLength:      1,
        onChanged:      onChanged,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontSize:   28,
          fontWeight: FontWeight.w700,
          color:      kTextColor,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled:      true,
          fillColor:   Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:   const BorderSide(color: kBorderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:   const BorderSide(color: kBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:   const BorderSide(color: kPrimaryColor, width: 2),
          ),
        ),
      ),
    );
  }
}