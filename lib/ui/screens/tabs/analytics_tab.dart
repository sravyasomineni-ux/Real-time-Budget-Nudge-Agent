import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme.dart';
import '../../../services/database_service.dart';
import '../../../models/transaction.dart';
import '../../../models/user_profile.dart';

class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    final profile = db.getUserProfile();
    final transactions = db.getAllTransactions();

    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: transactions.isEmpty
          ? Center(
              child: Text(
                'No transactions yet. Waiting for SMS...',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSummaryCards(
                    context,
                    transactions,
                    profile,
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
                  const SizedBox(height: 30),
                  Text(
                    'Last 7 Days',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: _buildBarChart(
                      transactions,
                    ).animate().fadeIn(delay: 200.ms).scaleXY(begin: 0.95),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Spending by Merchant',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: _buildPieChart(
                      transactions,
                    ).animate().fadeIn(delay: 400.ms).scaleXY(begin: 0.95),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    List<ExpenseTransaction> txs,
    UserProfile profile,
  ) {
    final now = DateTime.now();
    final thisMonthTxs = txs
        .where(
          (tx) =>
              tx.timestamp.year == now.year && tx.timestamp.month == now.month,
        )
        .toList();

    double totalSpent = thisMonthTxs.fold(0.0, (sum, tx) => sum + tx.amount);

    // Calculate top merchant
    Map<String, double> merchantSpend = {};
    for (var tx in thisMonthTxs) {
      merchantSpend[tx.merchantName] =
          (merchantSpend[tx.merchantName] ?? 0) + tx.amount;
    }

    String topMerchant = 'None';
    if (merchantSpend.isNotEmpty) {
      var sorted = merchantSpend.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      topMerchant = sorted.first.key;
    }

    // calculate average daily spend for the month so far
    int daysInMonth = now.day; // days passed so far
    double avgDaily = totalSpent / daysInMonth;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Avg Daily',
            value: '₹${avgDaily.toStringAsFixed(0)}',
            icon: Icons.show_chart,
            color: PersonaTheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Top Merchant',
            value: topMerchant,
            icon: Icons.storefront,
            color: PersonaTheme.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(List<ExpenseTransaction> txs) {
    final now = DateTime.now();
    // Initialize last 7 days to 0
    List<double> dailyTotals = List.filled(7, 0.0);
    List<String> labels = [];

    for (int i = 6; i >= 0; i--) {
      DateTime targetDate = now.subtract(Duration(days: i));
      labels.add('${targetDate.day}/${targetDate.month}');

      double totalForDay = txs
          .where(
            (tx) =>
                tx.timestamp.year == targetDate.year &&
                tx.timestamp.month == targetDate.month &&
                tx.timestamp.day == targetDate.day,
          )
          .fold(0.0, (sum, tx) => sum + tx.amount);

      dailyTotals[6 - i] = totalForDay;
    }

    double maxVal = 100.0;
    if (dailyTotals.isNotEmpty) {
      maxVal = dailyTotals.reduce((curr, next) => curr > next ? curr : next);
      if (maxVal == 0) {
        maxVal = 100;
      } else {
        maxVal = maxVal * 1.2; // Add 20% padding
      }
    }

    return Card(
      color: PersonaTheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxVal,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => PersonaTheme.background,
                tooltipPadding: const EdgeInsets.all(8),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '₹${rod.toY.round()}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 && value.toInt() < labels.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          labels[value.toInt()],
                          style: const TextStyle(
                            color: PersonaTheme.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      );
                    }
                    return const Text('');
                  },
                  reservedSize: 28,
                ),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: dailyTotals.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value,
                    color: PersonaTheme.primary,
                    width: 16,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxVal,
                      color: PersonaTheme.background.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(List<ExpenseTransaction> txs) {
    Map<String, double> merchantSpend = {};
    for (var tx in txs) {
      merchantSpend[tx.merchantName] =
          (merchantSpend[tx.merchantName] ?? 0) + tx.amount;
    }

    if (merchantSpend.isEmpty) return const SizedBox();

    // Sort and limit to top 4, group rest into "Other"
    var sorted = merchantSpend.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    List<PieChartSectionData> sections = [];
    final colors = [
      PersonaTheme.primary,
      PersonaTheme.accent,
      PersonaTheme.warningOrange,
      PersonaTheme.errorRed,
      Colors.purple,
    ];

    double total = merchantSpend.values.fold(0, (a, b) => a + b);

    for (int i = 0; i < sorted.length && i < 5; i++) {
      final isOther = i == 4 && sorted.length > 5;
      final val = isOther
          ? sorted.sublist(4).fold(0.0, (sum, item) => sum + item.value)
          : sorted[i].value;

      final title = isOther ? 'Other' : sorted[i].key;
      final percentage = (val / total) * 100;

      sections.add(
        PieChartSectionData(
          color: colors[i % colors.length],
          value: val,
          title: '${percentage.toStringAsFixed(0)}%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          badgeWidget: _Badge(title, colors[i % colors.length]),
          badgePositionPercentageOffset: 1.2,
        ),
      );
    }

    return Card(
      color: PersonaTheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: PieChart(
          PieChartData(
            sectionsSpace: 4,
            centerSpaceRadius: 40,
            sections: sections,
            pieTouchData: PieTouchData(enabled: true),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PersonaTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: PersonaTheme.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color fill;
  const _Badge(this.text, this.fill);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
