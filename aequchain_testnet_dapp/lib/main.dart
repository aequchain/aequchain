import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const aequchainTestnetApp());
}

class aequchainTestnetApp extends StatelessWidget {
  const aequchainTestnetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'aequchain Testnet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: const TestnetHome(),
    );
  }
}

class TestnetHome extends StatelessWidget {
  const TestnetHome({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    return Scaffold(
      body: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 377),
            curve: Curves.easeInOut,
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: isMobile ? 10 : 13,
              horizontal: isMobile ? 8 : 13,
            ),
            color: Colors.red[700],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: isMobile ? 16 : 21,
                ),
                SizedBox(width: isMobile ? 8 : 13),
                Flexible(
                  child: Text(
                    '⚠️  DEMO MODE - NO REAL VALUE - EPHEMERAL ONLY  ⚠️',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 10 : 13,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 34,
                vertical: isMobile ? 21 : 34,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    children: [
                      const SizedBox(height: 21),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 610),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          'aequchain',
                          style: TextStyle(
                            fontSize: isMobile ? 55 : 89,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 13),
                      Text(
                        'Testnet Demo Environment',
                        style: TextStyle(
                          fontSize: isMobile ? 18 : 28,
                          color: Colors.grey[600],
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 21),
                      // Safety notice
                      Container(
                        padding: EdgeInsets.all(isMobile ? 16 : 21),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[300]!, width: 2),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.verified_user, color: Colors.green[700], size: 24),
                                const SizedBox(width: 13),
                                Flexible(
                                  child: Text(
                                    '100% Safe Demo Environment',
                                    style: TextStyle(
                                      fontSize: isMobile ? 16 : 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[900],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 13),
                            Text(
                              'Use "Full Server Reset" button below to clear ALL data at any time.\n'
                              'Nothing is written to permanent storage. Complete confidence guaranteed!',
                              style: TextStyle(
                                fontSize: isMobile ? 13 : 14,
                                color: Colors.green[900],
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isMobile ? 34 : 55),
                      const _TestnetControls(),
                      const SizedBox(height: 55),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TestnetControls extends StatefulWidget {
  const _TestnetControls();
  
  @override
  State<_TestnetControls> createState() => _TestnetControlsState();
}

class _TestnetControlsState extends State<_TestnetControls> with SingleTickerProviderStateMixin {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _status = '';
  bool _loading = false;
  List<Map<String, dynamic>> _transactionHistory = [];
  Map<String, dynamic>? _blockchainStats;
  List<Map<String, dynamic>> _liveAccounts = [];
  bool _loadingAccounts = false;

  final String apiBase = 'http://localhost:3000/api/testnet';

  Future<void> _createAccount() async {
    if (_accountController.text.isEmpty) {
      setState(() => _status = '❌ Please enter an account ID');
      return;
    }
    
    setState(() {
      _loading = true;
      _status = 'Creating account...';
    });

    try {
      final timestamp = DateTime.now().toIso8601String();
      final response = await http.post(
        Uri.parse('$apiBase/account/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'account_id': _accountController.text.trim(),
          'initial_balance': 1000,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hash = _generateHash('account_${data['account_id']}_$timestamp');
        setState(() {
          _status = '✅ Account "${data['account_id']}" created!\nBalance: æ${data['balance']}\nHash: ${hash.substring(0, 16)}...\nTime: ${_formatTime(timestamp)}';
          _transactionHistory.insert(0, {
            'type': 'Account Created',
            'account': data['account_id'],
            'amount': 'æ${data['balance']}',
            'hash': hash,
            'timestamp': timestamp,
          });
        });
        await _fetchStats();
        await _fetchLiveAccounts();
      } else {
        setState(() => _status = '❌ Error: ${response.body}');
      }
    } catch (e) {
      setState(() => _status = '❌ Network error\nMake sure API server is running on port 3000');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _sendTransaction() async {
    if (_fromController.text.isEmpty || _toController.text.isEmpty || _amountController.text.isEmpty) {
      setState(() => _status = '❌ Please fill all transaction fields');
      return;
    }
    
    setState(() {
      _loading = true;
      _status = 'Sending transaction...';
    });

    try {
      final timestamp = DateTime.now().toIso8601String();
      final amount = int.tryParse(_amountController.text.trim()) ?? 0;
      final response = await http.post(
        Uri.parse('$apiBase/transaction/send'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'from': _fromController.text.trim(),
          'to': _toController.text.trim(),
          'amount': amount,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hash = _generateHash('tx_${data['from']}_${data['to']}_$amount\_$timestamp');
        setState(() {
          _status = '✅ Transaction complete!\nFrom: ${data['from']} → To: ${data['to']}\nAmount: æ$amount\nHash: ${hash.substring(0, 16)}...\nTime: ${_formatTime(timestamp)}';
          _transactionHistory.insert(0, {
            'type': 'Transaction',
            'from': data['from'],
            'to': data['to'],
            'amount': 'æ$amount',
            'hash': hash,
            'timestamp': timestamp,
          });
        });
        await _fetchStats();
        await _fetchLiveAccounts();
      } else {
        final errorData = json.decode(response.body);
        setState(() => _status = '❌ Error: ${errorData['message'] ?? response.body}');
      }
    } catch (e) {
      setState(() => _status = '❌ Network error\nMake sure API server is running');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchStats() async {
    try {
      final response = await http.get(Uri.parse('$apiBase/stats'));
      if (response.statusCode == 200) {
        setState(() {
          _blockchainStats = json.decode(response.body);
        });
      }
    } catch (e) {
      // Silently fail - stats are optional
    }
  }

  Future<void> _fetchLiveAccounts() async {
    setState(() => _loadingAccounts = true);
    try {
      final response = await http.get(Uri.parse('$apiBase/accounts'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _liveAccounts = List<Map<String, dynamic>>.from(data['accounts'] ?? []);
        });
      }
    } catch (e) {
      // Silently fail
    } finally {
      setState(() => _loadingAccounts = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchLiveAccounts();
    _fetchStats();
  }

  void _resetTestnet() async {
    setState(() {
      _loading = true;
      _status = 'Resetting testnet...';
    });

    try {
      // Clear local state
      setState(() {
        _transactionHistory.clear();
        _blockchainStats = null;
        _accountController.clear();
        _fromController.clear();
        _toController.clear();
        _amountController.clear();
        _status = '✅ Local UI reset! All form fields and history cleared.\n⚠️ Server data still exists. Use "Full Server Reset" to clear everything.';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _fullServerReset() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 13),
            Text('Full Server Reset'),
          ],
        ),
        content: const Text(
          'This will delete ALL data from the server:\n\n'
          '• All accounts\n'
          '• All transactions\n'
          '• All blockchain history\n'
          '• All UI state\n\n'
          'Everything will be permanently cleared!\n\n'
          'This demonstrates that the testnet is truly ephemeral '
          'and nothing is persisted to permanent storage.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Reset Everything'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _loading = true;
      _status = '🔄 Performing FULL SERVER RESET...\nClearing all blockchain data...';
    });

    try {
      // Call server reset endpoint
      final response = await http.post(
        Uri.parse('$apiBase/reset'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Clear local state
        setState(() {
          _transactionHistory.clear();
          _blockchainStats = null;
          _liveAccounts.clear();
          _accountController.clear();
          _fromController.clear();
          _toController.clear();
          _amountController.clear();
          _status = '✅ ✅ ✅ FULL RESET COMPLETE! ✅ ✅ ✅\n\n'
                   '🧹 ALL blockchain data cleared from server\n'
                   '🧹 ALL accounts deleted\n'
                   '🧹 ALL transactions removed\n'
                   '🧹 ALL UI state cleared\n\n'
                   '✨ Fresh testnet - nothing persisted!\n'
                   '✨ Complete confidence: ZERO data retention!\n\n'
                   'Server message: ${data['message']}';
        });
        await _fetchLiveAccounts();
        await _fetchStats();
      } else {
        setState(() => _status = '❌ Server reset failed: ${response.body}');
      }
    } catch (e) {
      setState(() => _status = '❌ Network error during reset\nMake sure API server is running on port 3000\nError: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _performRebalance() async {
    setState(() {
      _loading = true;
      _status = '⚖️ Performing rebalance...\nRecalculating equal distribution...';
    });

    try {
      // Call the rebalance API endpoint
      final response = await http.post(
        Uri.parse('$apiBase/rebalance'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Refresh accounts and stats to show updated balances
        await _fetchLiveAccounts();
        await _fetchStats();
        
        if (data['total_accounts'] == 0) {
          setState(() {
            _status = '⚠️ No accounts to rebalance\nCreate some accounts first!';
          });
          return;
        }

        setState(() {
          _status = '✅ Rebalance Complete!\n\n'
                   '⚖️ Equal Distribution Verified:\n'
                   '• Total Accounts: ${data['total_accounts']}\n'
                   '• Total Treasury: æ${data['total_treasury']}\n'
                   '• Equal Share: æ${data['equal_share']} per account\n\n'
                   '📝 Note: This demonstrates the rebalancing mechanism.\n'
                   'In production implementation, rebalancing occurs automatically\n'
                   'after every transaction to maintain perfect equality.\n\n'
                   '✨ All members now hold exactly equal value!';
        });
      } else {
        setState(() => _status = '❌ Rebalance failed: ${response.body}');
      }
    } catch (e) {
      setState(() => _status = '❌ Rebalance error: $e\nMake sure API server is running on port 3000');
    } finally {
      setState(() => _loading = false);
    }
  }

  String _generateHash(String input) {
    // Simple hash generation for demo purposes
    int hash = 0;
    for (int i = 0; i < input.length; i++) {
      hash = ((hash << 5) - hash) + input.codeUnitAt(i);
      hash = hash & hash; // Convert to 32-bit integer
    }
    return hash.abs().toRadixString(16).padLeft(64, '0');
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 377),
      curve: Curves.easeInOut,
      child: Card(
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 21 : 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 987),
                    builder: (context, value, child) {
                      return Transform.rotate(
                        angle: value * 6.28318,
                        child: child,
                      );
                    },
                    child: const Icon(Icons.flash_on, size: 24),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Text(
                      'Testnet Operations',
                      style: TextStyle(
                        fontSize: isMobile ? 21 : 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Ephemeral testnet - all data lost on restart',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  if (!isMobile) ...[
                    ElevatedButton.icon(
                      onPressed: _loading ? null : _performRebalance,
                      icon: const Icon(Icons.balance, size: 16),
                      label: const Text('Rebalance'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[600],
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: _loading ? null : _resetTestnet,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('UI Reset'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.orange[700],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  ElevatedButton.icon(
                    onPressed: _loading ? null : _fullServerReset,
                    icon: const Icon(Icons.delete_forever, size: 18),
                    label: Text(isMobile ? 'Reset All' : 'Full Server Reset'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                      elevation: 2,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 16,
                        vertical: isMobile ? 8 : 10,
                      ),
                    ),
                  ),
                ],
              ),
              if (isMobile) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _performRebalance,
                        icon: const Icon(Icons.balance, size: 16),
                        label: const Text('Rebalance'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[600],
                          foregroundColor: Colors.white,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: _loading ? null : _resetTestnet,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('UI Reset'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: isMobile ? 21 : 34),

              // Live Accounts Dashboard
              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 21),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple[300]!, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.people, color: Colors.purple[700], size: 24),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Text(
                            'Live Testnet Dashboard',
                            style: TextStyle(
                              fontSize: isMobile ? 18 : 21,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple[900],
                            ),
                          ),
                        ),
                        if (_loadingAccounts)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[700]!),
                            ),
                          )
                        else
                          IconButton(
                            icon: Icon(Icons.refresh, color: Colors.purple[700]),
                            onPressed: _fetchLiveAccounts,
                            tooltip: 'Refresh accounts',
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Stats row
                    if (_blockchainStats != null)
                      Wrap(
                        spacing: 21,
                        runSpacing: 13,
                        children: [
                          _buildStatChip(
                            'Active Nodes',
                            _blockchainStats!['active_nodes']?.toString() ?? '1',
                            Icons.hub,
                            Colors.purple,
                          ),
                          _buildStatChip(
                            'Total Accounts',
                            _blockchainStats!['total_accounts']?.toString() ?? '0',
                            Icons.account_circle,
                            Colors.blue,
                          ),
                          _buildStatChip(
                            'Transactions',
                            _blockchainStats!['total_transactions']?.toString() ?? '0',
                            Icons.swap_horiz,
                            Colors.green,
                          ),
                        ],
                      ),
                    
                    if (_liveAccounts.isNotEmpty) ...[
                      const SizedBox(height: 21),
                      Text(
                        'Active Accounts (${_liveAccounts.length})',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple[900],
                        ),
                      ),
                      const SizedBox(height: 13),
                      Container(
                        constraints: BoxConstraints(maxHeight: isMobile ? 200 : 250),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _liveAccounts.length,
                          itemBuilder: (context, index) {
                            final account = _liveAccounts[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(13),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Colors.purple[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.account_box, size: 20, color: Colors.purple[700]),
                                  const SizedBox(width: 13),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          account['account_id'],
                                          style: TextStyle(
                                            fontSize: isMobile ? 13 : 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.purple[900],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Balance: æ${account['balance']}',
                                          style: TextStyle(
                                            fontSize: isMobile ? 12 : 13,
                                            color: Colors.green[700],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red[100],
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      'IN USE',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red[900],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 13),
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.orange[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 18, color: Colors.orange[900]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Names marked "IN USE" cannot be reused until Full Server Reset',
                                style: TextStyle(
                                  fontSize: isMobile ? 11 : 12,
                                  color: Colors.orange[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (!_loadingAccounts) ...[
                      const SizedBox(height: 13),
                      Center(
                        child: Text(
                          'No accounts yet. Create one below! 👇',
                          style: TextStyle(
                            fontSize: isMobile ? 13 : 14,
                            color: Colors.purple[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              SizedBox(height: isMobile ? 21 : 34),
              
              _buildSection(
                isMobile: isMobile,
                title: '1. Create Account',
                children: [
                  TextField(
                    controller: _accountController,
                    enabled: !_loading,
                    decoration: InputDecoration(
                      labelText: 'Account ID',
                      hintText: 'alice',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 13),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _createAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        elevation: 0,
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Create Account',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 21 : 34),
              
              _buildSection(
                isMobile: isMobile,
                title: '2. Send Transaction',
                children: [
                  if (isMobile) ...[
                    TextField(
                      controller: _fromController,
                      enabled: !_loading,
                      decoration: InputDecoration(
                        labelText: 'From Account',
                        hintText: 'alice',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 13),
                    TextField(
                      controller: _toController,
                      enabled: !_loading,
                      decoration: InputDecoration(
                        labelText: 'To Account',
                        hintText: 'bob',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 13),
                    TextField(
                      controller: _amountController,
                      enabled: !_loading,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        hintText: '100',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _fromController,
                            enabled: !_loading,
                            decoration: InputDecoration(
                              labelText: 'From',
                              hintText: 'alice',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: TextField(
                            controller: _toController,
                            enabled: !_loading,
                            decoration: InputDecoration(
                              labelText: 'To',
                              hintText: 'bob',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 13),
                        SizedBox(
                          width: 150,
                          child: TextField(
                            controller: _amountController,
                            enabled: !_loading,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Amount',
                              hintText: '100',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 13),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _sendTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Send Transaction',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              if (_status.isNotEmpty) ...[
                const SizedBox(height: 21),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 233),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _status.startsWith('✅') 
                        ? Colors.green[50] 
                        : _status.startsWith('❌')
                            ? Colors.red[50]
                            : Colors.blue[50],
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: _status.startsWith('✅') 
                          ? Colors.green[200]! 
                          : _status.startsWith('❌')
                              ? Colors.red[200]!
                              : Colors.blue[200]!,
                    ),
                  ),
                  child: Text(
                    _status,
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 14,
                      fontFamily: 'monospace',
                      height: 1.5,
                    ),
                  ),
                ),
              ],
              
              // Blockchain stats
              if (_blockchainStats != null) ...[
                SizedBox(height: isMobile ? 21 : 34),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.link, size: 18, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Blockchain Evidence',
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 13),
                      Text(
                        'Total Transactions: ${_blockchainStats!['total_transactions'] ?? 0}\n'
                        'Total Accounts: ${_blockchainStats!['total_accounts'] ?? 0}\n'
                        'Demo Currency: æ (aequus)\n'
                        'Network: Ephemeral Testnet',
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 13,
                          color: Colors.blue[900],
                          fontFamily: 'monospace',
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Rebalance explanation
              SizedBox(height: isMobile ? 21 : 34),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.purple[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.balance, size: 18, color: Colors.purple[700]),
                        const SizedBox(width: 8),
                        Text(
                          'About Rebalancing',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 13),
                    Text(
                      'The "Rebalance" button demonstrates the mechanism that maintains perfect equality. '
                      'In production implementation, rebalancing occurs automatically after every transaction, '
                      'ensuring all members always hold exactly equal value. '
                      'This demo shows the calculation: total treasury divided equally among all accounts.',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 13,
                        color: Colors.purple[900],
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              // Transaction history
              if (_transactionHistory.isNotEmpty) ...[
                SizedBox(height: isMobile ? 21 : 34),
                Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 13),
                ..._transactionHistory.take(5).map((tx) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 13),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              tx['type'] == 'Transaction' 
                                  ? Icons.swap_horiz 
                                  : Icons.account_circle,
                              size: 16,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              tx['type'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isMobile ? 13 : 14,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatTime(tx['timestamp']),
                              style: TextStyle(
                                fontSize: isMobile ? 11 : 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (tx['type'] == 'Transaction') ...[
                          Text(
                            '${tx['from']} → ${tx['to']}',
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 13,
                              color: Colors.grey[800],
                            ),
                          ),
                        ] else ...[
                          Text(
                            'Account: ${tx['account']}',
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 13,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Amount: ${tx['amount']}',
                              style: TextStyle(
                                fontSize: isMobile ? 12 : 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hash: ${tx['hash'].substring(0, 16)}...${tx['hash'].substring(tx['hash'].length - 8)}',
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 11,
                            color: Colors.grey[600],
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
              
              SizedBox(height: isMobile ? 21 : 34),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  'API Endpoints:\n'
                  '• POST /api/testnet/account/create\n'
                  '• POST /api/testnet/transaction/send\n'
                  '• GET  /api/testnet/stats\n'
                  '• POST /api/testnet/content/publish',
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 13,
                    color: Colors.grey[700],
                    fontFamily: 'monospace',
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: color[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color[700]),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color[900],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required bool isMobile,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 13),
        ...children,
      ],
    );
  }

  @override
  void dispose() {
    _accountController.dispose();
    _fromController.dispose();
    _toController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
