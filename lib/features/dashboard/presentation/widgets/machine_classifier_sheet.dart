import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/providers/providers.dart';

class MachineClassifierSheet extends StatefulWidget {
  const MachineClassifierSheet({super.key});

  @override
  State<MachineClassifierSheet> createState() => _MachineClassifierSheetState();
}

class _MachineClassifierSheetState extends State<MachineClassifierSheet> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        if (!mounted) return;
        setState(() {
          _image = File(pickedFile.path);
        });
        context.read<MachineClassifierProvider>().clearPrediction();
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _classifyMachine() {
    if (_image != null) {
      context.read<MachineClassifierProvider>().classifyMachine(_image!);
    }
  }

  Future<void> _launchVideo(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch the video link.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MachineClassifierProvider>();
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
                  'Identify Gym Machine',
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
                        Icon(Icons.fitness_center_outlined, size: 48, color: colorScheme.primary),
                        const SizedBox(height: 16),
                        const Text(
                          'Take a photo of the gym machine to learn how to use it.',
                          textAlign: TextAlign.center,
                        ),
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
                        child: Image.file(_image!, height: 300, width: double.infinity, fit: BoxFit.cover),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.white, size: 32),
                        onPressed: () => setState(() {
                          _image = null;
                          context.read<MachineClassifierProvider>().clearPrediction();
                        }),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),

                if (provider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (provider.error != null)
                  Text(provider.error!, style: TextStyle(color: colorScheme.error), textAlign: TextAlign.center)
                else if (provider.prediction != null)
                  _buildResult(provider.prediction!, colorScheme)
                else if (_image != null)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _classifyMachine,
                    child: const Text('Identify Machine', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResult(MachinePrediction prediction, ColorScheme colorScheme) {
    // Basic formatting for names like "Seated_Cable_Row" -> "Seated Cable Row"
    final formattedName = prediction.label.replaceAll('_', ' ').replaceAll('-', ' ').toUpperCase();
    final isUnknown = prediction.label.toLowerCase() == 'unknown';

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (isUnknown) ...[
              Icon(Icons.help_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Machine Not Recognized',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please try taking a clearer photo from a different angle.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ] else ...[
              Icon(Icons.check_circle_outline, size: 48, color: colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                formattedName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                textAlign: TextAlign.center,
              ),
              if (prediction.videoUrl != null) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: () => _launchVideo(prediction.videoUrl!),
                  icon: const Icon(Icons.play_circle_fill),
                  label: const Text('Watch Tutorial Video', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ]
          ],
        ),
      ),
    );
  }
}
