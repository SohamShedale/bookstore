import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:bookstore/common/widgets/builder/cart_list.dart';
import 'package:bookstore/common/widgets/button/basic_app_button.dart';
import 'package:bookstore/common/widgets/drawer/custom_drawer.dart';
import 'package:bookstore/core/configs/theme/app_colors.dart';
import 'package:bookstore/provider/cart_provider.dart';
import 'package:bookstore/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyCart extends StatefulWidget {
  const MyCart({super.key});

  @override
  State<MyCart> createState() => _MyCartState();
}

class _MyCartState extends State<MyCart> {
  late bool _isFirstLoaded;

  @override
  void initState() {
    super.initState();
    _isFirstLoaded = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isFirstLoaded) {
      _isFirstLoaded = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchCartData();
      });
    }
  }

  Future<void> _fetchCartData() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    await cartProvider.getCartItems();
  }

  double _calculateTotalPrice(List<Map<String, dynamic>> cartItems) {
    double totalPrice = 0;
    for (var item in cartItems) {
      totalPrice += (item["saleInfo"]["amount"] ?? 0) * (item["quantity"] ?? 1);
    }
    return totalPrice;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final myCartItems = cartProvider.myCartItems.length;
        double totalPrice = _calculateTotalPrice(cartProvider.myCartItems);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (cartProvider.errorMessage != null) {
            showSnackBar(
                context, cartProvider.errorMessage!, ContentType.failure);
            cartProvider.clearErrorMessage();
          }

          if (cartProvider.successMessage != null) {
            showSnackBar(
                context, cartProvider.successMessage!, ContentType.success);
            cartProvider.clearSuccessMessage();
          }
        });

        return Scaffold(
          appBar: AppBar(),
          drawer: CustomDrawer(
            homeContext: context,
          ),
          body: (myCartItems == 0)
              ? Center(
                  child: Text(
                    "Cart is empty",
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 30,
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(child: CartList()),
                  ],
                ),
          bottomNavigationBar: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Total",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      totalPrice.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(child: BasicAppButton(onPressed: () {}, title: "Buy")),
              ],
            ),
          ),
        );
      },
    );
  }
}
