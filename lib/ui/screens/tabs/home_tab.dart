import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme.dart';
import '../../../services/database_service.dart';
import '../../../services/risk_engine.dart';
import '../../../models/user_profile.dart';
import '../../../models/transaction.dart';
import '../../widgets/popups.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  void _simulateSmsTransaction(
    BuildContext context,
    DatabaseService db,
    UserProfile profile,
  ) {
    final tx = ExpenseTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      merchantName: 'ZOMATO',
      amount: 450.0,
      timestamp: DateTime.now(),
      rawSms: 'Spent INR 450 on Zomato',
      riskScoreAtTime: 0,
      toneUsed: '',
    );

    db.addTransaction(tx).then((_) {
      if (!context.mounted) return;
      setState(() {});
      InterventionPopups.showTransactionPopup(
        context: context,
        transaction: tx,
        currentTotal: db.getTotalSpentThisMonth(),
        budget: profile.monthlyFoodBudget,
        profile: profile,
      );
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month} • ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  _MerchantInfo _getMerchantInfo(String merchant) {
    final m = merchant.toUpperCase();
    if (m.contains('SWIGGY')) {
      return _MerchantInfo(Icons.delivery_dining, Colors.orange);
    }
    if (m.contains('ZOMATO')) {
      return _MerchantInfo(Icons.restaurant, Colors.red);
    }
    if (m.contains('DOMINO')) {
      return _MerchantInfo(Icons.local_pizza, Colors.blue);
    }
    if (m.contains('CAFE')) {
      return _MerchantInfo(Icons.local_cafe, Colors.brown);
    }
    return _MerchantInfo(Icons.fastfood, PersonaTheme.primary);
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    final profile = db.getUserProfile();

    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalSpent = db.getTotalSpentThisMonth();
    final riskScore = RiskEngine.calculateRiskScore(
      totalSpent: totalSpent,
      monthlyBudget: profile.monthlyFoodBudget,
      transactionTime: DateTime.now(),
    );
    final budgetPercentage = (totalSpent / profile.monthlyFoodBudget) * 100;
    final color = PersonaTheme.getRiskColor(riskScore);
    final transactions = db.getAllTransactions();

    return PersonaTheme.meshBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'PersonaBudget',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: PersonaTheme.textMain,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.history_toggle_off,
                size: 48,
                color: PersonaTheme.textMuted.withAlpha(128),
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildRiskSection(context, riskScore, color),
                const SizedBox(height: 32),
                _buildBudgetCard(
                  context,
                  totalSpent,
                  profile.monthlyFoodBudget,
                  budgetPercentage,
                  color,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Activity',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'See All',
                        style: TextStyle(color: PersonaTheme.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTransactionList(context, transactions),
              ],
            ),
          ),
        ),
        floatingActionButton:
            FloatingActionButton(
              onPressed: () => _simulateSmsTransaction(context, db, profile),
              backgroundColor: PersonaTheme.primary,
              elevation: 4,
              child: const Icon(
                Icons.add,
                color: PersonaTheme.background,
                size: 30,
              ),
            ).animate().scale(
              delay: 1.seconds,
              duration: 500.ms,
              curve: Curves.elasticOut,
            ),
      ),
    );
  }

  Widget _buildRiskSection(
    BuildContext context,
    double riskScore,
    Color color,
  ) {
    return Center(
      child: PersonaTheme.glassCard(
        opacity: 0.05,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                        width: 200,
                        height: 200,
                        child: ShaderMask(
                          shaderCallback: (rect) => SweepGradient(
                            colors: [color.withAlpha(0), color],
                            stops: const [0.5, 1.0],
                          ).createShader(rect),
                          child: CircularProgressIndicator(
                            value: riskScore / 100,
                            strokeWidth: 12,
                            backgroundColor: Colors.white.withAlpha(12),
                            valueColor: const AlwaysStoppedAnimation(
                              Colors.white,
                            ),
                          ),
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat())
                      .rotate(duration: 8.seconds),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'RISK',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          letterSpacing: 4,
                          fontWeight: FontWeight.w900,
                          color: PersonaTheme.textMuted,
                        ),
                      ),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color.withAlpha(51),
                            color,
                            color,
                            color.withAlpha(51),
                          ],
                        ).createShader(bounds),
                        child: Text(
                          '${riskScore.toInt()}',
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(
                                fontSize: 72,
                                fontWeight: FontWeight.w900,
                                color: Colors
                                    .white, // Color is applied by ShaderMask
                              ),
                        ),
                      ).animate().scale(
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _getRiskStatus(riskScore),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1);
  }

  String _getRiskStatus(double score) {
    if (score > 80) return 'CRITICAL DANGER';
    if (score > 60) return 'HIGH RISK';
    if (score > 40) return 'MODERATE';
    return 'STABLE';
  }

  Widget _buildBudgetCard(
    BuildContext context,
    double spent,
    double budget,
    double percentage,
    Color color,
  ) {
    return PersonaTheme.glassCard(
      opacity: 0.1,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Monthly Budget',
                  style: TextStyle(
                    color: PersonaTheme.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (spent / budget).clamp(0, 1),
                minHeight: 10,
                backgroundColor: Colors.white.withAlpha(12),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Spent',
                      style: TextStyle(
                        color: PersonaTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '₹${spent.toInt()}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Remaining',
                      style: TextStyle(
                        color: PersonaTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '₹${(budget - spent).toInt()}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: PersonaTheme.accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildTransactionList(
    BuildContext context,
    List<ExpenseTransaction> transactions,
  ) {
    if (transactions.isEmpty) {
      return PersonaTheme.glassCard(
        child: const Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: Text(
              'No recent spending. You\'re doing great!',
              textAlign: TextAlign.center,
              style: TextStyle(color: PersonaTheme.textMuted),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final merchantInfo = _getMerchantInfo(tx.merchantName);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child:
              PersonaTheme.glassCard(
                    opacity: 0.08,
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: merchantInfo.color.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          merchantInfo.icon,
                          color: merchantInfo.color,
                        ),
                      ),
                      title: Text(
                        tx.merchantName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        _formatDate(tx.timestamp),
                        style: const TextStyle(
                          color: PersonaTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      trailing: Text(
                        '₹${tx.amount.toInt()}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  )
                  .animate(delay: (index * 50).ms)
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: 0.1),
        );
      },
    );
  }
}

class _MerchantInfo {
  final IconData icon;
  final Color color;
  _MerchantInfo(this.icon, this.color);
}
