import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/view_state.dart';
import '../../models/disciplina.dart';
import '../../services/disciplina_service.dart';
import '../../viewmodels/disciplina_form_viewmodel.dart';
import '../../viewmodels/disciplinas_viewmodel.dart';
import 'components/disciplina_tile.dart';
import 'components/status_message.dart';
import 'disciplina_form_screen.dart';

class DisciplinasScreen extends StatelessWidget {
  const DisciplinasScreen({super.key});

  Future<void> _abrirFormulario(BuildContext context) async {
    final service = context.read<DisciplinaService>();
    final listVm = context.read<DisciplinasViewModel>();
    final messenger = ScaffoldMessenger.of(context);

    final criada = await Navigator.of(context).push<Disciplina>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => DisciplinaFormViewModel(service),
          child: const DisciplinaFormScreen(),
        ),
      ),
    );

    if (criada == null) return;
    listVm.adicionar(criada);
    messenger.showSnackBar(SnackBar(content: Text('"${criada.nome}" adicionada!')));
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DisciplinasViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Disciplinas')),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('novaDisciplinaButton'),
        onPressed: () => _abrirFormulario(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova disciplina'),
      ),
      body: RefreshIndicator(
        onRefresh: vm.carregar,
        child: switch (vm.state) {
          ViewState.idle || ViewState.loading => const Center(child: CircularProgressIndicator()),
          ViewState.error => _scrollable(StatusMessage(
              icon: Icons.cloud_off_rounded,
              title: 'Algo deu errado',
              message: vm.errorMessage,
              actionLabel: 'Tentar novamente',
              onAction: vm.carregar,
            )),
          ViewState.success when vm.isEmpty => _scrollable(const StatusMessage(
              icon: Icons.menu_book_rounded,
              title: 'Nenhuma disciplina ainda',
              message: 'Cadastre suas disciplinas para centralizar seu cronograma.',
            )),
          ViewState.success => ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                _Resumo(quantidade: vm.disciplinas.length, horas: vm.cargaHorariaTotal),
                const SizedBox(height: 16),
                for (final d in vm.disciplinas) DisciplinaTile(key: ValueKey(d.id), disciplina: d),
              ],
            ),
        },
      ),
    );
  }

  Widget _scrollable(Widget child) => LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(height: constraints.maxHeight, child: child),
        ),
      );
}

class _Resumo extends StatelessWidget {
  final int quantidade;
  final int horas;

  const _Resumo({required this.quantidade, required this.horas});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0.25), AppColors.secondary.withValues(alpha: 0.15)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(child: _Metrica(valor: '$quantidade', rotulo: 'disciplinas')),
          Expanded(child: _Metrica(valor: '${horas}h', rotulo: 'carga total')),
        ],
      ),
    );
  }
}

class _Metrica extends StatelessWidget {
  final String valor;
  final String rotulo;

  const _Metrica({required this.valor, required this.rotulo});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(valor, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
        Text(rotulo, style: const TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }
}
