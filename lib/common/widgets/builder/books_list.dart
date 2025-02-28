import 'package:bookstore/common/widgets/loading/loading.dart';
import 'package:bookstore/core/configs/theme/app_colors.dart';
import 'package:bookstore/pages/books/pages/book_details.dart';
import 'package:bookstore/provider/api_calls_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BooksList extends StatelessWidget {
  final String categoryName;
  final List<Map<String, dynamic>> books;
  final bool isHomePage;
  const BooksList({
    super.key,
    required this.categoryName,
    required this.books,
    this.isHomePage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ApiCallsProvider>(builder: (context, apiProvider, child) {
      return ListView.builder(
        itemCount: isHomePage ? books.length : books.length + 1,
        scrollDirection: isHomePage ? Axis.horizontal : Axis.vertical,
        physics: isHomePage
            ? AlwaysScrollableScrollPhysics()
            : NeverScrollableScrollPhysics(),
        shrinkWrap: !isHomePage,
        itemBuilder: (BuildContext context, int index) {
          if (!isHomePage && index >= books.length) {
            if (apiProvider.hasMoreBooks(categoryName)) {
              return Loading();
            } else {
              return SizedBox.shrink(); 
            }
          }

          final book = books[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => BookDetails(book: book),
                  ));
            },
            child: isHomePage
                ? _buildHorizontalBookItem(book)
                : _buildVerticalBookItem(book),
          );
        },
      );
    });
  }

  Widget _buildHorizontalBookItem(Map<String, dynamic> book) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: EdgeInsets.only(right: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: SizedBox(
              width: 160,
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  book["imageLinks"]["smallThumbnail"],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: Text(
              book["title"],
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              "₹ ${book["saleInfo"]["amount"].toString()}",
              style: TextStyle(
                color: AppColors.grey,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalBookItem(Map<String, dynamic> book) {
    return Card(
      margin: EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                book["imageLinks"]["smallThumbnail"],
                width: 80,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book["title"],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "₹ ${book["saleInfo"]["amount"].toString()}",
                    style: TextStyle(color: AppColors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
