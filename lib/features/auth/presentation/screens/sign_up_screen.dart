import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:task_management_flutter/core/error/failure_handler.dart';
import 'package:task_management_flutter/core/theme/app_colors.dart';
import 'package:task_management_flutter/core/widgets/error_retry_widget.dart';
import 'package:task_management_flutter/core/widgets/loader.dart';
import '../controllers/sign_up_controller.dart';
import '../states/sign_up_state.dart';

class SignUpScreen extends HookConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hooks - auto-disposed!
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final usernameController = useTextEditingController();
    final fullNameController = useTextEditingController();
    final obscurePassword = useState(true);
    
    final signUpState = ref.watch(signUpControllerProvider);

    // Listen for success to navigate
    ref.listen<SignUpState>(signUpControllerProvider, (previous, next) {
      next.maybeWhen(
        success: () {
          Navigator.pushReplacementNamed(context, '/home');
        },
        orElse: () {},
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: SafeArea(
        child: signUpState.when(
          // Initial state - show form
          initial: () => _buildSignUpForm(
            context,
            ref,
            emailController,
            passwordController,
            usernameController,
            fullNameController,
            obscurePassword,
          ),
          
          // Loading state - show form with loading button
          loading: () => _buildSignUpForm(
            context,
            ref,
            emailController,
            passwordController,
            usernameController,
            fullNameController,
            obscurePassword,
            isLoading: true,
          ),
          
          // Validating username
          validating: () => _buildSignUpForm(
            context,
            ref,
            emailController,
            passwordController,
            usernameController,
            fullNameController,
            obscurePassword,
            isValidating: true,
          ),
          
          // Success state - will navigate via listener
          success: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 80, color: AppColors.success),
                SizedBox(height: 16),
                Text('Account created successfully!'),
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
                    ? () => ref.read(signUpControllerProvider.notifier).retry()
                    : null,
                onDismiss: () => ref.read(signUpControllerProvider.notifier).resetState(),
              ),
              
              // Form still visible
              Expanded(
                child: _buildSignUpForm(
                  context,
                  ref,
                  emailController,
                  passwordController,
                  usernameController,
                  fullNameController,
                  obscurePassword,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpForm(
    BuildContext context,
    WidgetRef ref,
    TextEditingController emailController,
    TextEditingController passwordController,
    TextEditingController usernameController,
    TextEditingController fullNameController,
    ValueNotifier<bool> obscurePassword,
    {bool isLoading = false, bool isValidating = false}
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
            'Create Account',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Sign up to get started',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 48),

          // Email field
          TextField(
            controller: emailController,
            enabled: !isLoading && !isValidating,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          // Username field
          TextField(
            controller: usernameController,
            enabled: !isLoading && !isValidating,
            decoration: InputDecoration(
              labelText: 'Username',
              hintText: 'Choose a username',
              prefixIcon: const Icon(Icons.person_outline),
              border: const OutlineInputBorder(),
              suffixIcon: isValidating 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
            ),
          ),

          const SizedBox(height: 16),

          // Full name field (optional)
          TextField(
            controller: fullNameController,
            enabled: !isLoading && !isValidating,
            decoration: const InputDecoration(
              labelText: 'Full Name (Optional)',
              hintText: 'Enter your full name',
              prefixIcon: Icon(Icons.badge_outlined),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          // Password field
          TextField(
            controller: passwordController,
            enabled: !isLoading && !isValidating,
            obscureText: obscurePassword.value,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Create a password',
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

          // Sign up button
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: (isLoading || isValidating)
                  ? null
                  : () => _handleSignUp(
                        ref,
                        emailController,
                        passwordController,
                        usernameController,
                        fullNameController,
                      ),
              child: isLoading
                  ? const SmallLoader()
                  : const Text('Sign Up'),
            ),
          ),

          const SizedBox(height: 16),

          // Sign in link
          TextButton(
            onPressed: (isLoading || isValidating) ? null : () {
              Navigator.pushReplacementNamed(context, '/sign-in');
            },
            child: const Text('Already have an account? Sign In'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignUp(
    WidgetRef ref,
    TextEditingController emailController,
    TextEditingController passwordController,
    TextEditingController usernameController,
    TextEditingController fullNameController,
  ) async {
    await ref.read(signUpControllerProvider.notifier).signUp(
      email: emailController.text,
      password: passwordController.text,
      username: usernameController.text,
      fullName: fullNameController.text.isEmpty ? null : fullNameController.text,
    );
  }
}