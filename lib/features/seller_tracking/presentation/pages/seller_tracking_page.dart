import 'package:flutter/material.dart';
import 'package:piyasa_radar/app/app_state.dart';
import 'package:piyasa_radar/features/seller_tracking/domain/models/seller_watch_item.dart';
import 'package:piyasa_radar/features/seller_tracking/presentation/pages/add_seller_watch_page.dart';
import 'package:piyasa_radar/features/seller_tracking/presentation/pages/seller_tracking_detail_page.dart';
import 'package:piyasa_radar/features/seller_tracking/presentation/widgets/seller_watch_card.dart';
import 'package:piyasa_radar/shared/widgets/page_container.dart';

class SellerTrackingPage extends StatefulWidget {
  const SellerTrackingPage({required this.appState, super.key});

  final AppState appState;

  @override
  State<SellerTrackingPage> createState() => _SellerTrackingPageState();
}

class _SellerTrackingPageState extends State<SellerTrackingPage> {
  Future<void> _openAddSellerWatchPage() async {
    final newSeller = await Navigator.of(context).push<SellerWatchItem>(
      MaterialPageRoute<SellerWatchItem>(
        builder: (context) => const AddSellerWatchPage(),
      ),
    );

    if (!mounted || newSeller == null) {
      return;
    }

    widget.appState.addSellerItem(newSeller);
  }

  void _openSellerDetailPage(SellerWatchItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SellerTrackingDetailPage(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: widget.appState,
        builder: (context, child) => PageContainer(
          maxWidth: 1100,
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: widget.appState.sellerItems.length + 1,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Text(
                  'Satıcı Takibi',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                );
              }

              final item = widget.appState.sellerItems[index - 1];

              return SellerWatchCard(
                item: item,
                onTap: () => _openSellerDetailPage(item),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSellerWatchPage,
        label: const Text('Satıcı Takibe Al'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
