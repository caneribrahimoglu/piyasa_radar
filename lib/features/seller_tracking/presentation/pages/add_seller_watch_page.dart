import 'package:flutter/material.dart';
import 'package:piyasa_radar/core/constants/default_check_times.dart';
import 'package:piyasa_radar/features/seller_tracking/domain/models/seller_watch_item.dart';
import 'package:piyasa_radar/shared/widgets/app_button.dart';
import 'package:piyasa_radar/shared/widgets/app_text_field.dart';
import 'package:piyasa_radar/shared/widgets/check_time_editor.dart';
import 'package:piyasa_radar/shared/widgets/page_container.dart';

class AddSellerWatchPage extends StatefulWidget {
  const AddSellerWatchPage({super.key, this.initialItem});

  final SellerWatchItem? initialItem;

  @override
  State<AddSellerWatchPage> createState() => _AddSellerWatchPageState();
}

class _AddSellerWatchPageState extends State<AddSellerWatchPage> {
  final _formKey = GlobalKey<FormState>();
  final _sellerNameController = TextEditingController();
  final _sellerLinkController = TextEditingController();
  final _marketplaceNameController = TextEditingController();
  List<String> _checkTimes = defaultCheckTimes;
  String? _checkTimesErrorText;

  bool get _isEditing => widget.initialItem != null;

  @override
  void initState() {
    super.initState();
    final initialItem = widget.initialItem;
    if (initialItem == null) return;

    _sellerNameController.text = initialItem.sellerName;
    _sellerLinkController.text = initialItem.sellerUrl;
    _marketplaceNameController.text = initialItem.marketplaceName;
    _checkTimes = normalizeCheckTimes(
      initialItem.checkTimes,
      fallback: defaultCheckTimes,
    );
  }

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
    if (_checkTimes.isEmpty) {
      setState(() {
        _checkTimesErrorText = 'En az bir kontrol saati seçmelisiniz.';
      });
      return;
    }

    final initialItem = widget.initialItem;
    final newSeller = initialItem == null
        ? SellerWatchItem(
            id: 'seller_${DateTime.now().microsecondsSinceEpoch}',
            sellerName: _sellerNameController.text.trim(),
            sellerUrl: _sellerLinkController.text.trim(),
            marketplaceName: _marketplaceNameController.text.trim(),
            checkTimes: _checkTimes,
            totalProducts: 0,
            newProductsCount: 0,
            lastCheckedAt: DateTime.now(),
            products: const [],
            alerts: const [],
          )
        : initialItem.copyWith(
            sellerName: _sellerNameController.text.trim(),
            sellerUrl: _sellerLinkController.text.trim(),
            marketplaceName: _marketplaceNameController.text.trim(),
            checkTimes: _checkTimes,
          );

    Navigator.of(context).pop(newSeller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Satıcı Takibini Düzenle' : 'Satıcı Takibe Al',
        ),
      ),
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
