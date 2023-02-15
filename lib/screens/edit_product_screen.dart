import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:string_validator/string_validator.dart';

import '../providers/products_notifier.dart';
import '../models/product.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  Product _editedProduct = Product.emptyValue();
  Product? _initialValues;
  bool _isErrorImage = false;
  bool _isInit = true;
  bool _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final prodId = ModalRoute.of(context)?.settings.arguments as String?;
      if (prodId != null) {
        _editedProduct = context.read<ProductsNotifier>().findById(prodId);
        _initialValues = _editedProduct.copyWith();
        _imageUrlController.text = _initialValues?.imageUrl ?? '';
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValidate = _formKey.currentState?.validate();
    if (isValidate == null || !isValidate || _isErrorImage) return;

    _formKey.currentState?.save();
    setState(() {
      _isLoading = true;
    });

    try {
      if (_initialValues != null) {
        await context.read<ProductsNotifier>().updateProduct(_editedProduct.id, _editedProduct);
      } else {
        await context.read<ProductsNotifier>().addProduct(_editedProduct);
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('An error occurred!'),
            content: const Text('Something went wrong.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text('Okay'),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.always,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initialValues?.title,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please provide a value.';
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        _editedProduct = _editedProduct.copyWith(title: newValue ?? '');
                      },
                    ),
                    TextFormField(
                      initialValue: _initialValues?.price.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Price',
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please provide a value.';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number.';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Please enter a number greater than zero.';
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        if (newValue != null) {
                          _editedProduct =
                              _editedProduct.copyWith(price: double.tryParse(newValue));
                        }
                      },
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(_descriptionFocusNode);
                      },
                    ),
                    TextFormField(
                      initialValue: _initialValues?.description,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                      maxLength: 125,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please provide a value.';
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        _editedProduct = _editedProduct.copyWith(description: newValue ?? '');
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child:
                              _imageUrlController.text.isEmpty || !isURL(_imageUrlController.text)
                                  ? const Center(child: Text('Enter a URL'))
                                  : FittedBox(
                                      child: CachedNetworkImage(
                                        imageUrl: _imageUrlController.text,
                                        fit: BoxFit.cover,
                                        progressIndicatorBuilder: (context, url, progress) {
                                          return Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: CircularProgressIndicator(
                                              color: Theme.of(context).primaryColor,
                                              value: progress.progress,
                                            ),
                                          );
                                        },
                                        errorWidget: (ctx, url, error) {
                                          _isErrorImage = true;
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(
                                              Icons.error,
                                              color: Theme.of(context).colorScheme.error,
                                            ),
                                          );
                                        },
                                        imageBuilder: (ctx, imageProvider) {
                                          _isErrorImage = false;
                                          return Image(image: imageProvider);
                                        },
                                      ),
                                    ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an image URL.';
                              }
                              if (!isURL(_imageUrlController.text)) {
                                return 'Please enter a valid URL.';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _editedProduct = _editedProduct.copyWith(imageUrl: newValue);
                            },
                            onChanged: (value) {
                              if (_isErrorImage) {
                                setState(() {});
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
