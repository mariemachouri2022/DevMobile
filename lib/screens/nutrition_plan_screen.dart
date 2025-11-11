import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/nutrition_plan_model.dart';
import '../models/user_model.dart';
import '../models/meal_model.dart';
import '../providers/nutrition_plan_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';

class NutritionPlanScreen extends StatefulWidget {
  const NutritionPlanScreen({super.key});

  @override
  State<NutritionPlanScreen> createState() => _NutritionPlanScreenState();
}

class _NutritionPlanScreenState extends State<NutritionPlanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>().currentUser!;
    final userProvider = context.read<UserProvider>();
    
    if (auth.role == UserRole.coach) {
      await context.read<NutritionPlanProvider>().loadPlansByCoach(auth.id!);
      await userProvider.loadClientsByCoach(auth.id!);
    } else if (auth.role == UserRole.client) {
      await context.read<NutritionPlanProvider>().loadPlansByClient(auth.id!);
      // Load all users to get coach information
      await userProvider.loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>().currentUser!;
    final planProvider = context.watch<NutritionPlanProvider>();
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plans Nutritionnels'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (auth.role == UserRole.coach)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Créer un plan',
              onPressed: () => _showCreatePlanDialog(context, auth.id!, userProvider),
            ),
        ],
      ),
      body: planProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: planProvider.plans.isEmpty
                  ? _buildEmptyState(context, auth.role)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: planProvider.plans.length,
                      itemBuilder: (context, index) {
                        final plan = planProvider.plans[index];
                        return _buildPlanCard(context, plan, userProvider, auth.role);
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, UserRole role) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun plan nutritionnel',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            role == UserRole.coach
                ? 'Créez votre premier plan pour vos clients'
                : 'Aucun plan assigné par votre coach',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          if (role == UserRole.coach) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                final auth = context.read<AuthProvider>().currentUser!;
                final userProvider = context.read<UserProvider>();
                _showCreatePlanDialog(context, auth.id!, userProvider);
              },
              icon: const Icon(Icons.add),
              label: const Text('Créer un plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlanCard(
      BuildContext context, NutritionPlan plan, UserProvider userProvider, UserRole userRole) {
    final client = plan.clientId != null
        ? userProvider.users.firstWhere(
            (u) => u.id == plan.clientId,
            orElse: () => UserModel(
              name: 'Unknown',
              firstName: 'Client',
              age: 0,
              phone: '',
              email: '',
              password: '',
              role: UserRole.client,
            ),
          )
        : null;
    
    final coach = userProvider.users.firstWhere(
      (u) => u.id == plan.coachId,
      orElse: () => UserModel(
        name: 'Unknown',
        firstName: 'Coach',
        age: 0,
        phone: '',
        email: '',
        password: '',
        role: UserRole.coach,
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: plan.isTemplate
              ? AppTheme.accentColor
              : AppTheme.primaryColor,
          child: Icon(
            plan.isTemplate ? Icons.content_copy : Icons.restaurant_menu,
            color: Colors.white,
          ),
        ),
        title: Text(
          plan.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (plan.description != null)
              Text(
                plan.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  userRole == UserRole.client
                      ? Icons.person
                      : plan.isTemplate
                          ? Icons.content_copy
                          : Icons.person,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  userRole == UserRole.client
                      ? 'Coach: ${coach.fullName}'
                      : plan.isTemplate
                          ? 'Modèle'
                          : client != null
                              ? 'Client: ${client.fullName}'
                              : 'Non assigné',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Du ${DateFormat('dd/MM/yyyy').format(plan.startDate)}${plan.endDate != null ? ' au ${DateFormat('dd/MM/yyyy').format(plan.endDate!)}' : ''}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: userRole == UserRole.coach
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!plan.isTemplate && plan.clientId == null)
                    IconButton(
                      icon: const Icon(Icons.assignment, size: 20),
                      tooltip: 'Assigner à un client',
                      onPressed: () => _showAssignDialog(context, plan, userProvider),
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    tooltip: 'Modifier',
                    onPressed: () => _showEditPlanDialog(context, plan),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    tooltip: 'Supprimer',
                    onPressed: () => _confirmDelete(context, plan),
                  ),
                ],
              )
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => _viewPlanDetails(context, plan),
                      icon: const Icon(Icons.visibility),
                      label: const Text('Voir les détails'),
                    ),
                    if (userRole == UserRole.coach && plan.isTemplate)
                      ElevatedButton.icon(
                        onPressed: () => _showAssignDialog(context, plan, userProvider),
                        icon: const Icon(Icons.assignment),
                        label: const Text('Utiliser ce modèle'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePlanDialog(BuildContext context, int coachId, UserProvider userProvider) async {
    // Ensure clients are loaded before showing dialog
    // Clear any filters first
    userProvider.clearFilters();
    await userProvider.loadClientsByCoach(coachId);
    
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    DateTime startDate = DateTime.now();
    DateTime? endDate;
    bool isTemplate = false;
    int? selectedClientId;
    
    // Get clients from the provider (already filtered by coach)
    // Since loadClientsByCoach already filters by coach, we just need client role
    final clients = userProvider.users
        .where((u) => u.role == UserRole.client)
        .toList();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Créer un plan nutritionnel'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nom du plan *',
                    hintText: 'Ex: Plan perte de poids',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Description du plan...',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('Date de début'),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(startDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => startDate = picked);
                    }
                  },
                ),
                ListTile(
                  title: const Text('Date de fin (optionnel)'),
                  subtitle: Text(endDate != null
                      ? DateFormat('dd/MM/yyyy').format(endDate!)
                      : 'Aucune'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (endDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => endDate = null),
                        ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? startDate.add(const Duration(days: 30)),
                      firstDate: startDate,
                      lastDate: DateTime.now().add(const Duration(days: 730)),
                    );
                    if (picked != null) {
                      setState(() => endDate = picked);
                    }
                  },
                ),
                if (clients.isNotEmpty) ...[
                  DropdownButtonFormField<int>(
                    value: selectedClientId,
                    decoration: const InputDecoration(
                      labelText: 'Assigner à un client (optionnel)',
                      hintText: 'Sélectionner un client',
                    ),
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('Aucun (créer comme modèle)'),
                      ),
                      ...clients.map((client) {
                        return DropdownMenuItem<int>(
                          value: client.id,
                          child: Text(client.fullName),
                        );
                      }),
                    ],
                    onChanged: (value) => setState(() {
                      selectedClientId = value;
                      isTemplate = value == null;
                    }),
                  ),
                  const SizedBox(height: 12),
                ] else ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.warningColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: AppTheme.warningColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Aucun client assigné. Le plan sera créé comme modèle.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.warningColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                CheckboxListTile(
                  title: const Text('Créer comme modèle'),
                  subtitle: const Text(
                    'Les modèles peuvent être réutilisés pour plusieurs clients',
                  ),
                  value: isTemplate && selectedClientId == null,
                  onChanged: selectedClientId == null
                      ? (value) => setState(() => isTemplate = value ?? false)
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Le nom du plan est requis'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                  return;
                }

                final plan = NutritionPlan(
                  coachId: coachId,
                  clientId: selectedClientId,
                  name: nameCtrl.text.trim(),
                  description: descCtrl.text.trim().isEmpty
                      ? null
                      : descCtrl.text.trim(),
                  startDate: startDate,
                  endDate: endDate,
                  isTemplate: selectedClientId == null ? isTemplate : false,
                );

                final provider = context.read<NutritionPlanProvider>();
                final planId = await provider.createPlan(plan);

                if (mounted) {
                  Navigator.pop(context);
                  if (planId != null) {
                    await provider.loadPlanWithMeals(planId);
                    _showPlanMealsEditor(context, planId);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPlanDialog(BuildContext context, NutritionPlan plan) {
    final nameCtrl = TextEditingController(text: plan.name);
    final descCtrl = TextEditingController(text: plan.description ?? '');
    DateTime startDate = plan.startDate;
    DateTime? endDate = plan.endDate;
    bool isTemplate = plan.isTemplate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Modifier le plan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nom du plan *',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('Date de début'),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(startDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => startDate = picked);
                    }
                  },
                ),
                ListTile(
                  title: const Text('Date de fin (optionnel)'),
                  subtitle: Text(endDate != null
                      ? DateFormat('dd/MM/yyyy').format(endDate!)
                      : 'Aucune'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (endDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => endDate = null),
                        ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? startDate.add(const Duration(days: 30)),
                      firstDate: startDate,
                      lastDate: DateTime.now().add(const Duration(days: 730)),
                    );
                    if (picked != null) {
                      setState(() => endDate = picked);
                    }
                  },
                ),
                CheckboxListTile(
                  title: const Text('Modèle'),
                  value: isTemplate,
                  onChanged: (value) => setState(() => isTemplate = value ?? false),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Le nom du plan est requis'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                  return;
                }

                final updatedPlan = plan.copyWith(
                  name: nameCtrl.text.trim(),
                  description: descCtrl.text.trim().isEmpty
                      ? null
                      : descCtrl.text.trim(),
                  startDate: startDate,
                  endDate: endDate,
                  isTemplate: isTemplate,
                );

                final provider = context.read<NutritionPlanProvider>();
                final success = await provider.updatePlan(updatedPlan);

                if (mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Plan mis à jour avec succès'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignDialog(
      BuildContext context, NutritionPlan plan, UserProvider userProvider) {
    final clients = userProvider.users
        .where((u) => u.role == UserRole.client && u.coachId != null)
        .toList();

    if (clients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun client disponible'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    int? selectedClientId;
    DateTime startDate = DateTime.now();
    DateTime? endDate;
    int daysToApply = 7;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(plan.isTemplate
              ? 'Utiliser ce modèle pour un client'
              : 'Assigner le plan à un client'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: selectedClientId,
                  decoration: const InputDecoration(
                    labelText: 'Sélectionner un client *',
                  ),
                  items: clients.map((client) {
                    return DropdownMenuItem(
                      value: client.id,
                      child: Text(client.fullName),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedClientId = value),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date de début'),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(startDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => startDate = picked);
                    }
                  },
                ),
                ListTile(
                  title: const Text('Date de fin (optionnel)'),
                  subtitle: Text(endDate != null
                      ? DateFormat('dd/MM/yyyy').format(endDate!)
                      : 'Aucune'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (endDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => endDate = null),
                        ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? startDate.add(const Duration(days: 30)),
                      firstDate: startDate,
                      lastDate: DateTime.now().add(const Duration(days: 730)),
                    );
                    if (picked != null) {
                      setState(() => endDate = picked);
                    }
                  },
                ),
                if (plan.isTemplate) ...[
                  const SizedBox(height: 8),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de jours à appliquer',
                      helperText: 'Générer les repas pour X jours',
                    ),
                    onChanged: (value) {
                      final days = int.tryParse(value);
                      if (days != null && days > 0) {
                        setState(() => daysToApply = days);
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: selectedClientId == null
                  ? null
                  : () async {
                      final provider = context.read<NutritionPlanProvider>();

                      if (plan.isTemplate) {
                        // Create a copy of the template for the client
                        final newPlan = NutritionPlan(
                          coachId: plan.coachId,
                          clientId: selectedClientId,
                          name: plan.name,
                          description: plan.description,
                          startDate: startDate,
                          endDate: endDate,
                          isTemplate: false,
                        );

                        final newPlanId = await provider.createPlan(newPlan);
                        if (newPlanId != null) {
                          // Copy meals from template
                          await provider.loadPlanWithMeals(plan.id!);
                          final templateMeals = provider.currentPlanMeals;
                          for (final meal in templateMeals) {
                            await provider.addPlanMeal(
                              meal.copyWith(planId: newPlanId),
                            );
                          }

                          // Apply plan to generate meals
                          final success = await provider.applyPlanToClient(
                            newPlanId,
                            selectedClientId!,
                            startDate,
                            daysToApply,
                          );

                          if (mounted) {
                            Navigator.pop(context);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Plan appliqué avec succès pour $daysToApply jours',
                                  ),
                                  backgroundColor: AppTheme.successColor,
                                ),
                              );
                              await provider.loadPlansByCoach(plan.coachId);
                            }
                          }
                        }
                      } else {
                        // Assign existing plan
                        final success = await provider.assignPlanToClient(
                          plan.id!,
                          selectedClientId!,
                          startDate,
                          endDate,
                        );

                        if (mounted) {
                          Navigator.pop(context);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Plan assigné avec succès'),
                                backgroundColor: AppTheme.successColor,
                              ),
                            );
                            await provider.loadPlansByCoach(plan.coachId);
                          }
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Assigner'),
            ),
          ],
        ),
      ),
    );
  }

  void _viewPlanDetails(BuildContext context, NutritionPlan plan) async {
    final provider = context.read<NutritionPlanProvider>();
    await provider.loadPlanWithMeals(plan.id!);
    _showPlanMealsEditor(context, plan.id!, readOnly: true);
  }

  void _showPlanMealsEditor(BuildContext context, int planId, {bool readOnly = false}) {
    final provider = context.read<NutritionPlanProvider>();
    provider.loadPlanWithMeals(planId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Consumer<NutritionPlanProvider>(
          builder: (context, provider, child) {
            final plan = provider.currentPlan;
            final meals = provider.currentPlanMeals;

            if (plan == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                AppBar(
                  title: Text(plan.name),
                  automaticallyImplyLeading: false,
                  actions: [
                    if (!readOnly)
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _showAddMealDialog(context, planId),
                      ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Expanded(
                  child: meals.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.restaurant_menu,
                                  size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun repas dans ce plan',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                              if (!readOnly) ...[
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () => _showAddMealDialog(context, planId),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Ajouter un repas'),
                                ),
                              ],
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: meals.length,
                          itemBuilder: (context, index) {
                            final meal = meals[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.primaryColor,
                                  child: Text(
                                    _getMealTypeIcon(meal.mealType),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(meal.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${_getDayName(meal.dayOfWeek)} - ${_getMealTypeName(meal.mealType)}'),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${meal.calories.toStringAsFixed(0)} kcal | P: ${meal.proteins.toStringAsFixed(1)}g | C: ${meal.carbs.toStringAsFixed(1)}g | F: ${meal.fats.toStringAsFixed(1)}g',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                trailing: !readOnly
                                    ? IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => _confirmDeleteMeal(
                                            context, meal, planId),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAddMealDialog(BuildContext context, int planId) {
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController(text: '0');
    final proCtrl = TextEditingController(text: '0');
    final carbCtrl = TextEditingController(text: '0');
    final fatCtrl = TextEditingController(text: '0');
    final noteCtrl = TextEditingController();
    String selectedDay = 'daily';
    MealType selectedType = MealType.breakfast;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Ajouter un repas'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nom du repas *',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedDay,
                  decoration: const InputDecoration(labelText: 'Jour'),
                  items: [
                    'daily',
                    'monday',
                    'tuesday',
                    'wednesday',
                    'thursday',
                    'friday',
                    'saturday',
                    'sunday',
                  ].map((day) {
                    return DropdownMenuItem(
                      value: day,
                      child: Text(_getDayName(day)),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedDay = value!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<MealType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type de repas'),
                  items: MealType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getMealTypeName(type)),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedType = value!),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: calCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Calories',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: proCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Protéines (g)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: carbCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Glucides (g)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: fatCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Lipides (g)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Note (optionnel)',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Le nom du repas est requis'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                  return;
                }

                final meal = PlanMeal(
                  planId: planId,
                  dayOfWeek: selectedDay,
                  mealType: selectedType,
                  name: nameCtrl.text.trim(),
                  calories: double.tryParse(calCtrl.text) ?? 0,
                  proteins: double.tryParse(proCtrl.text) ?? 0,
                  carbs: double.tryParse(carbCtrl.text) ?? 0,
                  fats: double.tryParse(fatCtrl.text) ?? 0,
                  note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
                );

                final provider = context.read<NutritionPlanProvider>();
                final success = await provider.addPlanMeal(meal);

                if (mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Repas ajouté avec succès'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, NutritionPlan plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le plan'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le plan "${plan.name}" ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = context.read<NutritionPlanProvider>();
              final success = await provider.deletePlan(plan.id!, plan.coachId);

              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Plan supprimé avec succès'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteMeal(BuildContext context, PlanMeal meal, int planId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le repas'),
        content: Text('Supprimer "${meal.name}" du plan ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = context.read<NutritionPlanProvider>();
              final success = await provider.deletePlanMeal(meal.id!);

              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Repas supprimé'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  String _getDayName(String day) {
    switch (day) {
      case 'daily':
        return 'Tous les jours';
      case 'monday':
        return 'Lundi';
      case 'tuesday':
        return 'Mardi';
      case 'wednesday':
        return 'Mercredi';
      case 'thursday':
        return 'Jeudi';
      case 'friday':
        return 'Vendredi';
      case 'saturday':
        return 'Samedi';
      case 'sunday':
        return 'Dimanche';
      default:
        return day;
    }
  }

  String _getMealTypeName(MealType type) {
    switch (type) {
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

  String _getMealTypeIcon(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '🍽️';
      case MealType.snack:
        return '🍎';
      case MealType.dinner:
        return '🌙';
    }
  }
}

