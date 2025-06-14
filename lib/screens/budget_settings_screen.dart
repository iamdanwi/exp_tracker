import 'package:flutter/material.dart';
import '../models/budget_model.dart';

class BudgetSettingsScreen extends StatefulWidget {
  const BudgetSettingsScreen({super.key});

  @override
  _BudgetSettingsScreenState createState() => _BudgetSettingsScreenState();
}

class _BudgetSettingsScreenState extends State<BudgetSettingsScreen>
    with TickerProviderStateMixin {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  final Map<String, bool> _isEditing = {};

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _headerController;
  late AnimationController _buttonController;
  late AnimationController _listController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _headerScaleAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _listOpacityAnimation;

  final List<Map<String, dynamic>> categories = [
    {'name': 'Food', 'icon': Icons.restaurant, 'color': Colors.orange},
    {
      'name': 'Transportation',
      'icon': Icons.directions_car,
      'color': Colors.blue,
    },
    {'name': 'Entertainment', 'icon': Icons.movie, 'color': Colors.purple},
    {'name': 'Shopping', 'icon': Icons.shopping_bag, 'color': Colors.pink},
    {'name': 'Bills', 'icon': Icons.receipt_long, 'color': Colors.red},
    {'name': 'Others', 'icon': Icons.more_horiz, 'color': Colors.grey},
  ];

  final TextEditingController _customCategoryController =
      TextEditingController();
  bool _showAddCategory = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeFocusNodes();
    _loadBudgets();
    _startAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _listController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _headerScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.elasticOut),
    );

    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );

    _listOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _listController, curve: Curves.easeInOut),
    );
  }

  void _initializeFocusNodes() {
    for (var category in categories) {
      String categoryName = category['name'] as String;
      _focusNodes[categoryName] = FocusNode();
      _isEditing[categoryName] = false;

      _focusNodes[categoryName]!.addListener(() {
        setState(() {
          _isEditing[categoryName] = _focusNodes[categoryName]!.hasFocus;
        });
      });
    }
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _headerController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _slideController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _listController.forward();
  }

  Future<void> _loadBudgets() async {
    final budgets = await CategoryBudget.getAllBudgets();
    setState(() {
      for (var category in categories) {
        String categoryName = category['name'] as String;
        _controllers[categoryName] = TextEditingController(
          text: (budgets[categoryName] ?? 0.0).toString(),
        );
      }
    });
  }

  void _onSavePressed() async {
    _buttonController.forward().then((_) {
      _buttonController.reverse();
    });

    // Save all category budgets
    for (var category in categories) {
      String categoryName = category['name'] as String;
      double amount =
          double.tryParse(_controllers[categoryName]?.text ?? '0') ?? 0.0;
      await CategoryBudget.saveBudget(categoryName, amount);
    }

    // Show success message and return to previous screen
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Budget settings saved successfully!'),
          backgroundColor: Colors.green[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      Navigator.pop(
        context,
        true,
      ); // Return true to indicate budget was updated
    }
  }

  // Widget _buildAddCategoryButton() {
  //   return AnimatedContainer(
  //     duration: const Duration(milliseconds: 300),
  //     child: _showAddCategory
  //         ? Container(
  //             margin: const EdgeInsets.only(bottom: 12),
  //             padding: const EdgeInsets.all(20),
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(16),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.black.withOpacity(0.05),
  //                   blurRadius: 10,
  //                   offset: const Offset(0, 2),
  //                 ),
  //               ],
  //             ),
  //             child: Column(
  //               children: [
  //                 TextField(
  //                   controller: _customCategoryController,
  //                   decoration: InputDecoration(
  //                     hintText: 'Enter new category name...',
  //                     border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(12),
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 16),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.end,
  //                   children: [
  //                     TextButton(
  //                       onPressed: () {
  //                         setState(() {
  //                           _showAddCategory = false;
  //                         });
  //                       },
  //                       child: const Text('Cancel'),
  //                     ),
  //                     const SizedBox(width: 8),
  //                     ElevatedButton(
  //                       onPressed: () {
  //                         final newCategory = _customCategoryController.text
  //                             .trim();
  //                         if (newCategory.isNotEmpty) {
  //                           setState(() {
  //                             categories.add({
  //                               'name': newCategory,
  //                               'icon': Icons.category,
  //                               'color': Colors.grey,
  //                             });
  //                             _controllers[newCategory] = TextEditingController(
  //                               text: '0',
  //                             );
  //                             _focusNodes[newCategory] = FocusNode();
  //                             _isEditing[newCategory] = false;
  //                             _showAddCategory = false;
  //                           });
  //                           _customCategoryController.clear();
  //                         }
  //                       },
  //                       child: const Text('Add'),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           )
  //         : TextButton.icon(
  //             onPressed: () {
  //               setState(() {
  //                 _showAddCategory = true;
  //               });
  //             },
  //             icon: const Icon(Icons.add),
  //             label: const Text('Add New Category'),
  //           ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: const Text('Budget Settings'),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () {
                setState(() {
                  _showAddCategory = true;
                });
              },
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Add New Category',
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Animated Header section
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _headerScaleAnimation,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24.0),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 800),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: Text(
                                    'Set Your Budget',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 1200),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: Text(
                                    'Set monthly budget limits for each category to better manage your expenses.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.grey[600]),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Animated Categories list
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _listOpacityAnimation,
                      child: ListView(
                        children: [
                          ...categories.map(
                            (category) => _buildAnimatedCategoryItem(
                              category,
                              categories.indexOf(category),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Animated Save button
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _buttonScaleAnimation,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        margin: const EdgeInsets.only(top: 16),
                        child: ElevatedButton(
                          onPressed: _onSavePressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF58CC02),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Save Budget Settings',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_showAddCategory)
            Container(
              color: Colors.black54,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Add New Category',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _customCategoryController,
                        decoration: InputDecoration(
                          hintText: 'Enter category name...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.category),
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _showAddCategory = false;
                                _customCategoryController.clear();
                              });
                            },
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              final newCategory = _customCategoryController.text
                                  .trim();
                              if (newCategory.isNotEmpty) {
                                setState(() {
                                  categories.add({
                                    'name': newCategory,
                                    'icon': Icons.category,
                                    'color': Colors.grey,
                                  });
                                  _controllers[newCategory] =
                                      TextEditingController(text: '0');
                                  _focusNodes[newCategory] = FocusNode();
                                  _isEditing[newCategory] = false;
                                  _showAddCategory = false;
                                  _customCategoryController.clear();
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF58CC02),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Add Category'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCategoryItem(Map<String, dynamic> category, int index) {
    String categoryName = category['name'] as String;
    bool isEditing = _isEditing[categoryName] ?? false;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800 + (index * 100)),
      curve: Curves.easeOutBack,
      builder: (context, animationValue, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue.clamp(0.0, 1.0),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: isEditing
                      ? Border.all(color: Colors.blue[300]!, width: 2)
                      : null,
                ),
                child: Row(
                  children: [
                    // Animated Category icon
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 1000 + (index * 150)),
                      builder: (context, iconValue, child) {
                        return Transform.scale(
                          scale: (0.5 + (iconValue * 0.5)).clamp(0.0, 1.0),
                          child: Transform.rotate(
                            angle: (1 - iconValue) * 0.5,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isEditing
                                    ? category['color'].withOpacity(0.2)
                                    : category['color'].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                category['icon'],
                                color: category['color'],
                                size: 24,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(width: 16),

                    // Category name with slide animation
                    Expanded(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 1200 + (index * 100)),
                        builder: (context, textValue, child) {
                          return Transform.translate(
                            offset: Offset(-30 * (1 - textValue), 0),
                            child: Opacity(
                              opacity: textValue.clamp(0.0, 1.0),
                              child: Text(
                                category['name'],
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Animated Amount input
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 1400 + (index * 80)),
                      builder: (context, inputValue, child) {
                        return Transform.scale(
                          scale: (0.8 + (inputValue * 0.2)).clamp(0.8, 1.0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 120,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isEditing
                                  ? Colors.blue[50]
                                  : Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isEditing
                                    ? Colors.blue[300]!
                                    : Colors.grey[200]!,
                                width: isEditing ? 2 : 1,
                              ),
                            ),
                            child: TextField(
                              controller: _controllers[category['name']],
                              focusNode: _focusNodes[category['name']],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: isEditing
                                    ? Colors.blue[700]
                                    : Colors.black87,
                              ),
                              decoration: const InputDecoration(
                                prefixText: '₹',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              onChanged: (value) {
                                final amount = double.tryParse(value) ?? 0.0;
                                CategoryBudget.saveBudget(
                                  category['name'],
                                  amount,
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _headerController.dispose();
    _buttonController.dispose();
    _listController.dispose();
    _customCategoryController.dispose();

    for (var controller in _controllers.values) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }
}
