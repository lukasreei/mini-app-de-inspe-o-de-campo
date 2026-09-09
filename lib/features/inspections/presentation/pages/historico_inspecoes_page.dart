import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/database/app_database.dart';
import '../bloc/inspection_history_cubit.dart';
import '../bloc/inspection_history_state.dart';

class HistoricoInspecoesPage extends StatelessWidget {
  const HistoricoInspecoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<InspectionHistoryCubit, InspectionHistoryState>(
      listenWhen: (previous, current) => previous.message != current.message,
      listener: (context, state) {
        if (state.message == null) {
          return;
        }

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.message!)));
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Histórico de Inspeções')),
        body: BlocBuilder<InspectionHistoryCubit, InspectionHistoryState>(
          builder: (context, state) {
            final inspections = state.filteredInspections;

            return Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: InspectionHistoryFilter.values
                        .map(
                          (filter) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(_filterLabel(filter)),
                              selected: state.filter == filter,
                              onSelected: (_) {
                                context
                                    .read<InspectionHistoryCubit>()
                                    .setFilter(filter);
                              },
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Expanded(
                  child: inspections.isEmpty
                      ? const Center(
                          child: Text('Nenhuma inspeção encontrada.'),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: inspections.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _InspectionCard(
                              inspection: inspections[index],
                              retryingClientId: state.retryingClientId,
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
}

class _InspectionCard extends StatelessWidget {
  const _InspectionCard({
    required this.inspection,
    required this.retryingClientId,
  });

  final LocalInspection inspection;
  final String? retryingClientId;

  @override
  Widget build(BuildContext context) {
    final isRetrying = retryingClientId == inspection.clientId;

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
                Expanded(
                  child: Text(
                    'OS ${inspection.workOrderId}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _SyncStatusBadge(status: inspection.syncStatus),
              ],
            ),
            const SizedBox(height: 12),
            if (inspection.observation != null)
              Text(
                inspection.observation!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 12),
            _InfoLine(
              icon: Icons.health_and_safety_outlined,
              text: 'Condição: ${inspection.condition ?? '-'}',
            ),

            const SizedBox(height: 8),

            _InfoLine(
              icon: Icons.sync,
              text: 'Tentativas de sincronização: ${inspection.syncAttempts}',
            ),

            const SizedBox(height: 8),

            _InfoLine(
              icon: Icons.schedule_outlined,
              text: 'Atualizado em ${_formatDate(inspection.updatedAt)}',
            ),
            if (inspection.errorMessage != null) ...[
              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(inspection.errorMessage!)),
                  ],
                ),
              ),
            ],
            if (inspection.syncStatus == 'failed') ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: isRetrying
                    ? null
                    : () {
                        context.read<InspectionHistoryCubit>().retry(
                          inspection.clientId,
                        );
                      },
                icon: isRetrying
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _filterLabel(InspectionHistoryFilter filter) {
  switch (filter) {
    case InspectionHistoryFilter.all:
      return 'Todas';

    case InspectionHistoryFilter.draft:
      return 'Rascunhos';

    case InspectionHistoryFilter.pending:
      return 'Pendentes';

    case InspectionHistoryFilter.synced:
      return 'Sincronizadas';

    case InspectionHistoryFilter.failed:
      return 'Falhas';
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'draft':
      return 'Rascunho';

    case 'pending':
      return 'Pendente';

    case 'synced':
      return 'Sincronizada';

    case 'failed':
      return 'Falhou';

    default:
      return status;
  }
}

String _formatDate(DateTime date) {
  final local = date.toLocal();

  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');

  return '$day/$month/${local.year} '
      '$hour:$minute';
}

class _SyncStatusBadge extends StatelessWidget {
  const _SyncStatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _statusColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(status), size: 16, color: Colors.black87),
          const SizedBox(width: 6),
          Text(
            _statusLabel(status),
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'draft':
      return Colors.grey.shade200;

    case 'pending':
      return Colors.amber.shade100;

    case 'synced':
      return Colors.green.shade100;

    case 'failed':
      return Colors.red.shade100;

    default:
      return Colors.grey.shade200;
  }
}

IconData _statusIcon(String status) {
  switch (status) {
    case 'draft':
      return Icons.edit_note;

    case 'pending':
      return Icons.schedule;

    case 'synced':
      return Icons.cloud_done_outlined;

    case 'failed':
      return Icons.error_outline;

    default:
      return Icons.info_outline;
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
