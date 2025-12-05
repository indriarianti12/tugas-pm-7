import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KalkulatorSederhanaApp());
}

// Palet warna yang lebih elegan
const Color primaryIndigo = Color(0xFF4361EE);
const Color secondaryOrange = Color(0xFFF77F00);
const Color charcoalBackground = Color(0xFF1E1E1E);
const Color lightGreyBackground = Color(0xFFF5F7FA);

class KalkulatorSederhanaApp extends StatelessWidget {
  const KalkulatorSederhanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkulator Flutter Elegance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Menggunakan skema warna yang lebih tenang dan modern
        primaryColor: primaryIndigo, 
        colorScheme: ColorScheme.light(
          primary: primaryIndigo,
          secondary: secondaryOrange,
          background: lightGreyBackground,
          surface: Colors.white,
        ),
        fontFamily: 'Inter', // Font modern
        scaffoldBackgroundColor: lightGreyBackground, // Latar belakang sangat terang
        cardColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Menghilangkan ripple effect yang terlalu keras
        splashFactory: InkRipple.splashFactory,
      ),
      home: const KalkulatorPage(),
    );
  }
}

class KalkulatorPage extends StatefulWidget {
  const KalkulatorPage({super.key});

  @override
  State<KalkulatorPage> createState() => _KalkulatorPageState();
}

class _KalkulatorPageState extends State<KalkulatorPage> {
  // 1. Controller untuk Input Angka
  TextEditingController angka1Controller = TextEditingController();
  TextEditingController angka2Controller = TextEditingController();

  // Focus Node untuk mengontrol fokus input
  final FocusNode _angka1Focus = FocusNode();
  final FocusNode _angka2Focus = FocusNode();

  // 2. State untuk Hasil dan Operasi
  double hasil = 0;
  String operasi = '';
  String defaultOperation = '+'; // Operasi default saat menekan Enter

  @override
  void dispose() {
    angka1Controller.dispose();
    angka2Controller.dispose();
    _angka1Focus.dispose();
    _angka2Focus.dispose();
    super.dispose();
  }

  // Fungsi Pembantu untuk Memformat Hasil
  // Memastikan hasil tampil bersih (misalnya 12 daripada 12.0000)
  String _formatResult(double result) {
    if (result == result.roundToDouble()) {
      return result.round().toString();
    }
    // Batasi hingga 6 desimal untuk menjaga kebersihan tampilan
    return result.toStringAsFixed(6).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), ""); 
  }

  // Fungsi Perhitungan
  void hitung(String op) {
    setState(() {
      double a = double.tryParse(angka1Controller.text.replaceAll(',', '.')) ?? 0;
      double b = double.tryParse(angka2Controller.text.replaceAll(',', '.')) ?? 0;
      
      operasi = op;

      switch (op) {
        case '+':
          hasil = a + b;
          break;
        case '-':
          hasil = a - b;
          break;
        case '×':
          hasil = a * b;
          break;
        case '÷':
          if (b != 0) {
            hasil = a / b;
          } else {
            hasil = 0;
            _showSnackBar('Tidak bisa membagi dengan nol!', isError: true);
          }
          break;
        default:
          hasil = 0;
      }
      FocusScope.of(context).unfocus();
    });
  }
  
  // Fungsi Clear (C)
  void clear() {
    setState(() {
      angka1Controller.clear();
      angka2Controller.clear();
      hasil = 0;
      operasi = '';
      FocusScope.of(context).unfocus();
    });
  }

  // Fungsi yang dipanggil saat tombol Enter ditekan pada input kedua
  void _submitCalculationOnEnter(String value) {
    if (_angka2Focus.hasFocus) {
      hitung(operasi.isNotEmpty ? operasi : defaultOperation);
    }
  }

  // Fungsi utilitas untuk menampilkan SnackBar
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : primaryIndigo,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Widget Tombol Operasi yang Ditingkatkan (Elegan & Interaktif)
  Widget _buildOperatorButton(String op, Color color, IconData icon) {
    final bool isActive = op == operasi;
    
    return AspectRatio(
      aspectRatio: 1, 
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isActive ? color : color.withOpacity(0.08), 
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isActive ? color : color.withOpacity(0.4), 
            width: isActive ? 0 : 1.0
          ),
          boxShadow: isActive ? [
            BoxShadow(
              color: color.withOpacity(0.6),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Set operasi saat tombol ditekan
              setState(() {
                operasi = op;
              });
              // Langsung hitung jika kedua input terisi
              if (angka1Controller.text.isNotEmpty && angka2Controller.text.isNotEmpty) {
                hitung(op);
              }
            },
            borderRadius: BorderRadius.circular(15),
            child: Center(
              child: Icon(
                icon,
                color: isActive ? Colors.white : color,
                size: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // Widget Input Field Ditingkatkan (Clean & Outline)
  Widget _buildInputField(TextEditingController controller, String label, FocusNode focusNode, {Function(String)? onSubmitted}) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        // Mendengarkan perubahan fokus untuk memperbarui UI
        final bool isFocused = focusNode.hasFocus; 
        return TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onSubmitted: onSubmitted, 
          // Mengganti koma dengan titik secara otomatis saat diketik (untuk parsing double)
          onChanged: (text) {
            final newText = text.replaceAll(',', '.');
            if (newText != text) {
              controller.value = controller.value.copyWith(
                text: newText,
                selection: TextSelection.collapsed(offset: newText.length),
              );
            }
          },
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: isFocused ? Theme.of(context).primaryColor : Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            hintText: 'Masukkan angka',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        );
      },
    );
  }
  
  // Widget Tombol Clear
  Widget _buildClearButton() {
    return ElevatedButton.icon(
      onPressed: clear,
      icon: const Icon(Icons.refresh, size: 24),
      label: const Text('Clear / Reset', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        foregroundColor: primaryIndigo, 
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: primaryIndigo.withOpacity(0.5), width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        elevation: 0,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator Sederhana', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500), 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // --- Tampilan Hasil (Clean Card) ---
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Hasil Perhitungan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.end,
                        ),
                        const SizedBox(height: 4),
                        // Teks Hasil Besar
                        Text(
                          _formatResult(hasil), 
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).primaryColor,
                          ),
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Divider(height: 24, thickness: 1.5),
                        // Tampilan Operasi
                        Text(
                          'Operasi terpilih: ${operasi.isEmpty ? 'Belum dipilih' : operasi}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // --- Input Angka Pertama ---
                _buildInputField(
                  angka1Controller, 
                  'Angka Pertama (A)',
                  _angka1Focus,
                  onSubmitted: (value) => FocusScope.of(context).requestFocus(_angka2Focus),
                ),
                const SizedBox(height: 16),
                
                // --- Input Angka Kedua ---
                _buildInputField(
                  angka2Controller, 
                  'Angka Kedua (B)',
                  _angka2Focus,
                  onSubmitted: _submitCalculationOnEnter,
                ),

                const SizedBox(height: 32),

                // --- Tombol Operasi (Grid Responsif) ---
                GridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    _buildOperatorButton('+', Colors.green.shade700, Icons.add),
                    _buildOperatorButton('-', Colors.orange.shade700, Icons.remove),
                    _buildOperatorButton('×', primaryIndigo, Icons.close),
                    _buildOperatorButton('÷', Colors.red.shade700, Icons.percent),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // --- Tombol Clear ---
                _buildClearButton(),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}