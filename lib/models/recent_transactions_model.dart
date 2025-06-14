class RecentTransactionModel {
  String name;
  String category;
  String price;

  RecentTransactionModel({
    required this.name,
    required this.category,
    required this.price,
  });

  static List<RecentTransactionModel> getRecentTransactions() {
    List<RecentTransactionModel> recentTransactions = [];

    recentTransactions.add(
      RecentTransactionModel(
        name: "Supermarket",
        category: "Grocery",
        price: "-\$50",
      ),
    );
    recentTransactions.add(
      RecentTransactionModel(
        name: "Bus Fare",
        category: "Transportation",
        price: "-\$5",
      ),
    );
    recentTransactions.add(
      RecentTransactionModel(
        name: "Restaurant",
        category: "Dining",
        price: "-\$20",
      ),
    );
    recentTransactions.add(
      RecentTransactionModel(
        name: "Restaurant",
        category: "Dining",
        price: "-\$20",
      ),
    );
    recentTransactions.add(
      RecentTransactionModel(
        name: "Restaurant",
        category: "Dining",
        price: "-\$20",
      ),
    );
    recentTransactions.add(
      RecentTransactionModel(
        name: "Restaurant",
        category: "Dining",
        price: "-\$20",
      ),
    );
    recentTransactions.add(
      RecentTransactionModel(
        name: "Restaurant",
        category: "Dining",
        price: "-\$20",
      ),
    );
    recentTransactions.add(
      RecentTransactionModel(
        name: "Restaurant",
        category: "Dining",
        price: "-\$20",
      ),
    );
    recentTransactions.add(
      RecentTransactionModel(
        name: "Restaurant",
        category: "Dining",
        price: "-\$20",
      ),
    );
    recentTransactions.add(
      RecentTransactionModel(
        name: "Restaurant",
        category: "Dining",
        price: "-\$20",
      ),
    );

    return recentTransactions;
  }
}
