// import 'dart:ui';

// import 'package:ezzybill/consts/consts.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:intl/intl.dart';

// Widget _monthlySalesGraph(Size size, dynamic monthlySalesData) {
//   if (monthlySalesData.isEmpty) {
//     return Center(child: CircularProgressIndicator());
//   }

//   final months = monthlySalesData.keys.toList()..sort();
//   final values = months.map((m) => monthlySalesData[m] ?? 0.0).toList();

//   String _formatMonth(String raw) {
//     final parts = raw.split("-");
//     final monthNum = int.tryParse(parts[0]) ?? 1;
//     final monthName = DateFormat.MMM().format(DateTime(0, monthNum));
//     return "$monthName ${parts[1]}";
//   }

//   return Container(
//     margin: EdgeInsets.symmetric(vertical: 16),
//     padding: EdgeInsets.all(12),
//     decoration: BoxDecoration(
//       color: secondaryColor2,
//       borderRadius: BorderRadius.circular(14),
//       boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("Monthly Sales Graph", style: TextStyle(fontWeight: FontWeight.bold)),
//         SizedBox(height: 12),
//         SizedBox(
//           height: size.height * 0.25,
//           child: LineChart(LineChartData(
//             titlesData: FlTitlesData(
//               bottomTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   interval: 1,
//                   getTitlesWidget: (value, meta) {
//                     int index = value.toInt();
//                     if (index >= 0 && index < months.length) {
//                       return Text(_formatMonth(months[index]), style: TextStyle(fontSize: 10));
//                     }
//                     return Text('');
//                   },
//                 ),
//               ),
//               leftTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   getTitlesWidget: (value, meta) => Text("₹${value.toInt()}", style: TextStyle(fontSize: 10)),
//                 ),
//               ),
//               topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//               rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//             ),
//             gridData: FlGridData(show: true),
//             borderData: FlBorderData(show: true),
//             lineBarsData: [
//               LineChartBarData(
//                 spots: List.generate(values.length, (i) => FlSpot(i.toDouble(), values[i])),
//                 isCurved: true,
//                 color: Colors.teal,
//                 dotData: FlDotData(show: true),
//                 belowBarData: BarAreaData(show: true, color: Colors.teal.withOpacity(0.2)),
//               )
//             ],
//           )),
//         ),
//       ],
//     ),
//   );
// }
