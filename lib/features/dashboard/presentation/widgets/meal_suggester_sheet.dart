import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/providers.dart';

class MealSuggesterSheet extends StatefulWidget {
  const MealSuggesterSheet({super.key});

  @override
  State<MealSuggesterSheet> createState() => _MealSuggesterSheetState();
}

class _MealSuggesterSheetState extends State<MealSuggesterSheet> {
  File? _image;
  String _cuisine = 'No preference';
  String _mealType = 'Main meal';
  final ImagePicker _picker = ImagePicker();

  final List<String> _cuisines = [
    'No preference',
    'Egyptian',
    'Middle Eastern',
    'Mediterranean',
    'Italian',
    'Asian',
    'Indian',
    'Mexican',
    'American'
  ];

  final List<String> _mealTypes = ['Main meal', 'Snack'];

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        if (!mounted) return;
        setState(() {
          _image = File(pickedFile.path);
        });
        context.read<MealSuggesterProvider>().clearSuggestion();
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _suggestMeal() {
    if (_image != null) {
      context.read<MealSuggesterProvider>().suggestMeal(_image!, _cuisine, _mealType);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MealSuggesterProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outline.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Suggest a Meal',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Image selection
                if (_image == null)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.camera_alt_outlined, size: 48, color: colorScheme.primary),
                        const SizedBox(height: 16),
                        const Text('Take a photo of your ingredients'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _pickImage(ImageSource.camera),
                                icon: const Icon(Icons.camera),
                                label: const Text('Camera'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _pickImage(ImageSource.gallery),
                                icon: const Icon(Icons.photo_library),
                                label: const Text('Gallery'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                else
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(_image!, height: 200, width: double.infinity, fit: BoxFit.cover),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.white),
                        onPressed: () => setState(() {
                          _image = null;
                          context.read<MealSuggesterProvider>().clearSuggestion();
                        }),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
                
                // Preferences
                DropdownButtonFormField<String>(
                  value: _cuisine,
                  decoration: const InputDecoration(labelText: 'Cuisine Preference', border: OutlineInputBorder()),
                  items: _cuisines.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setState(() => _cuisine = val!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _mealType,
                  decoration: const InputDecoration(labelText: 'Meal Type', border: OutlineInputBorder()),
                  items: _mealTypes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setState(() => _mealType = val!),
                ),
                const SizedBox(height: 24),

                if (provider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (provider.error != null)
                  Text(provider.error!, style: TextStyle(color: colorScheme.error))
                else if (provider.suggestedMeal != null)
                  _buildResult(provider.suggestedMeal!, colorScheme)
                else if (_image != null)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _suggestMeal,
                    child: const Text('Get Suggestion', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResult(SuggestedMeal meal, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline,
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Suggested Meal', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(meal.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(meal.description, style: Theme.of(context).textTheme.bodyMedium),
            const Divider(height: 32),
            Text('Calories: ${meal.calories} kcal', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Macros: Protein ${meal.protein}g | Carbs ${meal.carbs}g | Fat ${meal.fat}g'),
            const Divider(height: 32),
            Text('Ingredients to Use:', style: const TextStyle(fontWeight: FontWeight.bold)),
            ...meal.ingredientsUsed.map((i) => Text('- $i')),
            const Divider(height: 32),
            Text('Steps:', style: const TextStyle(fontWeight: FontWeight.bold)),
            ...meal.steps.map((s) => Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(s),
            )),
          ],
        ),
      ),
    );
  }
}
