import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../viewmodels/avaliacao_form_viewmodel.dart';
import '../../viewmodels/disciplinas_viewmodel.dart';

class AvaliacaoFormScreen extends StatefulWidget {
  const AvaliacaoFormScreen({super.key});

  @override
  State<AvaliacaoFormScreen> createState() => _AvaliacaoFormScreenState();
}

class _AvaliacaoFormScreenState extends State<AvaliacaoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _subtarefaController = TextEditingController();

  static const _tipos = [
    'Trabalho de Conclusão',
    'Trabalho Prático',
    'Prova Teórica',
    'Projeto em Grupo',
    'Seminário',
  ];

  @override
  void dispose() {
    _tituloController.dispose();
    _subtarefaController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(BuildContext context, AvaliacaoFormViewModel vm) async {
    final agora = DateTime.now();
    final selecionada = await showDatePicker(
      context: context,
      initialDate: vm.dataEntrega ?? agora.add(const Duration(days: 7)),
      firstDate: agora.subtract(const Duration(days: 1)),
      lastDate: agora.add(const Duration(days: 365 * 2)),
    );
    if (selecionada != null) {
      vm.setDataEntrega(selecionada);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<AvaliacaoFormViewModel>();
    final navigator = Navigator.of(context);
    final criada = await vm.salvar(titulo: _tituloController.text);
    if (criada != null) navigator.pop(criada);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AvaliacaoFormViewModel>();
    final disciplinasVm = context.watch<DisciplinasViewModel>();
    final disciplinas = disciplinasVm.disciplinas;

    final dataFormatada = vm.dataEntrega == null
        ? 'Selecione o prazo'
        : '${vm.dataEntrega!.day.toString().padLeft(2, '0')}/${vm.dataEntrega!.month.toString().padLeft(2, '0')}/${vm.dataEntrega!.year}';

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Scaffold(
        appBar: AppBar(title: const Text('Novo prazo / avaliação')),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                DropdownButtonFormField<int>(
                  key: const Key('disciplinaDropdown'),
                  initialValue: vm.disciplinaId,
                  decoration: const InputDecoration(
                    labelText: 'Disciplina obrigatória',
                    prefixIcon: Icon(Icons.school_rounded),
                  ),
                  items: [
                    for (final d in disciplinas)
                      DropdownMenuItem<int>(
                        value: d.id,
                        child: Text(d.nome),
                      ),
                  ],
                  onChanged: vm.isSaving ? null : vm.setDisciplina,
                  validator: (v) => v == null ? 'É obrigatório selecionar uma disciplina' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('tituloField'),
                  controller: _tituloController,
                  enabled: !vm.isSaving,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Título da avaliação',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                  validator: vm.validarTitulo,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  key: const Key('tipoDropdown'),
                  initialValue: vm.tipo,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    prefixIcon: Icon(Icons.category_rounded),
                  ),
                  items: [
                    for (final t in _tipos)
                      DropdownMenuItem<String>(
                        value: t,
                        child: Text(t),
                      ),
                  ],
                  onChanged: vm.isSaving ? null : (v) => v != null ? vm.setTipo(v) : null,
                ),
                const SizedBox(height: 16),
                InkWell(
                  key: const Key('dataPickerButton'),
                  onTap: vm.isSaving ? null : () => _selecionarData(context, vm),
                  borderRadius: BorderRadius.circular(16),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data de Entrega / Prazo',
                      prefixIcon: Icon(Icons.calendar_month_rounded),
                    ),
                    child: Text(
                      dataFormatada,
                      style: TextStyle(
                        color: vm.dataEntrega == null ? AppColors.textSecondary : AppColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Seção de Decomposição Inteligente
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.auto_awesome_rounded, color: AppColors.secondary, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Decomposição Inteligente',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                            ],
                          ),
                          OutlinedButton.icon(
                            key: const Key('decomporButton'),
                            onPressed: vm.isSaving || vm.isDecompondo ? null : vm.decompor,
                            icon: vm.isDecompondo
                                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.splitscreen_rounded, size: 16),
                            label: const Text('Decompor'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Divide tarefas complexas em etapas editáveis.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      if (vm.subtarefas.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        for (var i = 0; i < vm.subtarefas.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                const Icon(Icons.arrow_right_rounded, color: AppColors.secondary),
                                Expanded(
                                  child: Text(
                                    vm.subtarefas[i],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.danger),
                                  onPressed: () => vm.removerSubtarefa(i),
                                ),
                              ],
                            ),
                          ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              key: const Key('novaSubtarefaField'),
                              controller: _subtarefaController,
                              decoration: const InputDecoration(
                                hintText: 'Adicionar etapa manual...',
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            key: const Key('adicionarSubtarefaButton'),
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              vm.adicionarSubtarefa(_subtarefaController.text);
                              _subtarefaController.clear();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (vm.errorMessage != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      vm.errorMessage!,
                      key: const Key('formError'),
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  ),
                ] else
                  const SizedBox(height: 24),
                FilledButton(
                  key: const Key('salvarAvaliacaoButton'),
                  onPressed: vm.isSaving ? null : _salvar,
                  child: vm.isSaving
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                      : const Text('Salvar prazo'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

