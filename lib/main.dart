
import 'package:flutter/material.dart';

void main() {
  runApp(const FinTrackApp());
}

class FinTrackApp extends StatefulWidget {
  const FinTrackApp({super.key});

  @override
  State<FinTrackApp> createState() => _FinTrackAppState();
}

class _FinTrackAppState extends State<FinTrackApp> {
  bool isEnglish = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FinTrack Pro',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF087F5B),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: HomePage(
        isEnglish: isEnglish,
        onLanguageChanged: (value) {
          setState(() => isEnglish = value);
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final bool isEnglish;
  final ValueChanged<bool> onLanguageChanged;

  const HomePage({
    super.key,
    required this.isEnglish,
    required this.onLanguageChanged,
  });

  String t(String en, String ml) => isEnglish ? en : ml;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF102B46),
        foregroundColor: Colors.white,
        title: const Text(
          'FinTrack Pro',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => onLanguageChanged(!isEnglish),
            child: Text(
              isEnglish ? 'മലയാളം' : 'English',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t('Welcome!', 'സ്വാഗതം!'),
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(t('Your financial overview',
                'നിങ്ങളുടെ സാമ്പത്തിക വിവരങ്ങൾ')),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF102B46),
                    Color(0xFF087F5B),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('Total Balance', 'ആകെ ബാലൻസ്'),
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '₹ 0.00',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      _summary(
                        t('Income', 'വരവ്'),
                        '₹ 0.00',
                        Icons.trending_up,
                      ),
                      _summary(
                        t('Expense', 'ചിലവ്'),
                        '₹ 0.00',
                        Icons.trending_down,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Text(
              t('Manage Accounts', 'അക്കൗണ്ടുകൾ'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _accountCard(
              context,
              Icons.person,
              t('Personal', 'വ്യക്തിഗതം'),
              t('Personal income and expenses',
                  'വ്യക്തിഗത വരവ് ചിലവുകൾ'),
              Colors.blue,
            ),
            _accountCard(
              context,
              Icons.people,
              t('Family', 'കുടുംബം'),
              t('Family income and expenses',
                  'കുടുംബ വരവ് ചിലവുകൾ'),
              Colors.orange,
            ),
            _accountCard(
              context,
              Icons.business,
              t('Business', 'ബിസിനസ്'),
              t('Business and project accounts',
                  'ബിസിനസ് പ്രോജക്ട് കണക്കുകൾ'),
              Colors.green,
            ),
            const SizedBox(height: 20),
            Text(
              t('Quick Access', 'വേഗത്തിലുള്ള സേവനങ്ങൾ'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _quickItem(
                  Icons.add_circle,
                  t('Add Income', 'വരവ് ചേർക്കുക'),
                ),
                _quickItem(
                  Icons.remove_circle,
                  t('Add Expense', 'ചിലവ് ചേർക്കുക'),
                ),
                _quickItem(
                  Icons.bar_chart,
                  t('Reports', 'റിപ്പോർട്ടുകൾ'),
                ),
                _quickItem(
                  Icons.backup,
                  t('Backup', 'ബാക്കപ്പ്'),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Center(
              child: Text(
                'FinTrack Pro',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summary(String title, String amount, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 5),
            Text(title,
                style: const TextStyle(color: Colors.white)),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          amount,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ],
    );
  }

  Widget _accountCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Widget _quickItem(IconData icon, String title) {
    return Container(
      width: 145,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: const Color(0xFF087F5B)),
          const SizedBox(height: 7),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
