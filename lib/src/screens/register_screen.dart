import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../config/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _otpSent = false;
  String? _generatedOtp;

  Future<void> _sendWhatsApp() async {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showSnackBar('Mohon isi semua data');
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool isRegistered = await _authService.isPhoneRegistered(
        _phoneController.text,
      );
      if (isRegistered) {
        _showSnackBar('Nomor ini sudah terdaftar. Silakan login.');
        setState(() => _isLoading = false);
        return;
      }

      String code = await _authService.sendWhatsAppOtp(_phoneController.text);
      setState(() {
        _generatedOtp = code;
        _otpSent = true;
      });
      _showSnackBar('Kode OTP telah dikirim ke WhatsApp Anda', isError: false);
    } catch (e) {
      _showSnackBar(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyAndRegister() async {
    if (_otpController.text != _generatedOtp) {
      _showSnackBar('Kode OTP salah!');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.completeRegistration(
        name: _nameController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      _showSnackBar('Gagal Registrasi: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Registration'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Create Account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Register with your WhatsApp number',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 40),
              if (!_otpSent) ...[
                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _phoneController,
                  label: 'WhatsApp Number',
                  hintText: 'e.g. 08123456789',
                  prefixIcon: Icons.phone_android_rounded,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hintText: 'Create a password',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: true,
                ),
              ] else ...[
                const Icon(
                  Icons.mark_chat_read_outlined,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Verify OTP',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the 6-digit code sent to\n${_phoneController.text}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.grey),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  controller: _otpController,
                  label: 'OTP Code',
                  hintText: 'Enter 6 digit code',
                  prefixIcon: Icons.password_rounded,
                  keyboardType: TextInputType.number,
                ),
              ],
              const SizedBox(height: 40),
              PrimaryButton(
                text: _otpSent ? 'Verify & Register' : 'Send OTP via WhatsApp',
                onPressed: _otpSent ? _verifyAndRegister : _sendWhatsApp,
                isLoading: _isLoading,
              ),
              if (_otpSent) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() => _otpSent = false),
                  child: const Text(
                    'Change Details',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
