import 'package:flutter/material.dart';
import 'package:piyasa_radar/features/watchlist/data/repositories/fake_watchlist_repository.dart';
import 'package:piyasa_radar/features/watchlist/domain/models/product_watch_item.dart';
import 'package:piyasa_radar/shared/widgets/app_button.dart';
import 'package:piyasa_radar/shared/widgets/app_text_field.dart';
import 'package:piyasa_radar/shared/widgets/page_container.dart';

class AddProductWatchPage extends StatefulWidget {
  const AddProductWatchPage({super.key});

  @override
  State<AddProductWatchPage> createState() => _AddProductWatchPageState();
}

class _AddProductWatchPageState extends State<AddProductWatchPage> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _productLinkController = TextEditingController();
  final _marketplaceNameController = TextEditingController();
  final _sellerNameController = TextEditingController();
  final _targetPriceController = TextEditingController();

  bool _isStockTrackingEnabled = true;

  @override
  void dispose() {
    _productNameController.dispose();
    _productLinkController.dispose();
    _marketplaceNameController.dispose();
    _sellerNameController.dispose();
    _targetPriceController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final currentPrice = int.tryParse(_targetPriceController.text.trim()) ?? 0;
    final sellerName = _sellerNameController.text.trim().isEmpty
        ? 'Bilinmeyen satıcı'
        : _sellerNameController.text.trim();
    final newItem = ProductWatchItem(
      id: 'product_${DateTime.now().microsecondsSinceEpoch}',
      productName: _productNameController.text.trim(),
      productUrl: _productLinkController.text.trim(),
      checkTimes: FakeWatchlistRepository.defaultCheckTimes,
      alerts: const [],
      marketplaceName: _marketplaceNameController.text.trim(),
      sellerName: sellerName,
      lastPrice: currentPrice,
      previousPrice: currentPrice,
      lastCheckedAt: DateTime.now(),
      priceChanged: false,
      inStock: _isStockTrackingEnabled,
    );

    Navigator.of(context).pop(newItem);
  }

  String? _requiredFieldValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bu alan boş olamaz';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ürün Takibe Al')),
      body: PageContainer(
        maxWidth: 800,
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              AppTextField(
                controller: _productNameController,
                labelText: 'Ürün adı',
                validator: _requiredFieldValidator,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _productLinkController,
                labelText: 'Ürün linki',
                keyboardType: TextInputType.url,
                validator: _requiredFieldValidator,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _marketplaceNameController,
                labelText: 'Pazaryeri/Site',
                validator: _requiredFieldValidator,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _sellerNameController,
                labelText: 'Satıcı adı',
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _targetPriceController,
                labelText: 'Hedef fiyat',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Stok takibi aktif mi?'),
                value: _isStockTrackingEnabled,
                onChanged: (value) {
                  setState(() {
                    _isStockTrackingEnabled = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              AppButton(label: 'Kaydet', onPressed: _saveForm),
            ],
          ),
        ),
      ),
    );
  }
}
