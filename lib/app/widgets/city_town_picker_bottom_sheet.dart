import 'package:flutter/material.dart';

/// Result from [showStateCityPicker]: selected city with id, name, and state name.
/// Use cityName for display and for APIs that accept string; use cityId for APIs that need id.
Map<String, dynamic> stateCityPickerResult({
  required int cityId,
  required String cityName,
  required String stateName,
}) =>
    {'cityId': cityId, 'cityName': cityName, 'stateName': stateName};

/// Shows a bottom sheet to pick State → City → Area (required for campaign).
/// Returns map with cityId, cityName, stateName, areaId, areaName; or null if dismissed.
Future<Map<String, dynamic>?> showStateCityPicker({
  required BuildContext context,
  required List<Map<String, dynamic>> states,
  required Future<List<Map<String, dynamic>>> Function(int stateId) loadCities,
  required Future<List<Map<String, dynamic>>> Function(int cityTownId) loadAreas,
  String? selectedCityName,
  String title = 'Choose city/town',
  String hintTextStates = 'Search state...',
  String hintTextCities = 'Search city...',
  String hintTextAreas = 'Search area...',
}) async {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _StateCityPickerSheet(
      states: states,
      loadCities: loadCities,
      loadAreas: loadAreas,
      selectedCityName: selectedCityName,
      title: title,
      hintTextStates: hintTextStates,
      hintTextCities: hintTextCities,
      hintTextAreas: hintTextAreas,
    ),
  );
}

/// Legacy: flat list of city/town strings (e.g. from GET /misc/city-town).
Future<String?> showCityTownPicker({
  required BuildContext context,
  required List<String> options,
  String? selectedValue,
  String title = 'Choose city/town',
  String hintText = 'Search city or town...',
  String confirmLabel = 'Use this city/town',
  bool required = true,
}) async {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _CityTownPickerSheet(
      options: options,
      selectedValue: selectedValue,
      title: title,
      hintText: hintText,
      confirmLabel: confirmLabel,
      required: required,
    ),
  );
}

// ─── State → City picker (new API: /misc/states, /misc/cities/{stateId}) ───

class _StateCityPickerSheet extends StatefulWidget {
  final List<Map<String, dynamic>> states;
  final Future<List<Map<String, dynamic>>> Function(int stateId) loadCities;
  final Future<List<Map<String, dynamic>>> Function(int cityTownId) loadAreas;
  final String? selectedCityName;
  final String title;
  final String hintTextStates;
  final String hintTextCities;
  final String hintTextAreas;

  const _StateCityPickerSheet({
    required this.states,
    required this.loadCities,
    required this.loadAreas,
    this.selectedCityName,
    required this.title,
    required this.hintTextStates,
    required this.hintTextCities,
    required this.hintTextAreas,
  });

  @override
  State<_StateCityPickerSheet> createState() => _StateCityPickerSheetState();
}

class _StateCityPickerSheetState extends State<_StateCityPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  int _step = 0; // 0 = states, 1 = cities, 2 = areas
  Map<String, dynamic>? _selectedState;
  Map<String, dynamic>? _selectedCity;
  List<Map<String, dynamic>> _cities = [];
  List<Map<String, dynamic>> _areas = [];
  bool _citiesLoading = false;
  bool _areasLoading = false;
  String? _citiesError;
  String? _areasError;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredStates {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return List.from(widget.states);
    return widget.states.where((s) => (s['name'] as String?)?.toLowerCase().contains(q) ?? false).toList();
  }

  List<Map<String, dynamic>> get _filteredCities {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return List.from(_cities);
    return _cities.where((c) => (c['name'] as String?)?.toLowerCase().contains(q) ?? false).toList();
  }

  List<Map<String, dynamic>> get _filteredAreas {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return List.from(_areas);
    return _areas.where((a) => (a['name'] as String?)?.toLowerCase().contains(q) ?? false).toList();
  }

  Future<void> _onStateTap(Map<String, dynamic> state) async {
    setState(() {
      _selectedState = state;
      _citiesLoading = true;
      _citiesError = null;
      _cities = [];
      _step = 1;
      _searchController.clear();
    });
    try {
      final stateId = state['id'] is int ? state['id'] as int : int.parse(state['id'].toString());
      final list = await widget.loadCities(stateId);
      if (mounted) setState(() { _cities = list; _citiesLoading = false; });
    } catch (e) {
      if (mounted) setState(() {
        _citiesError = e.toString().replaceAll('Exception: ', '');
        _citiesLoading = false;
      });
    }
  }

  Future<void> _onCityTap(Map<String, dynamic> city) async {
    setState(() {
      _selectedCity = city;
      _areasLoading = true;
      _areasError = null;
      _areas = [];
      _step = 2;
      _searchController.clear();
    });
    try {
      final cityTownId = city['id'] is int ? city['id'] as int : int.tryParse(city['id']?.toString() ?? '0') ?? 0;
      final list = await widget.loadAreas(cityTownId);
      if (mounted) setState(() { _areas = list; _areasLoading = false; });
    } catch (e) {
      if (mounted) setState(() {
        _areasError = e.toString().replaceAll('Exception: ', '');
        _areasLoading = false;
      });
    }
  }

  void _onAreaTap(Map<String, dynamic> area) {
    final stateName = _selectedState?['name']?.toString() ?? '';
    final city = _selectedCity!;
    final cityId = city['id'] is int ? city['id'] as int : int.tryParse(city['id']?.toString() ?? '0') ?? 0;
    final cityName = city['name']?.toString() ?? '';
    final areaId = area['id'] is int ? area['id'] as int : int.tryParse(area['id']?.toString() ?? '0') ?? 0;
    final areaName = area['name']?.toString() ?? '';
    Navigator.of(context).pop(<String, dynamic>{
      'cityId': cityId,
      'cityName': cityName,
      'stateName': stateName,
      'areaId': areaId,
      'areaName': areaName,
    });
  }

  void _back() {
    setState(() {
      if (_step == 2) {
        _step = 1;
        _selectedCity = null;
        _areas = [];
      } else {
        _step = 0;
        _selectedState = null;
        _cities = [];
      }
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  if (_step >= 1)
                    IconButton(
                      onPressed: _back,
                      icon: const Icon(Icons.arrow_back),
                    ),
                  Text(
                    _step == 0 ? 'Select state' : _step == 1 ? widget.title : 'Select area',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'ProductSans',
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: _step == 0 ? widget.hintTextStates : _step == 1 ? widget.hintTextCities : widget.hintTextAreas,
                  hintStyle: TextStyle(color: Colors.grey[500], fontFamily: 'ProductSans'),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                style: const TextStyle(fontFamily: 'ProductSans', fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _step == 0
                  ? _buildList(
                      scrollController,
                      _filteredStates,
                      (s) => (s['name'] as String?) ?? '',
                      _onStateTap,
                      Icons.map_outlined,
                    )
                  : _step == 1
                      ? (_citiesLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _citiesError != null
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      _citiesError!,
                                      style: TextStyle(fontFamily: 'ProductSans', color: Colors.red[700]),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : _buildList(
                                  scrollController,
                                  _filteredCities,
                                  (c) => (c['name'] as String?) ?? '',
                                  _onCityTap,
                                  Icons.location_city_outlined,
                                ))
                      : (_areasLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _areasError != null
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      _areasError!,
                                      style: TextStyle(fontFamily: 'ProductSans', color: Colors.red[700]),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : _buildList(
                                  scrollController,
                                  _filteredAreas,
                                  (a) => (a['name'] as String?) ?? '',
                                  _onAreaTap,
                                  Icons.place_outlined,
                                )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
    ScrollController scrollController,
    List<Map<String, dynamic>> items,
    String Function(Map<String, dynamic>) title,
    void Function(Map<String, dynamic>) onTap,
    IconData icon,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.trim().isEmpty ? 'No items' : 'No matches',
          style: TextStyle(fontFamily: 'ProductSans', fontSize: 15, color: Colors.grey[600]),
        ),
      );
    }
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          dense: true,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.black54, size: 22),
          ),
          title: Text(
            title(item),
            style: const TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: () => onTap(item),
        );
      },
    );
  }
}

// ─── Legacy flat city/town list ───

class _CityTownPickerSheet extends StatefulWidget {
  final List<String> options;
  final String? selectedValue;
  final String title;
  final String hintText;
  final String confirmLabel;
  final bool required;

  const _CityTownPickerSheet({
    required this.options,
    this.selectedValue,
    required this.title,
    required this.hintText,
    required this.confirmLabel,
    this.required = true,
  });

  @override
  State<_CityTownPickerSheet> createState() => _CityTownPickerSheetState();
}

class _CityTownPickerSheetState extends State<_CityTownPickerSheet> {
  late TextEditingController _searchController;
  String? _selected;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selected =
        widget.selectedValue?.trim().isEmpty == false
            ? widget.selectedValue
            : null;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filteredOptions {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return List.from(widget.options);
    return widget.options
        .where((s) => s.toLowerCase().contains(query))
        .toList();
  }

  void _confirm() {
    if (widget.required && _selected == null) return;
    Navigator.of(context).pop(_selected);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredOptions;

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      builder:
          (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Title and close
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'ProductSans',
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                // Search field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontFamily: 'ProductSans',
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // List of cities/towns
                Expanded(
                  child:
                      filtered.isEmpty
                          ? Center(
                            child: Text(
                              _searchController.text.trim().isEmpty
                                  ? 'No cities available'
                                  : 'No matching city or town',
                              style: TextStyle(
                                fontFamily: 'ProductSans',
                                fontSize: 15,
                                color: Colors.grey[600],
                              ),
                            ),
                          )
                          : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filtered.length,
                            separatorBuilder:
                                (_, __) =>
                                    Divider(height: 1, color: Colors.grey[200]),
                            itemBuilder: (context, index) {
                              final city = filtered[index];
                              final isSelected = _selected == city;
                              return ListTile(
                                dense: true,
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.location_city_outlined,
                                    color:
                                        isSelected
                                            ? Colors.black
                                            : Colors.black54,
                                    size: 22,
                                  ),
                                ),
                                title: Text(
                                  city,
                                  style: TextStyle(
                                    fontFamily: 'ProductSans',
                                    fontSize: 15,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                  ),
                                ),
                                trailing:
                                    isSelected
                                        ? const Icon(
                                          Icons.check_circle,
                                          color: Colors.black,
                                          size: 22,
                                        )
                                        : null,
                                onTap: () {
                                  setState(() => _selected = city);
                                },
                              );
                            },
                          ),
                ),
                const SizedBox(height: 16),
                // Confirm
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          (widget.required && _selected == null)
                              ? null
                              : _confirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.confirmLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'ProductSans',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
