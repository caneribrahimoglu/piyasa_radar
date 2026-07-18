import 'package:flutter/material.dart';
import 'package:piyasa_radar/core/constants/default_check_times.dart';
import 'package:piyasa_radar/features/watchlist/domain/models/product_watch_item.dart';
import 'package:piyasa_radar/shared/widgets/app_button.dart';
import 'package:piyasa_radar/shared/widgets/app_text_field.dart';
import 'package:piyasa_radar/shared/widgets/check_time_editor.dart';
import 'package:piyasa_radar/shared/widgets/page_container.dart';

class AddProductWatchPage extends StatefulWidget {
  const AddProductWatchPage({super.key, this.initialItem});

  final ProductWatchItem? initialItem;

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
  List<String> _checkTimes = defaultCheckTimes;
  String? _checkTimesErrorText;

  bool get _isEditing => widget.initialItem != null;

  @override
  void initState() {
    super.initState();
    final initialItem = widget.initialItem;
    if (initialItem == null) return;

    _productNameController.text = initialItem.productName;
    _productLinkController.text = initialItem.productUrl;
    _marketplaceNameController.text = initialItem.marketplaceName;
    _sellerNameController.text = initialItem.sellerName;
    _targetPriceController.text = initialItem.targetPrice?.toString() ?? '';
    _isStockTrackingEnabled = initialItem.stockTrackingEnabled;
    _checkTimes = normalizeCheckTimes(initialItem.checkTimes);
  }

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
    if (_checkTimes.isEmpty) {
      setState(() {
        _checkTimesErrorText = 'En az bir kontrol saati seçmelisiniz.';
      });
      return;
    }

    final targetPriceText = _targetPriceController.text.trim();
    final targetPrice = targetPriceText.isEmpty
        ? null
        : int.parse(targetPriceText);
    final sellerName = _sellerNameController.text.trim().isEmpty
        ? 'Bilinmeyen satıcı'
        : _sellerNameController.text.trim();
    final initialItem = widget.initialItem;
    final newItem = initialItem == null
        ? ProductWatchItem(
            id: 'product_${DateTime.now().microsecondsSinceEpoch}',
            productName: _productNameController.text.trim(),
            productUrl: _productLinkController.text.trim(),
            checkTimes: _checkTimes,
            alerts: const [],
            marketplaceName: _marketplaceNameController.text.trim(),
            sellerName: sellerName,
            lastPrice: 0,
            previousPrice: 0,
            targetPrice: targetPrice,
            lastCheckedAt: DateTime.now(),
            priceChanged: false,
            stockTrackingEnabled: _isStockTrackingEnabled,
            inStock: true,
          )
        : initialItem.copyWith(
            productName: _productNameController.text.trim(),
            productUrl: _productLinkController.text.trim(),
            checkTimes: _checkTimes,
            marketplaceName: _marketplaceNameController.text.trim(),
            sellerName: sellerName,
            targetPrice: targetPrice,
            stockTrackingEnabled: _isStockTrackingEnabled,
          );

    Navigator.of(context).pop(newItem);
  }

  String? _requiredFieldValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bu alan boş olamaz';
    }

    return null;
  }

  String? _targetPriceValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;

    final price = int.tryParse(text);
    if (price == null || price <= 0) {
      return "Hedef fiyat 0'dan büyük olmalı.";
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Ürün Takibini Düzenle' : 'Ürün Takibe Al'),
      ),
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
                validator: _targetPriceValidator,
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
              AppButton(
                label: _isEditing ? 'Güncelle' : 'Kaydet',
                onPressed: _saveForm,
              ),
              const SizedBox(height: 16),
              CheckTimeEditor(
                times: _checkTimes,
                errorText: _checkTimesErrorText,
                onChanged: (times) {
                  setState(() {
                    _checkTimes = times;
                    _checkTimesErrorText = null;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
