
import 'package:flutter/material.dart';

enum PaymentMode {
  online,
  cash,
}

enum TransactionType {
  expense,
  income,
  transfer,
}

enum Category {
  food('Food', Icons.restaurant, Colors.orange),
  travel('Travel', Icons.directions_car, Colors.blue),
  shopping('Shopping', Icons.shopping_bag, Colors.purple),
  transfer('Transfer', Icons.swap_horiz, Colors.teal),
  bills('Bills', Icons.receipt_long, Colors.redAccent),
  other('Other', Icons.category, Colors.blueGrey);

  final String label;
  final IconData icon;
  final Color color;

  const Category(this.label, this.icon, this.color);
}

class Expense {
  final String id;
  final String title;
  final String personName;
  final double amount;
  final PaymentMode mode;
  final TransactionType type;
  final Category category;
  final DateTime date;
  final String note;

  const Expense({
    required this.id,
    required this.title,
    required this.personName,
    required this.amount,
    required this.mode,
    required this.type,
    required this.category,
    required this.date,
    this.note = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'personName': personName,
      'amount': amount,
      'mode': mode.name,
      'type': type.name,
      'category': category.name,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      title: map['title'] as String,
      personName: map['personName'] as String,
      amount: (map['amount'] as num).toDouble(),
      mode: PaymentMode.values.byName(map['mode'] as String),
      type: TransactionType.values.byName(map['type'] as String),
      category: Category.values.byName(map['category'] as String),
      date: DateTime.parse(map['date'] as String),
      note: (map['note'] as String?) ?? '',
    );
  }
}
