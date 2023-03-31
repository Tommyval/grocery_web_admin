import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../consts/constants.dart';
import 'orders_widget.dart';

class OrdersList extends StatelessWidget {
  const OrdersList({Key? key, this.isInDashboard = true}) : super(key: key);
  final bool isInDashboard;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data!.docs.isNotEmpty) {
              return Container(
                padding: const EdgeInsets.all(defaultPadding),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: isInDashboard && snapshot.data!.docs.length > 5
                        ? 5
                        : snapshot.data!.docs.length,
                    itemBuilder: (ctx, index) {
                      return Column(
                        children: [
                          OrdersWidget(
                            imageUrl: snapshot.data!.docs[index]['imageUrl'],
                            orderDate: snapshot.data!.docs[index]['orderDate'],
                            price: snapshot.data!.docs[index]['price'],
                            totalPrice: snapshot.data!.docs[index]
                                ['totalPrice'],
                            productId: snapshot.data!.docs[index]['productId'],
                            userId: snapshot.data!.docs[index]['userId'],
                            userName: snapshot.data!.docs[index]['userName'],
                            quantity: snapshot.data!.docs[index]['quantity'],
                          ),
                          const Divider(
                            thickness: 3,
                          ),
                        ],
                      );
                    }),
              );
            } else {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(18.0),
                  child: Text('Your order is empty'),
                ),
              );
            }
          }
          return const Center(
            child: Text(
              'Something went wrong',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
          );
        });
  }
}
