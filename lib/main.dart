import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/api_provider.dart';
import 'core/constants/api_constants.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('API Test')),
        body: const ApiTestScreen(),
      ),
    );
  }
}

class ApiTestScreen extends ConsumerWidget {
  const ApiTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiClient = ref.watch(apiClientProvider);

    return Center(
      child: ElevatedButton(
        onPressed: () async {
          try {
            // Test a simple GET request
            final response = await apiClient.get(
              ApiConstants.profiles,
              queryParameters: {'select': '*', 'limit': '1'},
            );
            print('✅ API Response: $response');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('API call successful!')),
              );
            }
          } catch (e) {
            print('❌ API Error: $e');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('API call failed: $e')),
              );
            }
          }
        },
        child: const Text('Test API Call'),
      ),
    );
  }
}