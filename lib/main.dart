import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FinanceDatabase.instance.database;
  runApp(const FinTrackApp());
}

const navy = Color(0xFF102B46);
const green = Color(0xFF087F5B);
const pageBg = Color(0xFFF4F6F9);

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
      version: 1,
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
        await db.execute('''CREATE TABLE projects (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          customer TEXT,
          budget REAL DEFAULT 0,
          start_date TEXT
        )''');
      },
    );
    return _database!;
  }

  Future<int> addTransaction(Map<String, dynamic> data) async =>
      (await database).insert('transactions', data);

  Future<int> updateTransaction(int id, Map<String, dynamic> data) async =>
      (await database).update('transactions', data, where: 'id = ?', whereArgs: [id]);

  Future<int> deleteTransaction(int id) async =>
      (await database).delete('transactions', where: 'id = ?', whereArgs: [id]);

  Future<List<Map<String, dynamic>>> getTransactions({String? scope, DateTime? from, DateTime? to}) async {
    final db = await database;
    final clauses = <String>[];
    final args = <Object?>[];
    if (scope != null) { clauses.add('scope = ?'); args.add(scope); }
    if (from != null) { clauses.add('date >= ?'); args.add(DateTime(from.year, from.month, from.day).toIso8601String()); }
    if (to != null) { clauses.add('date < ?'); args.add(DateTime(to.year, to.month, to.day).add(const Duration(days: 1)).toIso8601String()); }
    return db.query('transactions', where: clauses.isEmpty ? null : clauses.join(' AND '), whereArgs: args.isEmpty ? null : args, orderBy: 'date DESC, id DESC');
  }

  Future<Map<String, double>> getSummary({String? scope, DateTime? from, DateTime? to}) async {
    final db = await database;
    final clauses = <String>[];
    final args = <Object?>[];
    if (scope != null) { clauses.add('scope = ?'); args.add(scope); }
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
  Widget build(BuildContext context) => MaterialApp(
    title: 'FinTrack Pro', debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: green), scaffoldBackgroundColor: pageBg,
      appBarTheme: const AppBarTheme(backgroundColor: navy, foregroundColor: Colors.white, centerTitle: false)),
    home: const HomePage(),
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
    final scope = await showDialog<String>(context: context, builder: (_) => SimpleDialog(title: const Text('Select account'), children: accounts.map((a) => SimpleDialogOption(onPressed: () => Navigator.pop(context, a.$1), child: Text(a.$1))).toList()));
    if (!mounted || scope == null) return;
    final saved = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => EntryPage(scope: scope, type: type)));
    if (saved == true && mounted) setState(() {});
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('FinTrack Pro', style: TextStyle(fontWeight: FontWeight.bold)), actions: [IconButton(tooltip: 'Reports', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsPage())), icon: const Icon(Icons.analytics_outlined)), IconButton(tooltip: 'Projects', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectsPage())), icon: const Icon(Icons.folder_open))]),
    body: FutureBuilder<Map<String,double>>(future: db.getSummary(), builder: (context, snap) {
      final d = snap.data ?? {'income':0.0,'expense':0.0,'balance':0.0};
      return ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Welcome!', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4), Text('Your financial overview', style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: const LinearGradient(colors: [navy, green]), borderRadius: BorderRadius.circular(22)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Total Balance', style: TextStyle(color: Colors.white70)), const SizedBox(height: 8), Text(money(d['balance']), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)), const SizedBox(height: 22),
          Row(children: [Expanded(child: _summaryLabel('Income', d['income']!, Icons.trending_up)), Expanded(child: _summaryLabel('Expense', d['expense']!, Icons.trending_down))])])),
        const SizedBox(height: 24), const Text('Manage Accounts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
        ...accounts.map((a) => Card(child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7), leading: CircleAvatar(backgroundColor: a.$4.withValues(alpha: .12), child: Icon(a.$3, color: a.$4)), title: Text(a.$1, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(a.$2), trailing: const Icon(Icons.chevron_right), onTap: () => openAccount(a.$1)))),
        const SizedBox(height: 14), const Text('Quick Access', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
        Row(children: [Expanded(child: _quickCard('Add Income', Icons.add_circle, green, () => quickEntry('income'))), const SizedBox(width: 10), Expanded(child: _quickCard('Add Expense', Icons.remove_circle, Colors.red, () => quickEntry('expense')))]),
        const SizedBox(height: 10), Row(children: [Expanded(child: _quickCard('Reports', Icons.bar_chart, navy, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsPage())))), const SizedBox(width: 10), Expanded(child: _quickCard('Projects', Icons.folder, Colors.deepOrange, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectsPage()))))]),
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
    final yes = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Delete transaction?'), content: const Text('This transaction will be permanently deleted.'), actions: [TextButton(onPressed: () => Navigator.pop(context,false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context,true), child: const Text('Delete'))]));
    if (yes == true) { await db.deleteTransaction(row['id'] as int); if (mounted) setState(() {}); }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.scope} Account')),
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
                    const Text('Current Balance', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Text(money(d['balance']), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    Row(children: [
                      Expanded(child: Text('Income: ${money(d['income'])}', style: const TextStyle(color: Colors.white))),
                      Expanded(child: Text('Expense: ${money(d['expense'])}', style: const TextStyle(color: Colors.white))),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: FilledButton.icon(onPressed: () => add('income'), icon: const Icon(Icons.add), label: const Text('Income'))),
                const SizedBox(width: 10),
                Expanded(child: FilledButton.tonalIcon(onPressed: () => add('expense'), icon: const Icon(Icons.remove), label: const Text('Expense'))),
              ]),
              const SizedBox(height: 20),
              const Text('Transaction History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: db.getTransactions(scope: widget.scope),
                builder: (context, history) {
                  if (!history.hasData) return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                  final rows = history.data!;
                  if (rows.isEmpty) return const Padding(padding: EdgeInsets.all(24), child: Text('No transactions yet.', textAlign: TextAlign.center));
                  return Column(children: rows.map((r) {
                    final income = r['type'] == 'income';
                    return Card(child: ListTile(
                      leading: CircleAvatar(backgroundColor: (income ? green : Colors.red).withValues(alpha: .1), child: Icon(income ? Icons.south_west : Icons.north_east, color: income ? green : Colors.red)),
                      title: Text(r['category'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${dateLabel(r['date'] as String?)}${(r['note'] ?? '').toString().isEmpty ? '' : ' • ${r['note']}'}'),
                      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('${income ? '+' : '-'}${money(r['amount'] as num)}', style: TextStyle(color: income ? green : Colors.red, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 3),
                        const Text('Edit / Delete', style: TextStyle(fontSize: 10, color: Colors.grey)),
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
  const EntryPage({super.key, required this.scope, required this.type, this.record});
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
  @override
  void initState() { super.initState(); final r = widget.record; if (r != null) { amount.text = (r['amount'] as num).toString(); note.text = (r['note'] ?? '').toString(); category = r['category'] as String; selectedDate = DateTime.tryParse(r['date'] as String) ?? DateTime.now(); projectId = r['project_id'] as int?; } }
  @override
  void dispose() { amount.dispose(); note.dispose(); super.dispose(); }
  Future<void> save() async {
    final value = double.tryParse(amount.text.trim());
    if (value == null || value <= 0) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount'))); return; }
    setState(() => saving = true);
    final data = {'scope': widget.scope, 'type': widget.type, 'amount': value, 'category': category, 'note': note.text.trim(), 'date': selectedDate.toIso8601String(), 'project_id': projectId};
    try { if (widget.record == null) { await FinanceDatabase.instance.addTransaction(data); } else { await FinanceDatabase.instance.updateTransaction(widget.record!['id'] as int, data); } if (mounted) Navigator.pop(context,true); }
    catch (e) { if (mounted) { setState(() => saving = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e'))); } }
  }
  @override
  Widget build(BuildContext context) { final cats = isIncome ? incomeCategories : expenseCategories; return Scaffold(appBar: AppBar(title: Text(widget.record == null ? (isIncome ? 'Add Income' : 'Add Expense') : 'Edit Transaction')), body: ListView(padding: const EdgeInsets.all(18), children: [Text('${widget.scope} Account', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 18), TextField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Amount', prefixText: '₹ ', border: OutlineInputBorder())), const SizedBox(height: 14), DropdownButtonFormField<String>(initialValue: cats.contains(category) ? category : 'Other', decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()), items: cats.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) { if (v != null) setState(() => category = v); }), const SizedBox(height: 14), FutureBuilder<List<Map<String,dynamic>>>(future: FinanceDatabase.instance.getProjects(), builder: (context,s) { final projects = s.data ?? []; return DropdownButtonFormField<int?>(initialValue: projectId, decoration: const InputDecoration(labelText: 'Project (optional)', border: OutlineInputBorder()), items: [const DropdownMenuItem<int?>(value: null, child: Text('No project')), ...projects.map((p) => DropdownMenuItem<int?>(value: p['id'] as int, child: Text(p['name'] as String)))], onChanged: (v) => setState(() => projectId = v)); }), const SizedBox(height: 14), TextField(controller: note, maxLines: 2, decoration: const InputDecoration(labelText: 'Description / Notes', border: OutlineInputBorder())), const SizedBox(height: 14), OutlinedButton.icon(onPressed: () async { final d = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2100)); if (d != null) setState(() => selectedDate = d); }, icon: const Icon(Icons.calendar_month), label: Text('Date: ${DateFormat('dd-MM-yyyy').format(selectedDate)}')), const SizedBox(height: 22), FilledButton.icon(onPressed: saving ? null : save, icon: const Icon(Icons.save), label: Text(saving ? 'Saving...' : 'Save Transaction'))])); }
}

class ReportsPage extends StatefulWidget { const ReportsPage({super.key}); @override State<ReportsPage> createState() => _ReportsPageState(); }
class _ReportsPageState extends State<ReportsPage> {
  DateTime from = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime to = DateTime.now();
  String scope = 'All Accounts';
  Future<void> pick(bool start) async { final d = await showDatePicker(context: context, initialDate: start ? from : to, firstDate: DateTime(2000), lastDate: DateTime(2100)); if (d != null) setState(() { if (start) { from = d; } else { to = d; } }); }
  @override
  Widget build(BuildContext context) {
    final selectedScope = scope == 'All Accounts' ? null : scope;
    return Scaffold(
      appBar: AppBar(title: const Text('Financial Reports')),
      body: FutureBuilder<Map<String, double>>(
        future: FinanceDatabase.instance.getSummary(scope: selectedScope, from: from, to: to),
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
              const Text('Transactions in selected period', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: FinanceDatabase.instance.getTransactions(scope: selectedScope, from: from, to: to),
                builder: (context, rows) {
                  if (!rows.hasData) return const Center(child: CircularProgressIndicator());
                  if (rows.data!.isEmpty) return const Padding(padding: EdgeInsets.all(20), child: Text('No transactions for this period.'));
                  return Column(children: rows.data!.map((r) {
                    final inc = r['type'] == 'income';
                    return Card(child: ListTile(
                      title: Text('${r['scope']} • ${r['category']}'),
                      subtitle: Text(dateLabel(r['date'] as String?)),
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
        title: const Text('New Project'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Project name')),
          TextField(controller: customer, decoration: const InputDecoration(labelText: 'Customer / Client')),
          TextField(controller: budget, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Budget', prefixText: '₹ ')),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
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
      title: const Text('Delete project?'),
      content: const Text('Transactions linked to this project will remain in the database.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
      ],
    ));
    if (yes == true) {
      await FinanceDatabase.instance.deleteProject(id);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Projects')),
    floatingActionButton: FloatingActionButton.extended(onPressed: addProject, icon: const Icon(Icons.add), label: const Text('Add Project')),
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
          trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => deleteProject(r['id'] as int)),
        ))).toList());
      },
    ),
  );
}
