
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'expense.dart';

class TransactionTile extends StatelessWidget {
  final Expense item;
  final VoidCallback onDelete;

  const TransactionTile({
    super.key,
    required this.item,
    required this.onDelete,
  });

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final bool isExpense = item.type == TransactionType.expense;
    final bool isIncome = item.type == TransactionType.income;

    final Color accentColor = isExpense
        ? const Color(0xFFE85D68)
        : isIncome
        ? const Color(0xFF159B78)
        : const Color(0xFF477DE0);

    final Color iconBackground = isExpense
        ? const Color(0xFFFFE9E8)
        : isIncome
        ? const Color(0xFFE0F7ED)
        : const Color(0xFFE6EEFF);

    final IconData transactionIcon = isExpense
        ? Icons.north_east_rounded
        : isIncome
        ? Icons.south_west_rounded
        : Icons.swap_horiz_rounded;

    final String prefix = isExpense
        ? '−'
        : isIncome
        ? '+'
        : '';

    final String typeLabel = isExpense
        ? 'EXPENSE'
        : isIncome
        ? 'INCOME'
        : 'TRANSFER';

    final Color badgeBackground = isExpense
        ? const Color(0xFFFFE9E8)
        : isIncome
        ? const Color(0xFFE0F7ED)
        : const Color(0xFFE6EEFF);

    final String paymentLabel = item.mode == PaymentMode.online
        ? 'UPI / Bank'
        : 'Cash';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEDF0F5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF182B49).withValues(alpha: 0.055),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 15, 8, 15),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(17),
              ),
              child: Icon(
                item.category.icon,
                color: accentColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF192536),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 11,
                        color: Colors.blueGrey.shade400,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          '${_dateFormat.format(item.date)} · $paymentLabel',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blueGrey.shade500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (item.personName.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.personName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blueGrey.shade500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBackground,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      typeLabel,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: accentColor,
                      ),
                    ),
                  ),
                  if (item.note.trim().isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      item.note,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blueGrey.shade400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 5),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      transactionIcon,
                      size: 13,
                      color: accentColor,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '$prefix${_currencyFormat.format(item.amount)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                IconButton(
                  tooltip: 'Delete transaction',
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(
                    minWidth: 34,
                    minHeight: 34,
                  ),
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.blueGrey.shade300,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
