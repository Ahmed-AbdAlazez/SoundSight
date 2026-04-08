import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:convert';
void main() {
  runApp(const MyApp());
}

// ─────────────────────────────────────────────
//  Theme & Colors
// ─────────────────────────────────────────────
const Color kBg = Color(0xFF0A0E1A);
const Color kCard = Color(0xFF121829);
const Color kAccent = Color(0xFF00D4FF);
const Color kAccentGlow = Color(0x3300D4FF);
const Color kGreen = Color(0xFF00FF9C);
const Color kGreenGlow = Color(0x3300FF9C);
const Color kRed = Color(0xFFFF4566);
const Color kTextPrimary = Color(0xFFEEF2FF);
const Color kTextSecondary = Color(0xFF8892B0);

// ─────────────────────────────────────────────
//  App Root
// ─────────────────────────────────────────────
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sound Sight',
      
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: kBg,
        colorScheme: const ColorScheme.dark(primary: kAccent),
      ),
      home: const HomeScreen(),
    );
  }
}

// ─────────────────────────────────────────────
//  Home Screen
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  // ── Speech ──
  String _selectedLocale = 'ar_EG';
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _liveText = '';
  String _lastPartial = '';
  final List<String> _history = [];
List<String> _wordBuffer = [];
Timer? _silenceTimer;
Set<String> _sentChunks = {};


  // ── Bluetooth ──
  BluetoothConnection? _btConnection;
  bool _btConnected = false;
  String _btDeviceName = '';
  String _lastSent = '';

  // ── Animation ──
  late AnimationController _pulseCtrl;
  late AnimationController _waveCtrl;
  late Animation<double> _pulseAnim;

  // ── Scroll ──
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _requestPermissions();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _waveCtrl.dispose();
    _scrollCtrl.dispose();
    _btConnection?.dispose();
    _silenceTimer?.cancel();
    super.dispose();
  }

  // ─────────────── Permissions ───────────────
Future<void> _requestPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.microphone,
    Permission.bluetooth,
    Permission.bluetoothConnect,
    Permission.bluetoothScan,
  ].request();

  // Debug output
  statuses.forEach((permission, status) {
    print("$permission => $status");
  });

  // Check microphone specifically
  if (statuses[Permission.microphone]?.isGranted == true) {
    print("Microphone granted ✅");
  } else {
    print("Microphone denied ❌");
  }
}
////////
void _sendChunk(String text) {
  if (text.isEmpty) return;

  // 🔥 منع التكرار نهائي
  if (_sentChunks.contains(text)) return;

  _sentChunks.add(text);

  _lastSent = text;

  _sendViaBluetooth(text);

  setState(() {
    _history.insert(0, text);
  });
}

//////
  // ─────────────── Speech ───────────────
Future<void> _startListening() async {
  bool available = await _speech.initialize(
    onStatus: (s) {
      if (s == 'done' && _isListening) _startListening();
    },
    onError: (e) => debugPrint('STT Error: $e'),
  );

  if (available) {
    setState(() => _isListening = true);

    _speech.listen(
      onResult: (result) {
        final text = result.recognizedWords;

        setState(() {
          _liveText = text;
        });

        final words = text.trim().isEmpty
            ? <String>[]
            : text.trim().split(RegExp(r'\s+'));

        // 🧠 update buffer بدون تكرار
        if (words.length > _wordBuffer.length) {
          _wordBuffer = words;
        }

        // 🔥 ابعت كل 5 كلمات
        while (_wordBuffer.length >= 5) {
          final chunk = _wordBuffer.sublist(0, 5).join(' ');
          _wordBuffer = _wordBuffer.sublist(5);

          _sendChunk(chunk);
        }

        // 🧠 reset silence timer
        _silenceTimer?.cancel();
        _silenceTimer = Timer(const Duration(seconds: 2), () {
          _flushRemaining(); // 👈 هنا السحر
        });

        // ✅ لو final → ابعت الباقي فورًا
        if (result.finalResult) {
          _silenceTimer?.cancel();
          _flushRemaining();
        }
      },
      localeId: _selectedLocale,
      listenMode: stt.ListenMode.dictation,
      cancelOnError: false,
      partialResults: true,
    );
  }
}

////////////////////////////////
 void _flushRemaining() {
  if (_wordBuffer.isEmpty) return;

  final chunk = _wordBuffer.join(' ');
  _wordBuffer.clear();

  _sendChunk(chunk);
}

////////////////////////
  void _stopListening() {
  _speech.stop();

  _silenceTimer?.cancel();
  _flushRemaining();

  _sentChunks.clear(); // 👈 مهم

  setState(() => _isListening = false);
}

  void _clearAll() {
    setState(() {
      _history.clear();
      _liveText = '';
    });
  }

  void _copyText() {
    final all = [_liveText, ..._history].where((s) => s.isNotEmpty).join('\n');
    Clipboard.setData(ClipboardData(text: all));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: kCard,
        content: const Text('Copied to clipboard', style: TextStyle(color: kTextPrimary)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─────────────── Bluetooth ───────────────
  Future<void> _connectBluetooth() async {
    final devices = await FlutterBluetoothSerial.instance.getBondedDevices();

    if (!mounted) return;

    if (devices.isEmpty) {
      _showBtMessage('No paired devices found.\nPair your ESP32 first.');
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _DevicePickerSheet(
        devices: devices,
        onPick: (device) async {
          Navigator.pop(context);
          await _doConnect(device);
        },
      ),
    );
  }

  Future<void> _doConnect(BluetoothDevice device) async {
    try {
      final conn = await BluetoothConnection.toAddress(device.address);
      setState(() {
        _btConnection = conn;
        _btConnected = true;
        _btDeviceName = device.name ?? device.address;
      });
    } catch (e) {
      _showBtMessage('Connection failed: $e');
    }
  }

  void _disconnectBluetooth() {
    _btConnection?.dispose();
    setState(() {
      _btConnection = null;
      _btConnected = false;
      _btDeviceName = '';
    });
  }

  Future<void> _sendViaBluetooth(String text) async {
    if (!_btConnected || _btConnection == null) return;
    if (text == _lastSent || text.isEmpty) return;
    _lastSent = text;
    try {
      String formatted = text.trim() + "\n";
_btConnection!.output.add(Uint8List.fromList(utf8.encode(formatted)));
      await _btConnection!.output.allSent;
    } catch (e) {
      debugPrint('BT send error: $e');
    }
  }

  void _showBtMessage(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(msg, style: const TextStyle(color: kTextPrimary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: kAccent)),
          ),
        ],
      ),
    );
  }

  // ─────────────── Build ───────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildLiveDisplay(),
            _buildHistoryList(),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // ── Header ──
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          // Logo / Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: kAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Sound Sight',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: kTextPrimary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),

GestureDetector(
  onTap: () {
    setState(() {
      _selectedLocale =
          _selectedLocale == 'ar_EG' ? 'en_US' : 'ar_EG';
    });
  },
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: kCard,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: kAccent.withOpacity(0.3)),
    ),
    child: Text(
      _selectedLocale == 'ar_EG' ? 'AR' : 'EN',
      style: const TextStyle(
        color: kAccent,
        fontWeight: FontWeight.w700,
      ),
    ),
  ),
),
              const Text(
                'Real-time voice transcription',
                style: TextStyle(fontSize: 11, color: kTextSecondary),
              ),
            ],
          ),
          const Spacer(),

          // BT Button
          GestureDetector(
            onTap: _btConnected ? _disconnectBluetooth : _connectBluetooth,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _btConnected ? kGreenGlow : kAccentGlow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _btConnected ? kGreen : kAccent,
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.bluetooth,
                    size: 14,
                    color: _btConnected ? kGreen : kAccent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _btConnected ? _btDeviceName : 'Connect',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _btConnected ? kGreen : kAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Live Display ──
  Widget _buildLiveDisplay() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 220),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isListening ? kAccent.withOpacity(0.6) : Colors.white.withOpacity(0.06),
            width: 1.5,
          ),
          boxShadow: _isListening
              ? [BoxShadow(color: kAccentGlow, blurRadius: 24, spreadRadius: 2)]
              : [],
        ),
        child: Stack(
          children: [
            // Corner label
            Positioned(
              top: 16,
              left: 20,
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: _isListening ? kAccent : kTextSecondary.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isListening ? 'LIVE' : 'READY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: _isListening ? kAccent : kTextSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Main text
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _liveText.isNotEmpty
                    ? Text(
                        _liveText,
                        key: ValueKey(_liveText),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: kTextPrimary,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                        textDirection: _selectedLocale == 'ar_EG'
    ? TextDirection.rtl
    : TextDirection.ltr,
                      )
                    : Text(
                        _isListening
                            ? 'Listening...'
                            : 'Tap the mic to start',
                        key: const ValueKey('placeholder'),
                        style: TextStyle(
                          fontSize: 18,
                          color: kTextSecondary.withOpacity(0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
            ),

            // BT send indicator
            if (_btConnected && _liveText.isNotEmpty)
              Positioned(
                bottom: 14,
                right: 16,
                child: Row(
                  children: [
                    const Icon(Icons.send, size: 11, color: kGreen),
                    const SizedBox(width: 4),
                    Text(
                      'Sending to OLED',
                      style: TextStyle(
                        fontSize: 10,
                        color: kGreen.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── History ──
  Widget _buildHistoryList() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  'History',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kTextSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                if (_history.isNotEmpty) ...[
                  _iconBtn(Icons.copy_outlined, _copyText),
                  const SizedBox(width: 4),
                  _iconBtn(Icons.delete_outline, _clearAll),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _history.isEmpty
                ? Center(
                    child: Text(
                      'Transcribed sentences will appear here',
                      style: TextStyle(
                        color: kTextSecondary.withOpacity(0.4),
                        fontSize: 13,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _history.length,
                    itemBuilder: (_, i) => _HistoryTile(
                      text: _history[i],
                      index: i,
                      locale: _selectedLocale,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 16, color: kTextSecondary),
      ),
    );
  }

  // ── Bottom Bar ──
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Mic button
          GestureDetector(
            onTap: _isListening ? _stopListening : _startListening,
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, child) => Transform.scale(
                scale: _isListening ? _pulseAnim.value : 1.0,
                child: child,
              ),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening ? kAccent : kCard,
                  border: Border.all(
                    color: _isListening ? kAccent : kTextSecondary.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: _isListening
                      ? [BoxShadow(color: kAccentGlow, blurRadius: 30, spreadRadius: 4)]
                      : [],
                ),
                child: Icon(
                  _isListening ? Icons.stop_rounded : Icons.mic_none_rounded,
                  size: 34,
                  color: _isListening ? kBg : kTextSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  History Tile
// ─────────────────────────────────────────────
class _HistoryTile extends StatelessWidget {
  final String text;
  final int index;
  final String locale;
  const _HistoryTile({
    required this.text,
    required this.index,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: kAccentGlow,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 10,
                  color: kAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: kTextPrimary,
                height: 1.5,
              ),
              textDirection: locale == 'ar_EG'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Device Picker Bottom Sheet
// ─────────────────────────────────────────────
class _DevicePickerSheet extends StatelessWidget {
  final List<BluetoothDevice> devices;
  final void Function(BluetoothDevice) onPick;

  const _DevicePickerSheet({required this.devices, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select ESP32 Device',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Make sure ESP32 is paired in Bluetooth settings',
            style: TextStyle(fontSize: 12, color: kTextSecondary),
          ),
          const SizedBox(height: 16),
          ...devices.map(
            (d) => GestureDetector(
              onTap: () => onPick(d),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kAccent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bluetooth, color: kAccent, size: 20),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.name ?? 'Unknown',
                          style: const TextStyle(
                            color: kTextPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          d.address,
                          style: const TextStyle(
                            color: kTextSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: kTextSecondary, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}