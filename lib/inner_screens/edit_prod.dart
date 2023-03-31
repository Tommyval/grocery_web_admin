import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_admin_panel/screens/loading_manager.dart';
import 'package:grocery_admin_panel/services/global_method.dart';
import 'package:grocery_admin_panel/services/utils.dart';
import 'package:grocery_admin_panel/widgets/buttons.dart';
import 'package:grocery_admin_panel/widgets/text_widget.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class EditProductScreen extends StatefulWidget {
  // static const routeName = '/EditProductScreen';

  const EditProductScreen(
      {Key? key,
      required this.id,
      required this.title,
      required this.price,
      required this.productCat,
      required this.imageUrl,
      required this.isPiece,
      required this.isOnSale,
      required this.salePrice})
      : super(key: key);
  final String id, title, price, productCat, imageUrl;
  final bool isPiece, isOnSale;
  final double salePrice;

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  //categorie
  String _cartValue = 'Vegetables';
  //sale
  late String percToshow;
  String? _salePercent;
  late bool _isOnSale;
  late double _salePrice;
  //image
  File? _pickedImage;
  Uint8List webImage = Uint8List(10);
  late String _imageUrl;
  //kg or piece
  bool _isPiece = false;
  late int val;
  // while loading
  final bool _isloading = false;

  late final TextEditingController _titleController, _priceController;

  int _groupValue = 1;

  @override
  void initState() {
    _priceController = TextEditingController(text: widget.price);
    _titleController = TextEditingController(text: widget.title);
    _salePrice = widget.salePrice;
    _cartValue = widget.productCat;
    _isOnSale = widget.isOnSale;
    _isPiece = widget.isPiece;
    val = _isPiece ? 2 : 1;
    _imageUrl = widget.imageUrl;
    percToshow = (100 - (_salePrice - 100) / double.parse(widget.price))
            .round()
            .toStringAsFixed(1) +
        '%';

    super.initState();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _priceController.clear();
    _titleController.clear();
    _cartValue = 'Vegetables';
    _groupValue = 1;
    _isPiece = false;
    setState(() {
      _pickedImage = null;
      webImage = Uint8List(8);
    });
  }

  bool _isLoading = false;
  void _UpdateProduct() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();

      try {
        setState(() {
          _isLoading = true;
        });
        if (_pickedImage != null) {
          final ref = fb.FirebaseStorage.instance
              .ref()
              .child('productImages')
              .child(widget.id + 'jpeg');
          if (kIsWeb) {
            await ref.putData(webImage);
          } else {
            await ref.putFile(_pickedImage!);
          }
          _imageUrl = await ref.getDownloadURL();
        }

        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.id)
            .update({
          'id': widget.id,
          'title': _titleController.text,
          'price': _priceController.text,
          'salePrice': _salePrice,
          'imageUrl': _pickedImage == null ? widget.imageUrl : _imageUrl,
          'productCategoriesName': _cartValue,
          'isOnSale': _isOnSale,
          'isPiece': _isPiece,
          'createAt': Timestamp.now()
        });

        await Fluttertoast.showToast(
          msg: 'Product updated successfully',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
        );
      } on FirebaseException catch (err) {
        GlobalMethods.errorDialog(context: context, subTitle: '${err.message}');
        setState(() {
          _isLoading = false;
        });
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
  }

  void _uploadForm() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      if (_pickedImage == null) {
        GlobalMethods.errorDialog(
            context: context, subTitle: 'please pickup an image');
        return;
      }
      final _uuid = const Uuid().v4();
      try {
        setState(() {
          _isLoading = true;
        });
        final ref = fb.FirebaseStorage.instance
            .ref()
            .child('productImages')
            .child(_uuid + 'jpeg');
        if (kIsWeb) {
          await ref.putData(webImage);
        } else {
          await ref.putFile(_pickedImage!);
        }
        _imageUrl = await ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('products').doc(_uuid).set({
          'id': _uuid,
          'title': _titleController.text,
          'price': _priceController.text,
          'salePrice': 0.1,
          'imageUrl': _imageUrl,
          'productCategoriesName': _cartValue,
          'isOnSale': false,
          'isPiece': _isPiece,
          'createAt': Timestamp.now()
        });
        _clearForm();
        Fluttertoast.showToast(
          msg: 'Product uploaded successfully',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
        );
      } on FirebaseException catch (err) {
        GlobalMethods.errorDialog(context: context, subTitle: '${err.message}');
        setState(() {
          _isLoading = false;
        });
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Utils(context).getTheme;
    final color = Utils(context).color;
    final _scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    Size size = Utils(context).getScreenSize;

    var inputDecoration = InputDecoration(
      filled: true,
      fillColor: _scaffoldColor,
      border: InputBorder.none,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
          width: 1.0,
        ),
      ),
    );
    return Scaffold(
        // key: context.read<MenuController>().getAddProductscaffoldKey,
        // drawer: const SideMenu(),
        body: LoadingManager(
      isLoading: _isLoading,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // const SizedBox(
            //   height: 25,
            // ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              // child: Header(
              //     title: 'Add product',
              //     showTextField: false,
              //     fct: () {
              //       context
              //           .read<MenuController>()
              //           .controlAddProductsMenu();
              //     }),
            ),
            const SizedBox(
              height: 25,
            ),
            Container(
              width: size.width > 650 ? 650 : size.width,
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextWidget(
                      text: 'Product title*',
                      color: color,
                      isTitle: true,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: _titleController,
                      key: const ValueKey('Title'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a Title';
                        }
                        return null;
                      },
                      decoration: inputDecoration,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: FittedBox(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                TextWidget(
                                  text: 'Price in \$*',
                                  color: color,
                                  isTitle: true,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  width: 100,
                                  child: TextFormField(
                                    controller: _priceController,
                                    key: const ValueKey('Price \$'),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Price is missed';
                                      }
                                      return null;
                                    },
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9.]')),
                                    ],
                                    decoration: inputDecoration,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextWidget(
                                  text: 'Porduct category*',
                                  color: color,
                                  isTitle: true,
                                ),
                                const SizedBox(height: 10),
                                _categoryDropDown(),
                                const SizedBox(
                                  height: 20,
                                ),
                                TextWidget(
                                  text: 'Measure unit*',
                                  color: color,
                                  isTitle: true,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    TextWidget(text: 'Kg', color: color),
                                    Radio(
                                      value: 1,
                                      groupValue: _groupValue,
                                      onChanged: (value) {
                                        setState(() {
                                          _groupValue = 1;
                                          _isPiece = false;
                                        });
                                      },
                                      activeColor: Colors.green,
                                    ),
                                    TextWidget(text: 'piece', color: color),
                                    Radio(
                                      value: 2,
                                      groupValue: _groupValue,
                                      onChanged: (value) {
                                        setState(() {
                                          _groupValue = 2;
                                          _isPiece = true;
                                        });
                                      },
                                      activeColor: Colors.green,
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: [
                                    Checkbox(
                                        value: _isOnSale,
                                        onChanged: (newValue) {
                                          setState(() {
                                            _isOnSale = newValue!;
                                          });
                                        }),
                                  ],
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                TextWidget(
                                  text: 'sale',
                                  color: color,
                                  isTitle: true,
                                ),
                                AnimatedSwitcher(
                                    duration: const Duration(seconds: 1),
                                    child: !_isOnSale
                                        ? Container()
                                        : Row(children: [
                                            TextWidget(
                                              text: '\$' +
                                                  _salePrice.toStringAsFixed(2),
                                              color: color,
                                            ),
                                            const SizedBox(width: 10),
                                            salePercentageDropDownWidget(color)
                                          ]))
                              ],
                            ),
                          ),
                        ),
                        // Image to be picked code is here
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                                height:
                                    size.width > 650 ? 350 : size.width * 0.45,
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(12)),
                                child: _pickedImage == null
                                    ? Image.network(_imageUrl)
                                    : kIsWeb
                                        ? Image.memory(
                                            webImage,
                                            fit: BoxFit.fill,
                                          )
                                        : Image.file(
                                            _pickedImage!,
                                            fit: BoxFit.fill,
                                          )),
                          ),
                        ),
                        Expanded(
                            flex: 1,
                            child: FittedBox(
                              child: Column(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _pickedImage = null;
                                        webImage = Uint8List(8);
                                      });
                                    },
                                    child: TextWidget(
                                      text: 'Clear',
                                      color: Colors.red,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: TextWidget(
                                      text: 'Update image',
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ButtonsWidget(
                            onPressed: () {
                              GlobalMethods.warningDialog(
                                  title: 'Delete',
                                  subtitle: 'press okay to confirm',
                                  fct: () async {
                                    await FirebaseFirestore.instance
                                        .collection('products')
                                        .doc(widget.id)
                                        .delete();
                                    await Fluttertoast.showToast(
                                      msg: 'Product has been deleted',
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                    );
                                    while (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  },
                                  context: context);
                            },
                            text: 'Delete',
                            icon: IconlyBold.danger,
                            backgroundColor: Colors.red.shade300,
                          ),
                          ButtonsWidget(
                            onPressed: () {
                              _UpdateProduct();
                            },
                            text: 'Update',
                            icon: IconlyBold.upload,
                            backgroundColor: Colors.blue,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Future<void> _pickImage() async {
    if (!kIsWeb) {
      final ImagePicker _picker = ImagePicker();
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var selected = File(image.path);
        setState(() {
          _pickedImage = selected;
        });
      } else {
        print('No image has been picked');
      }
    } else if (kIsWeb) {
      final ImagePicker _picker = ImagePicker();
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var f = await image.readAsBytes();
        setState(() {
          webImage = f;
          _pickedImage = File('a');
        });
      } else {
        print('No image has been picked');
      }
    } else {
      print('something went wrong');
    }
  }

  Widget dottedBorder({required Color color}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DottedBorder(
          dashPattern: const [6.7],
          borderType: BorderType.RRect,
          color: color,
          radius: const Radius.circular(12),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_outlined,
                  color: color,
                  size: 50,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextButton(
                    onPressed: () {
                      _pickImage();
                    },
                    child:
                        TextWidget(text: 'choose an image', color: Colors.blue))
              ],
            ),
          )),
    );
  }

  Widget _categoryDropDown() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            value: _cartValue,
            items: const [
              DropdownMenuItem(
                child: Text('Vegetables'),
                value: 'Vegetables',
              ),
              DropdownMenuItem(
                child: Text('Fruits'),
                value: 'Fruits',
              ),
              DropdownMenuItem(
                child: Text('Grains'),
                value: 'Grains',
              ),
              DropdownMenuItem(
                child: Text('Nuts'),
                value: 'Nuts',
              ),
              DropdownMenuItem(
                child: Text('Herbs'),
                value: 'Herbs',
              ),
              DropdownMenuItem(
                child: Text('Spices'),
                value: 'Spices',
              )
            ],
            onChanged: ((value) {
              setState(() {
                _cartValue = value!;
              });
            }),
            hint: const Text('Select a category'),
          ),
        ),
      ),
    );
  }

  DropdownButtonHideUnderline salePercentageDropDownWidget(Color color) {
    return DropdownButtonHideUnderline(
        child: DropdownButton<String>(
      items: const [
        DropdownMenuItem<String>(
          child: Text('10%'),
          value: '10',
        ),
        DropdownMenuItem<String>(
          child: Text('15%'),
          value: '15',
        ),
        DropdownMenuItem<String>(
          child: Text('20%'),
          value: '20',
        ),
        DropdownMenuItem<String>(
          child: Text('25%'),
          value: '25',
        ),
        DropdownMenuItem<String>(
          child: Text('50%'),
          value: '50',
        ),
        DropdownMenuItem<String>(
          child: Text('75%'),
          value: '75',
        ),
        DropdownMenuItem<String>(
          child: Text('0%'),
          value: '0',
        ),
      ],
      onChanged: (value) {
        if (value == '0') {
          return;
        } else {
          setState(() {
            _salePercent = value;
            _salePrice = double.parse(widget.price) -
                (double.parse(value!) * double.parse(widget.price) / 100);
            // to calculate the sale price
          });
        }
      },
      hint: Text(_salePercent ?? percToshow),
      value: _salePercent,
    ));
  }
}
