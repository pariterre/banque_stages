import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/models/internship.dart';
import '/common/models/person.dart';
import '/common/models/visiting_priority.dart';
import '/common/models/job.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/providers/internships_provider.dart';
import '/common/providers/teachers_provider.dart';
import '/misc/form_service.dart';
import 'steps/general_informations_step.dart';
import 'steps/requirements_step.dart';
import 'steps/schedule_step.dart';

class InternshipEnrollmentScreen extends StatefulWidget {
  const InternshipEnrollmentScreen({super.key, required this.enterpriseId});

  final String enterpriseId;

  @override
  State<InternshipEnrollmentScreen> createState() =>
      _InternshipEnrollmentScreenState();
}

class _InternshipEnrollmentScreenState
    extends State<InternshipEnrollmentScreen> {
  final _generalInfoKey = GlobalKey<GeneralInformationsStepState>();
  final _scheduleKey = GlobalKey<ScheduleStepState>();
  final _requirementsKey = GlobalKey<RequirementsStepState>();
  int _currentStep = 0;

  void _nextStep() {
    final formKeys = [
      _generalInfoKey.currentState!.formKey,
      _scheduleKey.currentState!.formKey,
      _requirementsKey.currentState!.formKey
    ];

    FormService.validateForm(formKeys[_currentStep]);

    if (_currentStep == 2) {
      _submit();
    } else {
      setState(() => _currentStep += 1);
    }
  }

  void _submit() {
    // TODO: Proper validation
    _generalInfoKey.currentState!.formKey.currentState!.save();
    _scheduleKey.currentState!.formKey.currentState!.save();
    _requirementsKey.currentState!.formKey.currentState!.save();

    final enterprises = context.read<EnterprisesProvider>();

    final internship = Internship(
      studentId: _generalInfoKey.currentState!.student!.id,
      teacherId: context.read<TeachersProvider>().currentTeacherId,
      enterpriseId: widget.enterpriseId,
      jobId: _getAvailableJobs()
          .firstWhere((job) =>
              job.activitySector ==
                  _generalInfoKey.currentState!.primaryJob!.activitySector &&
              job.specialization ==
                  _generalInfoKey.currentState!.primaryJob!.specialization)
          .id,
      program: _generalInfoKey.currentState!.student!.program,
      supervisor: Person(
          firstName: _generalInfoKey.currentState!.supervisorFirstName!,
          lastName: _generalInfoKey.currentState!.supervisorLastName!,
          email: _generalInfoKey.currentState!.supervisorEmail ?? '',
          phone: _generalInfoKey.currentState!.supervisorPhone ?? ''),
      protection: _requirementsKey.currentState!.protection,
      uniform: _requirementsKey.currentState!.uniform,
      date: _scheduleKey.currentState!.dateRange,
      schedule: [], // TODO: Fill that
      visitingPriority: VisitingPriority.low,
    );
    context.read<InternshipsProvider>().add(internship);

    enterprises.replace(
      enterprises[widget.enterpriseId].copyWith(
        internshipIds: [
          ...enterprises[widget.enterpriseId].internshipIds,
          internship.id,
        ],
      ),
    );

    Navigator.pop(context);
  }

  Iterable<Job> _getAvailableJobs() {
    return context.read<EnterprisesProvider>()[widget.enterpriseId].jobs.where(
          (job) =>
              job.positionsOffered - job.positionsOccupied > 0 &&
              job.activitySector != null &&
              job.specialization != null,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscrire un stagiaire'),
      ),
      body: Selector<EnterprisesProvider, Enterprise>(
        builder: (context, enterprise, _) => Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepContinue: _nextStep,
          onStepTapped: (int tapped) => setState(() => _currentStep = tapped),
          onStepCancel: () => Navigator.pop(context),
          steps: [
            Step(
              isActive: _currentStep == 0,
              title: const Text('Général'),
              content: GeneralInformationsStep(
                key: _generalInfoKey,
                enterprise: enterprise,
                availableJobs: _getAvailableJobs(),
              ),
            ),
            Step(
              isActive: _currentStep == 1,
              title: const Text('Horaire'),
              content: ScheduleStep(
                key: _scheduleKey,
              ),
            ),
            Step(
              isActive: _currentStep == 2,
              title: const Text('Exigences'),
              content: RequirementsStep(
                key: _requirementsKey,
              ),
            ),
          ],
          controlsBuilder: _controlBuilder,
        ),
        selector: (context, enterprises) => enterprises[widget.enterpriseId],
      ),
    );
  }

  Widget _controlBuilder(BuildContext context, ControlsDetails details) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
              onPressed: details.onStepCancel, child: const Text('Annuler')),
          const SizedBox(
            width: 20,
          ),
          TextButton(
            onPressed: details.onStepContinue,
            child: _currentStep == 2
                ? const Text('Confirmer')
                : const Text('Suivant'),
          )
        ],
      ),
    );
  }
}
