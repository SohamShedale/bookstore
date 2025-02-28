import 'package:bookstore/common/widgets/builder/books_list.dart';
import 'package:bookstore/provider/api_calls_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryBooksPage extends StatefulWidget {
  final String category;

  const CategoryBooksPage({super.key, required this.category});

  @override
  State<CategoryBooksPage> createState() => _CategoryBooksPageState();
}

class _CategoryBooksPageState extends State<CategoryBooksPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialBooks();
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreBooks();
    }
  }

  Future<void> _loadInitialBooks() async {
    final apiProvider = Provider.of<ApiCallsProvider>(context, listen: false);
    if (apiProvider.getAllCategoryBooks(widget.category).isEmpty) {
      await apiProvider.getBooksByCategory(widget.category);
    }
  }

  Future<void> _loadMoreBooks() async {
    final apiProvider = Provider.of<ApiCallsProvider>(context, listen: false);
    if (apiProvider.hasMoreBooks(widget.category)) {
      await apiProvider.loadMoreBooks(widget.category);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "${widget.category[0].toUpperCase()}${widget.category.substring(1)} Books"),
      ),
      body: Consumer<ApiCallsProvider>(
        builder: (context, apiProvider, child) {
          final books = apiProvider.getAllCategoryBooks(widget.category);
          return ListView(
            controller: _scrollController,
            padding: EdgeInsets.all(20),
            children: [
              BooksList(
                categoryName: widget.category,
                books: books,
                isHomePage: false,
              ),
            ],
          );
        },
      ),
    );
  }
}
