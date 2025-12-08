import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker_ocr/core/constants/colors.dart';
import 'package:flutter_expense_tracker_ocr/core/constants/text_strings.dart';
import 'package:intl/intl.dart';

class TransactionDetailPage extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailPage({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final amount = transaction['amount'];
    final date = transaction['date'];
    final type = transaction['type'];
    final note = transaction['note'] ?? "Sin nota";
    final imageUrl = transaction['imageUrl'];

    DateTime parsedDate;

    if (date is String) {
      parsedDate = DateTime.parse(date);
    } else if (date is Timestamp) {
      parsedDate = date.toDate();
    } else {
      parsedDate = DateTime.now();
    }
    final formattedDate = DateFormat('dd/MM/yy - HH:mm').format(parsedDate);

    final bool isIncome = type == "income";
    final Color typeColor = isIncome ? Colors.green : Colors.red;
    final IconData typeIcon = isIncome
        ? Icons.arrow_upward
        : Icons.arrow_downward;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(tAppName),
        centerTitle: true,
        elevation: 0,
        backgroundColor: tSecondaryColor,
        foregroundColor: tPrimaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [tPrimaryColor, tSecondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.monetization_on, color: tWhiteColor, size: 32),
                      const SizedBox(width: 10),
                      Text(
                        "L. $amount",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: typeColor.withOpacity(0.2),
                    child: Icon(typeIcon, color: typeColor, size: 28),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: isDarkMode ? tSecondaryColor : tWhiteColor,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildDetailRow(
                      Icons.calendar_today,
                      "Fecha",
                      formattedDate,
                      context,
                    ),
                    const Divider(),
                    _buildDetailRow(
                      Icons.category,
                      "Tipo",
                      isIncome ? "Ingreso" : "Gasto",
                      context,
                    ),
                    const Divider(),
                    _buildDetailRow(Icons.note, "Nota", note, context),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 220,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text("No se pudo cargar la imagen");
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    BuildContext context,
  ) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: isDarkMode ? tPrimaryColor : tSecondaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? tPrimaryColor : tSecondaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? tWhiteColor : tSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
