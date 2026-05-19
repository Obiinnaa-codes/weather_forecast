import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/weather_model.dart';
import '../services/weather_api_service.dart';
import '../services/cache_service.dart';
import '../widgets/weather_info_card.dart';
import '../widgets/forecast_card.dart';
import '../utils/constants.dart';

/// The primary screen of the application.
/// 
/// It maintains states for loading, network errors, weather models, and caching
/// indicators entirely using Flutter's native [setState] state management.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Service instances isolated following clean architecture practices
  final WeatherApiService _apiService = WeatherApiService();
  final CacheService _cacheService = CacheService();
  
  // Controllers and FocusNodes for input handling
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Screen State Variables
  bool _isLoading = false;          // True when fetching weather data from internet/local database
  String? _errorMessage;           // Holds human-readable network/invalid city error messages
  WeatherModel? _weather;          // Structured weather model to render on screen
  bool _isOfflineData = false;     // True if the current weather displayed is a cached fallback

  @override
  void initState() {
    super.initState();
    // Fetch last searched city on startup to keep app session contiguous
    _loadInitialData();
  }

  @override
  void dispose() {
    // Avoid memory leaks by cleaning up controllers and focus nodes
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// Initial load lifecycle hook.
  /// Checks local shared_preferences cache for the last searched city.
  /// If empty, defaults to fetching London.
  Future<void> _loadInitialData() async {
    final lastCity = await _cacheService.getLastCity();
    if (lastCity != null && lastCity.isNotEmpty) {
      _searchController.text = lastCity;
      await _fetchWeather(lastCity);
    } else {
      // Default city if the user launches the app for the very first time
      await _fetchWeather('London');
    }
  }

  /// Core logic to fetch weather data.
  /// 
  /// Implements online-first fetching with immediate local cache saving, and 
  /// graceful catch-based offline fallback loading.
  Future<void> _fetchWeather(String city) async {
    if (city.trim().isEmpty) return;
    
    // Smooth UX: automatically dismiss the virtual keyboard
    _searchFocusNode.unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Try to fetch fresh live data from WeatherAPI
      final weather = await _apiService.fetchWeather(city);
      
      // 2. Cache successful result locally (JSON string representation)
      await _cacheService.cacheWeather(weather);
      await _cacheService.saveLastCity(weather.cityName);

      // 3. Update active UI variables
      setState(() {
        _weather = weather;
        _isOfflineData = false;
        _isLoading = false;
      });
    } catch (e) {
      // 4. OFFLINE FALLBACK: If network request fails or API throws error, check local cache
      final cachedWeather = await _cacheService.getCachedWeather();
      if (cachedWeather != null) {
        setState(() {
          _weather = cachedWeather;
          _isOfflineData = true; // Mark as offline to display banner
          _isLoading = false;
        });
      } else {
        // 5. Hard failure: No internet and no cached data exists
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _weather = null;
          _isLoading = false;
        });
      }
    }
  }

  /// Helper to dynamically pick background gradient values based on current weather conditions.
  List<Color> _getBackgroundColors() {
    if (_weather == null) return [AppColors.sunnyTop, AppColors.sunnyBottom];
    
    final condition = _weather!.weatherCondition.toLowerCase();
    
    if (condition.contains('rain') || condition.contains('drizzle')) {
      return [AppColors.rainyTop, AppColors.rainyBottom];
    } else if (condition.contains('cloud') || condition.contains('overcast')) {
      return [AppColors.cloudyTop, AppColors.cloudyBottom];
    } else if (condition.contains('night') || condition.contains('clear')) {
      // WeatherAPI returns 'Clear' for clear night skies and 'Sunny' for daytime
      if (condition == 'clear') {
        return [AppColors.nightTop, AppColors.nightBottom];
      }
      return [AppColors.sunnyTop, AppColors.sunnyBottom];
    }
    return [AppColors.sunnyTop, AppColors.sunnyBottom];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(seconds: 1), // Smooth background shift when weather updates
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _getBackgroundColors(),
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: RefreshIndicator(
                  // Trigger refresh logic seamlessly when user pulls down
                  onRefresh: () async {
                    if (_weather != null) {
                      await _fetchWeather(_weather!.cityName);
                    } else if (_searchController.text.isNotEmpty) {
                      await _fetchWeather(_searchController.text);
                    }
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: _buildContent(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Text field allowing user to search by city name.
  /// Triggers on keyboard submit (Enter/Search key) or on tapping the send icon.
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        autofocus: kIsWeb, // Auto focus search field on Web (Responsive requirement)
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search city...',
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.2), // Semi-transparent glassmorphic look
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          suffixIcon: IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: () => _fetchWeather(_searchController.text),
          ),
        ),
        onSubmitted: _fetchWeather,
        textInputAction: TextInputAction.search,
      ),
    );
  }

  /// Conditional body builder based on the current state machine.
  Widget _buildContent() {
    // 1. Loading State
    if (_isLoading) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    // 2. Error State
    if (_errorMessage != null) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: AppStyles.body,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // 3. Empty State (Should not be hit due to London default, but good defensive practice)
    if (_weather == null) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: const Center(
          child: Text('Search for a city to get weather', style: AppStyles.body),
        ),
      );
    }

    // 4. Loaded Data State (Offline or Online)
    return Column(
      children: [
        // Display fallback banner if we are currently showing cached offline data
        if (_isOfflineData)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_off, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  'Offline Data', 
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        
        // Present primary weather details
        WeatherInfoCard(weather: _weather!),
        
        const SizedBox(height: 32),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '3-Day Forecast',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        
        // Horizontal list for forecast data
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _weather!.forecast.length,
            itemBuilder: (context, index) {
              return ForecastCard(forecastDay: _weather!.forecast[index]);
            },
          ),
        ),
      ],
    );
  }
}
