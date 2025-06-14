import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import 'package:intl/intl.dart';

class RecentTransactionsScreen extends StatefulWidget {
  const RecentTransactionsScreen({super.key});

  @override
  _RecentTransactionsScreenState createState() =>
      _RecentTransactionsScreenState();
}

class _RecentTransactionsScreenState extends State<RecentTransactionsScreen>
    with TickerProviderStateMixin {
  List<Expense> _expenses = [];
  List<Expense> _filteredExpenses = [];
  final TextEditingController _searchTextController = TextEditingController();
  String _selectedFilter = 'All';

  late AnimationController _listController;
  late AnimationController _searchAnimationController;
  late AnimationController _filterAnimationController;

  Animation<double>? _searchOpacityAnimation;
  Animation<Offset>? _searchSlideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadExpenses();
  }

  void _initializeAnimations() {
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _searchAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _filterAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _searchOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_searchAnimationController);

    _searchSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _searchAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Start animations
    _searchAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _filterAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _listController.forward();
    });
  }

  Future<void> _loadExpenses() async {
    final expenses = await Expense.getAllExpenses();
    setState(() {
      _expenses = expenses;
      _filteredExpenses = expenses;
    });
    _listController.forward();
  }

  void _filterExpenses(String query) {
    setState(() {
      _filteredExpenses = _expenses.where((expense) {
        final matchesQuery =
            expense.name.toLowerCase().contains(query.toLowerCase()) ||
            expense.category.toLowerCase().contains(query.toLowerCase());
        final matchesFilter =
            _selectedFilter == 'All' ||
            expense.category.toLowerCase() == _selectedFilter.toLowerCase();
        return matchesQuery && matchesFilter;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Recent Transactions'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Animated Search Bar
                SlideTransition(
                  position: _searchSlideAnimation!,
                  child: FadeTransition(
                    opacity: _searchOpacityAnimation!,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchTextController,
                        onChanged: _filterExpenses,
                        decoration: InputDecoration(
                          hintText: 'Search transactions...',
                          icon: const Icon(Icons.search),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchTextController.clear();
                              _filterExpenses('');
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Animated Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        [
                          'All',
                          'Food',
                          'Transport',
                          'Shopping',
                          'Bills',
                          'Entertainment',
                          'Others',
                        ].asMap().entries.map((entry) {
                          final index = entry.key;
                          final filter = entry.value;
                          return AnimatedBuilder(
                            animation: _filterAnimationController,
                            builder: (context, child) {
                              final delay = index * 0.1;
                              final value = _filterAnimationController.value;
                              final animationProgress = value > delay
                                  ? ((value - delay) / 0.1).clamp(0.0, 1.0)
                                  : 0.0;

                              return Transform.scale(
                                scale: 0.5 + (0.5 * animationProgress),
                                child: Opacity(
                                  opacity: animationProgress,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      label: Text(filter),
                                      selected: _selectedFilter == filter,
                                      onSelected: (selected) {
                                        setState(() {
                                          _selectedFilter = filter;
                                          _filterExpenses(
                                            _searchTextController.text,
                                          );
                                        });
                                      },
                                      backgroundColor: Colors.white,
                                      selectedColor: Colors.blue[100],
                                      checkmarkColor: Color(
                                        0xFF58CC02,
                                      ).withOpacity(0.2),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredExpenses.isEmpty
                ? Center(
                    child: Text(
                      'No transactions found',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = _filteredExpenses[index];
                      return AnimatedBuilder(
                        animation: _listController,
                        builder: (context, child) {
                          // Update animation intervals to prevent range error
                          final start = (index / _filteredExpenses.length)
                              .clamp(0.0, 0.9);
                          final end = ((index + 1) / _filteredExpenses.length)
                              .clamp(0.1, 1.0);

                          return SlideTransition(
                            position:
                                Tween<Offset>(
                                  begin: const Offset(1, 0),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: _listController,
                                    curve: Interval(
                                      start,
                                      end,
                                      curve: Curves.easeOut,
                                    ),
                                  ),
                                ),
                            child: FadeTransition(
                              opacity: _listController,
                              child: child,
                            ),
                          );
                        },
                        child: _buildTransactionItem(expense),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Expense expense) {
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
      onDismissed: (direction) async {
        try {
          final index = _expenses.indexOf(expense);
          setState(() {
            _expenses.removeAt(index);
            _filteredExpenses = List.from(_expenses);
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
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: InkWell(
          onTap: () {
            // Handle transaction tap
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                          Text('•', style: TextStyle(color: Colors.grey[400])),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('MMM d, y').format(expense.date),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
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
        ),
      ),
    );
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

  @override
  void dispose() {
    _listController.dispose();
    _searchTextController.dispose();
    _searchAnimationController.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }
}
