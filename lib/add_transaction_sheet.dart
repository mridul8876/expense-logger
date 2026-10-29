import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'expense.dart';

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _personController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  PaymentMode _selectedMode = PaymentMode.online;
  PaymentMode _transferFrom = PaymentMode.cash;
  PaymentMode _transferTo = PaymentMode.online;
  Category _selectedCategory = Category.food;
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5146E5),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedType == TransactionType.transfer &&
        _transferFrom == _transferTo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose two different transfer accounts.'),
        ),
      );
      return;
    }

    final amount = double.parse(_amountController.text.trim());
    final title = _titleController.text.trim();
    final person = _personController.text.trim();
    final note = _noteController.text.trim();

    final isTransfer = _selectedType == TransactionType.transfer;

    final newTransaction = Expense(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      personName: person.isEmpty ? 'Self / General' : person,
      amount: amount,
      mode: isTransfer ? _transferFrom : _selectedMode,
      type: _selectedType,
      category: isTransfer ? Category.transfer : _selectedCategory,
      date: _selectedDate,
      note: isTransfer
          ? 'Transfer to ${_transferTo == PaymentMode.cash ? 'Cash' : 'UPI / Bank'}${note.isEmpty ? '' : ' · $note'}'
          : note,
    );

    Navigator.of(context).pop(newTransaction);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _personController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF7771D9)),
      filled: true,
      fillColor: const Color(0xFFF7F8FC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE9EAF2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF5146E5), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF273249),
        ),
      ),
    );
  }

  Widget _typeOption({
    required String title,
    required IconData icon,
    required TransactionType type,
    required Color color,
  }) {
    final selected = _selectedType == type;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => setState(() => _selectedType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.10) : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selected ? color : const Color(0xFFE7E9F0),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: selected ? color : Colors.blueGrey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentOption({
    required String title,
    required IconData icon,
    required PaymentMode mode,
    required bool selected,
    required ValueChanged<PaymentMode> onSelected,
  }) {
    final color = mode == PaymentMode.online
        ? const Color(0xFF477DE0)
        : const Color(0xFFB7791F);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onSelected(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.09) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? color : const Color(0xFFE7E9F0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected ? color : Colors.blueGrey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTransfer = _selectedType == TransactionType.transfer;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9DCE5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5146E5).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Color(0xFF5146E5),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New Transaction',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1D2939),
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Record where your money goes',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8791A3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _sectionLabel('Transaction type'),
                Row(
                  children: [
                    _typeOption(
                      title: 'Expense',
                      icon: Icons.arrow_upward_rounded,
                      type: TransactionType.expense,
                      color: const Color(0xFFE85D68),
                    ),
                    const SizedBox(width: 9),
                    _typeOption(
                      title: 'Income',
                      icon: Icons.arrow_downward_rounded,
                      type: TransactionType.income,
                      color: const Color(0xFF159B78),
                    ),
                    const SizedBox(width: 9),
                    _typeOption(
                      title: 'Transfer',
                      icon: Icons.swap_horiz_rounded,
                      type: TransactionType.transfer,
                      color: const Color(0xFF477DE0),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _sectionLabel('Amount'),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  decoration: _inputDecoration(
                    label: 'Amount in rupees',
                    icon: Icons.currency_rupee_rounded,
                    hint: '0.00',
                  ),
                  validator: (value) {
                    final amount = double.tryParse(value?.trim() ?? '');
                    if (amount == null || amount <= 0) {
                      return 'Enter an amount greater than zero';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                _sectionLabel(
                  isTransfer ? 'Transfer accounts' : 'Payment method',
                ),
                if (isTransfer) ...[
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<PaymentMode>(
                          initialValue: _transferFrom,
                          isExpanded: true,
                          decoration: _inputDecoration(
                            label: 'From',
                            icon: Icons.north_east_rounded,
                          ),
                          items: PaymentMode.values.map((mode) {
                            return DropdownMenuItem(
                              value: mode,
                              child: Text(
                                mode == PaymentMode.cash
                                    ? 'Cash'
                                    : 'UPI / Bank',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (mode) {
                            if (mode != null) {
                              setState(() => _transferFrom = mode);
                            }
                          },
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: Color(0xFF7771D9),
                        ),
                      ),
                      Expanded(
                        child: DropdownButtonFormField<PaymentMode>(
                          initialValue: _transferTo,
                          isExpanded: true,
                          decoration: _inputDecoration(
                            label: 'To',
                            icon: Icons.south_west_rounded,
                          ),
                          items: PaymentMode.values.map((mode) {
                            return DropdownMenuItem(
                              value: mode,
                              child: Text(
                                mode == PaymentMode.cash
                                    ? 'Cash'
                                    : 'UPI / Bank',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (mode) {
                            if (mode != null) {
                              setState(() => _transferTo = mode);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  if (_transferFrom == _transferTo)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        'Choose different accounts for the transfer.',
                        style: TextStyle(color: Colors.redAccent, fontSize: 12),
                      ),
                    ),
                ] else
                  Row(
                    children: [
                      _paymentOption(
                        title: 'UPI / Bank',
                        icon: Icons.account_balance_rounded,
                        mode: PaymentMode.online,
                        selected: _selectedMode == PaymentMode.online,
                        onSelected: (mode) {
                          setState(() => _selectedMode = mode);
                        },
                      ),
                      const SizedBox(width: 10),
                      _paymentOption(
                        title: 'Cash',
                        icon: Icons.payments_rounded,
                        mode: PaymentMode.cash,
                        selected: _selectedMode == PaymentMode.cash,
                        onSelected: (mode) {
                          setState(() => _selectedMode = mode);
                        },
                      ),
                    ],
                  ),
                const SizedBox(height: 18),

                _sectionLabel('Transaction details'),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _inputDecoration(
                    label: 'Title',
                    icon: Icons.edit_note_rounded,
                    hint: 'e.g. Dinner, Salary, Shopping',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a transaction title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _personController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDecoration(
                    label: isTransfer
                        ? 'Person (optional)'
                        : _selectedType == TransactionType.expense
                        ? 'Paid to (optional)'
                        : 'Received from (optional)',
                    icon: Icons.person_outline_rounded,
                  ),
                ),
                const SizedBox(height: 12),

                if (!isTransfer) ...[
                  DropdownButtonFormField<Category>(
                    initialValue: _selectedCategory,
                    isExpanded: true,
                    decoration: _inputDecoration(
                      label: 'Category',
                      icon: Icons.category_outlined,
                    ),
                    items: Category.values
                        .where((category) => category != Category.transfer)
                        .map((category) {
                          return DropdownMenuItem<Category>(
                            value: category,
                            child: Row(
                              children: [
                                Icon(
                                  category.icon,
                                  color: category.color,
                                  size: 19,
                                ),
                                const SizedBox(width: 10),
                                Text(category.label),
                              ],
                            ),
                          );
                        })
                        .toList(),
                    onChanged: (category) {
                      if (category != null) {
                        setState(() => _selectedCategory = category);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                ],

                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(16),
                  child: InputDecorator(
                    decoration: _inputDecoration(
                      label: 'Transaction date',
                      icon: Icons.calendar_month_rounded,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('dd MMM yyyy').format(_selectedDate),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF273249),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF7771D9),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _noteController,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _inputDecoration(
                    label: 'Notes (optional)',
                    icon: Icons.notes_rounded,
                    hint: 'Add a short note',
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text(
                      'Save Transaction',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5146E5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
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
