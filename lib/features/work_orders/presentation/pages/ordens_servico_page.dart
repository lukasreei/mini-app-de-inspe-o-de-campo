import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../inspections/presentation/bloc/inspection_sync_cubit.dart';
import '../../../inspections/presentation/bloc/inspection_sync_state.dart';
import '../../data/models/work_order_model.dart';
import '../../data/repositories/work_orders_repository.dart';
import '../bloc/work_order_detail_bloc.dart';
import '../bloc/work_order_detail_event.dart';
import '../bloc/work_orders_bloc.dart';
import '../bloc/work_orders_event.dart';
import '../bloc/work_orders_state.dart';
import 'detalhe_ordem_servico_page.dart';
import '../../../inspections/data/repositories/inspections_repository.dart';
import '../../../inspections/presentation/bloc/inspection_history_cubit.dart';
import '../../../inspections/presentation/pages/historico_inspecoes_page.dart';

class OrdensServicoPage extends StatelessWidget {
  const OrdensServicoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<InspectionSyncCubit, InspectionSyncState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.message != current.message,
      listener: (context, state) {
        final message = state.message;

        if (message == null) {
          return;
        }

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ordens de Serviço'),
          actions: [
            IconButton(
              tooltip: 'Histórico de inspeções',
              icon: const Icon(Icons.history),
              onPressed: () {
                final repository = context.read<InspectionsRepository>();

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => InspectionHistoryCubit(
                        inspectionsRepository: repository,
                      )..start(),
                      child: const HistoricoInspecoesPage(),
                    ),
                  ),
                );
              },
            ),
            BlocBuilder<InspectionSyncCubit, InspectionSyncState>(
              builder: (context, syncState) {
                return IconButton(
                  tooltip: 'Sincronizar agora',
                  onPressed: syncState.isSyncing
                      ? null
                      : () {
                          context.read<InspectionSyncCubit>().syncNow();
                        },
                  icon: syncState.isSyncing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync),
                );
              },
            ),
            IconButton(
              tooltip: 'Sair',
              onPressed: () {
                context.read<AuthBloc>().add(const LogoutRequested());
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: BlocBuilder<WorkOrdersBloc, WorkOrdersState>(
          builder: (context, state) {
            if (state is WorkOrdersLoading || state is WorkOrdersInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is WorkOrdersFailure) {
              return _ErrorState(message: state.message);
            }

            if (state is WorkOrdersEmpty) {
              return const _EmptyState();
            }

            if (state is WorkOrdersLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<WorkOrdersBloc>().add(
                    const WorkOrdersRefreshed(),
                  );
                },
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: state.workOrders.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final workOrder = state.workOrders[index];

                    return _WorkOrderCard(
                      workOrder: workOrder,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider(
                              create: (_) =>
                                  WorkOrderDetailBloc(
                                    workOrdersRepository: context
                                        .read<WorkOrdersRepository>(),
                                  )..add(
                                    WorkOrderDetailRequested(
                                      workOrderId: workOrder.id,
                                    ),
                                  ),
                              child: DetalheOrdemServicoPage(
                                workOrderId: workOrder.id,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _WorkOrderCard extends StatelessWidget {
  const _WorkOrderCard({required this.workOrder, required this.onTap});

  final WorkOrderModel workOrder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final priorityColor = _priorityAccentColor(workOrder.priority);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: priorityColor, width: 5)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        workOrder.code,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _PriorityChip(priority: workOrder.priority),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  workOrder.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 19,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        workOrder.address,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    _StatusChip(status: workOrder.status),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.priority});

  final String priority;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _priorityBackgroundColor(priority);

    final foregroundColor = _priorityForegroundColor(priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _priorityLabel(priority),
        style: TextStyle(
          color: foregroundColor,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _statusBackgroundColor(status),
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
              fontSize: 13,
            ),
          ),
        ],
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<WorkOrdersBloc>().add(const WorkOrdersRefreshed());
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 180),
          Icon(Icons.assignment_outlined, size: 64),
          SizedBox(height: 16),
          Center(child: Text('Nenhuma ordem de serviço encontrada.')),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

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
              onPressed: () {
                context.read<WorkOrdersBloc>().add(const WorkOrdersRequested());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

Color _priorityBackgroundColor(String priority) {
  switch (priority) {
    case 'high':
      return Colors.red.shade100;

    case 'medium':
      return Colors.amber.shade100;

    case 'low':
      return Colors.green.shade100;

    default:
      return Colors.grey.shade200;
  }
}

Color _priorityForegroundColor(String priority) {
  switch (priority) {
    case 'high':
      return Colors.red.shade800;

    case 'medium':
      return Colors.amber.shade900;

    case 'low':
      return Colors.green.shade800;

    default:
      return Colors.grey.shade800;
  }
}

Color _statusBackgroundColor(String status) {
  switch (status) {
    case 'open':
      return Colors.blue.shade100;

    case 'in_progress':
      return Colors.orange.shade100;

    case 'done':
      return Colors.green.shade100;

    default:
      return Colors.grey.shade200;
  }
}

IconData _statusIcon(String status) {
  switch (status) {
    case 'open':
      return Icons.assignment_outlined;

    case 'in_progress':
      return Icons.timelapse;

    case 'done':
      return Icons.check_circle_outline;

    default:
      return Icons.info_outline;
  }
}

Color _priorityAccentColor(String priority) {
  switch (priority) {
    case 'high':
      return Colors.red.shade500;

    case 'medium':
      return Colors.amber.shade600;

    case 'low':
      return Colors.green.shade500;

    default:
      return Colors.grey.shade500;
  }
}
