import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/network_service.dart';
import 'services/location_service.dart';
import 'network/polling_strategy.dart';
import 'constants/const.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => LocationService()),
        ProxyProvider<LocationService, NetworkService>(
          update:
              (_, location, __) => NetworkService(
                strategy: PollingStrategy(baseUrl: AppConstants.baseUrl),
                locationService: location,
              ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Network Ping Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        cardColor: const Color(0xFF252525),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isServiceRunning = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Ping Service'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isServiceRunning ? Icons.check_circle : Icons.info,
                  color: _isServiceRunning ? Colors.green : Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  _isServiceRunning ? 'Service Running' : 'Service Stopped',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Network monitoring service status',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _toggleNetworkService,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isServiceRunning ? Colors.red : Colors.green,
        padding: const EdgeInsets.all(16),
      ),
      child:
          _isLoading
              ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : Text(_isServiceRunning ? 'Stop Service' : 'Start Service'),
    );
  }

  Future<void> _toggleNetworkService() async {
    setState(() => _isLoading = true);
    try {
      final network = context.read<NetworkService>();
      if (_isServiceRunning) {
        // 서비스 중지 로직
        _showSuccess('Network service stopped successfully!');
        setState(() => _isServiceRunning = false);
      } else {
        // 서비스 시작
        await network.startConnection();
        _showSuccess('Network service started successfully!');
        setState(() => _isServiceRunning = true);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}
