import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/nutrition_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/meal_card.dart';
import '../widgets/add_meal_dialog.dart';
import '../models/meal_model.dart';
import '../theme/app_theme.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _currentDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>().currentUser!;
      context.read<NutritionProvider>().loadMealsForDay(auth.id!, _currentDay);
      context.read<NutritionProvider>().loadChartsAndAverages(
        auth.id!,
        _currentDay,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>().currentUser!;
    final np = context.watch<NutritionProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Plan du jour'),
            Tab(text: 'Statistiques'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Afficher les favoris',
            icon: Icon(
              np.showFavoritesOnly ? Icons.star : Icons.star_border,
              color: np.showFavoritesOnly ? Colors.yellowAccent : Colors.white,
            ),
            onPressed: () async {
              final userId = auth.id!;
              if (np.showFavoritesOnly) {
                await context.read<NutritionProvider>().loadMealsForDay(userId, _currentDay);
              } else {
                await context.read<NutritionProvider>().loadFavoriteMeals(userId);
              }
            },
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showAddDialog(auth.id!),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter'),
            )
          : null,
      body: TabBarView(
        controller: _tabController,
        children: [
          RefreshIndicator(
            onRefresh: () => np.loadMealsForDay(auth.id!, _currentDay),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _dayHeader(context),
                const SizedBox(height: 12),
                ...np.meals.map(
                  (m) => MealCard(
                    meal: m,
                    onDelete: () => _deleteMeal(m),
                    onEdit: () => _editMeal(m),
                    onFavoriteToggle: () => _toggleFavorite(m),
                  ),
                ),
                const SizedBox(height: 12),
                _totalsCard(context, np.meals),
              ],
            ),
          ),
          _statsTab(context, np),
        ],
      ),
    );
  }

  Widget _dayHeader(BuildContext context) {
    final smallButtonStyle = OutlinedButton.styleFrom(
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      minimumSize: const Size(0, 36),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        OutlinedButton.icon(
          style: smallButtonStyle,
          onPressed: () {
            setState(
              () => _currentDay = _currentDay.subtract(const Duration(days: 1)),
            );
            final auth = context.read<AuthProvider>().currentUser!;
            context.read<NutritionProvider>().loadMealsForDay(
              auth.id!,
              _currentDay,
            );
          },
          icon: const Icon(Icons.chevron_left, size: 18),
          label: const Text('Hier'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Builder(
            builder: (context) {
              final showFav = context.watch<NutritionProvider>().showFavoritesOnly;
              final dateStr = DateFormat('EEE dd/MM/yyyy', 'fr').format(_currentDay).toLowerCase();
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    showFav ? 'Repas favoris' : 'Repas d\'aujourd\'hui',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (!showFav) ...[
                    const SizedBox(height: 2),
                    Text(
                      dateStr,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          style: smallButtonStyle,
          onPressed: () {
            setState(() => _currentDay = DateTime.now());
            final auth = context.read<AuthProvider>().currentUser!;
            context.read<NutritionProvider>().loadMealsForDay(
              auth.id!,
              _currentDay,
            );
          },
          icon: const Icon(Icons.today, size: 18),
          label: const Text('Aujourd\'hui'),
        ),
      ],
    );
  }

  Widget _totalsCard(BuildContext context, List<Meal> meals) {
    double cal = 0, pro = 0, carb = 0, fat = 0;
    for (final m in meals) {
      cal += m.calories;
      pro += m.proteins;
      carb += m.carbs;
      fat += m.fats;
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            _metric(context, 'Total', '${cal.toStringAsFixed(0)} kcal'),
            _metric(context, 'Protéines', '${pro.toStringAsFixed(1)} g'),
            _metric(context, 'Glucides', '${carb.toStringAsFixed(1)} g'),
            _metric(context, 'Lipides', '${fat.toStringAsFixed(1)} g'),
          ],
        ),
      ),
    );
  }

  Widget _metric(BuildContext context, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _statsTab(BuildContext context, NutritionProvider np) {
    return RefreshIndicator(
      onRefresh: () async {
        final auth = context.read<AuthProvider>().currentUser!;
        await np.loadChartsAndAverages(auth.id!, DateTime.now());
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Moyennes hebdomadaires',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  _metric(
                    context,
                    'Calories',
                    '${np.weeklyAverages['avgCalories']?.toStringAsFixed(0) ?? '0'} kcal',
                  ),
                  _metric(
                    context,
                    'Protéines',
                    '${np.weeklyAverages['avgProteins']?.toStringAsFixed(1) ?? '0'} g',
                  ),
                  _metric(
                    context,
                    'Glucides',
                    '${np.weeklyAverages['avgCarbs']?.toStringAsFixed(1) ?? '0'} g',
                  ),
                  _metric(
                    context,
                    'Lipides',
                    '${np.weeklyAverages['avgFats']?.toStringAsFixed(1) ?? '0'} g',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Évolution des calories (7 derniers jours)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: true),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            color: AppTheme.warningColor,
                            spots: np.calories7d
                                .asMap()
                                .entries
                                .map(
                                  (e) => FlSpot(
                                    e.key.toDouble(),
                                    (e.value['totalCalories'] as num)
                                        .toDouble(),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Répartition des macronutriments (7 derniers jours)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 240,
                    child: BarChart(
                      BarChartData(
                        titlesData: const FlTitlesData(show: false),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: np.macros7d.asMap().entries.map((e) {
                          final m = e.value;
                          return BarChartGroupData(
                            x: e.key,
                            barsSpace: 4,
                            barRods: [
                              BarChartRodData(
                                toY: (m['totalCarbs'] as num).toDouble(),
                                color: Colors.blueAccent,
                                width: 6,
                              ),
                              BarChartRodData(
                                toY: (m['totalFats'] as num).toDouble(),
                                color: AppTheme.accentColor,
                                width: 6,
                              ),
                              BarChartRodData(
                                toY: (m['totalProteins'] as num).toDouble(),
                                color: Colors.green,
                                width: 6,
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(int userId) {
    showDialog(
      context: context,
      builder: (_) => AddMealDialog(
        userId: userId,
        date: _currentDay,
        onSubmit: (m) async {
          await context.read<NutritionProvider>().addMeal(userId, m);
        },
      ),
    );
  }

  Future<void> _deleteMeal(Meal meal) async {
    await context.read<NutritionProvider>().deleteMeal(
      meal.userId,
      meal.id!,
      DateTime.parse(meal.day),
    );
  }

  void _editMeal(Meal meal) {
    // Reuse the add dialog with existing meal data
    showDialog(
      context: context,
      builder: (_) => AddMealDialog(
        userId: meal.userId,
        date: DateTime.parse(meal.day),
        existingMeal: meal, // Pass the existing meal to pre-fill the form
        onSubmit: (updated) async {
          await context.read<NutritionProvider>().updateMeal(updated);
        },
      ),
    );
  }

  Future<void> _toggleFavorite(Meal meal) async {
    await context.read<NutritionProvider>().updateMeal(
      meal.copyWith(isFavorite: !meal.isFavorite),
    );
  }
}
