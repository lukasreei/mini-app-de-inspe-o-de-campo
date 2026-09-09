import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/inspection_form_bloc.dart';
import '../bloc/inspection_form_event.dart';
import '../bloc/inspection_form_state.dart';

class FormularioInspecaoPage extends StatelessWidget {
  const FormularioInspecaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Inspeção')),
      body: BlocConsumer<InspectionFormBloc, InspectionFormState>(
        listener: (context, state) {
          final message = state.errorMessage;

          if (message != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
          }
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Inspeção',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'ID local: ${state.clientId}',
                style: Theme.of(context).textTheme.bodySmall,
              ),

              const SizedBox(height: 24),

              TextFormField(
                maxLines: 5,
                minLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observação',
                  hintText:
                      'Descreva o que foi identificado durante a inspeção.',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                onChanged: (value) {
                  context.read<InspectionFormBloc>().add(
                    InspectionObservationChanged(value),
                  );
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: state.condition,
                decoration: const InputDecoration(
                  labelText: 'Condição encontrada',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'bom', child: Text('Bom')),
                  DropdownMenuItem(value: 'regular', child: Text('Regular')),
                  DropdownMenuItem(value: 'ruim', child: Text('Ruim')),
                  DropdownMenuItem(value: 'crítico', child: Text('Crítico')),
                ],
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  context.read<InspectionFormBloc>().add(
                    InspectionConditionChanged(value),
                  );
                },
              ),

              const SizedBox(height: 24),

              Text(
                'Evidência fotográfica',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              if (state.photoPath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(state.photoPath!),
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 180,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_a_photo_outlined, size: 48),
                      SizedBox(height: 8),
                      Text('Nenhuma foto capturada'),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: state.isCapturingPhoto
                          ? null
                          : () {
                              context.read<InspectionFormBloc>().add(
                                const InspectionPhotoRequested(),
                              );
                            },
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Câmera'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: state.isCapturingPhoto
                          ? null
                          : () {
                              context.read<InspectionFormBloc>().add(
                                const InspectionGalleryPhotoRequested(),
                              );
                            },
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Galeria'),
                    ),
                  ),
                ],
              ),

              if (state.isCapturingPhoto) ...[
                const SizedBox(height: 12),
                const Center(child: CircularProgressIndicator()),
              ],

              const SizedBox(height: 24),

              Text(
                'Localização',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(
                    state.hasLocation
                        ? 'Localização capturada'
                        : 'Localização pendente',
                  ),
                  subtitle: state.hasLocation
                      ? Text(
                          '${state.latitude!.toStringAsFixed(6)}, '
                          '${state.longitude!.toStringAsFixed(6)}',
                        )
                      : const Text('Capture sua posição atual.'),
                ),
              ),

              const SizedBox(height: 8),

              OutlinedButton.icon(
                onPressed: state.isGettingLocation
                    ? null
                    : () {
                        context.read<InspectionFormBloc>().add(
                          const InspectionLocationRequested(),
                        );
                      },
                icon: state.isGettingLocation
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: const Text('Obter localização atual'),
              ),

              const SizedBox(height: 24),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        state.canComplete
                            ? Icons.check_circle_outline
                            : Icons.pending_outlined,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.canComplete
                              ? 'Inspeção pronta para ser concluída.'
                              : 'Preencha observação, condição, foto e localização.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
