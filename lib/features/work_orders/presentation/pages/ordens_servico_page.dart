import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../data/models/work_order_model.dart';
import '../bloc/work_orders_bloc.dart';
import '../bloc/work_orders_event.dart';
import '../bloc/work_orders_state.dart';

class OrdensServicoPage extends StatelessWidget {
  const OrdensServicoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordens de Serviço'),
        actions: [
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
                context.read<WorkOrdersBloc>().add(const WorkOrdersRefreshed());
              },
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: state.workOrders.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _WorkOrderCard(workOrder: state.workOrders[index]);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _WorkOrderCard extends StatelessWidget {
  const _WorkOrderCard({required this.workOrder});

  final WorkOrderModel workOrder;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    workOrder.code,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                _PriorityChip(priority: workOrder.priority),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              workOrder.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(workOrder.address)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Status: '),
                Text(
                  _statusLabel(workOrder.status),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
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
    return Chip(label: Text(_priorityLabel(priority)));
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
