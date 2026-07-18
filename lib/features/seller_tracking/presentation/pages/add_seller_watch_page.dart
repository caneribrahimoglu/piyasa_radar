import 'package:flutter/material.dart';
import 'package:piyasa_radar/features/seller_tracking/domain/models/seller_watch_item.dart';
import 'package:piyasa_radar/shared/widgets/app_button.dart';
import 'package:piyasa_radar/shared/widgets/app_text_field.dart';
import 'package:piyasa_radar/shared/widgets/page_container.dart';

class AddSellerWatchPage extends StatefulWidget {
  const AddSellerWatchPage({super.key});

  @override
  State<AddSellerWatchPage> createState() => _AddSellerWatchPageState();
}

class _AddSellerWatchPageState extends State<AddSellerWatchPage> {
  final _formKey = GlobalKey<FormState>();
  final _sellerNameController = TextEditingController();
  final _sellerLinkController = TextEditingController();
  final _marketplaceNameController = TextEditingController();

  @override
  void dispose() {
    _sellerNameController.dispose();
    _sellerLinkController.dispose();
    _marketplaceNameController.dispose();
    super.dispose();
  }

  String? _requiredFieldValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bu alan boş olamaz';
    }

    return null;
  }

  void _saveForm() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final newSeller = SellerWatchItem(
      sellerName: _sellerNameController.text.trim(),
      sellerUrl: _sellerLinkController.text.trim(),
      marketplaceName: _marketplaceNameController.text.trim(),
      totalProducts: 0,
      newProductsCount: 0,
      lastCheckedAt: DateTime.now(),
      products: const [],
      alerts: const [],
    );

    Navigator.of(context).pop(newSeller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Satıcı Takibe Al')),
      body: PageContainer(
        maxWidth: 800,
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              AppTextField(
                controller: _sellerNameController,
                labelText: 'Satıcı adı',
                validator: _requiredFieldValidator,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _sellerLinkController,
                labelText: 'Satıcı linki',
                keyboardType: TextInputType.url,
                validator: _requiredFieldValidator,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _marketplaceNameController,
                labelText: 'Pazaryeri/Site',
                validator: _requiredFieldValidator,
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
