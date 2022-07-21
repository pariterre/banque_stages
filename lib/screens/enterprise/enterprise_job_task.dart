import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/widgets/confirm_pop_dialog.dart';

class EnterpriseJobTask extends StatefulWidget {
  const EnterpriseJobTask({Key? key, required this.enterpriseId})
      : super(key: key);

  static const String route = "jobTask";

  final String enterpriseId;

  @override
  State<EnterpriseJobTask> createState() => _EnterpriseJobTaskState();
}

class _EnterpriseJobTaskState extends State<EnterpriseJobTask> {
  late String jobId = ModalRoute.of(context)!.settings.arguments as String;

  final _formKey = GlobalKey<FormState>();

  bool _editable = false;

  Future<bool> _onWillPop() async {
    if (_editable) {
      return await showDialog(
          context: context, builder: (context) => const ConfirmPopDialog());
    }

    return true;
  }

  void _toggleEdit() {
    if (_editable) {
      if (!_formKey.currentState!.validate()) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Assurez vous que tous les champs soient valides")));

        return;
      }

      _formKey.currentState!.save();
      EnterprisesProvider provider = context.read<EnterprisesProvider>();
    }

    setState(() => _editable = !_editable);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Selector<EnterprisesProvider, Enterprise>(
            builder: (context, enterprise, child) => Form(
                    child: Scaffold(
                  appBar: AppBar(title: Text(enterprise.name)),
                  body: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ListTile(
                              title: Text(enterprise.jobs[jobId].specialization
                                  .toString())),
                          const ListTile(title: Text("Tâches principales")),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: TextFormField(
                              enabled: _editable,
                              keyboardType: TextInputType.multiline,
                              minLines: 4,
                              maxLines: null,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: _toggleEdit,
                    child: _editable
                        ? const Icon(Icons.save_rounded)
                        : const Icon(Icons.edit),
                  ),
                )),
            selector: (context, enterprises) =>
                enterprises[widget.enterpriseId]));
  }
}
