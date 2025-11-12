import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezzybill/DataBase/invoicesHistory.dart';
import 'package:ezzybill/DataBase/salesData.dart';
import 'package:flutter/material.dart';
import 'package:ezzybill/widgetsCommon/CardComm.dart';
import 'package:ezzybill/consts/consts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class Historyscreen extends StatefulWidget {
  @override
  State<Historyscreen> createState() => _HistoryscreenState();
}

class _HistoryscreenState extends State<Historyscreen> {
  double totalTodaySales = 0.0;
  double totalMonthSales = 0.0;
  bool isLoading = true;
  bool isHistoryLoading = true;
  List<Map<String, dynamic>> invoiceHistory = [];

  @override
  void initState() {
    super.initState();
    _loadTotalSales();
    _loadInvoiceHistory();
  }

  Future<void> _loadTotalSales() async {
    setState(() => isLoading = true);
    totalTodaySales = await fetchTodayTotalSales();
    totalMonthSales = await fetchMonthlyTotalSales();
    setState(() => isLoading = false);
  }

  Future<void> _loadInvoiceHistory() async {
    setState(() => isHistoryLoading = true);
    invoiceHistory = await fetchInvoicesFromFirestore();

    invoiceHistory.sort((a, b) {
      final timeA = (a['timestamp'] as Timestamp?)?.toDate() ?? DateTime(0);
      final timeB = (b['timestamp'] as Timestamp?)?.toDate() ?? DateTime(0);
      return timeB.compareTo(timeA);
    });

    setState(() => isHistoryLoading = false);
  }

  Widget _buildShimmerPlaceholder() {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          height: 12,
                          color: Colors.white,
                          margin: EdgeInsets.only(bottom: 6)),
                      Container(height: 12, width: 150, color: Colors.white),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Container(height: 20, width: 60, color: Colors.white),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerCardPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Row(
        children: [
          Expanded(
            child: CardComm(
              count: "...",
              title: "Today Sales",
              screenHeight: 610,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: CardComm(
              count: "...",
              title: "This Month",
              screenHeight: 610,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height - 100;
    final todayDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final yesterdayDate = DateFormat('dd-MM-yyyy')
        .format(DateTime.now().subtract(Duration(days: 1)));

    final Set<String> shownHeaders = {};
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadTotalSales();
          await _loadInvoiceHistory();
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                isLoading
                    ? _buildShimmerCardPlaceholder()
                    : Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: CardComm(
                                count: "₹${totalTodaySales.toStringAsFixed(2)}",
                                title: "Today Sales",
                                screenHeight: screenHeight,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: CardComm(
                                count: "₹${totalMonthSales.toStringAsFixed(2)}",
                                title: "This Month",
                                screenHeight: screenHeight,
                              ),
                            ),
                          ],
                        ),
                      ),
                SizedBox(height: 10),
                Expanded(
                  child: isHistoryLoading
                      ? _buildShimmerPlaceholder()
                      : ListView.builder(
                          itemCount: invoiceHistory.length,
                          itemBuilder: (context, index) {
                            final invoice = invoiceHistory[index];
                            final invoiceDate = invoice['timestamp'] != null
                                ? DateFormat('dd-MM-yyyy').format(
                                    (invoice['timestamp'] as Timestamp)
                                        .toDate())
                                : 'Unknown';
                            final invoiceMonth = invoice['timestamp'] != null
                                ? DateFormat('MM-yyyy').format(
                                    (invoice['timestamp'] as Timestamp)
                                        .toDate())
                                : 'Unknown';
                            var label = "a";
                            if (todayDate == invoiceDate) {
                              label = "Today";
                            } else if (yesterdayDate == invoiceDate) {
                              label = "Yesterday";
                            } else {
                              label = "$invoiceMonth";
                            }
                            final shouldShowHeader =
                                !shownHeaders.contains(label);
                            shownHeaders.add(label);

                            return Column(
                              children: [
                                if (shouldShowHeader)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.01),
                                  padding: EdgeInsets.all(screenHeight * 0.01),
                                  decoration: BoxDecoration(
                                    color: secondaryColor2,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                        offset: Offset(2, 2),
                                      )
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.receipt_long,
                                          color: primaryColor, size: 28),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                "Bill No: ${invoice['bill_no']}",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16)),
                                            Text(
                                              "Date: ${invoice['timestamp'] != null ? DateFormat('dd-MM-yyyy HH:mm').format((invoice['timestamp'] as Timestamp).toDate()) : 'Unknown'}",
                                              style: TextStyle(fontSize: 14),
                                            )
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text("₹${invoice['total_amount']}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
                                          SizedBox(height: 4),
                                          Visibility(
                                            visible:
                                                !(invoice['status'] ?? false),
                                            child: TextButton(
                                              onPressed: invoice['status'] ==
                                                      true
                                                  ? null
                                                  : () async {
                                                      await updateTotalSales(
                                                          invoice['bill_no'],
                                                          invoice[
                                                              'total_amount']);
                                                      await markInvoiceAsReceived(
                                                          invoice['bill_no'],
                                                          true);
                                                      await _loadTotalSales();
                                                      await _loadInvoiceHistory();
                                                    },
                                              style: TextButton.styleFrom(
                                                side: BorderSide(
                                                    color: primaryColor2),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 6, vertical: 4),
                                                minimumSize: Size.zero,
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                              child: Text("Recived",
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: greencolor)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
