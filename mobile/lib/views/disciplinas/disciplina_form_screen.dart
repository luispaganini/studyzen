import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../viewmodels/disciplina_form_viewmodel.dart';

class DisciplinaFormScreen extends StatefulWidget {
  const DisciplinaFormScreen({super.key});

  @override
  State<DisciplinaFormScreen> createState() => _DisciplinaFormScreenState();
}

class _DisciplinaFormScreenState extends State<DisciplinaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cargaController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _cargaController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<DisciplinaFormViewModel>();
    final navigator = Navigator.of(context);
    final criada = await vm.salvar(nome: _nomeController.text, cargaHoraria: _cargaController.text);
    if (criada != null) navigator.pop(criada);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DisciplinaFormViewModel>();

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Scaffold(
        appBar: AppBar(title: const Text('Nova disciplina')),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                TextFormField(
                  key: const Key('nomeField'),
                  controller: _nomeController,
                  enabled: !vm.isSaving,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  maxLength: DisciplinaFormViewModel.maxNome,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    prefixIcon: Icon(Icons.menu_book_rounded),
                  ),
                  validator: vm.validarNome,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('cargaField'),
                  controller: _cargaController,
                  enabled: !vm.isSaving,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Carga horária',
                    suffixText: 'horas',
                    prefixIcon: Icon(Icons.schedule_rounded),
                  ),
                  validator: vm.validarCargaHoraria,
                  onFieldSubmitted: (_) => _salvar(),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: vm.errorMessage == null
                      ? const SizedBox(height: 24)
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            vm.errorMessage!,
                            key: const Key('formError'),
                            style: const TextStyle(color: AppColors.danger),
                          ),
                        ),
                ),
                FilledButton(
                  key: const Key('salvarButton'),
                  onPressed: vm.isSaving ? null : _salvar,
                  child: vm.isSaving
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                      : const Text('Salvar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
