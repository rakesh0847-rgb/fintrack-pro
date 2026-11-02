import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
  'Personal income and expenses':'വ്യക്തിഗത വരവും ചെലവും', 'Family income and expenses':'കുടുംബ വരവും ചെലവും', 'Business income and expenses only':'ബിസിനസിലെ മറ്റ് വരവും ചെലവും മാത്രം', 'Projects Balance':'പ്രോജക്റ്റുകളുടെ അറ്റ ബാലൻസ്',
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
  'Transactions linked to this project will remain in the database.':'ഈ പ്രോജക്റ്റുമായി ബന്ധിപ്പിച്ച ഇടപാടുകൾ ഡാറ്റാബേസിൽ തുടരും.',
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
      version: 5,
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          scope TEXT NOT NULL,
          type TEXT NOT NULL,
          amount REAL NOT NULL,
          category TEXT NOT NULL,
          note TEXT,
          date TEXT NOT NULL,
          project_id INTEGER,
          payment_mode TEXT
        )''');
        await db.execute('''CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT NOT NULL)''');
        await db.execute('''CREATE TABLE projects (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          customer TEXT,
          budget REAL DEFAULT 0,
          start_date TEXT
        )''');
        await db.execute('''CREATE TABLE invoices (
          id INTEGER PRIMARY KEY AUTOINCREMENT, number TEXT NOT NULL UNIQUE, customer TEXT NOT NULL, phone TEXT, address TEXT,
          invoice_date TEXT NOT NULL, due_date TEXT, items_json TEXT NOT NULL, subtotal REAL NOT NULL, total REAL NOT NULL,
          status TEXT NOT NULL DEFAULT 'Unpaid', notes TEXT
        )''');
        await db.execute('''CREATE TABLE staff (
          id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, phone TEXT, address TEXT,
          salary_type TEXT NOT NULL DEFAULT 'Monthly', salary_rate REAL NOT NULL DEFAULT 0,
          overtime_rate REAL NOT NULL DEFAULT 0, joining_date TEXT, active INTEGER NOT NULL DEFAULT 1
        )''');
        await db.execute('''CREATE TABLE staff_attendance (
          id INTEGER PRIMARY KEY AUTOINCREMENT, staff_id INTEGER NOT NULL, work_date TEXT NOT NULL,
          status TEXT NOT NULL, check_in TEXT, check_out TEXT, overtime_hours REAL NOT NULL DEFAULT 0,
          UNIQUE(staff_id, work_date), FOREIGN KEY(staff_id) REFERENCES staff(id)
        )''');
        await db.execute('''CREATE TABLE staff_payments (
          id INTEGER PRIMARY KEY AUTOINCREMENT, staff_id INTEGER NOT NULL, pay_date TEXT NOT NULL,
          period TEXT, payment_type TEXT NOT NULL, amount REAL NOT NULL, payment_mode TEXT NOT NULL,
          note TEXT, FOREIGN KEY(staff_id) REFERENCES staff(id)
        )''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) { await db.execute('CREATE TABLE IF NOT EXISTS settings (key TEXT PRIMARY KEY, value TEXT NOT NULL)'); }
        if (oldVersion < 3) { await db.execute('''CREATE TABLE IF NOT EXISTS invoices (id INTEGER PRIMARY KEY AUTOINCREMENT, number TEXT NOT NULL UNIQUE, customer TEXT NOT NULL, phone TEXT, address TEXT, invoice_date TEXT NOT NULL, due_date TEXT, items_json TEXT NOT NULL, subtotal REAL NOT NULL, total REAL NOT NULL, status TEXT NOT NULL DEFAULT 'Unpaid', notes TEXT)'''); }
        if (oldVersion < 4) { await db.execute('ALTER TABLE transactions ADD COLUMN payment_mode TEXT'); }
        if (oldVersion < 5) {
          await db.execute('''CREATE TABLE IF NOT EXISTS staff (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, phone TEXT, address TEXT, salary_type TEXT NOT NULL DEFAULT 'Monthly', salary_rate REAL NOT NULL DEFAULT 0, overtime_rate REAL NOT NULL DEFAULT 0, joining_date TEXT, active INTEGER NOT NULL DEFAULT 1)''');
          await db.execute('''CREATE TABLE IF NOT EXISTS staff_attendance (id INTEGER PRIMARY KEY AUTOINCREMENT, staff_id INTEGER NOT NULL, work_date TEXT NOT NULL, status TEXT NOT NULL, check_in TEXT, check_out TEXT, overtime_hours REAL NOT NULL DEFAULT 0, UNIQUE(staff_id, work_date), FOREIGN KEY(staff_id) REFERENCES staff(id))''');
          await db.execute('''CREATE TABLE IF NOT EXISTS staff_payments (id INTEGER PRIMARY KEY AUTOINCREMENT, staff_id INTEGER NOT NULL, pay_date TEXT NOT NULL, period TEXT, payment_type TEXT NOT NULL, amount REAL NOT NULL, payment_mode TEXT NOT NULL, note TEXT, FOREIGN KEY(staff_id) REFERENCES staff(id))''');
        }
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

  Future<List<Map<String, dynamic>>> getTransactions({String? scope, DateTime? from, DateTime? to, int? projectId, bool excludeProjectTransactions = true}) async {
    final clauses = <String>[];
    final args = <Object?>[];
    if (scope != null) { clauses.add('t.scope = ?'); args.add(scope); }
    if (projectId != null) { clauses.add('t.project_id = ?'); args.add(projectId); }
    else if (excludeProjectTransactions) { clauses.add('t.project_id IS NULL'); }
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

  Future<Map<String, double>> getSummary({String? scope, DateTime? from, DateTime? to, int? projectId, bool excludeProjectTransactions = true}) async {
    final db = await database;
    final clauses = <String>[];
    final args = <Object?>[];
    if (scope != null) { clauses.add('scope = ?'); args.add(scope); }
    if (projectId != null) { clauses.add('project_id = ?'); args.add(projectId); }
    else if (excludeProjectTransactions) { clauses.add('project_id IS NULL'); }
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

  Future<Map<String, double>> getIncomeByPaymentMode({String? scope, DateTime? from, DateTime? to, int? projectId}) async {
    final clauses = <String>["type = 'income'"];
    final args = <Object?>[];
    if (scope != null) { clauses.add('scope = ?'); args.add(scope); }
    if (projectId != null) { clauses.add('project_id = ?'); args.add(projectId); }
    if (from != null) { clauses.add('date >= ?'); args.add(DateTime(from.year, from.month, from.day).toIso8601String()); }
    if (to != null) { clauses.add('date < ?'); args.add(DateTime(to.year, to.month, to.day).add(const Duration(days: 1)).toIso8601String()); }
    final rows = await (await database).rawQuery("""SELECT COALESCE(payment_mode, 'Not specified') AS mode, COALESCE(SUM(amount),0) AS total FROM transactions WHERE ${clauses.join(' AND ')} GROUP BY payment_mode ORDER BY total DESC""", args);
    return {for (final row in rows) row['mode'].toString(): (row['total'] as num).toDouble()};
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

  Future<Map<String, double>> getAllProjectsSummary() async {
    final rows = await (await database).rawQuery('''SELECT
      COALESCE(SUM(CASE WHEN type='income' THEN amount ELSE 0 END),0) AS income,
      COALESCE(SUM(CASE WHEN type='expense' THEN amount ELSE 0 END),0) AS expense
      FROM transactions WHERE project_id IS NOT NULL''');
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

  Future<List<Map<String, dynamic>>> getInvoices() async => (await database).query('invoices', orderBy: 'id DESC');
  Future<int> saveInvoice(Map<String, dynamic> data, {int? id}) async {
    final db = await database;
    if (id == null) return db.insert('invoices', data);
    return db.update('invoices', data, where: 'id = ?', whereArgs: [id]);
  }
  Future<void> deleteInvoice(int id) async => (await database).delete('invoices', where: 'id = ?', whereArgs: [id]);
  Future<String> nextInvoiceNumber() async {
    final rows = await (await database).rawQuery('SELECT number FROM invoices ORDER BY id DESC LIMIT 1');
    var next = 1;
    if (rows.isNotEmpty) { final match = RegExp(r'(\d+)$').firstMatch(rows.first['number'].toString()); if (match != null) next = (int.tryParse(match.group(1)!) ?? 0) + 1; }
    return 'INV-${next.toString().padLeft(4, '0')}';
  }
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
    ('Business', 'Business income and expenses only', Icons.business, green),
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
    appBar: AppBar(title: Row(children: [ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/fintrack_logo.png', width: 38, height: 38, fit: BoxFit.cover)), const SizedBox(width: 9), const Text('FinTrack Pro', style: TextStyle(fontWeight: FontWeight.bold))]), actions: [IconButton(tooltip: 'Reports', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsPage())), icon: const Icon(Icons.analytics_outlined)), IconButton(tooltip: 'Projects', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectsPage())), icon: const Icon(Icons.folder_open)), PopupMenuButton<String>(tooltip: 'Language', onSelected: (v) async { appLanguage.value = v; await db.setSetting('language', v); if (mounted) setState(() {}); }, itemBuilder: (_) => [PopupMenuItem(value: 'en', child: Text(t('English'))), PopupMenuItem(value: 'ml', child: Text(t('Malayalam')))], icon: const Icon(Icons.language))]),
    body: Builder(builder: (context) {
      return ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.asset('assets/fintrack_logo.png', width: 76, height: 76, fit: BoxFit.cover)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t('Welcome!'), style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(t('Your financial overview'), style: TextStyle(color: Colors.grey.shade600))]))]),
        const SizedBox(height: 16),
        ...accounts.map((a) => FutureBuilder<Map<String,double>>(future: db.getSummary(scope: a.$1), builder: (context, balance) { final amount = balance.data?['balance'] ?? 0.0; return Card(child: ListTile(leading: Icon(a.$3, color: a.$4), title: Text(t('${a.$1} Balance')), trailing: Text(money(amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))); })),
        FutureBuilder<Map<String,double>>(future: db.getAllProjectsSummary(), builder: (context, balance) { final amount = balance.data?['balance'] ?? 0.0; return Card(child: ListTile(leading: const Icon(Icons.folder, color: Colors.deepOrange), title: Text(t('Projects Balance')), trailing: Text(money(amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))); }),
        const SizedBox(height: 24), Text(t('Manage Accounts'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
        ...accounts.map((a) => Card(child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7), leading: CircleAvatar(backgroundColor: a.$4.withValues(alpha: .12), child: Icon(a.$3, color: a.$4)), title: Text(t(a.$1), style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(t(a.$2)), trailing: const Icon(Icons.chevron_right), onTap: () => openAccount(a.$1)))),
        const SizedBox(height: 14), Text(t('Quick Access'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
        Row(children: [Expanded(child: _quickCard(t('Add Income'), Icons.add_circle, green, () => quickEntry('income'))), const SizedBox(width: 10), Expanded(child: _quickCard(t('Add Expense'), Icons.remove_circle, Colors.red, () => quickEntry('expense')))]),
        const SizedBox(height: 10), Row(children: [Expanded(child: _quickCard(t('Reports'), Icons.bar_chart, navy, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsPage())))), const SizedBox(width: 10), Expanded(child: _quickCard(t('Projects'), Icons.folder, Colors.deepOrange, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectsPage()))))]),
        const SizedBox(height: 10), _quickCard('Normal Invoice', Icons.receipt_long, green, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvoicesPage())).then((_) { if (mounted) setState(() {}); })),
        const SizedBox(height: 10), _quickCard('Staff Management', Icons.badge_outlined, navy, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffPage())).then((_) { if (mounted) setState(() {}); })),
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
                      subtitle: Text('${r['project_name'] == null ? '' : '${r['category']} • '}${dateLabel(r['date'] as String?)}${income && (r['payment_mode'] ?? '').toString().isNotEmpty ? ' • ${r['payment_mode']}' : ''}${(r['note'] ?? '').toString().isEmpty ? '' : ' • ${r['note']}'}'),
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
  String paymentMode = 'Cash';
  final paymentModes = const ['Cash', 'UPI', 'Bank Transfer', 'Card', 'Cheque', 'Other'];
  final incomeCategories = const ['Salary','Sales','Service','Interest','Other'];
  final expenseCategories = const ['Food','Travel','Rent','Salary','Materials','Bills','Other'];
  bool get isIncome => widget.type == 'income';
  bool get projectMode => widget.initialProjectId != null || (widget.record?['project_id'] != null);
  @override
  void initState() { super.initState(); projectId = widget.initialProjectId; final r = widget.record; if (r != null) { amount.text = (r['amount'] as num).toString(); note.text = (r['note'] ?? '').toString(); category = r['category'] as String; selectedDate = DateTime.tryParse(r['date'] as String) ?? DateTime.now(); projectId = r['project_id'] as int?; paymentMode = (r['payment_mode'] ?? 'Cash').toString(); } }
  @override
  void dispose() { amount.dispose(); note.dispose(); super.dispose(); }
  Future<void> save() async {
    final value = double.tryParse(amount.text.trim());
    if (value == null || value <= 0) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('Enter a valid amount')))); return; }
    setState(() => saving = true);
    final data = {'scope': widget.scope, 'type': widget.type, 'amount': value, 'category': projectMode ? category : 'Other', 'note': note.text.trim(), 'date': selectedDate.toIso8601String(), 'project_id': projectMode ? projectId : null, 'payment_mode': isIncome ? paymentMode : null};
    try { if (widget.record == null) { await FinanceDatabase.instance.addTransaction(data); } else { await FinanceDatabase.instance.updateTransaction(widget.record!['id'] as int, data); } if (mounted) Navigator.pop(context,true); }
    catch (e) { if (mounted) { setState(() => saving = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e'))); } }
  }
  @override
  Widget build(BuildContext context) { final cats = isIncome ? incomeCategories : expenseCategories; return Scaffold(appBar: AppBar(title: Text(t(widget.record == null ? (isIncome ? 'Add Income' : 'Add Expense') : 'Edit Transaction'))), body: ListView(padding: const EdgeInsets.all(18), children: [Text('${t(widget.scope)} Account', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 18), TextField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: t('Amount'), prefixText: '₹ ', border: const OutlineInputBorder())), const SizedBox(height: 14), if (isIncome) ...[DropdownButtonFormField<String>(value: paymentModes.contains(paymentMode) ? paymentMode : 'Cash', decoration: const InputDecoration(labelText: 'Payment Mode', border: OutlineInputBorder()), items: paymentModes.map((mode) => DropdownMenuItem(value: mode, child: Text(mode))).toList(), onChanged: (value) { if (value != null) setState(() => paymentMode = value); }), const SizedBox(height: 14)], if (projectMode) ...[DropdownButtonFormField<String>(initialValue: cats.contains(category) ? category : 'Other', decoration: InputDecoration(labelText: t('Category'), border: const OutlineInputBorder()), items: cats.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) { if (v != null) setState(() => category = v); }), const SizedBox(height: 14)], TextField(controller: note, maxLines: 2, decoration: InputDecoration(labelText: t('Description / Notes'), border: const OutlineInputBorder())), const SizedBox(height: 14), OutlinedButton.icon(onPressed: () async { final d = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2100)); if (d != null) setState(() => selectedDate = d); }, icon: const Icon(Icons.calendar_month), label: Text('${t('Date')}: ${DateFormat('dd-MM-yyyy').format(selectedDate)}')), const SizedBox(height: 22), FilledButton.icon(onPressed: saving ? null : save, icon: const Icon(Icons.save), label: Text(saving ? t('Saving...') : t('Save Transaction')))])); }
}

class ReportsPage extends StatefulWidget { const ReportsPage({super.key}); @override State<ReportsPage> createState() => _ReportsPageState(); }
class _ReportsPageState extends State<ReportsPage> {
  DateTime from = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime to = DateTime.now();
  String scope = 'All Accounts';
  int? selectedProjectId;
  List<Map<String,dynamic>> projects = [];
  bool exporting = false;
  @override void initState() { super.initState(); FinanceDatabase.instance.getProjects().then((v) { if (mounted) setState(() => projects = v); }); }
  Future<void> pick(bool start) async { final d = await showDatePicker(context: context, initialDate: start ? from : to, firstDate: DateTime(2000), lastDate: DateTime(2100)); if (d != null) setState(() { if (start) { from = d; } else { to = d; } }); }

  Future<void> exportPdf() async {
    setState(() => exporting = true);
    try {
      final project = selectedProjectId == null ? null : projects.firstWhere((p) => p['id'] == selectedProjectId);
      final reportTitle = project == null ? '$scope Financial Report' : '${project['name']} Project Report';
      final reportScope = project == null && scope != 'All Accounts' ? scope : null;
      final summary = await FinanceDatabase.instance.getSummary(scope: reportScope, projectId: selectedProjectId, from: from, to: to);
      final rows = await FinanceDatabase.instance.getTransactions(scope: reportScope, projectId: selectedProjectId, from: from, to: to);
      final doc = pw.Document();
      doc.addPage(pw.MultiPage(build: (context) => [
        pw.Text('FinTrack Pro', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5), pw.Text(reportTitle, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Text('Period: ${DateFormat('dd-MM-yyyy').format(from)} to ${DateFormat('dd-MM-yyyy').format(to)}'),
        pw.SizedBox(height: 16),
        pw.Table(border: pw.TableBorder.all(color: PdfColors.grey400), children: [
          _pdfRow('Total Income', '+Rs. ${NumberFormat('#,##0.00', 'en_IN').format(summary['income'] ?? 0)}'),
          _pdfRow('Total Expense', '-Rs. ${NumberFormat('#,##0.00', 'en_IN').format(summary['expense'] ?? 0)}'),
          _pdfRow('Net Balance', '${(summary['balance'] ?? 0) < 0 ? '-' : ''}Rs. ${NumberFormat('#,##0.00', 'en_IN').format((summary['balance'] ?? 0).abs())}'),
        ]),
        pw.SizedBox(height: 18),
        pw.Text('Transactions', style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        if (rows.isEmpty) pw.Text('No transactions in selected period.') else pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400),
          columnWidths: {0: const pw.FlexColumnWidth(1.2), 1: const pw.FlexColumnWidth(1.1), 2: const pw.FlexColumnWidth(2.2), 3: const pw.FlexColumnWidth(1.2)},
          children: [
            pw.TableRow(decoration: const pw.BoxDecoration(color: PdfColors.grey200), children: ['Date','Type','Description','Amount'].map((v) => pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(v, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))).toList()),
            ...rows.map((r) => pw.TableRow(children: [
              r['date'] == null ? '-' : dateLabel(r['date'].toString()),
              r['type'].toString().toUpperCase(),
              (r['note'] ?? r['category'] ?? '').toString(),
              '${r['type'].toString().toLowerCase() == 'income' ? '+' : '-'}Rs. ${NumberFormat('#,##0.00', 'en_IN').format((r['amount'] as num).abs())}',
            ].map((v) => pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(v))).toList())),
          ],
        ),
      ]));
      final bytes = await doc.save();
      await Printing.sharePdf(bytes: bytes, filename: 'FinTrack_${project == null ? scope.replaceAll(' ', '_') : (project['name'] as String).replaceAll(' ', '_')}_Report.pdf');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF export failed: $e')));
    } finally { if (mounted) setState(() => exporting = false); }
  }

  pw.TableRow _pdfRow(String label, String value) => pw.TableRow(children: [
    pw.Padding(padding: const pw.EdgeInsets.all(7), child: pw.Text(label)),
    pw.Padding(padding: const pw.EdgeInsets.all(7), child: pw.Text(value, textAlign: pw.TextAlign.right)),
  ]);

  @override
  Widget build(BuildContext context) {
    final selectedScope = selectedProjectId == null && scope != 'All Accounts' ? scope : null;
    return Scaffold(
      appBar: AppBar(title: Text(t('Financial Reports'))),
      body: FutureBuilder<Map<String, double>>(
        future: FinanceDatabase.instance.getSummary(scope: selectedScope, projectId: selectedProjectId, from: from, to: to),
        builder: (context, snap) {
          final d = snap.data ?? {'income': 0.0, 'expense': 0.0, 'balance': 0.0};
          return ListView(padding: const EdgeInsets.all(16), children: [
            DropdownButtonFormField<String>(
              initialValue: scope,
              decoration: const InputDecoration(labelText: 'Account', border: OutlineInputBorder()),
              items: ['All Accounts', 'Personal', 'Family', 'Business'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (v) => setState(() { scope = v ?? 'All Accounts'; selectedProjectId = null; }),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int?>(
              initialValue: selectedProjectId,
              decoration: InputDecoration(labelText: t('Project Report (optional)'), border: const OutlineInputBorder()),
              items: [const DropdownMenuItem<int?>(value: null, child: Text('No Project / Account Report')), ...projects.map((p) => DropdownMenuItem<int?>(value: p['id'] as int, child: Text(p['name'] as String)))],
              onChanged: (v) => setState(() => selectedProjectId = v),
            ),
            const SizedBox(height: 12),
            Row(children: [Expanded(child: OutlinedButton(onPressed: () => pick(true), child: Text('From: ${DateFormat('dd-MM-yyyy').format(from)}'))), const SizedBox(width: 8), Expanded(child: OutlinedButton(onPressed: () => pick(false), child: Text('To: ${DateFormat('dd-MM-yyyy').format(to)}')))]),
            const SizedBox(height: 16),
            _reportTile('Total Income', d['income']!, green, Icons.trending_up),
            _reportTile('Total Expense', d['expense']!, Colors.red, Icons.trending_down),
            _reportTile('Net Balance', d['balance']!, navy, Icons.account_balance_wallet),
            const SizedBox(height: 12),
            FutureBuilder<Map<String, double>>(
              future: FinanceDatabase.instance.getIncomeByPaymentMode(scope: selectedScope, projectId: selectedProjectId, from: from, to: to),
              builder: (context, modes) {
                if (!modes.hasData || modes.data!.isEmpty) return const SizedBox.shrink();
                return Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Income by Payment Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...modes.data!.entries.map((entry) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(entry.key), Text(money(entry.value), style: const TextStyle(fontWeight: FontWeight.w600))]))),
                ])));
              },
            ),
            const SizedBox(height: 12),
            FilledButton.icon(onPressed: exporting ? null : exportPdf, icon: const Icon(Icons.picture_as_pdf), label: Text(exporting ? 'Preparing PDF...' : 'Export PDF')),
            const SizedBox(height: 18),
            Text(t('Transactions in selected period'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: FinanceDatabase.instance.getTransactions(scope: selectedScope, projectId: selectedProjectId, from: from, to: to),
              builder: (context, rows) {
                if (!rows.hasData) return const Center(child: CircularProgressIndicator());
                if (rows.data!.isEmpty) return Padding(padding: const EdgeInsets.all(20), child: Text(t('No transactions for this period.')));
                return Column(children: rows.data!.map((r) {
                  final inc = r['type'] == 'income';
                  return Card(child: ListTile(title: Text('${r['scope']} • ${(r['project_name'] ?? r['category']).toString()}'), subtitle: Text('${r['project_name'] == null ? '' : '${r['category']} • '}${dateLabel(r['date'] as String?)}${inc && (r['payment_mode'] ?? '').toString().isNotEmpty ? ' • ${r['payment_mode']}' : ''} • ${(r['note'] ?? '').toString()}'), trailing: Text('${inc ? '+' : '-'}${money(r['amount'] as num)}', style: TextStyle(color: inc ? green : Colors.red, fontWeight: FontWeight.bold))));
                }).toList());
              },
            ),
          ]);
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


// Standalone normal invoices. These records are intentionally separate from Business Income.
class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});
  @override State<InvoicesPage> createState() => _InvoicesPageState();
}
class _InvoicesPageState extends State<InvoicesPage> {
  Future<void> refresh() async { if (mounted) setState(() {}); }
  Future<void> createOrEdit([Map<String,dynamic>? invoice]) async {
    final changed = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => InvoiceEditorPage(invoice: invoice)));
    if (changed == true) refresh();
  }
  Future<void> remove(Map<String,dynamic> invoice) async {
    final yes = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Delete invoice?'), content: const Text('This invoice will be permanently deleted.'), actions: [TextButton(onPressed: () => Navigator.pop(ctx,false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(ctx,true), child: const Text('Delete'))]));
    if (yes == true) { await FinanceDatabase.instance.deleteInvoice(invoice['id'] as int); refresh(); }
  }
  Future<void> setStatus(Map<String,dynamic> invoice, String status) async { await FinanceDatabase.instance.saveInvoice({...invoice, 'status': status}, id: invoice['id'] as int); refresh(); }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Normal Invoices')),
    floatingActionButton: FloatingActionButton.extended(onPressed: () => createOrEdit(), icon: const Icon(Icons.add), label: const Text('Create Invoice')),
    body: FutureBuilder<List<Map<String,dynamic>>>(future: FinanceDatabase.instance.getInvoices(), builder: (context, snap) {
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      final rows = snap.data!;
      if (rows.isEmpty) return const Center(child: Text('No invoices yet. Tap Create Invoice to begin.'));
      return ListView(padding: const EdgeInsets.all(12), children: rows.map((r) => Card(child: ListTile(
        leading: CircleAvatar(backgroundColor: r['status']=='Paid' ? green.withValues(alpha:.12) : Colors.orange.withValues(alpha:.12), child: Icon(Icons.receipt_long, color: r['status']=='Paid' ? green : Colors.orange)),
        title: Text('${r['number']} • ${r['customer']}', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${dateLabel(r['invoice_date'] as String?)}  •  ${r['status']}'),
        trailing: PopupMenuButton<String>(onSelected: (v) { if (v=='edit') createOrEdit(r); if (v=='paid') setStatus(r,'Paid'); if (v=='unpaid') setStatus(r,'Unpaid'); if (v=='delete') remove(r); if (v=='share') shareInvoicePdf(r); if (v=='print') printInvoicePdf(r); }, itemBuilder: (_) => [const PopupMenuItem(value:'share',child:Text('Share PDF')), const PopupMenuItem(value:'print',child:Text('Print PDF')), const PopupMenuItem(value:'edit',child:Text('Edit')), if (r['status']=='Unpaid') const PopupMenuItem(value:'paid',child:Text('Mark as Paid')), if (r['status']=='Paid') const PopupMenuItem(value:'unpaid',child:Text('Mark as Unpaid')), const PopupMenuItem(value:'delete',child:Text('Delete'))]),
        onTap: () => createOrEdit(r),
      ))).toList());
    }),
  );
}

class InvoiceEditorPage extends StatefulWidget {
  final Map<String,dynamic>? invoice;
  const InvoiceEditorPage({super.key, this.invoice});
  @override State<InvoiceEditorPage> createState() => _InvoiceEditorPageState();
}
class _InvoiceEditorPageState extends State<InvoiceEditorPage> {
  final customer = TextEditingController(), phone = TextEditingController(), address = TextEditingController(), notes = TextEditingController();
  final List<Map<String,dynamic>> items = [];
  DateTime invoiceDate = DateTime.now();
  DateTime? dueDate;
  String number = 'INV-0001', status = 'Unpaid';
  bool loading = true, saving = false;
  double get total => items.fold(0, (sum, item) => sum + ((double.tryParse(item['qty'].toString()) ?? 0) * (double.tryParse(item['rate'].toString()) ?? 0)));
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final r = widget.invoice;
    if (r == null) { number = await FinanceDatabase.instance.nextInvoiceNumber(); }
    else {
      number = r['number'].toString(); customer.text = (r['customer']??'').toString(); phone.text = (r['phone']??'').toString(); address.text = (r['address']??'').toString(); notes.text = (r['notes']??'').toString();
      invoiceDate = DateTime.tryParse(r['invoice_date'].toString()) ?? DateTime.now(); dueDate = DateTime.tryParse((r['due_date']??'').toString()); status = r['status'].toString();
      final decoded = jsonDecode(r['items_json'].toString()) as List; items.addAll(decoded.map((e) => Map<String,dynamic>.from(e as Map)));
    }
    if (items.isEmpty) items.add({'description':'','qty':'1','rate':'0'});
    if (mounted) setState(() => loading = false);
  }
  @override void dispose() { customer.dispose(); phone.dispose(); address.dispose(); notes.dispose(); super.dispose(); }
  Future<void> chooseDate(bool due) async { final initial = due ? (dueDate ?? invoiceDate) : invoiceDate; final d = await showDatePicker(context: context, initialDate: initial, firstDate: DateTime(2000), lastDate: DateTime(2100)); if (d != null) setState(() { if (due) dueDate=d; else invoiceDate=d; }); }
  Future<void> addItem() async => setState(() => items.add({'description':'','qty':'1','rate':'0'}));
  Future<void> save() async {
    if (customer.text.trim().isEmpty || items.any((e) => e['description'].toString().trim().isEmpty) || total <= 0 || items.any((e) => (double.tryParse(e['qty'].toString())??0)<=0 || (double.tryParse(e['rate'].toString())??-1)<0)) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter customer, item descriptions, valid quantities and rates.'))); return; }
    setState(() => saving=true);
    final data = {'number':number,'customer':customer.text.trim(),'phone':phone.text.trim(),'address':address.text.trim(),'invoice_date':invoiceDate.toIso8601String(),'due_date':dueDate?.toIso8601String(),'items_json':jsonEncode(items),'subtotal':total,'total':total,'status':status,'notes':notes.text.trim()};
    try { await FinanceDatabase.instance.saveInvoice(data, id: widget.invoice?['id'] as int?); if (mounted) Navigator.pop(context,true); }
    catch(e) { if(mounted) { setState(()=>saving=false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Could not save invoice: $e'))); } }
  }
  @override Widget build(BuildContext context) {
    if (loading) return Scaffold(appBar: AppBar(title: const Text('Invoice')), body: const Center(child:CircularProgressIndicator()));
    return Scaffold(appBar: AppBar(title: Text(widget.invoice==null?'Create Invoice':'Edit Invoice')), body: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('INVOICE', style: TextStyle(fontSize:28, fontWeight:FontWeight.bold, letterSpacing:3, color:navy)),
      const SizedBox(height:14), Text('Invoice No: $number', style: const TextStyle(fontWeight:FontWeight.bold)),
      const SizedBox(height:12), TextField(controller:customer, decoration:const InputDecoration(labelText:'Issued To / Customer', border:OutlineInputBorder())),
      const SizedBox(height:10), TextField(controller:address, maxLines:2, decoration:const InputDecoration(labelText:'Address (optional)', border:OutlineInputBorder())),
      const SizedBox(height:10), TextField(controller:phone, keyboardType:TextInputType.phone, decoration:const InputDecoration(labelText:'Phone (optional)', border:OutlineInputBorder())),
      const SizedBox(height:10), Wrap(spacing:10, runSpacing:8, children:[OutlinedButton.icon(onPressed:()=>chooseDate(false), icon:const Icon(Icons.calendar_today), label:Text('Date: ${dateLabel(invoiceDate.toIso8601String())}')), OutlinedButton.icon(onPressed:()=>chooseDate(true), icon:const Icon(Icons.event), label:Text('Due: ${dueDate==null?'Not set':dateLabel(dueDate!.toIso8601String())}'))]),
      const SizedBox(height:18), const Divider(), const Text('DESCRIPTION                         RATE          QTY          TOTAL', style:TextStyle(fontWeight:FontWeight.bold,fontSize:12)), const Divider(),
      ...List.generate(items.length,(i) { final item=items[i]; final qty=double.tryParse(item['qty'].toString())??0, rate=double.tryParse(item['rate'].toString())??0; return Padding(padding:const EdgeInsets.only(bottom:12), child: Column(children:[TextFormField(initialValue:item['description'].toString(), decoration:const InputDecoration(labelText:'Description',border:OutlineInputBorder()), onChanged:(v)=>item['description']=v), const SizedBox(height:7), Row(children:[Expanded(child:TextFormField(initialValue:item['rate'].toString(), keyboardType:const TextInputType.numberWithOptions(decimal:true), decoration:const InputDecoration(labelText:'Rate',prefixText:'₹ ',border:OutlineInputBorder()), onChanged:(v)=>setState(()=>item['rate']=v))), const SizedBox(width:8), Expanded(child:TextFormField(initialValue:item['qty'].toString(), keyboardType:const TextInputType.numberWithOptions(decimal:true), decoration:const InputDecoration(labelText:'Qty',border:OutlineInputBorder()), onChanged:(v)=>setState(()=>item['qty']=v))), IconButton(onPressed:items.length==1?null:()=>setState(()=>items.removeAt(i)), icon:const Icon(Icons.delete_outline,color:Colors.red))]), Align(alignment:Alignment.centerRight, child:Text('Line total: ${money(qty*rate)}',style:const TextStyle(fontWeight:FontWeight.bold))) ])); }),
      OutlinedButton.icon(onPressed:addItem, icon:const Icon(Icons.add), label:const Text('Add Item')), const Divider(height:28),
      Align(alignment:Alignment.centerRight, child:Column(crossAxisAlignment:CrossAxisAlignment.end, children:[const Text('SUBTOTAL'), Text(money(total),style:const TextStyle(fontSize:18,fontWeight:FontWeight.bold)), const SizedBox(height:4), const Text('TOTAL',style:TextStyle(fontWeight:FontWeight.bold)), Text(money(total),style:const TextStyle(fontSize:23,fontWeight:FontWeight.bold,color:navy))])),
      const SizedBox(height:12), TextField(controller:notes,maxLines:2,decoration:const InputDecoration(labelText:'Notes (optional)',border:OutlineInputBorder())), const SizedBox(height:20), FilledButton.icon(onPressed:saving?null:save, icon:const Icon(Icons.save), label:Text(saving?'Saving...':'Save Invoice')),
    ]));
  }
}

Future<Uint8List> buildInvoicePdf(Map<String,dynamic> invoice) async {
  final doc = pw.Document();
  final items = (jsonDecode(invoice['items_json'].toString()) as List).map((e)=>Map<String,dynamic>.from(e as Map)).toList();
  final fmt = NumberFormat.currency(locale:'en_IN',symbol:'Rs. ',decimalDigits:2);
  final total = (invoice['total'] as num).toDouble();
  doc.addPage(pw.Page(pageFormat:PdfPageFormat.a4, margin:const pw.EdgeInsets.fromLTRB(42,48,42,42), build:(ctx) => pw.Column(crossAxisAlignment:pw.CrossAxisAlignment.start, children:[
    pw.Row(mainAxisAlignment:pw.MainAxisAlignment.spaceBetween, crossAxisAlignment:pw.CrossAxisAlignment.start, children:[pw.Text('INVOICE',style:pw.TextStyle(fontSize:30,fontWeight:pw.FontWeight.bold,letterSpacing:3)),pw.Column(crossAxisAlignment:pw.CrossAxisAlignment.end,children:[pw.Text('INVOICE NO: ${invoice['number']}',style:pw.TextStyle(fontWeight:pw.FontWeight.bold)),pw.SizedBox(height:5),pw.Text('DATE: ${dateLabel(invoice['invoice_date'].toString())}'),if((invoice['due_date']??'').toString().isNotEmpty) pw.Text('DUE DATE: ${dateLabel(invoice['due_date'].toString())}')])]),
    pw.SizedBox(height:65), pw.Text('ISSUED TO:',style:pw.TextStyle(fontWeight:pw.FontWeight.bold,letterSpacing:1)), pw.SizedBox(height:7), pw.Text(invoice['customer'].toString()), if((invoice['address']??'').toString().isNotEmpty) pw.Text(invoice['address'].toString()), if((invoice['phone']??'').toString().isNotEmpty) pw.Text(invoice['phone'].toString()),
    pw.SizedBox(height:55), pw.Table(border:pw.TableBorder(horizontalInside:pw.BorderSide(color:PdfColors.grey300),top:pw.BorderSide(color:PdfColors.grey700),bottom:pw.BorderSide(color:PdfColors.grey700)), columnWidths:{0:const pw.FlexColumnWidth(4),1:const pw.FlexColumnWidth(1.3),2:const pw.FlexColumnWidth(1),3:const pw.FlexColumnWidth(1.5)}, children:[pw.TableRow(children:['DESCRIPTION','RATE','QTY','TOTAL'].map((v)=>pw.Padding(padding:const pw.EdgeInsets.symmetric(vertical:10),child:pw.Text(v,style:pw.TextStyle(fontWeight:pw.FontWeight.bold,fontSize:9)))).toList()), ...items.map((it){final q=double.tryParse(it['qty'].toString())??0;final r=double.tryParse(it['rate'].toString())??0;return pw.TableRow(children:[it['description'].toString(),fmt.format(r),q.toString(),fmt.format(q*r)].map((v)=>pw.Padding(padding:const pw.EdgeInsets.symmetric(vertical:10),child:pw.Text(v,style:const pw.TextStyle(fontSize:9)))).toList());})]),
    pw.SizedBox(height:15), pw.Align(alignment:pw.Alignment.centerRight,child:pw.Column(crossAxisAlignment:pw.CrossAxisAlignment.end,children:[pw.Text('SUBTOTAL     ${fmt.format(total)}',style:pw.TextStyle(fontWeight:pw.FontWeight.bold)),pw.SizedBox(height:8),pw.Text('TOTAL     ${fmt.format(total)}',style:pw.TextStyle(fontWeight:pw.FontWeight.bold,fontSize:15))])),
    pw.Spacer(), if((invoice['notes']??'').toString().isNotEmpty) pw.Text('Notes: ${invoice['notes']}')
  ])));
  return doc.save();
}

Future<void> shareInvoicePdf(Map<String,dynamic> invoice) async {
  final bytes = await buildInvoicePdf(invoice);
  await Printing.sharePdf(bytes: bytes, filename: '${invoice['number']}.pdf');
}

Future<void> printInvoicePdf(Map<String,dynamic> invoice) async {
  final bytes = await buildInvoicePdf(invoice);
  await Printing.layoutPdf(onLayout: (format) async => bytes, name: '${invoice['number']}.pdf');
}


class StaffPage extends StatefulWidget {
  const StaffPage({super.key});
  @override
  State<StaffPage> createState() => _StaffPageState();
}
class _StaffPageState extends State<StaffPage> {
  final db = FinanceDatabase.instance;
  Future<void> refresh() async { if (mounted) setState(() {}); }
  Future<void> addOrEdit([Map<String,dynamic>? staff]) async {
    final name = TextEditingController(text: staff?['name']?.toString() ?? '');
    final phone = TextEditingController(text: staff?['phone']?.toString() ?? '');
    final address = TextEditingController(text: staff?['address']?.toString() ?? '');
    final rate = TextEditingController(text: staff?['salary_rate']?.toString() ?? '');
    final overtime = TextEditingController(text: staff?['overtime_rate']?.toString() ?? '');
    String salaryType = staff?['salary_type']?.toString() ?? 'Monthly';
    final joining = TextEditingController(text: staff?['joining_date']?.toString() ?? DateFormat('yyyy-MM-dd').format(DateTime.now()));
    final result = await showDialog<bool>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setD) => AlertDialog(
      title: Text(staff == null ? 'Add Staff' : 'Edit Staff'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Staff Name *')),
        TextField(controller: phone, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone),
        TextField(controller: address, decoration: const InputDecoration(labelText: 'Address')),
        DropdownButtonFormField<String>(value: salaryType, decoration: const InputDecoration(labelText: 'Salary Type'), items: const [DropdownMenuItem(value: 'Monthly', child: Text('Monthly Salary')), DropdownMenuItem(value: 'Daily', child: Text('Daily Wage'))], onChanged: (v) => setD(() => salaryType = v ?? 'Monthly')),
        TextField(controller: rate, decoration: InputDecoration(labelText: salaryType == 'Monthly' ? 'Monthly Salary' : 'Daily Wage'), keyboardType: TextInputType.number),
        TextField(controller: overtime, decoration: const InputDecoration(labelText: 'Overtime Rate / Hour'), keyboardType: TextInputType.number),
        TextField(controller: joining, decoration: const InputDecoration(labelText: 'Joining Date (YYYY-MM-DD)')),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save'))],
    )));
    if (result == true && name.text.trim().isNotEmpty) {
      final data = {'name': name.text.trim(), 'phone': phone.text.trim(), 'address': address.text.trim(), 'salary_type': salaryType, 'salary_rate': double.tryParse(rate.text) ?? 0, 'overtime_rate': double.tryParse(overtime.text) ?? 0, 'joining_date': joining.text.trim(), 'active': 1};
      if (staff == null) { await (await db.database).insert('staff', data); } else { await (await db.database).update('staff', data, where: 'id = ?', whereArgs: [staff['id']]); }
      refresh();
    }
  }
  Future<void> remove(Map<String,dynamic> row) async {
    final yes = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Delete staff?'), content: const Text('Staff profile, attendance and salary records will be deleted.'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete'))]));
    if (yes == true) { final database = await db.database; await database.transaction((txn) async { await txn.delete('staff_attendance', where: 'staff_id = ?', whereArgs: [row['id']]); await txn.delete('staff_payments', where: 'staff_id = ?', whereArgs: [row['id']]); await txn.delete('staff', where: 'id = ?', whereArgs: [row['id']]); }); refresh(); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Staff Management'), actions: [IconButton(onPressed: () => addOrEdit(), icon: const Icon(Icons.person_add_alt_1))]),
    floatingActionButton: FloatingActionButton.extended(onPressed: () => addOrEdit(), icon: const Icon(Icons.add), label: const Text('Add Staff')),
    body: FutureBuilder<List<Map<String,dynamic>>>(future: db.database.then((d) => d.query('staff', where: 'active = 1', orderBy: 'name COLLATE NOCASE')), builder: (context, snap) {
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      final rows = snap.data!;
      if (rows.isEmpty) return const Center(child: Text('No staff added yet. Tap Add Staff.'));
      return ListView(padding: const EdgeInsets.all(12), children: [
        Card(child: ListTile(leading: const Icon(Icons.groups, color: navy), title: const Text('Staff Members'), trailing: Text('${rows.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)))),
        ...rows.map((r) => Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: Text(r['name'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('${r['salary_type']} • ${money((r['salary_rate'] as num?) ?? 0)}${r['phone'] == null || r['phone'].toString().isEmpty ? '' : '\n${r['phone']}'}'), isThreeLine: true, trailing: PopupMenuButton<String>(onSelected: (v) { if (v == 'edit') addOrEdit(r); if (v == 'delete') remove(r); }, itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Edit')), PopupMenuItem(value: 'delete', child: Text('Delete'))]), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StaffDetailsPage(staff: r))).then((_) => refresh())))),
      ]);
    }),
  );
}

class StaffDetailsPage extends StatefulWidget {
  final Map<String,dynamic> staff;
  const StaffDetailsPage({super.key, required this.staff});
  @override
  State<StaffDetailsPage> createState() => _StaffDetailsPageState();
}
class _StaffDetailsPageState extends State<StaffDetailsPage> {
  final db = FinanceDatabase.instance;
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  String period() => DateFormat('yyyy-MM').format(month);
  Future<List<Map<String,dynamic>>> attendance() async => (await db.database).query('staff_attendance', where: 'staff_id = ? AND work_date LIKE ?', whereArgs: [widget.staff['id'], '${period()}%'], orderBy: 'work_date');
  Future<List<Map<String,dynamic>>> payments() async => (await db.database).query('staff_payments', where: 'staff_id = ? AND period = ?', whereArgs: [widget.staff['id'], period()], orderBy: 'pay_date DESC');
  Future<void> markAttendance(DateTime day) async {
    final date = DateFormat('yyyy-MM-dd').format(day);
    final rows = await (await db.database).query('staff_attendance', where: 'staff_id = ? AND work_date = ?', whereArgs: [widget.staff['id'], date], limit: 1);
    String status = rows.isEmpty ? 'Present' : rows.first['status'].toString();
    final checkIn = TextEditingController(text: rows.isEmpty ? '' : rows.first['check_in']?.toString() ?? '');
    final checkOut = TextEditingController(text: rows.isEmpty ? '' : rows.first['check_out']?.toString() ?? '');
    final overtime = TextEditingController(text: rows.isEmpty ? '0' : rows.first['overtime_hours'].toString());
    final ok = await showDialog<bool>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setD) => AlertDialog(title: Text('Attendance • ${DateFormat('dd MMM yyyy').format(day)}'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      DropdownButtonFormField<String>(value: status, items: const [DropdownMenuItem(value: 'Present', child: Text('Present')), DropdownMenuItem(value: 'Absent', child: Text('Absent')), DropdownMenuItem(value: 'Leave', child: Text('Leave'))], onChanged: (v) => setD(() => status = v ?? 'Present'), decoration: const InputDecoration(labelText: 'Status')),
      TextField(controller: checkIn, decoration: const InputDecoration(labelText: 'Check-in (e.g. 09:00)')),
      TextField(controller: checkOut, decoration: const InputDecoration(labelText: 'Check-out (e.g. 18:00)')),
      TextField(controller: overtime, decoration: const InputDecoration(labelText: 'Overtime Hours'), keyboardType: TextInputType.number),
    ])), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save'))])));
    if (ok == true) { await (await db.database).insert('staff_attendance', {'staff_id': widget.staff['id'], 'work_date': date, 'status': status, 'check_in': checkIn.text.trim(), 'check_out': checkOut.text.trim(), 'overtime_hours': double.tryParse(overtime.text) ?? 0}, conflictAlgorithm: ConflictAlgorithm.replace); setState(() {}); }
  }
  Future<double> calculatedSalary() async {
    final rows = await attendance();
    final present = rows.where((r) => r['status'] == 'Present').length;
    final overtime = rows.fold<double>(0, (sum, r) => sum + ((r['overtime_hours'] as num?)?.toDouble() ?? 0));
    final base = widget.staff['salary_type'] == 'Daily'
      ? present * ((widget.staff['salary_rate'] as num?)?.toDouble() ?? 0)
      : ((widget.staff['salary_rate'] as num?)?.toDouble() ?? 0);
    return base + overtime * ((widget.staff['overtime_rate'] as num?)?.toDouble() ?? 0);
  }
  Future<void> recordPayment({required String type}) async {
    final amount = TextEditingController();
    final note = TextEditingController();
    String mode = 'Cash';
    final due = await calculatedSalary();
    final paidRows = await payments();
    final paid = paidRows.fold<double>(0, (v, r) => v + ((r['amount'] as num?)?.toDouble() ?? 0));
    final advance = paidRows.where((r) => r['payment_type'] == 'Advance').fold<double>(0, (v, r) => v + ((r['amount'] as num?)?.toDouble() ?? 0));
    final suggest = type == 'Salary' ? (due - paid - advance).clamp(0, double.infinity).toDouble() : 0.0;
    if (suggest > 0) amount.text = suggest.toStringAsFixed(2);
    final ok = await showDialog<bool>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setD) => AlertDialog(title: Text(type == 'Advance' ? 'Record Advance' : 'Record Salary Payment'), content: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: amount, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
      DropdownButtonFormField<String>(value: mode, decoration: const InputDecoration(labelText: 'Payment Mode'), items: const ['Cash','UPI','Bank Transfer','Cheque','Other'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(), onChanged: (v) => setD(() => mode = v ?? 'Cash')),
      TextField(controller: note, decoration: const InputDecoration(labelText: 'Note (optional)')),
      Align(alignment: Alignment.centerLeft, child: Text('Calculated salary: ${money(due)}')),
    ]), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save'))])));
    final value = double.tryParse(amount.text) ?? 0;
    if (ok == true && value > 0) { await (await db.database).insert('staff_payments', {'staff_id': widget.staff['id'], 'pay_date': DateFormat('yyyy-MM-dd').format(DateTime.now()), 'period': period(), 'payment_type': type, 'amount': value, 'payment_mode': mode, 'note': note.text.trim()}); setState(() {}); }
  }
  Future<void> exportStaffReport() async {
    final att = await attendance();
    final pays = await payments();
    final present = att.where((r) => r['status'] == 'Present').length;
    final absent = att.where((r) => r['status'] == 'Absent').length;
    final leave = att.where((r) => r['status'] == 'Leave').length;
    final overtime = att.fold<double>(0, (v, r) => v + ((r['overtime_hours'] as num?)?.toDouble() ?? 0));
    final salary = await calculatedSalary();
    final paid = pays.where((r) => r['payment_type'] == 'Salary').fold<double>(0, (v, r) => v + ((r['amount'] as num?)?.toDouble() ?? 0));
    final advance = pays.where((r) => r['payment_type'] == 'Advance').fold<double>(0, (v, r) => v + ((r['amount'] as num?)?.toDouble() ?? 0));
    final doc = pw.Document();
    doc.addPage(pw.Page(pageFormat: PdfPageFormat.a4, build: (ctx) => pw.Padding(padding: const pw.EdgeInsets.all(28), child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text('STAFF MONTHLY REPORT', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 8), pw.Text(widget.staff['name'].toString(), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
      pw.Text('Period: ${DateFormat('MMMM yyyy').format(month)}'),
      pw.Divider(),
      pw.Text('Attendance', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      pw.Text('Present: $present    Absent: $absent    Leave: $leave    Overtime: ${overtime.toStringAsFixed(1)} hours'),
      pw.SizedBox(height: 16),
      pw.Text('Salary Summary', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      pw.Text('Calculated salary: ${money(salary)}'),
      pw.Text('Salary paid: ${money(paid)}'),
      pw.Text('Advance paid: ${money(advance)}'),
      pw.Text('Pending: ${money((salary - paid - advance).clamp(0, double.infinity))}'),
      pw.SizedBox(height: 16),
      pw.Text('Payment History', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      pw.Table.fromTextArray(headers: ['Date', 'Type', 'Mode', 'Amount'], data: pays.map((r) => [dateLabel(r['pay_date']?.toString()), r['payment_type'].toString(), r['payment_mode'].toString(), money((r['amount'] as num?)?.toDouble())]).toList()),
    ]))));
    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.staff['name'].toString()), actions: [IconButton(tooltip: 'Export PDF Report', onPressed: exportStaffReport, icon: const Icon(Icons.picture_as_pdf))]),
    body: FutureBuilder<List<Map<String,dynamic>>>(future: attendance(), builder: (context, aSnap) {
      if (!aSnap.hasData) return const Center(child: CircularProgressIndicator());
      final a = aSnap.data!;
      final present = a.where((r) => r['status'] == 'Present').length;
      final absent = a.where((r) => r['status'] == 'Absent').length;
      final overtime = a.fold<double>(0, (v, r) => v + ((r['overtime_hours'] as num?)?.toDouble() ?? 0));
      return ListView(padding: const EdgeInsets.all(14), children: [
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.staff['salary_type'].toString() == 'Monthly' ? 'Monthly Salary' : 'Daily Wage', style: const TextStyle(color: Colors.grey)),
          Text(money((widget.staff['salary_rate'] as num?)?.toDouble()), style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: navy)),
          Text('Phone: ${widget.staff['phone'] ?? '-'}'),
          Text('Overtime rate: ${money((widget.staff['overtime_rate'] as num?)?.toDouble())} / hour'),
        ]))),
        Row(children: [IconButton(onPressed: () => setState(() => month = DateTime(month.year, month.month - 1)), icon: const Icon(Icons.chevron_left)), Expanded(child: Center(child: Text(DateFormat('MMMM yyyy').format(month), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)))), IconButton(onPressed: () => setState(() => month = DateTime(month.year, month.month + 1)), icon: const Icon(Icons.chevron_right))]),
        Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Monthly Attendance Calendar', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 7, childAspectRatio: 1.25, children: [
            for (final w in ['M','T','W','T','F','S','S']) Center(child: Text(w, style: const TextStyle(fontWeight: FontWeight.bold))),
            for (int i = 0; i < DateTime(month.year, month.month, 1).weekday - 1; i++) const SizedBox(),
            for (int d = 1; d <= DateTime(month.year, month.month + 1, 0).day; d++)
              Builder(builder: (ctx) {
                final date = DateFormat('yyyy-MM-dd').format(DateTime(month.year, month.month, d));
                final matches = a.where((r) => r['work_date'] == date);
                final row = matches.isEmpty ? null : matches.first;
                final status = row?['status']?.toString();
                final color = status == 'Present' ? green : status == 'Absent' ? Colors.red : status == 'Leave' ? Colors.orange : Colors.grey.shade200;
                return InkWell(onTap: () => markAttendance(DateTime(month.year, month.month, d)), child: Container(margin: const EdgeInsets.all(2), decoration: BoxDecoration(color: color.withValues(alpha: status == null ? .5 : .9), borderRadius: BorderRadius.circular(8)), child: Center(child: Text('$d', style: TextStyle(fontWeight: FontWeight.w600, color: status == null ? Colors.black87 : Colors.white)))));
              }),
          ]),
          const SizedBox(height: 8),
          Text('Present: $present   Absent: $absent   Overtime: ${overtime.toStringAsFixed(1)} hrs'),
          const Text('Tap a date to record Present / Absent, manual check-in/out and overtime.', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ]))),
        FutureBuilder<double>(future: calculatedSalary(), builder: (context, calc) => Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Salary Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 6), Text('Calculated salary: ${money(calc.data ?? 0)}'),
          FutureBuilder<List<Map<String,dynamic>>>(future: payments(), builder: (context, pay) {
            final list = pay.data ?? [];
            final paid = list.where((r) => r['payment_type'] == 'Salary').fold<double>(0, (v, r) => v + ((r['amount'] as num?)?.toDouble() ?? 0));
            final advance = list.where((r) => r['payment_type'] == 'Advance').fold<double>(0, (v, r) => v + ((r['amount'] as num?)?.toDouble() ?? 0));
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Salary paid: ${money(paid)}'), Text('Advance: ${money(advance)}'), Text('Pending: ${money(((calc.data ?? 0) - paid - advance).clamp(0, double.infinity))}')]);
          }),
          const SizedBox(height: 10), Wrap(spacing: 8, children: [FilledButton.tonal(onPressed: () => recordPayment(type: 'Advance'), child: const Text('Record Advance')), FilledButton(onPressed: () => recordPayment(type: 'Salary'), child: const Text('Pay Salary'))]),
        ])))),
        FutureBuilder<List<Map<String,dynamic>>>(future: payments(), builder: (context, pay) => Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Salary & Advance History', style: TextStyle(fontWeight: FontWeight.bold)),
          if (pay.hasData) ...pay.data!.map((r) => ListTile(dense: true, contentPadding: EdgeInsets.zero, title: Text('${r['payment_type']} • ${money((r['amount'] as num?)?.toDouble())}'), subtitle: Text('${dateLabel(r['pay_date']?.toString())} • ${r['payment_mode']} ${r['note'] == null ? '' : '• ${r['note']}'}'))),
          if (pay.hasData && pay.data!.isEmpty) const Text('No payments recorded for this month.'),
        ])))),
      ]);
    }),
  );
}
