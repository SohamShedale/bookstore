import 'package:bookstore/common/widgets/builder/books_list.dart';
import 'package:bookstore/common/widgets/drawer/custom_drawer.dart';
import 'package:bookstore/common/widgets/loading/loading.dart';
import 'package:bookstore/provider/wish_list_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WishListBooks extends StatelessWidget {
  const WishListBooks({super.key});

  @override
  Widget build(BuildContext context) {
    final wishListProvider = Provider.of<WishListProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("My Wish List"),
      ),
      drawer: CustomDrawer(homeContext: context),
      body: StreamBuilder<QuerySnapshot>(
          stream: wishListProvider.getWishList(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Loading();
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text("No books in your wishlist."));
            }

            final wishlistedBooks = snapshot.data!.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();

            return BooksList(
              categoryName: "My Wish List",
              books: wishlistedBooks,
              isHomePage: false,
            );
          }),
    );
  }
}
