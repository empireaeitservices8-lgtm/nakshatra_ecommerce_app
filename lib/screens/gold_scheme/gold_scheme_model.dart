class GoldScheme {
  final int schemeId;
  final String name;
  final double monthlyInstallment;
  final int totalMonths;
  final int monthsPaid;
  final double totalSaved;
  final String maturityDate;
  final String status;
  final List<SchemePaymentRecord> paymentHistory;

  GoldScheme({
    required this.schemeId,
    required this.name,
    required this.monthlyInstallment,
    required this.totalMonths,
    required this.monthsPaid,
    required this.totalSaved,
    required this.maturityDate,
    required this.status,
    required this.paymentHistory,
  });

  factory GoldScheme.fromJson(Map<String, dynamic> json) {
    final historyList = json['payment_history'] as List? ?? json['history'] as List? ?? [];
    return GoldScheme(
      schemeId: json['scheme_id'] ?? json['id'] ?? 0,
      name: json['name'] ?? json['scheme_name'] ?? 'Gold Savings Scheme',
      monthlyInstallment: (json['monthly_installment'] ?? json['installment_amount'] ?? 1000.0).toDouble(),
      totalMonths: json['total_months'] ?? 11,
      monthsPaid: json['months_paid'] ?? 0,
      totalSaved: (json['total_saved'] ?? 0.0).toDouble(),
      maturityDate: json['maturity_date'] ?? json['maturityDate'] ?? '',
      status: json['status'] ?? 'Active',
      paymentHistory: historyList.map((item) => SchemePaymentRecord.fromJson(item)).toList(),
    );
  }
}

class SchemePaymentRecord {
  final String date;
  final double amount;
  final String status;
  final String transactionId;

  SchemePaymentRecord({
    required this.date,
    required this.amount,
    required this.status,
    required this.transactionId,
  });

  factory SchemePaymentRecord.fromJson(Map<String, dynamic> json) {
    return SchemePaymentRecord(
      date: json['date'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'Success',
      transactionId: json['transaction_id'] ?? json['id'] ?? '',
    );
  }
}
