import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_admin_panel/inner_screens/edit_prod.dart';
import 'package:grocery_admin_panel/services/global_method.dart';

import '../services/utils.dart';
import 'text_widget.dart';

class ProductWidget extends StatefulWidget {
  const ProductWidget({
    Key? key,
    required this.id,
  }) : super(key: key);
  final String id;
  @override
  _ProductWidgetState createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  @override
  void initState() {
    getProductData();
    super.initState();
  }

  bool _isLoading = false;
  String title = '';
  String productCat = '';
  String? imageUrl;
  String price = '0.0';
  double salePrice = 0.0;
  bool isOnSale = false;
  bool isPiece = false;

  Future<void> getProductData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final DocumentSnapshot prodDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.id)
          .get();
      if (prodDoc == null) {
        return;
      } else {
        setState(() {
          title = prodDoc.get('title');
          productCat = prodDoc.get('productCategoriesName');
          imageUrl = prodDoc.get('imageUrl');
          price = prodDoc.get('price');
          salePrice = prodDoc.get('salePrice');
          isOnSale = prodDoc.get('isOnSale');
          isPiece = prodDoc.get('isPiece');
        });
      }
    } catch (err) {
      GlobalMethods.errorDialog(context: context, subTitle: '$err');
      setState(() {
        _isLoading = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = Utils(context).getScreenSize;

    final color = Utils(context).color;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor.withOpacity(0.6),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => EditProductScreen(
                  id: widget.id,
                  title: title,
                  price: price,
                  productCat: productCat,
                  imageUrl: imageUrl == null
                      ? 'https://sunrisefruits.com/wp-content/uploads/2018/06/Productos-Naranja-Sunrisefruitscompany.jpg'
                      : imageUrl!,
                  isPiece: isPiece,
                  isOnSale: isOnSale,
                  salePrice: salePrice),
            ));
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 3,
                      child: Image.network(
                        // 'assets/images/Apricot.png',
                        // 'https://sunrisefruits.com/wp-content/uploads/2018/06/Productos-Naranja-Sunrisefruitscompany.jpg',
                        imageUrl == null
                            ? 'https://sunrisefruits.com/wp-content/uploads/2018/06/Productos-Naranja-Sunrisefruitscompany.jpg'
                            : imageUrl!,
                        fit: BoxFit.fill,
                        // width: screenWidth * 0.12,
                        height: size.width * 0.12,
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton(
                        itemBuilder: (context) => [
                              PopupMenuItem(
                                onTap: () {},
                                child: const Text('Edit'),
                                value: 1,
                              ),
                              PopupMenuItem(
                                onTap: () {},
                                child: const Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                                value: 2,
                              )
                            ])
                  ],
                ),
                const SizedBox(
                  height: 2,
                ),
                Row(
                  children: [
                    TextWidget(
                      // '\$${3.2}',
                      text: isOnSale
                          ? '\$${salePrice.toStringAsFixed(2)}'
                          : '\$$price',
                      color: color,
                      textSize: 18,
                    ),
                    const SizedBox(
                      width: 7,
                    ),
                    Visibility(
                        visible:
                            //true,
                            isOnSale,
                        child: Text(
                          // '\$${3.2}',
                          '\$$price',
                          style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: color),
                        )),
                    const Spacer(),
                    TextWidget(
                      text: isPiece ? 'piece' : '1Kg',
                      color: color,
                      textSize: 18,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 2,
                ),
                TextWidget(
                  text:
                      //'pineApple',
                      title,
                  color: color,
                  textSize: 24,
                  isTitle: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
