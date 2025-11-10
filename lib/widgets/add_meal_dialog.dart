import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import '../theme/app_theme.dart';

class AddMealDialog extends StatefulWidget {
  final int userId;
  final DateTime date;
  final void Function(Meal) onSubmit;

  const AddMealDialog({
    super.key,
    required this.userId,
    required this.date,
    required this.onSubmit,
  });

  @override
  State<AddMealDialog> createState() => _AddMealDialogState();
}

class _AddMealDialogState extends State<AddMealDialog> {
  final _formKey = GlobalKey<FormState>();
  MealType _type = MealType.breakfast;
  final _nameCtrl = TextEditingController();
  final _calCtrl = TextEditingController(text: '0');
  final _proCtrl = TextEditingController(text: '0');
  final _carbCtrl = TextEditingController(text: '0');
  final _fatCtrl = TextEditingController(text: '0');

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
                    Text('Ajouter un repas', style: Theme.of(context).textTheme.titleLarge),
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
                  onChanged: (v) => setState(() => _type = v ?? MealType.breakfast),
                  decoration: const InputDecoration(labelText: 'Type de repas'),
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
                  child: const Text('Ajouter'),
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
      userId: widget.userId,
      day: DateTime(widget.date.year, widget.date.month, widget.date.day).toIso8601String().substring(0, 10),
      mealType: _type,
      name: _nameCtrl.text.trim(),
      calories: double.tryParse(_calCtrl.text) ?? 0,
      proteins: double.tryParse(_proCtrl.text) ?? 0,
      carbs: double.tryParse(_carbCtrl.text) ?? 0,
      fats: double.tryParse(_fatCtrl.text) ?? 0,
    );
    widget.onSubmit(m);
    Navigator.pop(context);
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
}


