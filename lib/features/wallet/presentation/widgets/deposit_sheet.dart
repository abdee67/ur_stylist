import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ur_stylist/features/wallet/presentation/bloc/wallet_bloc.dart';

class DepositSheet extends StatefulWidget {
  final double minimumAmount;

  const DepositSheet({super.key, required this.minimumAmount});

  @override
  State<DepositSheet> createState() => _DepositSheetState();
}

class _DepositSheetState extends State<DepositSheet> {
  late final TextEditingController _amountController;
  File? _proof;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.minimumAmount.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Submit deposit proof',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: 'ETB ',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickProof,
            icon: const Icon(Iconsax.document_upload),
            label: Text(
              _proof == null ? 'Upload receipt image' : 'Receipt selected',
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: BlocBuilder<WalletBloc, WalletState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: state.isActionLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                  ),
                  child: state.isActionLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit for verification'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickProof() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() => _proof = File(image.path));
  }

  void _submit() {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final proof = _proof;
    if (amount <= 0 || proof == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter an amount and attach receipt proof.'),
        ),
      );
      return;
    }
    context.read<WalletBloc>().add(
      DepositProofSubmitted(amount: amount, proof: proof),
    );
    Navigator.pop(context);
  }
}
