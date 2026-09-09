import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/work_order_detail_bloc.dart';
import '../bloc/work_order_detail_event.dart';
import '../bloc/work_order_detail_state.dart';

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
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    workOrder.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _InfoCard(
                    title: 'Informações',
                    children: [
                      _InfoRow(
                        icon: Icons.flag_outlined,
                        label: 'Prioridade',
                        value: _priorityLabel(workOrder.priority),
                      ),
                      _InfoRow(
                        icon: Icons.assignment_outlined,
                        label: 'Status',
                        value: _statusLabel(workOrder.status),
                      ),
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Agendamento',
                        value: _formatDate(workOrder.scheduledAt),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _InfoCard(
                    title: 'Descrição',
                    children: [Text(workOrder.description)],
                  ),

                  const SizedBox(height: 16),

                  _InfoCard(
                    title: 'Local',
                    children: [
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Endereço',
                        value: workOrder.address,
                      ),
                    ],
                  ),

                  if (workOrder.notes != null &&
                      workOrder.notes!.trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _InfoCard(
                      title: 'Observações',
                      children: [Text(workOrder.notes!)],
                    ),
                  ],
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
  const _InfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
