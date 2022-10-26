import 'package:crcrme_banque_stages/screens/ref_sst/risks_cards/widgets/introduction.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/risks_cards/widgets/mainTitle.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/risks_cards/widgets/subTitle.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/risks_cards/widgets/paragraph.dart';
import 'package:flutter/material.dart';

class RisksCardsScreen extends StatefulWidget {
  const RisksCardsScreen(this.nmb, {super.key});
  final int nmb;

  static const route = "/risks-cards";

  @override
  State<RisksCardsScreen> createState() => _RisksCardsScreenState();
}

class _RisksCardsScreenState extends State<RisksCardsScreen> {
  final String intro =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip";
  final String mainTitle =
      "Nom risque - Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt";
  final int index = 1;
  final String subTitle = "TITRE 1 - TYPE DE RISQUE";
  final List<String> listText = ([
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut",
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut",
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut",
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut"
  ]);
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Fiche ${widget.nmb}"),
        ),
        body: ListView(
          children: [
            MainTitle(mainTitle),
            SubTitle(index, subTitle),
            Introduction(intro),
            Paragraph(listText),
          ],
        ));
  }
}
