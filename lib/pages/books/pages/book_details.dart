import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:bookstore/common/widgets/button/basic_app_button.dart';
import 'package:bookstore/common/widgets/loading/loading.dart';
import 'package:bookstore/core/configs/theme/app_colors.dart';
import 'package:bookstore/provider/cart_provider.dart';
import 'package:bookstore/provider/wish_list_provider.dart';
import 'package:bookstore/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookDetails extends StatefulWidget {
  final Map<String, dynamic> book;
  const BookDetails({super.key, required this.book});

  @override
  State<BookDetails> createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  bool isFavourite = false;

  @override
  void initState() {
    super.initState();
    checkIsFavourite();
  }

  void checkIsFavourite() async {
    final wishListProvider =
        Provider.of<WishListProvider>(context, listen: false);
    final favStatus = await wishListProvider.isFavourite(widget.book["id"]);
    setState(() {
      isFavourite = favStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<WishListProvider, CartProvider>(
        builder: (context, wishListProvider, cartProvider, child) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (wishListProvider.errorMessage != null) {
          showSnackBar(
              context, wishListProvider.errorMessage!, ContentType.failure);
          wishListProvider.clearErrorMessage();
        }

        if (cartProvider.errorMessage != null) {
          showSnackBar(
              context, cartProvider.errorMessage!, ContentType.failure);
          cartProvider.clearErrorMessage();
        }

        if (wishListProvider.successMessage != null) {
          showSnackBar(
              context, wishListProvider.successMessage!, ContentType.success);
          wishListProvider.clearSuccessMessage();
        }

        if (cartProvider.successMessage != null) {
          showSnackBar(
              context, cartProvider.successMessage!, ContentType.success);
          cartProvider.clearSuccessMessage();
        }
      });

      if (wishListProvider.isLoading) {
        return Loading();
      }
      return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  isFavourite = !isFavourite;
                  if (isFavourite) {
                    wishListProvider.addToWishList(widget.book);
                  } else {
                    wishListProvider.removeFromWishList(widget.book["id"]);
                  }
                });
              },
              icon: (isFavourite)
                  ? Icon(Icons.favorite)
                  : Icon(Icons.favorite_border),
              color: (isFavourite) ? Colors.red : null,
              iconSize: double.tryParse("30"),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: SizedBox(
                          height: 300,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              widget.book["imageLinks"]["thumbnail"],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        widget.book["title"],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                        softWrap: true,
                      ),
                      Text(
                        widget.book["authors"][0],
                        style: TextStyle(
                          color: AppColors.grey,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(
                        label: Text(widget.book["categories"][0]),
                        backgroundColor: Color(0xffFFCE31),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                (widget.book["publishedDate"] != null)
                    ? _buildColumn(
                        "Published Date", widget.book["publishedDate"])
                    : SizedBox.shrink(),
                _buildColumn("Price", "₹ ${widget.book["saleInfo"]["amount"]}"),
                _buildColumn("Overview", widget.book["description"]),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: BasicAppButton(
            onPressed: () {
              cartProvider.addItemToCart(widget.book, 1);
            },
            title: "Add to Cart",
          ),
        ),
      );
    });
  }

  Widget _buildColumn(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        Text(
          description,
          style: TextStyle(
            color: AppColors.grey,
            fontSize: 18,
          ),
          textAlign: TextAlign.justify,
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
