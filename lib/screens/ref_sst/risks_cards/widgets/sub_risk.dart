import 'package:flutter/material.dart';

import '../../common/Risk.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/risks_cards/widgets/sub_title.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/risks_cards/widgets/situation_risk.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/risks_cards/widgets/factors.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/risks_cards/widgets/symptoms.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/risks_cards/widgets/introduction.dart';

class SubRiskBuilding extends StatelessWidget {
  //params and variables
  const SubRiskBuilding(this.subRisks, {super.key});
  final List<SubRisk> subRisks;

  @override
  Widget build(BuildContext context) {
    final subRiskWidgets = <Widget>[];

    for (int i = 0; i < subRisks.length; i++) {
      SubRisk subRisk = subRisks[i];
      subRiskWidgets.add(Column(
        children: [
          if (subRisks.length > 1) SubTitle(subRisk.id, subRisk.title),

          Introduction(subRisk.intro),
          //Image.asset('assets/1.png'), //Testing how the picture is display
          Container(
            margin: const EdgeInsets.only(left: 20),
            child: const Text(
                "Illustration: Hervé Charbonneau"), //It will be with the picture
          ),
          SituationRisk(subRisk.situations),
          Factors(subRisk.factors),
          Symptoms(subRisk.symptoms)
        ],
      ));
    }
    return Column(children: subRiskWidgets);
  }
}
