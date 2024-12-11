class Account {
  String name;
  double balance;
  double initialBalance; // New property

  Account({
    required this.name,
    required this.balance,
    double? initialBalance, // Optional parameter
  }) : initialBalance = initialBalance ??
            balance; // Default to current balance if not provided

  factory Account.fromMap(Map map) {
    return Account(
      name: map['name'],
      balance: map['balance']?.toDouble() ?? 0.0,
      initialBalance: map['initialBalance']?.toDouble() ??
          map['balance']?.toDouble() ??
          0.0,
    );
  }

  Map toMap() {
    return {
      'name': name,
      'balance': balance,
      'initialBalance': initialBalance,
    };
  }
}
