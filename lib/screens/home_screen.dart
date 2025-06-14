import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../models/budget_model.dart';
import 'add_expenses.dart';
import 'budget_settings_screen.dart';
import 'package:intl/intl.dart';
import 'recent_transactions_screen.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Expense> expenses = [];
  double _monthlyBudget = 0.0; // New variable for dynamic budget
  // Remove static budget constant
  static const double WARNING_THRESHOLD = 0.8;
  static const double DANGER_THRESHOLD = 0.9;
  static const double CRITICAL_THRESHOLD = 0.95;
  static const double BUDGET_SPENT_80 = 0.8;
  static const double BUDGET_SPENT_90 = 0.9;
  static const double BUDGET_SPENT_95 = 0.95;
  static const double BUDGET_SPENT_100 = 1.0;

  AnimationController? _headerController;
  AnimationController? _cardsController;
  AnimationController? _listController;
  AnimationController? _fabController;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cardsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExpenses();
      _loadBudget();
      _startAnimations();
    });
  }

  void _startAnimations() {
    _headerController!.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _cardsController!.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _listController!.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _fabController!.forward();
    });
  }

  Future<void> _loadExpenses() async {
    final loadedExpenses = await Expense.getAllExpenses();
    if (mounted) {
      setState(() {
        expenses = loadedExpenses;
      });
      _checkBudgetAndNotify();
    }
  }

  Future<void> _loadBudget() async {
    final totalBudget = await CategoryBudget.getTotalBudget();
    if (mounted) {
      setState(() {
        _monthlyBudget = totalBudget;
      });
      // Also check budget notifications after updating
      _checkBudgetAndNotify();
    }
  }

  double _calculateTotalExpenses(List<Expense> expenses) {
    return expenses.fold(0, (sum, expense) {
      final price =
          double.tryParse(expense.price.replaceAll('-₹', '').trim()) ?? 0;
      return sum + price;
    });
  }

  double _getTodayExpenses() {
    return _calculateTotalExpenses(expenses.where((expense) => true).toList());
  }

  double _getWeekExpenses() {
    return _calculateTotalExpenses(expenses);
  }

  double _getMonthExpenses() {
    return _calculateTotalExpenses(expenses);
  }

  double _getBudgetPercentage() {
    if (_monthlyBudget == 0) return 0.0;
    return (_getMonthExpenses() / _monthlyBudget).clamp(0.0, 1.0);
  }

  Color _getBudgetColor() {
    final percentage = _getBudgetPercentage();
    if (percentage >= CRITICAL_THRESHOLD) return Colors.red;
    if (percentage >= DANGER_THRESHOLD) return Colors.orange;
    if (percentage >= WARNING_THRESHOLD) return Colors.amber;
    return Colors.green;
  }

  Future<void> _deleteExpense(int index) async {
    try {
      setState(() {
        expenses.removeAt(index);
      });
      await Expense.deleteExpense(index);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Expense deleted successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      _loadExpenses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('Failed to delete expense'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _checkBudgetAndNotify() {
    if (_monthlyBudget == 0) return;

    double percentageUsed = _getMonthExpenses() / _monthlyBudget;

    if (percentageUsed >= BUDGET_SPENT_100) {
      NotificationService().showBudgetAlert(
        id: 4,
        title: 'Budget Alert!',
        body:
            'You have exceeded your monthly budget! Time to review your expenses.',
      );
    } else if (percentageUsed >= BUDGET_SPENT_95) {
      NotificationService().showBudgetAlert(
        id: 3,
        title: 'Critical Budget Warning',
        body: 'You\'ve used 95% of your budget. Consider limiting expenses.',
      );
    } else if (percentageUsed >= BUDGET_SPENT_90) {
      NotificationService().showBudgetAlert(
        id: 2,
        title: 'Budget Warning',
        body: 'You\'ve reached 90% of your monthly budget. Time to be careful!',
      );
    } else if (percentageUsed >= BUDGET_SPENT_80) {
      NotificationService().showBudgetAlert(
        id: 1,
        title: 'Budget Reminder',
        body:
            'You\'ve used 80% of your monthly budget. Keep an eye on spending!',
      );
    }

    // Show in-app alert regardless of notification schedule
    if (percentageUsed >= BUDGET_SPENT_80) {
      _showBudgetAlert(
        'You\'ve used ${(percentageUsed * 100).toStringAsFixed(0)}% of your budget',
        _getBudgetColor(),
      );
    }
  }

  void _showBudgetAlert(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          textColor: Colors.white,
        ),
      ),
    );
  }

  void _showNotificationHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.notifications, color: Colors.green[600]),
            const SizedBox(width: 8),
            const Text('Budget Alerts'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_monthlyBudget > 0) ...[
              _buildAlertItem(
                'Current Budget Usage',
                '${(_getBudgetPercentage() * 100).toStringAsFixed(0)}% of budget used',
                _getBudgetColor(),
              ),
              const Divider(),
              _buildAlertItem(
                'Monthly Spending',
                '₹${_getMonthExpenses().toStringAsFixed(0)} / ₹${_monthlyBudget.toStringAsFixed(0)}',
                Colors.blue[700]!,
              ),
            ] else
              _buildAlertItem(
                'No Budget Set',
                'Set a budget in settings to get alerts',
                Colors.grey,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.settings, size: 18),
            label: const Text('Budget Settings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF58CC02),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BudgetSettingsScreen(),
                ),
              ).then((value) {
                if (value == true) _loadBudget();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(String title, String message, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.circle, color: color, size: 8),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _headerController!.dispose();
    _cardsController!.dispose();
    _listController!.dispose();
    _fabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildBudgetCard(),
                    const SizedBox(height: 24),
                    _buildExpenseCards(),
                    const SizedBox(height: 32),
                    _buildTransactionsHeader(),
                    const SizedBox(height: 16),
                    _buildTransactionsList(),
                    const SizedBox(height: 100), // Space for FAB
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _headerController!,
              curve: Curves.easeOutBack,
            ),
          ),
      child: Container(
        padding: const EdgeInsets.only(top: 10, bottom: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF58CC02), Color(0xFF4CAF50)],
            stops: [0.0, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF58CC02).withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back!',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Expense Tracker',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.notifications_outlined),
                            color: Colors.white,
                            onPressed: _showNotificationHistory,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.settings_outlined),
                            color: Colors.white,
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const BudgetSettingsScreen(),
                                ),
                              );
                              if (result == true) {
                                _loadBudget();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('EEEE, MMMM d').format(DateTime.now()),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('yyyy').format(DateTime.now()),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetCard() {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _cardsController!, curve: Curves.elasticOut),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getBudgetColor().withOpacity(0.1),
              _getBudgetColor().withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _getBudgetColor().withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monthly Budget',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                Icon(
                  Icons.account_balance_wallet,
                  color: _getBudgetColor(),
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  '₹${_getMonthExpenses().toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  ' / ₹${_monthlyBudget.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _getBudgetPercentage(),
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(_getBudgetColor()),
              minHeight: 6,
            ),
            const SizedBox(height: 8),
            Text(
              '${(_getBudgetPercentage() * 100).toStringAsFixed(1)}% used',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseCards() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _cardsController!,
              curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
            ),
          ),
      child: Row(
        children: [
          Expanded(
            child: _buildExpenseCard(
              'Today',
              _getTodayExpenses(),
              Icons.today,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildExpenseCard(
              'This Week',
              _getWeekExpenses(),
              Icons.date_range,
              Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '₹${amount.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsHeader() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
          .animate(
            CurvedAnimation(parent: _listController!, curve: Curves.easeOut),
          ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecentTransactionsScreen(),
                ),
              );
            },
            child: const Text('View All'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    if (expenses.isEmpty) {
      return FadeTransition(
        opacity: _listController!,
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No transactions yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Add your first expense to get started',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AnimatedList(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      initialItemCount: expenses.length,
      itemBuilder: (context, index, animation) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
                ),
              ),
          child: FadeTransition(
            opacity: animation,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTransactionItem(expenses[index], index),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionItem(Expense expense, int index) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 24),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text('Delete Expense'),
                content: const Text(
                  'Are you sure you want to delete this expense?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (direction) => _deleteExpense(index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getCategoryColor(expense.category).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(expense.category),
                color: _getCategoryColor(expense.category),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        expense.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getCategoryColor(expense.category),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('•', style: TextStyle(color: Colors.grey.shade400)),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMM d').format(expense.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              expense.price,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'bills':
        return Icons.receipt;
      case 'entertainment':
        return Icons.movie;
      default:
        return Icons.currency_rupee;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'transport':
        return Colors.blue;
      case 'shopping':
        return Colors.purple;
      case 'bills':
        return Colors.red;
      case 'entertainment':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _fabController!, curve: Curves.elasticOut),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade400, Colors.green.shade600],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const AddExpensses()),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Add Expense',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
