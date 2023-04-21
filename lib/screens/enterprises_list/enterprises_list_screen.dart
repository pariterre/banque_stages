import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/widgets/main_drawer.dart';
import '/common/widgets/search_bar.dart';
import '/router.dart';
import '/screens/visiting_students/models/waypoints.dart';
import '/screens/visiting_students/widgets/zoom_button.dart';
import 'widgets/enterprise_card.dart';

class EnterpriseController {
  EnterpriseController();
  List<Enterprise> selectedEnterprises = [];
}

class EnterprisesListScreen extends StatefulWidget {
  const EnterprisesListScreen({super.key});

  @override
  State<EnterprisesListScreen> createState() => _EnterprisesListScreenState();
}

class _EnterprisesListScreenState extends State<EnterprisesListScreen>
    with SingleTickerProviderStateMixin {
  bool _withSearchBar = false;
  final _enterpriseController = EnterpriseController();

  late final _tabController =
      TabController(initialIndex: 0, length: 2, vsync: this)
        ..addListener(() => setState(() {}));

  void _search() => setState(() => _withSearchBar = !_withSearchBar);

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: const Text('Entreprises'),
      actions: [
        if (_tabController.index == 0)
          IconButton(
            onPressed: _search,
            icon: const Icon(Icons.search),
          ),
        IconButton(
          onPressed: () => GoRouter.of(context).goNamed(Screens.addEnterprise),
          tooltip: 'Ajouter une entreprise',
          icon: const Icon(Icons.add),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        tabs: [
          Tab(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                Icon(Icons.list),
                SizedBox(width: 8),
                Text('Vue liste')
              ])),
          Tab(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                Icon(Icons.map),
                SizedBox(width: 8),
                Text('Vue carte')
              ])),
        ],
      ),
    );
    return Scaffold(
      appBar: appBar,
      drawer: const MainDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _EnterprisesByList(
            withSearchBar: _withSearchBar,
            enterpriseController: _enterpriseController,
          ),
          _EnterprisesByMap(enterpriseController: _enterpriseController),
        ],
      ),
    );
  }
}

class _EnterprisesByList extends StatefulWidget {
  const _EnterprisesByList({
    required this.withSearchBar,
    required this.enterpriseController,
  });

  final bool withSearchBar;
  final EnterpriseController enterpriseController;

  @override
  State<_EnterprisesByList> createState() => _EnterprisesByListState();
}

class _EnterprisesByListState extends State<_EnterprisesByList> {
  bool _hideNotAvailable = false;
  late final _searchController = TextEditingController()
    ..addListener(() => setState(() {}));

  List<Enterprise> _sortEnterprisesByName(List<Enterprise> enterprises) {
    final res = List<Enterprise>.from(enterprises);
    res.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return res.toList();
  }

  List<Enterprise> _filterSelectedEnterprises(List<Enterprise> enterprises) {
    return enterprises.where((enterprise) {
      // Remove if should not be shown by filter availability filter
      if (_hideNotAvailable &&
          !enterprise.jobs.any(
              (job) => job.positionsOccupied(context) < job.positionsOffered)) {
        return false;
      }

      // Perform the searchbar filter
      if (enterprise.name
          .toLowerCase()
          .contains(_searchController.text.toLowerCase())) {
        return true;
      }
      if (enterprise.jobs.any((job) {
        final hasSpecialization = job.specialization.name
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
        final hasSector = job.specialization.sector.name
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
        return hasSpecialization || hasSector;
      })) {
        return true;
      }
      if (enterprise.activityTypes.any((type) =>
          type.toLowerCase().contains(_searchController.text.toLowerCase()))) {
        return true;
      }
      if (enterprise.address
          .toString()
          .toLowerCase()
          .contains(_searchController.text.toLowerCase())) {
        return true;
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.withSearchBar) SearchBar(controller: _searchController),
        SwitchListTile(
          title: const Text('Afficher que les stages disponibles'),
          value: _hideNotAvailable,
          onChanged: (value) => setState(() => _hideNotAvailable = value),
        ),
        Selector<EnterprisesProvider, List<Enterprise>>(
          builder: (context, enterprises, child) => Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: enterprises.length,
              itemBuilder: (context, index) => EnterpriseCard(
                enterprise: enterprises.elementAt(index),
                onTap: (enterprise) => GoRouter.of(context).goNamed(
                  Screens.enterprise,
                  params: Screens.params(enterprise),
                  queryParams: Screens.queryParams(pageIndex: "0"),
                ),
              ),
            ),
          ),
          selector: (context, enterprises) {
            widget.enterpriseController.selectedEnterprises =
                _filterSelectedEnterprises(enterprises.toList());
            return _sortEnterprisesByName(
                widget.enterpriseController.selectedEnterprises);
          },
        ),
      ],
    );
  }
}

class _EnterprisesByMap extends StatelessWidget {
  const _EnterprisesByMap({required this.enterpriseController});

  final EnterpriseController enterpriseController;

  List<Marker> _latlngToMarkers(
      context, Map<Enterprise, Waypoint> enterprises) {
    List<Marker> out = [];

    const double markerSize = 40;
    for (final enterprise in enterprises.keys) {
      double nameWidth = 160;
      double nameHeight = 100;
      final waypoint = enterprises[enterprise]!;
      final color = enterprise.availableJobs(context).isNotEmpty
          ? Colors.green
          : Colors.red;

      out.add(
        Marker(
          point: waypoint.toLatLng(),
          anchorPos: AnchorPos.exactly(
              Anchor(markerSize / 2 + nameWidth, nameHeight / 2)),
          width: markerSize + nameWidth,
          height: markerSize + nameHeight,
          builder: (context) => Row(
            children: [
              GestureDetector(
                onTap: () => GoRouter.of(context).goNamed(
                  Screens.enterprise,
                  params: Screens.params(enterprise),
                  queryParams: Screens.queryParams(pageIndex: "0"),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(75),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on_sharp,
                    size: markerSize,
                    color: color,
                  ),
                ),
              ),
              if (waypoint.showTitle)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                      color: color.withAlpha(125), shape: BoxShape.rectangle),
                  child: Text(waypoint.title),
                )
            ],
          ),
        ),
      );
    }
    return out;
  }

  Future<Map<Enterprise, Waypoint>> _fetchEnterprisesCoordinates(
      BuildContext context) async {
    final enterprises = enterpriseController.selectedEnterprises;
    final Map<Enterprise, Waypoint> out = {};
    for (final enterprise in enterprises) {
      out[enterprise] = await Waypoint.fromAddress(
          enterprise.name, enterprise.address.toString());
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ScrollPhysics(),
      child: FutureBuilder<Map<Enterprise, Waypoint>>(
          future: _fetchEnterprisesCoordinates(context),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SizedBox(
                height: MediaQuery.of(context).size.height,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            Map<Enterprise, Waypoint> locations = snapshot.data!;
            return SizedBox(
              height: MediaQuery.of(context).size.height - 150,
              child: FlutterMap(
                options: MapOptions(
                    center: locations[locations.keys.first]!.toLatLng(),
                    zoom: 14),
                nonRotatedChildren: const [ZoomButtons()],
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                  ),
                  MarkerLayer(markers: _latlngToMarkers(context, locations)),
                ],
              ),
            );
          }),
    );
  }
}
