import 'package:flutter/material.dart';

class EmptyWatchlist extends StatelessWidget {
  const EmptyWatchlist({super.key, required this.onAddProductPressed});

  final VoidCallback onAddProductPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Takip edilen ürün yok',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: onAddProductPressed,
          child: const Text('Ürün Takibe Al'),
        ),
      ],
    );
  }
}
