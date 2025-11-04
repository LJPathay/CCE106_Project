import 'package:flutter/material.dart';
import '../UI/theme.dart';

class MakePaymentPage extends StatefulWidget {
  const MakePaymentPage({super.key});

  @override
  State<MakePaymentPage> createState() => _MakePaymentPageState();
}

class _MakePaymentPageState extends State<MakePaymentPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  final List<String> paymentMethods = ["Bank Transfer", "GCash", "Credit Card"];
  String? _selectedMethod;

  static const Color _accentPink = Color(0xFFD81B60);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: ShaderMask(
          shaderCallback: (bounds) =>
              AppTheme.instagramGradient.createShader(bounds),
          child: const Text(
            'Make Payment',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(18),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 15,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    'Receiver',
                    style: AppTheme.heading.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _accentPink,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Juan Dela Cruz',
                    style: AppTheme.heading.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.qr_code_scanner,
                              size: 34,
                              color: _accentPink.withOpacity(0.7),
                            ),
                            onPressed: () {},
                          ),
                          Text(
                            "Scan",
                            style: AppTheme.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.content_paste,
                              size: 34,
                              color: _accentPink.withOpacity(0.7),
                            ),
                            onPressed: () {},
                          ),
                          Text(
                            "Paste",
                            style: AppTheme.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Amount',
                  style: AppTheme.heading.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 7),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: AppTheme.body,
                  decoration: InputDecoration(
                    hintText: "Enter payment amount",
                    hintStyle: AppTheme.body.copyWith(color: Colors.grey[500]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Note',
                  style: AppTheme.heading.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 7),
                TextField(
                  controller: _noteController,
                  style: AppTheme.body,
                  decoration: InputDecoration(
                    hintText: "Add a note (optional)",
                    hintStyle: AppTheme.body.copyWith(color: Colors.grey[500]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  "Payment Method",
                  style: AppTheme.heading.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                ...paymentMethods.map(
                  (m) => RadioListTile<String>(
                    activeColor: _accentPink,
                    title: Text(m, style: AppTheme.body),
                    value: m,
                    groupValue: _selectedMethod,
                    onChanged: (v) => setState(() => _selectedMethod = v),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentPink,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 1,
                    ),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Payment sent: ${_amountController.text}, via ${_selectedMethod ?? ''}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: _accentPink,
                        ),
                      );
                      _amountController.clear();
                      _noteController.clear();
                      setState(() => _selectedMethod = null);
                    },
                    child: Text(
                      "Pay",
                      style: AppTheme.heading.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
