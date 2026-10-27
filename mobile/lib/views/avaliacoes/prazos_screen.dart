import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/view_state.dart';
import '../../models/avaliacao.dart';
import '../../services/avaliacao_service.dart';
import '../../viewmodels/avaliacao_form_viewmodel.dart';
import '../../viewmodels/avaliacoes_viewmodel.dart';
import '../../viewmodels/humor_viewmodel.dart';
import '../disciplinas/components/status_message.dart';
import '../humor/components/humor_scale_selector.dart';
import 'avaliacao_form_screen.dart';
import 'components/avaliacao_tile.dart';

class PrazosScreen extends StatelessWidget {
  const PrazosScreen({super.key});

  Future<void> _abrirFormulario(BuildContext context) async {
    final service = context.read<AvaliacaoService>();
    final listVm = context.read<AvaliacoesViewModel>();
    final messenger = ScaffoldMessenger.of(context);

    final criada = await Navigator.of(context).push<Avaliacao>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => AvaliacaoFormViewModel(service),
          child: const AvaliacaoFormScreen(),
        ),
      ),
    );

    if (criada == null) return;
    listVm.adicionar(criada);
    messenger.showSnackBar(SnackBar(content: Text('Prazo "${criada.titulo}" registrado!')));
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AvaliacoesViewModel>();
    final humorVm = context.watch<HumorViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Prazos e Bem-estar')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'novoPrazoFab',
        key: const Key('novoPrazoButton'),
        onPressed: () => _abrirFormulario(context),
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('Novo prazo'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await vm.carregar();
          await humorVm.carregar();
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [
            // US07: Checagem Rápida de Humor
            HumorScaleSelector(
              onSelect: (nivel, emoji, sentimento) async {
                final ok = await humorVm.registrarHumor(
                  nivel: nivel,
                  emoji: emoji,
                  sentimento: sentimento,
                );
                if (ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Humor $emoji ($sentimento) registrado com sucesso!')),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                'Próximas Avaliações e Entregas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            switch (vm.state) {
              ViewState.idle || ViewState.loading => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ViewState.error => StatusMessage(
                  icon: Icons.cloud_off_rounded,
                  title: 'Algo deu errado',
                  message: vm.errorMessage,
                  actionLabel: 'Tentar novamente',
                  onAction: vm.carregar,
                ),
              ViewState.success when vm.isEmpty => const StatusMessage(
                  icon: Icons.assignment_turned_in_rounded,
                  title: 'Nenhum prazo pendente',
                  message: 'Cadastre suas provas e trabalhos para organizar suas entregas.',
                ),
              ViewState.success => Column(
                  children: [
                    for (final a in vm.avaliacoes)
                      AvaliacaoTile(key: ValueKey(a.id), avaliacao: a),
                  ],
                ),
            },
          ],
        ),
      ),
    );
  }
}
