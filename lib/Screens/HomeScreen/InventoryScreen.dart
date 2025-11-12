import 'package:ezzybill/DataBase/firebaseDatabase.dart';
import 'package:ezzybill/Screens/InvoiceScreen/Invoicescreen.dart';
import 'package:flutter/material.dart';
import 'package:ezzybill/consts/consts.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class Inventoryscreen extends StatefulWidget {
  final int billNo;
  final ScrollController externalScrollController;
  final ValueNotifier<bool> isHeaderVisible;

  Inventoryscreen({
    required this.billNo,
    required this.externalScrollController,
    required this.isHeaderVisible,
  });

  @override
  State<Inventoryscreen> createState() => _InventoryscreenState();
}

class _InventoryscreenState extends State<Inventoryscreen> {
  List<FoodItem_firebase> FooditemList = [];
  List<int> itemCounts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    widget.externalScrollController.addListener(() {
      if (widget.externalScrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        widget.isHeaderVisible.value = false;
      } else if (widget.externalScrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        widget.isHeaderVisible.value = true;
      }
    });

    fetchFoodItems().then((items) {
      setState(() {
        FooditemList = items;
        itemCounts = List.generate(FooditemList.length, (index) => 0);
        isLoading = false;
      });
    });
  }

  double calculateTotalAmount() {
    return itemCounts.asMap().entries.fold(0, (total, entry) {
      int index = entry.key;
      int count = entry.value;
      int price = FooditemList[index].price;
      return total + (count * price);
    });
  }

  void increment(int index) {
    setState(() {
      itemCounts[index]++;
    });
  }

  void decrement(int index) {
    if (itemCounts[index] > 0) {
      setState(() {
        itemCounts[index]--;
      });
    }
  }

  Widget buildShimmerItem(double height, double width) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        height: height * 0.4,
        width: width,
        child: Column(
          children: [
            Container(height: height * 0.25, color: Colors.white),
            SizedBox(height: 8),
            Container(height: 20, width: width * 0.5, color: Colors.white),
            Spacer(),
            Container(height: 20, width: width * 0.3, color: Colors.white),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height - 100;
    double screenWidth = MediaQuery.of(context).size.width;
    double totalAmount = calculateTotalAmount();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = (screenWidth / 160).floor().clamp(2, 4);
            return Column(
              children: [
                SizedBox(height: 2),
                Expanded(
                  child: isLoading
                      ? GridView.builder(
                          controller: widget.externalScrollController,
                          padding: const EdgeInsets.all(10),
                          itemCount: 6,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.75,
                            mainAxisExtent: screenHeight * 0.4,
                          ),
                          itemBuilder: (_, __) =>
                              buildShimmerItem(screenHeight, screenWidth),
                        )
                      : GridView.builder(
                          controller: widget.externalScrollController,
                          physics: BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            2,
                            2,
                            2,
                            MediaQuery.of(context).viewInsets.bottom +
                                (itemCounts.any((c) => c > 0)
                                    ? screenHeight * 0.13
                                    : 80),
                          ),
                          itemCount: FooditemList.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.75,
                            mainAxisExtent: screenHeight * 0.4,
                          ),
                          itemBuilder: (context, index) {
                            final item = FooditemList[index];
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 6),
                              padding: EdgeInsets.all(8),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item.imageUrl,
                                      width: double.infinity,
                                      height: screenHeight * 0.25,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Image.asset(
                                        icNoimage,
                                        width: double.infinity,
                                        height: screenHeight * 0.25,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.015),
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      fontFamily: bold,
                                      color: darkFontGrey,
                                      fontSize: screenWidth * 0.035,
                                    ),
                                  ),
                                  Spacer(),
                                  Row(
                                    children: [
                                      Text(
                                        "${item.price}",
                                        style: TextStyle(
                                          fontFamily: semibold,
                                          color: Colors.black87,
                                          fontSize: screenWidth * 0.035,
                                        ),
                                      ),
                                      Spacer(),
                                      Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: whiteColor,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 4,
                                                  spreadRadius: 1,
                                                  offset: Offset(2, 2),
                                                )
                                              ],
                                            ),
                                            child: SizedBox(
                                              width: screenWidth * 0.08,
                                              height: screenWidth * 0.08,
                                              child: IconButton(
                                                onPressed: itemCounts[index] ==
                                                        0
                                                    ? null
                                                    : () => decrement(index),
                                                icon: Icon(Icons.remove),
                                                iconSize: screenWidth * 0.04,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            child: Text(
                                              "${itemCounts[index]}",
                                              style: TextStyle(
                                                color: darkFontGrey,
                                                fontSize: screenWidth * 0.03,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: whiteColor,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 4,
                                                  spreadRadius: 1,
                                                  offset: Offset(2, 2),
                                                )
                                              ],
                                            ),
                                            child: SizedBox(
                                              width: screenWidth * 0.08,
                                              height: screenWidth * 0.08,
                                              child: IconButton(
                                                onPressed: () =>
                                                    increment(index),
                                                icon: Icon(Icons.add),
                                                iconSize: screenWidth * 0.04,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: itemCounts.any((count) => count > 0)
          ? Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 12,
              ),
              child: Container(
                height: screenHeight * 0.12,
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      spreadRadius: 1,
                      offset: Offset(2, 2),
                    )
                  ],
                  color: Colors.white,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Items: ${itemCounts.fold(0, (a, b) => a + b)}",
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                            ),
                          ),
                          Text(
                            "Rs. $totalAmount",
                            style: TextStyle(
                              fontSize: screenWidth * 0.06,
                              fontFamily: semibold,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        onPressed: () {
                          Get.to(() => Invoicescreen(
                                itemCounts: itemCounts,
                                totalAmount: totalAmount,
                                foodItemList: FooditemList,
                                billNo: widget.billNo,
                              ));
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shopping_cart,
                                size: 24, color: whiteColor),
                            SizedBox(width: 8),
                            Text("View Cart",
                                style: TextStyle(color: Colors.white)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_ios_rounded,
                                color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
