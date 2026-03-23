import 'package:flutter/material.dart';
import 'package:flutter_opad/config/api_config.dart';
import 'package:flutter_opad/services/api_service.dart';

/// Widget to switch between local and production API modes
class ApiModeSwitcher extends StatefulWidget {
  final ApiService apiService;
  final VoidCallback? onModeChanged;

  const ApiModeSwitcher({
    Key? key,
    required this.apiService,
    this.onModeChanged,
  }) : super(key: key);

  @override
  State<ApiModeSwitcher> createState() => _ApiModeSwitcherState();
}

class _ApiModeSwitcherState extends State<ApiModeSwitcher> {
  late bool _useLocal;

  @override
  void initState() {
    super.initState();
    _useLocal = ApiConfig.instance.useLocalServer;
  }

  void _toggleMode() {
    setState(() {
      _useLocal = !_useLocal;
    });
    ApiConfig.instance.setUseLocalServer(_useLocal);
    widget.apiService.setUseLocalServer(_useLocal);
    widget.onModeChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _useLocal ? Colors.orange[100] : Colors.blue[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _useLocal ? Colors.orange : Colors.blue,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _useLocal ? Icons.computer : Icons.cloud,
            color: _useLocal ? Colors.orange : Colors.blue,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            _useLocal ? 'LOCAL' : 'PRODUCTION',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _useLocal ? Colors.orange[900] : Colors.blue[900],
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: _useLocal,
            onChanged: (_) => _toggleMode(),
            activeColor: Colors.orange,
            inactiveThumbColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}
