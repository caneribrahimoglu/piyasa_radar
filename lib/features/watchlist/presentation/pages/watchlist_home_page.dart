import 'package:flutter/material.dart';
import 'package:piyasa_radar/app/app_state.dart';
import 'package:piyasa_radar/features/watchlist/domain/models/product_watch_item.dart';
import 'package:piyasa_radar/features/watchlist/presentation/pages/add_product_watch_page.dart';
import 'package:piyasa_radar/features/watchlist/presentation/pages/product_watch_detail_page.dart';
import 'package:piyasa_radar/features/watchlist/presentation/widgets/empty_watchlist.dart';
import 'package:piyasa_radar/features/watchlist/presentation/widgets/product_watch_card.dart';
import 'package:piyasa_radar/shared/widgets/page_container.dart';

class WatchlistHomePage extends StatefulWidget {
  const WatchlistHomePage({
    required this.appState,
    this.showAppBar = true,
    super.key,
  });

  final AppState appState;
  final bool showAppBar;

  @override
  State<WatchlistHomePage> createState() => _WatchlistHomePageState();
}

class _WatchlistHomePageState extends State<WatchlistHomePage> {
  Future<void> _openAddProductWatchPage() async {
    final newItem = await Navigator.of(context).push<ProductWatchItem>(
      MaterialPageRoute<ProductWatchItem>(
        builder: (context) => const AddProductWatchPage(),
      ),
    );

    if (!mounted || newItem == null) {
      return;
    }

    widget.appState.addWatchItem(newItem);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Ürün takibe eklendi.')));
  }

  void _openProductWatchDetailPage(ProductWatchItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ProductWatchDetailPage(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: const Text('Piyasa Radar'))
          : null,
      body: AnimatedBuilder(
        animation: widget.appState,
        builder: (context, child) => PageContainer(
          maxWidth: 1100,
          child: widget.appState.watchItems.isEmpty
              ? Center(
                  child: EmptyWatchlist(
                    onAddProductPressed: _openAddProductWatchPage,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: widget.appState.watchItems.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = widget.appState.watchItems[index];

                    return ProductWatchCard(
                      item: item,
                      onTap: () => _openProductWatchDetailPage(item),
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddProductWatchPage,
        label: const Text('Ürün Takibe Al'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
