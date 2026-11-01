import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FinanceDatabase.instance.database;
  appLanguage.value = await FinanceDatabase.instance.getSetting('language') ?? 'en';
  runApp(const FinTrackApp());
}

const navy = Color(0xFF102B46);
const green = Color(0xFF087F5B);
const pageBg = Color(0xFFF4F6F9);
final ValueNotifier<String> appLanguage = ValueNotifier<String>('en');
String t(String en) {
  if (appLanguage.value != 'ml') return en;
  return _ml[en] ?? en;
}
const Map<String, String> _ml = {
  'Welcome!':'സ്വാഗതം!', 'Your financial overview':'നിങ്ങളുടെ സാമ്പത്തിക വിവരങ്ങൾ',
  'Manage Accounts':'അക്കൗണ്ടുകൾ', 'Personal':'വ്യക്തിഗതം', 'Family':'കുടുംബം', 'Business':'ബിസിനസ്',
  'Personal income and expenses':'വ്യക്തിഗത വരവും ചെലവും', 'Family income and expenses':'കുടുംബ വരവും ചെലവും', 'Business and project accounts':'ബിസിനസ്, പ്രോജക്റ്റ് അക്കൗണ്ടുകൾ',
  'Quick Access':'വേഗത്തിലുള്ള പ്രവർത്തനങ്ങൾ', 'Add Income':'വരവ് ചേർക്കുക', 'Add Expense':'ചെലവ് ചേർക്കുക',
  'Reports':'റിപ്പോർട്ടുകൾ', 'Projects':'പ്രോജക്റ്റുകൾ', 'Financial Reports':'സാമ്പത്തിക റിപ്പോർട്ടുകൾ',
  'Amount':'തുക', 'Description / Notes':'വിവരണം', 'Date':'തീയതി', 'Save Transaction':'ഇടപാട് സേവ് ചെയ്യുക',
  'Saving...':'സേവ് ചെയ്യുന്നു...', 'Edit Transaction':'ഇടപാട് തിരുത്തുക', 'Transaction History':'ഇടപാട് ചരിത്രം',
  'No transactions yet.':'ഇതുവരെ ഇടപാടുകളില്ല.', 'Current Balance':'നിലവിലെ ബാലൻസ്', 'Income':'വരവ്', 'Expense':'ചെലവ്',
  'Account':'അക്കൗണ്ട്', 'All Accounts':'എല്ലാ അക്കൗണ്ടുകളും', 'From':'മുതൽ', 'To':'വരെ',
  'Total Income':'ആകെ വരവ്', 'Total Expense':'ആകെ ചെലവ്', 'Net Balance':'അറ്റ ബാലൻസ്',
  'Transactions in selected period':'തിരഞ്ഞെടുത്ത കാലയളവിലെ ഇടപാടുകൾ', 'No transactions for this period.':'ഈ കാലയളവിൽ ഇടപാടുകളില്ല.',
  'Project Budget':'പ്രോജക്റ്റ് ബജറ്റ്', 'Total Received':'ആകെ ലഭിച്ചത്', 'Total Expenses':'ആകെ ചെലവ്',
  'Balance to Receive':'ലഭിക്കാനുള്ള തുക', 'Net Cash Flow':'അറ്റ പണമൊഴുക്ക്', 'Project Transactions':'പ്രോജക്റ്റ് ഇടപാടുകൾ',
  'No transactions for this project yet.':'ഈ പ്രോജക്റ്റിൽ ഇടപാടുകളില്ല.', 'Add Project':'പ്രോജക്റ്റ് ചേർക്കുക',
  'New Project':'പുതിയ പ്രോജക്റ്റ്', 'Project name':'പ്രോജക്റ്റിന്റെ പേര്', 'Customer / Client':'ഉപഭോക്താവ്',
  'Budget':'ബജറ്റ്', 'Cancel':'റദ്ദാക്കുക', 'Save':'സേവ് ചെയ്യുക', 'Delete':'ഡിലീറ്റ്',
  'Delete transaction?':'ഇടപാട് ഡിലീറ്റ് ചെയ്യണോ?', 'This transaction will be permanently deleted.':'ഈ ഇടപാട് സ്ഥിരമായി നീക്കം ചെയ്യപ്പെടും.',
  'Delete project?':'പ്രോജക്റ്റ് ഡിലീറ്റ് ചെയ്യണോ?', 'Language':'ഭാഷ', 'English':'ഇംഗ്ലീഷ്', 'Malayalam':'മലയാളം',
  'Select account':'അക്കൗണ്ട് തിരഞ്ഞെടുക്കുക', 'Enter a valid amount':'ശരിയായ തുക നൽകുക',
  'Project (optional)':'പ്രോജക്റ്റ് (ഐച്ഛികം)', 'No project':'പ്രോജക്റ്റ് ഇല്ല',
  'Personal Balance':'വ്യക്തിഗത ബാലൻസ്', 'Family Balance':'കുടുംബ ബാലൻസ്', 'Business Balance':'ബിസിനസ് ബാലൻസ്',
  'Category':'വിഭാഗം', 'Project Report (optional)':'പ്രോജക്റ്റ് റിപ്പോർട്ട് (ഐച്ഛികം)',
  'All Projects / Accounts':'എല്ലാ പ്രോജക്റ്റുകളും അക്കൗണ്ടുകളും', 'No projects yet. Tap Add Project to begin.':'പ്രോജക്റ്റുകളില്ല. ആരംഭിക്കാൻ പ്രോജക്റ്റ് ചേർക്കുക.',
  'Edit / Delete':'തിരുത്തുക / ഡിലീറ്റ്', 'Date:':'തീയതി:', 'From:':'മുതൽ:', 'To:':'വരെ:',
  'Salary':'ശമ്പളം', 'Sales':'വിൽപ്പന', 'Service':'സേവനം', 'Interest':'പലിശ', 'Food':'ഭക്ഷണം',
  'Travel':'യാത്ര', 'Rent':'വാടക', 'Materials':'സാധനങ്ങൾ', 'Bills':'ബില്ലുകൾ', 'Other':'മറ്റുള്ളവ',
  'Business Account':'ബിസിനസ് അക്കൗണ്ട്', 'Personal Account':'വ്യക്തിഗത അക്കൗണ്ട്', 'Family Account':'കുടുംബ അക്കൗണ്ട്',
  'Add Project':'പ്രോജക്റ്റ് ചേർക്കുക', 'Customer / Client':'ഉപഭോക്താവ്', 'No projects yet. Tap Add Project to begin.':'പ്രോജക്റ്റുകളില്ല. ആരംഭിക്കാൻ പ്രോജക്റ്റ് ചേർക്കുക.',
  'Transactions linked to this project will remain in the database.':'ഈ പ്രോജക്റ്റുമായി ബന്ധിപ്പിച്ച ഇടപാടുകൾ ഡാറ്റാബേസിൽ തുടരും.',
  'Project Report (optional)':'പ്രോജക്റ്റ് റിപ്പോർട്ട് (ഐച്ഛികം)', 'All Projects / Accounts':'എല്ലാ പ്രോജക്റ്റുകളും അക്കൗണ്ടുകളും',
  'Edit / Delete':'തിരുത്തുക / ഡിലീറ്റ്', 'Language':'ഭാഷ', 'English':'ഇംഗ്ലീഷ്', 'Malayalam':'മലയാളം',
  'Select account':'അക്കൗണ്ട് തിരഞ്ഞെടുക്കുക', 'Welcome!':'സ്വാഗതം!', 'Current Balance':'നിലവിലെ ബാലൻസ്',
  'Delete':'ഡിലീറ്റ്', 'Transactions linked to this project will remain in the database.':'ഈ പ്രോജക്റ്റുമായി ബന്ധിപ്പിച്ച ഇടപാടുകൾ ഡാറ്റാബേസിൽ തുടരും.',
};

class FinanceDatabase {
  FinanceDatabase._();
  static final FinanceDatabase instance = FinanceDatabase._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = await getDatabasesPath();
    final dbFile = p.join(dbPath, 'fintrack_pro.db');
    _database = await openDatabase(
      dbFile,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          scope TEXT NOT NULL,
          type TEXT NOT NULL,
          amount REAL NOT NULL,
          category TEXT NOT NULL,
          note TEXT,
          date TEXT NOT NULL,
          project_id INTEGER
        )''');
        await db.execute('''CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT NOT NULL)''');
        await db.execute('''CREATE TABLE projects (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          customer TEXT,
          budget REAL DEFAULT 0,
          start_date TEXT
        )''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) { await db.execute('CREATE TABLE IF NOT EXISTS settings (key TEXT PRIMARY KEY, value TEXT NOT NULL)'); }
      },
    );
    return _database!;
  }

  Future<String?> getSetting(String key) async {
    final rows = await (await database).query('settings', columns: ['value'], where: 'key = ?', whereArgs: [key], limit: 1);
    return rows.isEmpty ? null : rows.first['value'] as String;
  }
  Future<void> setSetting(String key, String value) async => (await database).insert('settings', {'key': key, 'value': value}, conflictAlgorithm: ConflictAlgorithm.replace);

  Future<int> addTransaction(Map<String, dynamic> data) async =>
      (await database).insert('transactions', data);

  Future<int> updateTransaction(int id, Map<String, dynamic> data) async =>
      (await database).update('transactions', data, where: 'id = ?', whereArgs: [id]);

  Future<int> deleteTransaction(int id) async =>
      (await database).delete('transactions', where: 'id = ?', whereArgs: [id]);

  Future<List<Map<String, dynamic>>> getTransactions({String? scope, DateTime? from, DateTime? to, int? projectId}) async {
    final clauses = <String>[];
    final args = <Object?>[];
    if (scope != null) { clauses.add('t.scope = ?'); args.add(scope); }
    if (projectId != null) { clauses.add('t.project_id = ?'); args.add(projectId); }
    if (from != null) { clauses.add('t.date >= ?'); args.add(DateTime(from.year, from.month, from.day).toIso8601String()); }
    if (to != null) { clauses.add('t.date < ?'); args.add(DateTime(to.year, to.month, to.day).add(const Duration(days: 1)).toIso8601String()); }
    return (await database).rawQuery('''
      SELECT t.*, p.name AS project_name
      FROM transactions t
      LEFT JOIN projects p ON p.id = t.project_id
      ${clauses.isEmpty ? '' : 'WHERE ${clauses.join(' AND ')}'}
      ORDER BY t.date DESC, t.id DESC
    ''', args);
  }

  Future<Map<String, double>> getSummary({String? scope, DateTime? from, DateTime? to, int? projectId}) async {
    final db = await database;
    final clauses = <String>[];
    final args = <Object?>[];
    if (scope != null) { clauses.add('scope = ?'); args.add(scope); }
    if (projectId != null) { clauses.add('project_id = ?'); args.add(projectId); }
    if (from != null) { clauses.add('date >= ?'); args.add(DateTime(from.year, from.month, from.day).toIso8601String()); }
    if (to != null) { clauses.add('date < ?'); args.add(DateTime(to.year, to.month, to.day).add(const Duration(days: 1)).toIso8601String()); }
    final rows = await db.rawQuery('''SELECT
      COALESCE(SUM(CASE WHEN type='income' THEN amount ELSE 0 END),0) AS income,
      COALESCE(SUM(CASE WHEN type='expense' THEN amount ELSE 0 END),0) AS expense
      FROM transactions ${clauses.isEmpty ? '' : 'WHERE ${clauses.join(' AND ')}'}''', args);
    final row = rows.first;
    final income = (row['income'] as num).toDouble();
    final expense = (row['expense'] as num).toDouble();
    return {'income': income, 'expense': expense, 'balance': income - expense};
  }

  Future<Map<String, double>> getProjectSummary(int projectId) async {
    final rows = await (await database).rawQuery('''
      SELECT
        COALESCE(SUM(CASE WHEN type='income' THEN amount ELSE 0 END),0) AS income,
        COALESCE(SUM(CASE WHEN type='expense' THEN amount ELSE 0 END),0) AS expense
      FROM transactions WHERE project_id = ?
    ''', [projectId]);
    final income = (rows.first['income'] as num).toDouble();
    final expense = (rows.first['expense'] as num).toDouble();
    return {'income': income, 'expense': expense, 'balance': income - expense};
  }

  Future<List<Map<String, dynamic>>> getProjects() async =>
      (await database).query('projects', orderBy: 'name COLLATE NOCASE');

  Future<int> addProject(Map<String, dynamic> data) async =>
      (await database).insert('projects', data);

  Future<int> deleteProject(int id) async =>
      (await database).delete('projects', where: 'id = ?', whereArgs: [id]);
}

class FinTrackApp extends StatelessWidget {
  const FinTrackApp({super.key});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String>(
    valueListenable: appLanguage,
    builder: (context, language, _) => MaterialApp(
      title: 'FinTrack Pro', debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: green), scaffoldBackgroundColor: pageBg,
        appBarTheme: const AppBarTheme(backgroundColor: navy, foregroundColor: Colors.white, centerTitle: false)),
      home: const HomePage(),
    ),
  );
}

String money(num? value) => NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2).format(value ?? 0);
String dateLabel(String? raw) {
  if (raw == null || raw.isEmpty) return '-';
  final parsed = DateTime.tryParse(raw);
  return parsed == null ? raw : DateFormat('dd-MM-yyyy').format(parsed);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  final db = FinanceDatabase.instance;
  final accounts = const [
    ('Personal', 'Personal income and expenses', Icons.person, Colors.blue),
    ('Family', 'Family income and expenses', Icons.groups, Colors.orange),
    ('Business', 'Business and project accounts', Icons.business, green),
  ];
  Future<void> openAccount(String name) async { await Navigator.push(context, MaterialPageRoute(builder: (_) => AccountPage(scope: name))); if (mounted) setState(() {}); }
  Future<void> quickEntry(String type) async {
    final scope = await showDialog<String>(context: context, builder: (_) => SimpleDialog(title: Text(t('Select account')), children: accounts.map((a) => SimpleDialogOption(onPressed: () => Navigator.pop(context, a.$1), child: Text(t(a.$1)))).toList()));
    if (!mounted || scope == null) return;
    final saved = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => EntryPage(scope: scope, type: type)));
    if (saved == true && mounted) setState(() {});
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('FinTrack Pro', style: TextStyle(fontWeight: FontWeight.bold)), actions: [IconButton(tooltip: 'Reports', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsPage())), icon: const Icon(Icons.analytics_outlined)), IconButton(tooltip: 'Projects', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectsPage())), icon: const Icon(Icons.folder_open)), PopupMenuButton<String>(tooltip: 'Language', onSelected: (v) async { appLanguage.value = v; await db.setSetting('language', v); if (mounted) setState(() {}); }, itemBuilder: (_) => [PopupMenuItem(value: 'en', child: Text(t('English'))), PopupMenuItem(value: 'ml', child: Text(t('Malayalam')))], icon: const Icon(Icons.language))]),
    body: Builder(builder: (context) {
      return ListView(padding: const EdgeInsets.all(16), children: [
        Text(t('Welcome!'), style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4), Text(t('Your financial overview'), style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 16),
        ...accounts.map((a) => FutureBuilder<Map<String,double>>(future: db.getSummary(scope: a.$1), builder: (context, balance) { final amount = balance.data?['balance'] ?? 0.0; return Card(child: ListTile(leading: Icon(a.$3, color: a.$4), title: Text(t('${a.$1} Balance')), trailing: Text(money(amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))); })),
        const SizedBox(height: 24), Text(t('Manage Accounts'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
        ...accounts.map((a) => Card(child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7), leading: CircleAvatar(backgroundColor: a.$4.withValues(alpha: .12), child: Icon(a.$3, color: a.$4)), title: Text(t(a.$1), style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(t(a.$2)), trailing: const Icon(Icons.chevron_right), onTap: () => openAccount(a.$1)))),
        const SizedBox(height: 14), Text(t('Quick Access'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
        Row(children: [Expanded(child: _quickCard(t('Add Income'), Icons.add_circle, green, () => quickEntry('income'))), const SizedBox(width: 10), Expanded(child: _quickCard(t('Add Expense'), Icons.remove_circle, Colors.red, () => quickEntry('expense')))]),
        const SizedBox(height: 10), Row(children: [Expanded(child: _quickCard(t('Reports'), Icons.bar_chart, navy, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsPage())))), const SizedBox(width: 10), Expanded(child: _quickCard(t('Projects'), Icons.folder, Colors.deepOrange, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectsPage()))))]),
        const SizedBox(height: 18), Center(child: Text('FinTrack Pro • Personal, Family & Business', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)))
      ]);
    }),
  );
  Widget _summaryLabel(String title, double amount, IconData icon) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, color: Colors.white70, size: 17), const SizedBox(width: 5), Text(title, style: const TextStyle(color: Colors.white70))]), const SizedBox(height: 5), Text(money(amount), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]);
  Widget _quickCard(String title, IconData icon, Color color, VoidCallback onTap) => Card(child: InkWell(borderRadius: BorderRadius.circular(16), onTap: onTap, child: Padding(padding: const EdgeInsets.symmetric(vertical: 18), child: Column(children: [Icon(icon, color: color, size: 29), const SizedBox(height: 7), Text(title, style: const TextStyle(fontWeight: FontWeight.w600))]))));
}

class AccountPage extends StatefulWidget {
  final String scope;
  const AccountPage({super.key, required this.scope});
  @override
  State<AccountPage> createState() => _AccountPageState();
}
class _AccountPageState extends State<AccountPage> {
  final db = FinanceDatabase.instance;
  Future<void> add(String type) async { final result = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => EntryPage(scope: widget.scope, type: type))); if (result == true && mounted) setState(() {}); }
  Future<void> edit(Map<String,dynamic> row) async { final result = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => EntryPage(scope: widget.scope, type: row['type'] as String, record: row))); if (result == true && mounted) setState(() {}); }
  Future<void> remove(Map<String,dynamic> row) async {
    final yes = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: Text(t('Delete transaction?')), content: Text(t('This transaction will be permanently deleted.')), actions: [TextButton(onPressed: () => Navigator.pop(context,false), child: Text(t('Cancel'))), FilledButton(onPressed: () => Navigator.pop(context,true), child: Text(t('Delete')))]));
    if (yes == true) { await db.deleteTransaction(row['id'] as int); if (mounted) setState(() {}); }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${t(widget.scope)} Account')),
      body: FutureBuilder<Map<String, double>>(
        future: db.getSummary(scope: widget.scope),
        builder: (context, summary) {
          final d = summary.data ?? {'income': 0.0, 'expense': 0.0, 'balance': 0.0};
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(18)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t('Current Balance'), style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Text(money(d['balance']), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    Row(children: [
                      Expanded(child: Text('${t('Income')}: ${money(d['income'])}', style: const TextStyle(color: Colors.white))),
                      Expanded(child: Text('${t('Expense')}: ${money(d['expense'])}', style: const TextStyle(color: Colors.white))),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: FilledButton.icon(onPressed: () => add('income'), icon: const Icon(Icons.add), label: Text(t('Income')))),
                const SizedBox(width: 10),
                Expanded(child: FilledButton.tonalIcon(onPressed: () => add('expense'), icon: const Icon(Icons.remove), label: Text(t('Expense')))),
              ]),
              const SizedBox(height: 20),
              Text(t('Transaction History'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: db.getTransactions(scope: widget.scope),
                builder: (context, history) {
                  if (!history.hasData) return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                  final rows = history.data!;
                  if (rows.isEmpty) return Padding(padding: const EdgeInsets.all(24), child: Text(t('No transactions yet.'), textAlign: TextAlign.center));
                  return Column(children: rows.map((r) {
                    final income = r['type'] == 'income';
                    return Card(child: ListTile(
                      leading: CircleAvatar(backgroundColor: (income ? green : Colors.red).withValues(alpha: .1), child: Icon(income ? Icons.south_west : Icons.north_east, color: income ? green : Colors.red)),
                      title: Text((r['project_name'] ?? r['category']).toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${r['project_name'] == null ? '' : '${r['category']} • '}${dateLabel(r['date'] as String?)}${(r['note'] ?? '').toString().isEmpty ? '' : ' • ${r['note']}'}'),
                      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('${income ? '+' : '-'}${money(r['amount'] as num)}', style: TextStyle(color: income ? green : Colors.red, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 3),
                        Text(t('Edit / Delete'), style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ]),
                      onTap: () => edit(r),
                      onLongPress: () => remove(r),
                    ));
                  }).toList());
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
  final String scope, type;
  final Map<String,dynamic>? record;
  final int? initialProjectId;
  const EntryPage({super.key, required this.scope, required this.type, this.record, this.initialProjectId});
  @override
  State<EntryPage> createState() => _EntryPageState();
}
class _EntryPageState extends State<EntryPage> {
  final amount = TextEditingController();
  final note = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String category = 'Other';
  int? projectId;
  bool saving = false;
  final incomeCategories = const ['Salary','Sales','Service','Interest','Other'];
  final expenseCategories = const ['Food','Travel','Rent','Salary','Materials','Bills','Other'];
  bool get isIncome => widget.type == 'income';
  bool get projectMode => widget.initialProjectId != null || (widget.record?['project_id'] != null);
  @override
  void initState() { super.initState(); projectId = widget.initialProjectId; final r = widget.record; if (r != null) { amount.text = (r['amount'] as num).toString(); note.text = (r['note'] ?? '').toString(); category = r['category'] as String; selectedDate = DateTime.tryParse(r['date'] as String) ?? DateTime.now(); projectId = r['project_id'] as int?; } }
  @override
  void dispose() { amount.dispose(); note.dispose(); super.dispose(); }
  Future<void> save() async {
    final value = double.tryParse(amount.text.trim());
    if (value == null || value <= 0) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('Enter a valid amount')))); return; }
    setState(() => saving = true);
    final data = {'scope': widget.scope, 'type': widget.type, 'amount': value, 'category': projectMode ? category : 'Other', 'note': note.text.trim(), 'date': selectedDate.toIso8601String(), 'project_id': projectMode ? projectId : null};
    try { if (widget.record == null) { await FinanceDatabase.instance.addTransaction(data); } else { await FinanceDatabase.instance.updateTransaction(widget.record!['id'] as int, data); } if (mounted) Navigator.pop(context,true); }
    catch (e) { if (mounted) { setState(() => saving = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e'))); } }
  }
  @override
  Widget build(BuildContext context) { final cats = isIncome ? incomeCategories : expenseCategories; return Scaffold(appBar: AppBar(title: Text(t(widget.record == null ? (isIncome ? 'Add Income' : 'Add Expense') : 'Edit Transaction'))), body: ListView(padding: const EdgeInsets.all(18), children: [Text('${t(widget.scope)} Account', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 18), TextField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: t('Amount'), prefixText: '₹ ', border: const OutlineInputBorder())), const SizedBox(height: 14), if (projectMode) ...[DropdownButtonFormField<String>(initialValue: cats.contains(category) ? category : 'Other', decoration: InputDecoration(labelText: t('Category'), border: const OutlineInputBorder()), items: cats.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) { if (v != null) setState(() => category = v); }), const SizedBox(height: 14)], TextField(controller: note, maxLines: 2, decoration: InputDecoration(labelText: t('Description / Notes'), border: const OutlineInputBorder())), const SizedBox(height: 14), OutlinedButton.icon(onPressed: () async { final d = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2100)); if (d != null) setState(() => selectedDate = d); }, icon: const Icon(Icons.calendar_month), label: Text('${t('Date')}: ${DateFormat('dd-MM-yyyy').format(selectedDate)}')), const SizedBox(height: 22), FilledButton.icon(onPressed: saving ? null : save, icon: const Icon(Icons.save), label: Text(saving ? t('Saving...') : t('Save Transaction')))])); }
}

class ReportsPage extends StatefulWidget { const ReportsPage({super.key}); @override State<ReportsPage> createState() => _ReportsPageState(); }
class _ReportsPageState extends State<ReportsPage> {
  DateTime from = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime to = DateTime.now();
  String scope = 'All Accounts';
  int? selectedProjectId;
  List<Map<String,dynamic>> projects = [];
  @override void initState() { super.initState(); FinanceDatabase.instance.getProjects().then((v) { if (mounted) setState(() => projects = v); }); }
  Future<void> pick(bool start) async { final d = await showDatePicker(context: context, initialDate: start ? from : to, firstDate: DateTime(2000), lastDate: DateTime(2100)); if (d != null) setState(() { if (start) { from = d; } else { to = d; } }); }
  @override
  Widget build(BuildContext context) {
    final selectedScope = scope == 'All Accounts' ? null : scope;
    return Scaffold(
      appBar: AppBar(title: Text(t('Financial Reports'))),
      body: FutureBuilder<Map<String, double>>(
        future: FinanceDatabase.instance.getSummary(scope: selectedProjectId == null ? selectedScope : null, projectId: selectedProjectId, from: from, to: to),
        builder: (context, snap) {
          final d = snap.data ?? {'income': 0.0, 'expense': 0.0, 'balance': 0.0};
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<String>(
                initialValue: scope,
                decoration: const InputDecoration(labelText: 'Account', border: OutlineInputBorder()),
                items: ['All Accounts', 'Personal', 'Family', 'Business'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                onChanged: (v) => setState(() => scope = v ?? 'All Accounts'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(initialValue: selectedProjectId, decoration: InputDecoration(labelText: t('Project Report (optional)'), border: const OutlineInputBorder()), items: [const DropdownMenuItem<int?>(value: null, child: Text('All Projects / Accounts')), ...projects.map((p) => DropdownMenuItem<int?>(value: p['id'] as int, child: Text(p['name'] as String)))], onChanged: (v) => setState(() => selectedProjectId = v)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: OutlinedButton(onPressed: () => pick(true), child: Text('From: ${DateFormat('dd-MM-yyyy').format(from)}'))),
                const SizedBox(width: 8),
                Expanded(child: OutlinedButton(onPressed: () => pick(false), child: Text('To: ${DateFormat('dd-MM-yyyy').format(to)}'))),
              ]),
              const SizedBox(height: 16),
              _reportTile('Total Income', d['income']!, green, Icons.trending_up),
              _reportTile('Total Expense', d['expense']!, Colors.red, Icons.trending_down),
              _reportTile('Net Balance', d['balance']!, navy, Icons.account_balance_wallet),
              const SizedBox(height: 18),
              Text(t('Transactions in selected period'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: FinanceDatabase.instance.getTransactions(scope: selectedProjectId == null ? selectedScope : null, projectId: selectedProjectId, from: from, to: to),
                builder: (context, rows) {
                  if (!rows.hasData) return const Center(child: CircularProgressIndicator());
                  if (rows.data!.isEmpty) return Padding(padding: const EdgeInsets.all(20), child: Text(t('No transactions for this period.')));
                  return Column(children: rows.data!.map((r) {
                    final inc = r['type'] == 'income';
                    return Card(child: ListTile(
                      title: Text('${r['scope']} • ${(r['project_name'] ?? r['category']).toString()}'),
                      subtitle: Text('${r['project_name'] == null ? '' : '${r['category']} • '}${dateLabel(r['date'] as String?)}'),
                      trailing: Text('${inc ? '+' : '-'}${money(r['amount'] as num)}', style: TextStyle(color: inc ? green : Colors.red, fontWeight: FontWeight.bold)),
                    ));
                  }).toList());
                },
              ),
            ],
          );
        },
      ),
    );
  }
  Widget _reportTile(String title, double value, Color color, IconData icon) => Card(child: ListTile(leading: CircleAvatar(backgroundColor: color.withValues(alpha: .1), child: Icon(icon,color:color)), title: Text(title), trailing: Text(money(value), style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16))));
}

class ProjectDetailsPage extends StatefulWidget {
  final Map<String, dynamic> project;
  const ProjectDetailsPage({super.key, required this.project});
  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  Future<void> add(String type) async {
    final saved = await Navigator.push<bool>(context, MaterialPageRoute(
      builder: (_) => EntryPage(scope: 'Business', type: type, initialProjectId: widget.project['id'] as int),
    ));
    if (saved == true && mounted) setState(() {});
  }

  Future<void> edit(Map<String, dynamic> row) async {
    final saved = await Navigator.push<bool>(context, MaterialPageRoute(
      builder: (_) => EntryPage(scope: row['scope'] as String, type: row['type'] as String, record: row),
    ));
    if (saved == true && mounted) setState(() {});
  }

  Future<void> delete(Map<String, dynamic> row) async {
    final yes = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: Text(t('Delete transaction?')),
      content: Text(t('This transaction will be permanently deleted.')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t('Cancel'))),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(t('Delete'))),
      ],
    ));
    if (yes == true) {
      await FinanceDatabase.instance.deleteTransaction(row['id'] as int);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final projectId = project['id'] as int;
    final budget = (project['budget'] as num?)?.toDouble() ?? 0;
    return Scaffold(
      appBar: AppBar(title: Text(project['name'] as String)),
      body: FutureBuilder<Map<String, double>>(
        future: FinanceDatabase.instance.getProjectSummary(projectId),
        builder: (context, summary) {
          final d = summary.data ?? {'income': 0.0, 'expense': 0.0, 'balance': 0.0};
          final received = d['income']!;
          final expense = d['expense']!;
          final receivable = budget - received;
          return ListView(padding: const EdgeInsets.all(16), children: [
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text((project['customer'] ?? '').toString(), style: TextStyle(color: Colors.grey.shade700)),
              const SizedBox(height: 14),
              _projectMetric('Project Budget', money(budget)),
              _projectMetric('Total Received', money(received), color: green),
              _projectMetric('Total Expenses', money(expense), color: Colors.red),
              _projectMetric('Balance to Receive', money(receivable), color: receivable > 0 ? Colors.orange.shade800 : green),
              const Divider(height: 24),
              _projectMetric('Net Cash Flow', money(d['balance']), color: d['balance']! >= 0 ? green : Colors.red),
            ]))),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: FilledButton.icon(onPressed: () => add('income'), icon: const Icon(Icons.add), label: Text(t('Add Income')))),
              const SizedBox(width: 10),
              Expanded(child: FilledButton.tonalIcon(onPressed: () => add('expense'), icon: const Icon(Icons.remove), label: Text(t('Add Expense')))),
            ]),
            const SizedBox(height: 20),
            Text(t('Project Transactions'), style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: FinanceDatabase.instance.getTransactions(projectId: projectId),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final rows = snap.data!;
                if (rows.isEmpty) return Padding(padding: const EdgeInsets.all(20), child: Text(t('No transactions for this project yet.')));
                return Column(children: rows.map((r) {
                  final isIncome = r['type'] == 'income';
                  return Card(child: ListTile(
                    leading: CircleAvatar(backgroundColor: (isIncome ? green : Colors.red).withValues(alpha: .1),
                      child: Icon(isIncome ? Icons.south_west : Icons.north_east, color: isIncome ? green : Colors.red)),
                    title: Text((r['category'] ?? (isIncome ? 'Income' : 'Expense')).toString()),
                    subtitle: Text('${dateLabel(r['date'] as String?)}${(r['note'] ?? '').toString().isEmpty ? '' : ' • ${r['note']}'}'),
                    trailing: Text('${isIncome ? '+' : '-'}${money(r['amount'] as num)}',
                      style: TextStyle(color: isIncome ? green : Colors.red, fontWeight: FontWeight.bold)),
                    onTap: () => edit(r),
                    onLongPress: () => delete(r),
                  ));
                }).toList());
              },
            ),
          ]);
        },
      ),
    );
  }

  Widget _projectMetric(String title, String value, {Color? color}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [Expanded(child: Text(title)), Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color))]),
  );
}

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});
  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final name = TextEditingController();
  final customer = TextEditingController();
  final budget = TextEditingController();

  @override
  void dispose() {
    name.dispose();
    customer.dispose();
    budget.dispose();
    super.dispose();
  }

  Future<void> addProject() async {
    name.clear(); customer.clear(); budget.clear();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('New Project')),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Project name')),
          TextField(controller: customer, decoration: const InputDecoration(labelText: 'Customer / Client')),
          TextField(controller: budget, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Budget', prefixText: '₹ ')),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t('Cancel'))),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t('Save'))),
        ],
      ),
    );
    if (ok == true && name.text.trim().isNotEmpty) {
      await FinanceDatabase.instance.addProject({
        'name': name.text.trim(), 'customer': customer.text.trim(),
        'budget': double.tryParse(budget.text.trim()) ?? 0,
        'start_date': DateTime.now().toIso8601String(),
      });
      if (mounted) setState(() {});
    }
  }

  Future<void> deleteProject(int id) async {
    final yes = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: Text(t('Delete project?')),
      content: const Text('Transactions linked to this project will remain in the database.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t('Cancel'))),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t('Delete'))),
      ],
    ));
    if (yes == true) {
      await FinanceDatabase.instance.deleteProject(id);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(t('Projects'))),
    floatingActionButton: FloatingActionButton.extended(onPressed: addProject, icon: const Icon(Icons.add), label: Text(t('Add Project'))),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: FinanceDatabase.instance.getProjects(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final rows = snap.data!;
        if (rows.isEmpty) return const Center(child: Text('No projects yet. Tap Add Project to begin.'));
        return ListView(padding: const EdgeInsets.all(16), children: rows.map((r) => Card(child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.folder)),
          title: Text(r['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${(r['customer'] ?? '').toString()}\nBudget: ${money(r['budget'] as num?)}'),
          isThreeLine: true,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectDetailsPage(project: r))).then((_) { if (mounted) setState(() {}); }),
          trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => deleteProject(r['id'] as int)),
        ))).toList());
      },
    ),
  );
}
