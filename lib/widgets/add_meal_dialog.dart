import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import '../theme/app_theme.dart';
import '../services/nutritionix_service.dart';
import '../config/nutritionix_config.dart';

class AddMealDialog extends StatefulWidget {
  final int userId;
  final DateTime date;
  final void Function(Meal) onSubmit;
  final Meal? existingMeal; // Optional: for editing existing meals

  const AddMealDialog({
    super.key,
    required this.userId,
    required this.date,
    required this.onSubmit,
    this.existingMeal,
  });

  @override
  State<AddMealDialog> createState() => _AddMealDialogState();
}

class _AddMealDialogState extends State<AddMealDialog> {
  final _formKey = GlobalKey<FormState>();
  late MealType _type;
  final _nameCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _proCtrl = TextEditingController();
  final _carbCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  
  // Nutritionix search
  final _searchCtrl = TextEditingController();
  bool _isSearching = false;
  List<FoodItem> _searchResults = [];
  String? _searchError;

  @override
  void initState() {
    super.initState();
    // Pre-fill fields if editing an existing meal
    if (widget.existingMeal != null) {
      final meal = widget.existingMeal!;
      _type = meal.mealType;
      _nameCtrl.text = meal.name;
      _calCtrl.text = meal.calories.toStringAsFixed(0);
      _proCtrl.text = meal.proteins.toStringAsFixed(1);
      _carbCtrl.text = meal.carbs.toStringAsFixed(1);
      _fatCtrl.text = meal.fats.toStringAsFixed(1);
    } else {
      _type = MealType.breakfast;
      _calCtrl.text = '0';
      _proCtrl.text = '0';
      _carbCtrl.text = '0';
      _fatCtrl.text = '0';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.existingMeal != null ? 'Modifier le repas' : 'Ajouter un repas',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Remplissez les informations nutritionnelles de votre repas.',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 12),
                DropdownButtonFormField<MealType>(
                  value: _type,
                  items: MealType.values
                      .map((e) => DropdownMenuItem(value: e, child: Text(_label(e))))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _type = v);
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Type de repas'),
                ),
                const SizedBox(height: 12),
                // Search food section
                Card(
                  color: AppTheme.primaryLight.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.search, size: 20, color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Rechercher un aliment',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (!NutritionixConfig.isConfigured)
                              Tooltip(
                                message: 'API non configurée. Configurez vos clés API dans lib/config/nutritionix_config.dart',
                                child: const Icon(Icons.info_outline, size: 16, color: AppTheme.warningColor),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                decoration: InputDecoration(
                                  hintText: 'Ex: pomme, poulet, riz...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                onSubmitted: (_) => _searchFoods(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: _isSearching ? null : _searchFoods,
                              icon: _isSearching
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.search, size: 20),
                              label: const Text('Rechercher'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        if (_searchError != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _searchError!,
                            style: const TextStyle(color: AppTheme.errorColor, fontSize: 12),
                          ),
                        ],
                        if (_searchResults.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final item = _searchResults[index];
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    item.name,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  subtitle: item.brand != null
                                      ? Text('${item.brand}', style: const TextStyle(fontSize: 12))
                                      : null,
                                  trailing: item.calories != null
                                      ? Text(
                                          '${item.calories!.toStringAsFixed(0)} kcal',
                                          style: const TextStyle(fontSize: 12, color: AppTheme.primaryColor),
                                        )
                                      : const Icon(Icons.arrow_forward_ios, size: 16),
                                  onTap: () => _selectFood(item),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nom du repas', hintText: 'Ex: Poulet grillé avec riz'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _calCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Calories (kcal)'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: _proCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Protéines (g)'))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _carbCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Glucides (g)'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: _fatCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Lipides (g)'))),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(widget.existingMeal != null ? 'Modifier' : 'Ajouter'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(foregroundColor: AppTheme.textPrimary),
                  child: const Text('Annuler'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final m = Meal(
      id: widget.existingMeal?.id, // Preserve ID when editing
      userId: widget.userId,
      day: DateTime(widget.date.year, widget.date.month, widget.date.day).toIso8601String().substring(0, 10),
      mealType: _type,
      name: _nameCtrl.text.trim(),
      calories: double.tryParse(_calCtrl.text) ?? 0,
      proteins: double.tryParse(_proCtrl.text) ?? 0,
      carbs: double.tryParse(_carbCtrl.text) ?? 0,
      fats: double.tryParse(_fatCtrl.text) ?? 0,
      isFavorite: widget.existingMeal?.isFavorite ?? false, // Preserve favorite status
      isTemplate: widget.existingMeal?.isTemplate ?? false, // Preserve template status
      note: widget.existingMeal?.note, // Preserve note
    );
    widget.onSubmit(m);
    Navigator.pop(context);
  }

  Future<void> _searchFoods() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) return;

    if (!NutritionixConfig.isConfigured) {
      setState(() {
        _searchError = 'API Nutritionix non configurée. Veuillez configurer vos clés API dans lib/config/nutritionix_config.dart';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
      _searchResults = [];
    });

    try {
      final results = await NutritionixService.searchFoods(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
        if (results.isEmpty) {
          _searchError = 'Aucun résultat trouvé';
        }
      });
    } catch (e) {
      setState(() {
        _searchError = 'Erreur de recherche: ${e.toString()}';
        _isSearching = false;
      });
    }
  }

  Future<void> _selectFood(FoodItem item) async {
    setState(() {
      _nameCtrl.text = item.name;
      _searchResults = [];
      _searchCtrl.clear();
    });

    // If we already have nutrition data, use it
    if (item.calories != null && item.proteins != null && item.carbs != null && item.fats != null) {
      setState(() {
        _calCtrl.text = item.calories!.toStringAsFixed(0);
        _proCtrl.text = item.proteins!.toStringAsFixed(1);
        _carbCtrl.text = item.carbs!.toStringAsFixed(1);
        _fatCtrl.text = item.fats!.toStringAsFixed(1);
      });
    } else {
      // Otherwise, fetch detailed nutrition info
      try {
        setState(() => _isSearching = true);
        FoodNutrition nutrition;
        
        if (item.isCommon) {
          nutrition = await NutritionixService.getFoodNutritionByName(item.name);
        } else {
          nutrition = await NutritionixService.getFoodNutrition(item.id, isCommon: false);
        }

        setState(() {
          _calCtrl.text = nutrition.calories.toStringAsFixed(0);
          _proCtrl.text = nutrition.proteins.toStringAsFixed(1);
          _carbCtrl.text = nutrition.carbs.toStringAsFixed(1);
          _fatCtrl.text = nutrition.fats.toStringAsFixed(1);
          _isSearching = false;
        });
      } catch (e) {
        setState(() {
          _searchError = 'Impossible de charger les informations nutritionnelles';
          _isSearching = false;
        });
      }
    }
  }

  String _label(MealType t) {
    switch (t) {
      case MealType.breakfast:
        return 'Petit-déjeuner';
      case MealType.lunch:
        return 'Déjeuner';
      case MealType.snack:
        return 'Collation';
      case MealType.dinner:
        return 'Dîner';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _calCtrl.dispose();
    _proCtrl.dispose();
    _carbCtrl.dispose();
    _fatCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }
}


