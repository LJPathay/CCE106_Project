import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LoanFormPage extends StatefulWidget {
  const LoanFormPage({super.key});

  @override
  _LoanFormPageState createState() => _LoanFormPageState();
}

class _LoanFormPageState extends State<LoanFormPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  double _loanAmount = 0.0;
  int _monthsToPay = 1;
  final double _interestRate = 0.2; // 20%
  double _monthlyPayment = 0.0;
  double _totalPayment = 0.0;
  bool _showSuccessOverlay = false;

  final currency = NumberFormat.currency(locale: 'en_PH', symbol: '₱');
  bool get _isOverLimit => _loanAmount > 50000;

  void _calculateLoan() {
    if (_loanAmount > 0 && !_isOverLimit) {
      final totalInterest = _loanAmount * _interestRate;
      _totalPayment = _loanAmount + totalInterest;
      _monthlyPayment = _totalPayment / _monthsToPay;
    } else {
      _totalPayment = 0.0;
      _monthlyPayment = 0.0;
    }
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate() && !_isOverLimit) {
      _formKey.currentState!.save();

      setState(() => _showSuccessOverlay = true);

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _showSuccessOverlay = false);
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _calculateLoan();

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: const Text(
              "Apply for a Loan",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 1,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              onChanged: () => setState(() => _calculateLoan()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Loan Amount Field
                  Text(
                    "Loan Amount",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Enter loan amount (max ₱50,000)",
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      prefixIcon: Icon(
                        Icons.payments_rounded,
                        color: Colors.grey[700],
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _isOverLimit
                              ? Colors.red
                              : Colors.grey.shade300, // red if over limit
                          width: 1.3,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _isOverLimit
                              ? Colors.red
                              : Colors.blueAccent, // red if over limit
                          width: 1.6,
                        ),
                      ),
                    ),
                    validator: (value) {
                      final amount = double.tryParse(value ?? '') ?? 0;
                      if (amount <= 0) return "Enter a valid loan amount.";
                      if (amount > 50000) return "Maximum loan is ₱50,000.";
                      return null;
                    },
                    onSaved: (value) =>
                        _loanAmount = double.parse(value ?? '0'),
                    onChanged: (value) {
                      setState(() {
                        _loanAmount = double.tryParse(value) ?? 0;
                      });
                    },
                  ),

                  // ⚠️ Warning Message
                  if (_isOverLimit)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              "Maximum loan limit is ₱50,000.",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Months to Pay Dropdown
                  Text(
                    "Months to Pay",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonFormField<int>(
                      initialValue: _monthsToPay,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      dropdownColor: Colors.white,
                      iconEnabledColor: Colors.grey[700],
                      style: TextStyle(color: Colors.grey[800], fontSize: 15),
                      items: List.generate(
                        12,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text(
                            "${index + 1} month${index > 0 ? 's' : ''}",
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _monthsToPay = value ?? 1;
                          _calculateLoan();
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Auto Calculation Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Loan Summary",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.grey[900],
                            ),
                          ),
                          Divider(color: Colors.grey[300], height: 20),
                          Text(
                            "Interest Rate: 20% (Fixed)",
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                          Text(
                            "Months to Pay: $_monthsToPay",
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Monthly Payment: ${currency.format(_monthlyPayment)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.blueAccent,
                            ),
                          ),
                          Text(
                            "Total Payment: ${currency.format(_totalPayment)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Request Loan Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isOverLimit ? null : _onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isOverLimit
                            ? Colors.grey
                            : Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text("Request Loan"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ✅ Success Overlay Animation
        if (_showSuccessOverlay)
          AnimatedOpacity(
            opacity: _showSuccessOverlay ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 400),
            child: Container(
              color: Colors.black.withOpacity(0.6),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.check_circle, color: Colors.green, size: 80),
                      SizedBox(height: 15),
                      Text(
                        "Loan Request Successful!",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
