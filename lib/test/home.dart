import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "RiverPod Example",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeView(),
    );
  }
}

class HomeView extends ConsumerWidget {
  HomeView({Key? key}) : super(key: key);
  final counterProvider = StateNotifierProvider((ref) => Counter());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);

    ref.listen(
      counterProvider,
      ((prev, next) {
        print("상태 반영: $prev, $next");
      }),
    );
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Count: ${count.toString()}",
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => ref.watch(counterProvider.notifier).increment(),
              child: const Text(
                "증가",
              ),
            ),
            TextButton(
              onPressed: () => ref.watch(counterProvider.notifier).decrease(),
              child: const Text(
                "감소",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Counter extends StateNotifier<int> {
  Counter() : super(0);

  void increment() => state++;
  void decrease() => state--;
}