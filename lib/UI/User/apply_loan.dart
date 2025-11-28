import 'dart:math';
import 'package:flutter/material.dart';
import '../../layout/theme.dart';
import '../../Services/firebase_service.dart';

class ApplyLoanPage extends StatefulWidget {
  const ApplyLoanPage({super.key});

  @override
  State<ApplyLoanPage> createState() => _ApplyLoanPageState();
}

class _ApplyLoanPageState extends State<ApplyLoanPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();

  final Map<String, Map<String, dynamic>> _loanTerms = {
    '7 days - 15%': {'months': 0.23, 'interestRate': 15.0, 'label': '7 days'},
    '14 days - 12%': {'months': 0.47, 'interestRate': 12.0, 'label': '14 days'},
    '1 month - 8%': {'months': 1, 'interestRate': 8.0, 'label': '1 month'},
    '3 months - 5%': {'months': 3, 'interestRate': 5.0, 'label': '3 months'},
    '6 months - 4%': {'months': 6, 'interestRate': 4.0, 'label': '6 months'},
    '12 months - 3.5%': {
      'months': 12,
      'interestRate': 3.5,
      'label': '12 months',
    },
    '24 months - 3%': {'months': 24, 'interestRate': 3.0, 'label': '24 months'},
  };
  String _selectedTerm = '3 months - 5%';

  final List<String> _loanPurposes = [
    'Personal/Emergency',
    'Medical Expenses',
    'Education',
    'Home Improvement',
    'Business Capital',
    'Debt Consolidation',
    'Travel',
    'Wedding',
    'Vehicle Purchase',
    'Others',
  ];
  String _selectedPurpose = 'Personal/Emergency';

  double _monthly = 0.0;
  double _total = 0.0;
  double _currentMonths = 3.0;
  bool _showSummary = false;
  bool _acceptedTerms = false;
  bool _isSubmitting = false;
  bool _isVerified = false;
  bool _isCheckingVerification = true;

  late final AnimationController _anim;
  late final Animation<double> _fade;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _checkVerification();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeInOut);
  }

  Future<void> _checkVerification() async {
    try {
      final verified = await _firebaseService.isUserVerified();
      if (mounted) {
        setState(() {
          _isVerified = verified;
          _isCheckingVerification = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCheckingVerification = false);
      }
    }
  }

  static const Color _accentPink = Color(0xFFD81B60);

  @override
  void dispose() {
    _amountController.dispose();
    _anim.dispose();
    super.dispose();
  }

  String _formatPeso(double v) => '₱${v.toStringAsFixed(2)}';

  void _calculate() {
    final a = double.tryParse(_amountController.text) ?? 0.0;
    if (a <= 0) {
      setState(() {
        _showSummary = false;
        _monthly = 0.0;
        _total = 0.0;
        _currentMonths = 0.0;
      });
      return;
    }
    final termData = _loanTerms[_selectedTerm]!;
    final months = termData['months'] as double;
    final interestRate = termData['interestRate'] as double;

    double total;
    if (months < 1) {
      total = a * (1 + (interestRate / 100));
    } else {
      final rate = interestRate / 100;
      total = a * pow((1 + rate), months);
    }
    final monthly = months < 1 ? total : total / months;
    setState(() {
      _total = total;
      _monthly = monthly;
      _showSummary = true;
      _currentMonths = months;
    });
    _anim.forward();
  }

  @override
  Widget build(BuildContext context) {
    final termData = _loanTerms[_selectedTerm]!;

    if (_isCheckingVerification) {
      return Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.instagramGradient.createShader(bounds),
            child: const Text(
              'Apply for a Loan',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isVerified) {
      return Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.instagramGradient.createShader(bounds),
            child: const Text(
              'Apply for a Loan',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 80,
                  color: Colors.orange.shade400,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Verification Required',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'You need to verify your account before applying for a loan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 32),
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
                      elevation: 2,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, "/verification");
                    },
                    child: const Text(
                      'Go to Verification',
                      style: TextStyle(
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
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Apply for Loan',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Loan Amount input
          const Text(
            'Loan Amount',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: _accentPink,
                ),
                hintText: 'Enter amount (e.g. 5000)',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              onChanged: (_) => _calculate(),
            ),
          ),
          const SizedBox(height: 24),

          // Repayment term dropdown
          const Text(
            'Repayment Term & Interest',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedTerm,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: _accentPink),
                items: _loanTerms.keys.map((term) {
                  return DropdownMenuItem<String>(
                    value: term,
                    child: Text(
                      term,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedTerm = value);
                    _calculate();
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Reason dropdown
          const Text(
            'Purpose of Loan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPurpose,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: _accentPink),
                items: _loanPurposes.map((purpose) {
                  return DropdownMenuItem<String>(
                    value: purpose,
                    child: Text(
                      purpose,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedPurpose = value);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Summary Card
          if (_showSummary)
            FadeTransition(
              opacity: _fade,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E3192).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Monthly Payment',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          _formatPeso(_monthly),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: Colors.white24),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Interest',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          _formatPeso(
                            _total -
                                (double.tryParse(_amountController.text) ?? 0),
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Repayment',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          _formatPeso(_total),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Center(
                child: Text(
                  'Enter amount and select terms\nto see calculation',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Terms & Conditions
          Theme(
            data: ThemeData(unselectedWidgetColor: Colors.grey[400]),
            child: CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _acceptedTerms,
              activeColor: _accentPink,
              onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
              title: Text(
                'I agree to the Terms and Conditions and Privacy Policy',
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: (!_acceptedTerms || _isSubmitting || !_showSummary)
                  ? null
                  : () async {
                      _calculate();
                      if (!_showSummary) return;

                      setState(() => _isSubmitting = true);
                      try {
                        final amount =
                            double.tryParse(_amountController.text) ?? 0.0;
                        if (amount <= 0) {
                          throw Exception('Please enter a valid amount');
                        }

                        final termData = _loanTerms[_selectedTerm]!;
                        final interestRate = termData['interestRate'] as double;

                        await _firebaseService.submitLoanApplication(
                          amount: amount,
                          interestRate: interestRate,
                          totalAmount: _total,
                          monthlyPayment: _monthly,
                          term: _selectedTerm,
                          purpose: _selectedPurpose,
                        );

                        if (mounted) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: const Column(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 60,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Application Submitted!',
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              content: const Text(
                                'Your loan application has been submitted successfully. We will review it shortly.',
                                textAlign: TextAlign.center,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close dialog
                                    Navigator.pop(
                                      context,
                                    ); // Go back to dashboard
                                  },
                                  child: const Text(
                                    'OK',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          );

                          // Clear form after successful submission
                          _amountController.clear();
                          setState(() {
                            _showSummary = false;
                            _acceptedTerms = false;
                            _monthly = 0.0;
                            _total = 0.0;
                            _currentMonths = 3.0;
                          });
                          _anim.reset();
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _isSubmitting = false);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentPink,
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: _accentPink.withOpacity(0.4),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Text(
                      'Apply Now',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
