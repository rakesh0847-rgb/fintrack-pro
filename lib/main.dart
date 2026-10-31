
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FinanceDatabase.instance.database;
  runApp(const FinTrackApp());
}

class FinanceDatabase {
  FinanceDatabase._();
  static final FinanceDatabase instance = FinanceDatabase._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'fintrack_pro.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            scope TEXT NOT NULL,
            type TEXT NOT NULL,
            amount REAL NOT NULL,
            category TEXT NOT NULL,
            note TEXT,
            date TEXT NOT NULL,
            project_id INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE projects (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            customer TEXT,
            budget REAL DEFAULT 0,
            start_date TEXT
          )
        ''');
      },
    );

    return _database!;
  }

  Future<int> addTransaction(Map<String, dynamic> data) async {
    final db = await database;
    return db.insert('transactions', data);
  }

  Future<List<Map<String, dynamic>>> getTransactions(
    String? scope,
  ) async {
    final db = await database;

    if (scope == null) {
      return db.query('transactions', orderBy: 'date DESC, id DESC');
    }

    return db.query(
      'transactions',
      where: 'scope = ?',
      whereArgs: [scope],
      orderBy: 'date DESC, id DESC',
    );
  }

  Future<Map<String, double>> getSummary(String? scope) async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT
        COALESCE(SUM(CASE WHEN type = 'income'
          THEN amount ELSE 0 END), 0) AS income,
        COALESCE(SUM(CASE WHEN type = 'expense'
          THEN amount ELSE 0 END), 0) AS expense
      FROM transactions
      ${scope == null ? '' : 'WHERE scope = ?'}
    ''', scope == null ? [] : [scope]);

    final row = result.first;

    final income = (row['income'] as num).toDouble();
    final expense = (row['expense'] as num).toDouble();

    return {
      'income': income,
      'expense': expense,
      'balance': income - expense,
    };
  }
}

class FinTrackApp extends StatelessWidget {
  const FinTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinTrack Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF087F5B),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
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
  final db = FinanceDatabase.instance;

  final accounts = const [
    {
      'name': 'Personal',
      'subtitle': 'വ്യക്തിഗത കണക്കുകൾ',
      'icon': Icons.person,
      'color': Colors.blue,
    },
    {
      'name': 'Family',
      'subtitle': 'കുടുംബ കണക്കുകൾ',
      'icon': Icons.people,
      'color': Colors.orange,
    },
    {
      'name': 'Business',
      'subtitle': 'ബിസിനസ് കണക്കുകൾ',
      'icon': Icons.business,
      'color': Colors.green,
    },
  ];

  Future<void> openAccount(String scope) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AccountPage(scope: scope),
      ),
    );

    if (mounted) setState(() {});
  }

  String money(double value) =>
      '₹ ${value.toStringAsFixed(2)}';

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
      ),
      body: FutureBuilder<Map<String, double>>(
        future: db.getSummary(null),
        builder: (context, snapshot) {
          final data = snapshot.data ??
              {'income': 0.0, 'expense': 0.0, 'balance': 0.0};

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Welcome! / സ്വാഗതം!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              Container(
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
                    const Text(
                      'Total Balance / ആകെ ബാലൻസ്',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      money(data['balance']!),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _moneyLabel(
                          'Income / വരവ്',
                          money(data['income']!),
                        ),
                        _moneyLabel(
                          'Expense / ചിലവ്',
                          money(data['expense']!),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'Manage Accounts / അക്കൗണ്ടുകൾ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ...accounts.map((account) {
                final color = account['color'] as Color;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.12),
                      child: Icon(
                        account['icon'] as IconData,
                        color: color,
                      ),
                    ),
                    title: Text(
                      account['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(account['subtitle'] as String),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => openAccount(
                      account['name'] as String,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 18),
              const Text(
                'Quick Access / വേഗത്തിലുള്ള സേവനങ്ങൾ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _quickButton(
                      context,
                      'Add Income',
                      'വരവ് ചേർക്കുക',
                      Icons.add_circle,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _quickButton(
                      context,
                      'Add Expense',
                      'ചിലവ് ചേർക്കുക',
                      Icons.remove_circle,
                      Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'FinTrack Pro',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _moneyLabel(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _quickButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () async {
        final scope = await showDialog<String>(
          context: context,
          builder: (context) => SimpleDialog(
            title: const Text('Select Account / അക്കൗണ്ട് തിരഞ്ഞെടുക്കുക'),
            children: ['Personal', 'Family', 'Business']
                .map(
                  (name) => SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, name),
                    child: Text(name),
                  ),
                )
                .toList(),
          ),
        );

        if (!context.mounted || scope == null) return;

        final saved = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => EntryPage(
              scope: scope,
              type: title == 'Add Income' ? 'income' : 'expense',
            ),
          ),
        );

        if (saved == true && context.mounted) {
          setState(() {});
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(subtitle, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class AccountPage extends StatefulWidget {
  final String scope;

  const AccountPage({super.key, required this.scope});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final db = FinanceDatabase.instance;

  Future<void> refresh() async {
    if (mounted) setState(() {});
  }

  Future<void> addEntry(String type) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EntryPage(
          scope: widget.scope,
          type: type,
        ),
      ),
    );

    if (saved == true) refresh();
  }

  String money(dynamic value) =>
      '₹ ${(value as num).toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.scope} Account'),
      ),
      body: FutureBuilder<Map<String, double>>(
        future: db.getSummary(widget.scope),
        builder: (context, snapshot) {
          final data = snapshot.data ??
              {'income': 0.0, 'expense': 0.0, 'balance': 0.0};

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: const Color(0xFF102B46),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Balance',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        money(data['balance']),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Income: ${money(data['income'])}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Expense: ${money(data['expense'])}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => addEntry('income'),
                      icon: const Icon(Icons.add),
                      label: const Text('Income'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => addEntry('expense'),
                      icon: const Icon(Icons.remove),
                      label: const Text('Expense'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const Text(
                'Transaction History / ഇടപാടുകൾ',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: db.getTransactions(widget.scope),
                builder: (context, history) {
                  if (!history.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final records = history.data!;

                  if (records.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(25),
                      child: Text(
                        'No transactions yet / ഇടപാടുകളില്ല',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return Column(
                    children: records.map((record) {
                      final income = record['type'] == 'income';
                      final amount = record['amount'] as num;
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            income
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: income ? Colors.green : Colors.red,
                          ),
                          title: Text(record['category'] as String),
                          subtitle: Text(
                            '${record['date']} • ${record['note'] ?? ''}',
                          ),
                          trailing: Text(
                            '${income ? '+' : '-'} ${money(amount)}',
                            style: TextStyle(
                              color: income ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class EntryPage extends StatefulWidget {
  final String scope;
  final String type;

  const EntryPage({
    super.key,
    required this.scope,
    required this.type,
  });

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  String category = 'Other';
  bool saving = false;

  final incomeCategories = [
    'Salary',
    'Sales',
    'Service',
    'Interest',
    'Other',
  ];

  final expenseCategories = [
    'Food',
    'Travel',
    'Rent',
    'Salary',
    'Materials',
    'Bills',
    'Other',
  ];

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final amount = double.tryParse(amountController.text.trim());

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    setState(() => saving = true);

    try {
      await FinanceDatabase.instance.addTransaction({
        'scope': widget.scope,
        'type': widget.type,
        'amount': amount,
        'category': category,
        'note': noteController.text.trim(),
        'date': selectedDate.toIso8601String(),
        'project_id': null,
      });

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.type == 'income';
    final categories = isIncome
        ? incomeCategories
        : expenseCategories;

    return Scaffold(
      appBar: AppBar(
        title: Text(isIncome ? 'Add Income / വരവ്' : 'Add Expense / ചിലവ്'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            '${widget.scope} Account',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Amount / തുക',
              prefixText: '₹ ',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: category,
            decoration: const InputDecoration(
              labelText: 'Category / വിഭാഗം',
              border: OutlineInputBorder(),
            ),
            items: categories
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => category = value);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: noteController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Description / വിവരണം',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );

              if (date != null) {
                setState(() => selectedDate = date);
              }
            },
            icon: const Icon(Icons.calendar_month),
            label: Text(
              'Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: saving ? null : save,
            icon: const Icon(Icons.save),
            label: Text(saving ? 'Saving...' : 'Save Transaction / സേവ്'),
          ),
        ],
      ),
    );
  }
}
