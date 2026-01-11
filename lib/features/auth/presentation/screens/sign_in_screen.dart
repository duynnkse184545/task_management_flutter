import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:task_management_flutter/core/error/failure_handler.dart';
import 'package:task_management_flutter/core/theme/app_colors.dart';
import 'package:task_management_flutter/core/widgets/error_retry_widget.dart';
import 'package:task_management_flutter/core/widgets/loader.dart';
import 'package:task_management_flutter/features/auth/presentation/controllers/sign_in_controller.dart';
import 'package:task_management_flutter/features/auth/presentation/states/sign_in_state.dart';

class SignInScreen extends HookConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hooks - auto-disposed! No manual dispose needed ✅
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final obscurePassword = useState(true);
    
    final signInState = ref.watch(signInControllerProvider);

    // Listen for success to navigate
    ref.listen<SignInState>(signInControllerProvider, (previous, next) {
      next.maybeWhen(
        success: () {
          // Navigate to home (or wherever your auth flow goes)
          Navigator.pushReplacementNamed(context, '/home');
        },
        orElse: () {},
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: SafeArea(
        child: signInState.when(
          // Initial state - show form
          initial: () => _buildSignInForm(
            context,
            ref,
            emailController,
            passwordController,
            obscurePassword,
          ),
          
          // Loading state - show form with loading button
          loading: () => _buildSignInForm(
            context,
            ref,
            emailController,
            passwordController,
            obscurePassword,
            isLoading: true,
          ),
          
          // Success state - will navigate via listener above
          success: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 80, color: AppColors.success),
                SizedBox(height: 16),
                Text('Sign in successful!'),
              ],
            ),
          ),
          
          // Error state - show error with retry option
          error: (message, failure) => Column(
            children: [
              // Error banner at top
              ErrorBanner(
                message: message,
                onRetry: FailureHandler.isRetryable(failure)
                    ? () => ref.read(signInControllerProvider.notifier).retry()
                    : null,
                onDismiss: () => ref.read(signInControllerProvider.notifier).resetState(),
              ),
              
              // Form still visible
              Expanded(
                child: _buildSignInForm(
                  context,
                  ref,
                  emailController,
                  passwordController,
                  obscurePassword,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm(
    BuildContext context,
    WidgetRef ref,
    TextEditingController emailController,
    TextEditingController passwordController,
    ValueNotifier<bool> obscurePassword,
    {bool isLoading = false}
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),

          // Logo or title
          const Icon(Icons.task_alt, size: 80, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Welcome Back',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to continue',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 48),

          // Email field
          TextField(
            controller: emailController,
            enabled: !isLoading,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          // Password field
          TextField(
            controller: passwordController,
            enabled: !isLoading,
            obscureText: obscurePassword.value,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword.value ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  obscurePassword.value = !obscurePassword.value;
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Sign in button
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () => _handleSignIn(
                        ref,
                        emailController,
                        passwordController,
                      ),
              child: isLoading
                  ? const SmallLoader()
                  : const Text('Sign In'),
            ),
          ),

          const SizedBox(height: 16),

          // Sign up link
          TextButton(
            onPressed: isLoading ? null : () {
              Navigator.pushReplacementNamed(context, '/sign-up');
            },
            child: const Text("Don't have an account? Sign Up"),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignIn(
    WidgetRef ref,
    TextEditingController emailController,
    TextEditingController passwordController,
  ) async {
    // Controller handles validation now
    await ref.read(signInControllerProvider.notifier).signIn(
      emailController.text,
      passwordController.text,
    );
    
    // Success navigation handled by listener above
    // Errors shown via state.when(error: ...)
  }
}