import 'package:flutter/material.dart';
import 'services_api.dart';
import 'home_screen.dart'; // for CityWeather model

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<CityWeather> _myCities = [];
  bool _isLoading = false;

  void _submitCity() async {
    final cityName = _controller.text.trim();
    if (cityName.isEmpty) return;

    setState(() => _isLoading = true);

    // fetch weather for the city
    final cityWeather = await services_api().fetchCityWeather(cityName);

    setState(() => _isLoading = false);

    if (cityWeather != null) {
      // avoid duplicates
      if (!_myCities.any((c) => c.city.toLowerCase() == cityWeather.city.toLowerCase())) {
        setState(() {
          _myCities.insert(0, cityWeather);
        });
      } else {
        // optionally move existing city to top
        final existingIndex = _myCities.indexWhere((c) => c.city.toLowerCase() == cityWeather.city.toLowerCase());
        final existing = _myCities.removeAt(existingIndex);
        setState(() {
          _myCities.insert(0, existing);
        });
      }

      _controller.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("City not found or API error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      appBar: AppBar(
        title: const Text("Search City"),
        backgroundColor: const Color(0xFF1E2228),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter city name",
                hintStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onSubmitted: (_) => _submitCity(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitCity,
              child: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text("Search"),
            ),
            const SizedBox(height: 20),
            Expanded(child: buildMyCities()),
          ],
        ),
      ),
    );
  }

  Widget buildMyCities() {
    if (_myCities.isEmpty) {
      return const Center(
        child: Text(
          "No cities yet. Search to add one.",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      itemCount: _myCities.length,
      itemBuilder: (context, index) {
        final city = _myCities[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Dismissible(
            key: ValueKey(city.city + city.time.toIso8601String()),
            direction: DismissDirection.endToStart,
            background: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.centerRight,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              setState(() {
                _myCities.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${city.city} removed')),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E2228),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(city.city,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(
                          "${city.time.hour.toString().padLeft(2,'0')}:${city.time.minute.toString().padLeft(2,'0')}",
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "${city.temp.toStringAsFixed(0)}°",
                    style: const TextStyle(
                        color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 12),
                  Image.network(
                    "https://openweathermap.org/img/wn/${city.iconCode}.png",
                    height: 30,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
