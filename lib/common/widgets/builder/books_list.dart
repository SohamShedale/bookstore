import 'package:bookstore/core/configs/theme/app_colors.dart';
import 'package:bookstore/pages/books/pages/book_details.dart';
import 'package:bookstore/provider/api_calls_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BooksList extends StatelessWidget {
  final String categoryName;
  const BooksList({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Consumer<ApiCallsProvider>(builder: (context, apiProvider, child) {
      List<Map<String, dynamic>> books = [];
      for (var category in apiProvider.books) {
        if (category.containsKey(categoryName)) {
          books = category[categoryName]!;
        }
      }
      return ListView.builder(
        itemCount: books.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        BookDetails(book: books[index]),
                  ));
            },
            child: SizedBox(
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
                          books[index]["imageLinks"]["smallThumbnail"],
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
                      books[index]["title"],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      "₹ ${books[index]["saleInfo"]["amount"].toString()}",
                      style: TextStyle(
                        color: AppColors.grey,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
