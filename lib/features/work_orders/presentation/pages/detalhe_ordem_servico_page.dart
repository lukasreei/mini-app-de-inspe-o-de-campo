import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/work_order_detail_bloc.dart';
import '../bloc/work_order_detail_event.dart';
import '../bloc/work_order_detail_state.dart';

import '../../../inspections/data/services/inspection_device_service.dart';
import '../../../inspections/presentation/bloc/inspection_form_bloc.dart';
import '../../../inspections/presentation/pages/formulario_inspecao_page.dart';
import '../../../inspections/data/repositories/inspections_repository.dart';

class DetalheOrdemServicoPage extends StatelessWidget {
  const DetalheOrdemServicoPage({required this.workOrderId, super.key});

  final String workOrderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe da OS')),
      body: BlocBuilder<WorkOrderDetailBloc, WorkOrderDetailState>(
        builder: (context, state) {
          if (state is WorkOrderDetailInitial ||
              state is WorkOrderDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WorkOrderDetailFailure) {
            return _ErrorState(
              message: state.message,
              onRetry: () {
                context.read<WorkOrderDetailBloc>().add(
                  WorkOrderDetailRequested(workOrderId: workOrderId),
                );
              },
            );
          }

          if (state is WorkOrderDetailLoaded) {
            final workOrder = state.workOrder;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    workOrder.code,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    workOrder.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _PriorityBadge(priority: workOrder.priority),
                      _StatusBadge(status: workOrder.status),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _InfoCard(
                    icon: Icons.info_outline,
                    title: 'Informações',
                    children: [
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Agendamento',
                        value: _formatDate(workOrder.scheduledAt),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _InfoCard(
                    icon: Icons.description_outlined,
                    title: 'Descrição',
                    children: [
                      Text(
                        workOrder.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _InfoCard(
                    icon: Icons.location_on_outlined,
                    title: 'Local',
                    children: [
                      _InfoRow(
                        icon: Icons.place_outlined,
                        label: 'Endereço',
                        value: workOrder.address,
                      ),
                    ],
                  ),

                  if (workOrder.notes != null &&
                      workOrder.notes!.trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _InfoCard(
                      icon: Icons.notes_outlined,
                      title: 'Observações',
                      children: [Text(workOrder.notes!)],
                    ),
                  ],

                  const SizedBox(height: 28),

                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      final inspectionsRepository = context
                          .read<InspectionsRepository>();

                      final draft = await inspectionsRepository
                          .getDraftForWorkOrder(workOrder.id);

                      if (!context.mounted) {
                        return;
                      }

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => InspectionFormBloc(
                              workOrderId: workOrder.id,
                              deviceService: InspectionDeviceService(),
                              inspectionsRepository: inspectionsRepository,
                              initialDraft: draft,
                            ),
                            child: const FormularioInspecaoPage(),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.fact_check_outlined),
                    label: const Text('Iniciar inspeção'),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
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
                  child: Icon(
                    icon,
                    size: 20,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
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
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 2),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

String _priorityLabel(String priority) {
  switch (priority) {
    case 'high':
      return 'Alta';
    case 'medium':
      return 'Média';
    case 'low':
      return 'Baixa';
    default:
      return priority;
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'open':
      return 'Aberta';
    case 'in_progress':
      return 'Em andamento';
    case 'done':
      return 'Concluída';
    default:
      return status;
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');

  return '$day/$month/${date.year} às $hour:$minute';
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});

  final String priority;

  @override
  Widget build(BuildContext context) {
    Color background;

    switch (priority) {
      case 'high':
        background = Colors.red.shade100;
        break;

      case 'medium':
        background = Colors.amber.shade100;
        break;

      case 'low':
        background = Colors.green.shade100;
        break;

      default:
        background = Colors.grey.shade200;
    }

    return _Badge(label: _priorityLabel(priority), backgroundColor: background);
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color background;

    switch (status) {
      case 'open':
        background = Colors.blue.shade100;
        break;

      case 'in_progress':
        background = Colors.orange.shade100;
        break;

      case 'done':
        background = Colors.green.shade100;
        break;

      default:
        background = Colors.grey.shade200;
    }

    return _Badge(label: _statusLabel(status), backgroundColor: background);
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.backgroundColor});

  final String label;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}
