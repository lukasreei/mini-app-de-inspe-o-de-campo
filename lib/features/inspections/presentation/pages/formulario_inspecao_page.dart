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

      bottomNavigationBar: BlocBuilder<InspectionFormBloc, InspectionFormState>(
        builder: (context, state) {
          return SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: state.isSaving
                          ? null
                          : () {
                              context.read<InspectionFormBloc>().add(
                                const InspectionDraftSaveRequested(),
                              );
                            },
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Salvar rascunho'),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: FilledButton.icon(
                      onPressed: state.isSaving || !state.canComplete
                          ? null
                          : () {
                              context.read<InspectionFormBloc>().add(
                                const InspectionCompleteRequested(),
                              );
                            },
                      icon: state.isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: const Text('Concluir'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      body: BlocConsumer<InspectionFormBloc, InspectionFormState>(
        listenWhen: (previous, current) {
          return previous.errorMessage != current.errorMessage ||
              previous.saveStatus != current.saveStatus;
        },
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }

          if (state.saveMessage != null &&
              state.saveStatus != InspectionFormSaveStatus.saving) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.saveMessage!)));
          }

          if (state.saveStatus == InspectionFormSaveStatus.pendingSaved ||
              state.saveStatus == InspectionFormSaveStatus.synced ||
              state.saveStatus == InspectionFormSaveStatus.syncFailed) {
            Navigator.of(context).pop();
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

              _SectionCard(
                icon: Icons.description_outlined,
                title: 'Observações',
                child: TextFormField(
                  initialValue: state.observation,
                  maxLines: 5,
                  minLines: 4,
                  decoration: const InputDecoration(
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
              ),

              const SizedBox(height: 16),

              _SectionCard(
                icon: Icons.health_and_safety_outlined,
                title: 'Condição encontrada',
                child: DropdownButtonFormField<String>(
                  initialValue: state.condition,
                  decoration: const InputDecoration(
                    hintText: 'Selecione a condição',
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
              ),

              const SizedBox(height: 16),

              _SectionCard(
                icon: Icons.photo_camera_outlined,
                title: 'Evidência fotográfica',
                child: Column(
                  children: [
                    if (state.photoPath != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
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
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, size: 46),
                            SizedBox(height: 10),
                            Text(
                              'Nenhuma foto adicionada',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 4),
                            Text('Capture ou escolha uma imagem'),
                          ],
                        ),
                      ),

                    const SizedBox(height: 14),

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
                      const SizedBox(height: 14),
                      const CircularProgressIndicator(),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _SectionCard(
                icon: Icons.location_on_outlined,
                title: 'Localização',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: state.hasLocation
                            ? Colors.green.shade50
                            : Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            state.hasLocation
                                ? Icons.check_circle
                                : Icons.location_searching,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.hasLocation
                                      ? 'Localização capturada'
                                      : 'Localização pendente',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (state.hasLocation)
                                  Text(
                                    '${state.latitude!.toStringAsFixed(6)}, '
                                    '${state.longitude!.toStringAsFixed(6)}',
                                  )
                                else
                                  const Text('Capture sua posição atual.'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

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
                      label: Text(
                        state.hasLocation
                            ? 'Atualizar localização'
                            : 'Obter localização atual',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: state.canComplete
                      ? Colors.green.shade50
                      : Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: state.canComplete
                        ? Colors.green.shade200
                        : Colors.amber.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      state.canComplete
                          ? Icons.check_circle
                          : Icons.info_outline,
                      color: Colors.black87,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.canComplete
                            ? 'Tudo pronto. A inspeção pode ser concluída.'
                            : 'Preencha todos os dados obrigatórios para concluir.',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
