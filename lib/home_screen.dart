
import 'package:flutter/material.dart';

import 'expense.dart';
import 'balance_card.dart';
import 'transaction_tile.dart';
import 'add_transaction_sheet.dart';
import 'expense_repository.dart';

class ExpenseHomeScreen extends StatefulWidget {
  const ExpenseHomeScreen({super.key});

  @override
  State<ExpenseHomeScreen> createState() => _ExpenseHomeScreenState();
}

class _ExpenseHomeScreenState extends State<ExpenseHomeScreen> {
  final ExpenseRepository _repository = ExpenseRepository();

  final List<Expense> _transactions = [];

  Category? _selectedFilter;

  bool _isLoading = true;
  String? _loadError;

  double get _currentOnlineBalance {
    return _transactions.fold<double>(
      0,
          (balance, item) {
        if (item.mode != PaymentMode.online) return balance;

        if (item.type == TransactionType.income) {
          return balance + item.amount;
        }

        if (item.type == TransactionType.expense) {
          return balance - item.amount;
        }

        return balance;
      },
    );
  }

  double get _currentCashBalance {
    return _transactions.fold<double>(
      0,
          (balance, item) {
        if (item.mode != PaymentMode.cash) return balance;

        if (item.type == TransactionType.income) {
          return balance + item.amount;
        }

        if (item.type == TransactionType.expense) {
          return balance - item.amount;
        }

        return balance;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final transactions = await _repository.getAllExpenses();

      if (!mounted) return;

      setState(() {
        _transactions
          ..clear()
          ..addAll(transactions);

        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Load transactions error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _loadError = 'Transactions load nahi ho sake.';
      });
    }
  }

  Future<void> _openAddSheet() async {
    final Expense? newTransaction =
    await showModalBottomSheet<Expense>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) => const AddTransactionSheet(),
    );

    if (!mounted || newTransaction == null) return;

    try {
      await _repository.addExpense(newTransaction);

      if (!mounted) return;

      setState(() {
        _transactions.insert(0, newTransaction);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction saved successfully'),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Save transaction error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction save nahi hua. Please try again.'),
        ),
      );
    }
  }

  Future<void> _deleteTransaction(Expense item) async {
    try {
      await _repository.deleteExpense(item.id);

      if (!mounted) return;

      setState(() {
        _transactions.removeWhere((tx) => tx.id == item.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction deleted'),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Delete transaction error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction delete nahi hua.'),
        ),
      );
    }
  }

  Future<void> _confirmDelete(Expense item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete transaction?'),
          content: Text(
            'Are you sure you want to delete "${item.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await _deleteTransaction(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _selectedFilter == null
        ? _transactions
        : _transactions
        .where((tx) => tx.category == _selectedFilter)
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'My Smart Wallet',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh transactions',
            onPressed: _loadTransactions,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BalanceCard(
            onlineBalance: _currentOnlineBalance,
            cashBalance: _currentCashBalance,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedFilter == null,
                  onSelected: (_) {
                    setState(() => _selectedFilter = null);
                  },
                ),
                const SizedBox(width: 8),
                ...Category.values.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      avatar: Icon(
                        cat.icon,
                        size: 16,
                        color: cat.color,
                      ),
                      label: Text(cat.label),
                      selected: _selectedFilter == cat,
                      onSelected: (_) {
                        setState(() => _selectedFilter = cat);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : _loadError != null
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 12),
                    Text(_loadError!),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _loadTransactions,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            )
                : filteredList.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _selectedFilter == null
                          ? 'No transactions yet!'
                          : 'No transactions in this category',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Add a transaction to start tracking your money.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
                : ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final item = filteredList[index];

                return TransactionTile(
                  key: ValueKey(item.id),
                  item: item,
                  onDelete: () => _confirmDelete(item),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _openAddSheet,
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Entry'),
      ),
    );
  }
}
