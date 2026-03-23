import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  static const String routeName = '/auth';

  @override
  State<AuthPage> createState() => _AuthPageState();
}

enum _EmailMode {
  signUp,
  signIn,
}

class _AuthPageState extends State<AuthPage> {
  final SupabaseClient client = Supabase.instance.client;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  _EmailMode mode = _EmailMode.signUp;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> withLoading(Future<void> Function() action) async {
    if (isLoading) return;
    setState(() => isLoading = true);
    try {
      await action();
    } on AuthException catch (error) {
      showMessage(error.message);
    } catch (error) {
      showMessage(error.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> signInWithGoogle() async {
    await withLoading(() async {
      await client.auth.signInWithOAuth(OAuthProvider.google);
    });
  }

  bool get shouldShowAppleButton {
    return !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS);
  }

  Future<void> signInWithApple() async {
    await withLoading(() async {
      await client.auth.signInWithOAuth(OAuthProvider.apple);
    });
  }

  Future<void> submitEmail() async {
    await withLoading(() async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      final email = emailController.text.trim();
      final password = passwordController.text;

      if (mode == _EmailMode.signUp) {
        await client.auth.signUp(
          email: email,
          password: password,
        );
        showMessage('สร้างบัญชีสำเร็จ (ถ้าต้องยืนยันอีเมล โปรดตรวจกล่องจดหมาย)');
      } else {
        await client.auth.signInWithPassword(
          email: email,
          password: password,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สมัคร/เข้าสู่ระบบ'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'เริ่มต้นใช้งานก่อน',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: isLoading ? null : signInWithGoogle,
            icon: const Icon(Icons.login),
            label: const Text('ดำเนินการต่อด้วย Google'),
          ),
          if (shouldShowAppleButton) ...[
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: isLoading ? null : signInWithApple,
              icon: const Icon(Icons.apple),
              label: const Text('ดำเนินการต่อด้วย Apple'),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          SegmentedButton<_EmailMode>(
            segments: const [
              ButtonSegment(
                value: _EmailMode.signUp,
                label: Text('สมัครด้วย Email'),
              ),
              ButtonSegment(
                value: _EmailMode.signIn,
                label: Text('เข้าสู่ระบบ'),
              ),
            ],
            selected: <_EmailMode>{mode},
            onSelectionChanged: isLoading
                ? null
                : (selected) {
                    setState(() => mode = selected.first);
                  },
          ),
          const SizedBox(height: 12),
          Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return 'กรอกอีเมล';
                    if (!text.contains('@')) return 'อีเมลไม่ถูกต้อง';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  validator: (value) {
                    final text = value ?? '';
                    if (text.isEmpty) return 'กรอกรหัสผ่าน';
                    if (text.length < 6) return 'อย่างน้อย 6 ตัวอักษร';
                    return null;
                  },
                ),
                if (mode == _EmailMode.signUp) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration:
                        const InputDecoration(labelText: 'Confirm password'),
                    obscureText: true,
                    validator: (value) {
                      final text = value ?? '';
                      if (text.isEmpty) return 'ยืนยันรหัสผ่าน';
                      if (text != passwordController.text) {
                        return 'รหัสผ่านไม่ตรงกัน';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isLoading ? null : submitEmail,
                    child: Text(
                      mode == _EmailMode.signUp ? 'สมัครสมาชิก' : 'เข้าสู่ระบบ',
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading) ...[
            const SizedBox(height: 16),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }
}
