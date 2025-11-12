import 'package:ezzybill/DataBase/firebaseHomedata.dart';
import 'package:ezzybill/DataBase/salesData.dart';
import 'package:ezzybill/Screens/HomeScreen/BillingScreen.dart';
import 'package:ezzybill/consts/consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class Homescreen extends StatefulWidget {
  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  int activeCustomers = 0;
  int lowStockItems = 0;
  double pendingPayments = 0;
  int unsentInvoices = 0;

  final FirebaseHomeData firebaseHomeData = FirebaseHomeData();
  Map<String, double> monthlySalesData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() => isLoading = true);
    await Future.wait([_loadStats(), _loadMonthlySales()]);
    setState(() => isLoading = false);
  }

  Future<void> _loadMonthlySales() async {
    monthlySalesData = await fetchMonthlySales();
  }

  Future<void> _loadStats() async {
    activeCustomers = await firebaseHomeData.getActiveCustomers();
    lowStockItems = await firebaseHomeData.getTotalStockItems(10);
    pendingPayments = await firebaseHomeData
        .getPendingPaymentsTotal()
        .then((v) => v.toDouble());
    unsentInvoices = await firebaseHomeData.getUnsentInvoicesCount();
  }

  void createNewInvoice() {
    Get.to(() => DynamicBillTabs());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = size.width * 0.04;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Dashboard",
                      style: TextStyle(
                          fontSize: size.width * 0.06,
                          fontWeight: FontWeight.w600)),
                  SizedBox(height: 20),
                  _createBillCard(size),
                  SizedBox(height: 24),
                  isLoading ? _dashboardShimmer(size) : _dashboardGrid(size),
                  SizedBox(height: 16),
                  isLoading ? _graphShimmer(size) : _monthlySalesGraph(size),
                  SizedBox(height: 24),
                  _tipCard(size),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _createBillCard(Size size) {
    return Hero(
      tag: "createBill",
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: createNewInvoice,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: size.height * 0.14,
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: primaryColor2,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline,
                    size: size.width * 0.09, color: Colors.black),
                SizedBox(width: 12),
                Flexible(
                  child: Text('Create New Bill',
                      style: TextStyle(
                          fontSize: size.width * 0.045,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dashboardGrid(Size size) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      physics: NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      children: [
        _statusCard("Today's Active Customers", "$activeCustomers",
            Icons.people_alt_rounded, Colors.indigo, size),
        _statusCard("Total Stock Items", "$lowStockItems Items",
            Icons.inventory_2_outlined, Colors.redAccent, size),
        _statusCard("Unsettled Invoices", "$unsentInvoices", Icons.mail_outline,
            Colors.purple, size),
        _statusCard("Pending Payments", "₹$pendingPayments", Icons.money_off,
            Colors.orange, size),
      ],
    );
  }

  Widget _statusCard(
      String title, String value, IconData icon, Color color, Size size) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: size.width * 0.07, color: color),
          SizedBox(height: size.height * 0.01),
          Text(value,
              style: TextStyle(
                  fontSize: size.width * 0.05, fontWeight: FontWeight.bold)),
          Text(title,
              style: TextStyle(
                  fontSize: size.width * 0.034, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _monthlySalesGraph(Size size) {
    final months = monthlySalesData.keys.toList()..sort();
    final values = months.map((m) => monthlySalesData[m] ?? 0.0).toList();

    String _formatMonth(String raw) {
      final parts = raw.split("-");
      final monthNum = int.tryParse(parts[0]) ?? 1;
      final monthName = DateFormat.MMM().format(DateTime(0, monthNum));
      return "$monthName";
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: secondaryColor2,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Monthly Sales Graph",
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          SizedBox(
            height: size.height * 0.25,
            child: LineChart(LineChartData(
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    reservedSize: 22,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < months.length) {
                        return Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(_formatMonth(months[index]),
                              style: TextStyle(fontSize: 10)),
                        );
                      }
                      return Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    getTitlesWidget: (value, meta) => Text("₹${value.toInt()}",
                        style: TextStyle(fontSize: 10)),
                  ),
                ),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(
                      values.length, (i) => FlSpot(i.toDouble(), values[i])),
                  isCurved: true,
                  color: Colors.teal,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                      show: true, color: Colors.teal.withOpacity(0.2)),
                )
              ],
            )),
          ),
        ],
      ),
    );
  }

  Widget _dashboardShimmer(Size size) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      physics: NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      children: List.generate(
        4,
        (index) => Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    );
  }

  Widget _graphShimmer(Size size) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: size.height * 0.25,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _tipCard(Size size) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline,
              color: Colors.green, size: size.width * 0.055),
          SizedBox(width: 12),
          Expanded(
              child: Text(
                  "💡 Tip: Automate invoice sending from settings > automation.",
                  style: TextStyle(fontSize: size.width * 0.036))),
        ],
      ),
    );
  }
}
