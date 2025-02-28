import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:bookstore/common/widgets/builder/books_list.dart';
import 'package:bookstore/common/widgets/drawer/custom_drawer.dart';
import 'package:bookstore/common/widgets/loading/loading.dart';
import 'package:bookstore/core/configs/theme/app_colors.dart';
import 'package:bookstore/pages/books/pages/category_books_page.dart';
import 'package:bookstore/provider/api_calls_provider.dart';
import 'package:bookstore/provider/auth_user_provider.dart';
import 'package:bookstore/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializedData();
    });
  }

  Future<void> _initializedData() async {
    final apiProvider = Provider.of<ApiCallsProvider>(context, listen: false);
    await apiProvider.syncUserDetails(context);
    await apiProvider.getHomePageBooks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final authUser = Provider.of<AuthUserProvider>(context, listen: false);
    final apiProvider = Provider.of<ApiCallsProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authUser.user == null && context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/signin",
          (route) => false,
        );
      }
      if (authUser.errorMessage != null) {
        showSnackBar(context, authUser.errorMessage!, ContentType.failure);
        authUser.clearErrorMessage();
      }
      if (authUser.successMessage != null) {
        showSnackBar(context, authUser.successMessage!, ContentType.success);
        authUser.clearSuccessMessage();
      }
      if (apiProvider.errorMessage != null) {
        showSnackBar(context, apiProvider.errorMessage!, ContentType.failure);
        apiProvider.clearErrorMessage();
      }
      if (apiProvider.successMessage != null) {
        showSnackBar(context, apiProvider.successMessage!, ContentType.success);
        apiProvider.clearSuccessMessage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthUserProvider, ApiCallsProvider>(
      builder: (context, authUser, apiProvider, child) {
        if (authUser.isLoading || apiProvider.isLoading) {
          return Loading();
        }
        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () {},
                iconSize: double.tryParse("27"),
                icon: Icon(
                  Icons.notifications_active_outlined,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    apiProvider.userDetails?["photoURL"] ??
                        "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png",
                  ),
                ),
              ),
            ],
          ),
          drawer: CustomDrawer(
            homeContext: context,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: 20,
                bottom: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (apiProvider.userDetails != null &&
                                  apiProvider.userDetails!["name"] != null)
                              ? "Hello, ${apiProvider.userDetails!["name"].split(" ")[0]} 👋"
                              : "Hello, Guest 👋",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "What do you want to read today?",
                          style: TextStyle(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: TextField(
                      cursorColor: AppColors.grey,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: "Search here",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.grey,
                          ),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.grey,
                          ),
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  _buildCategorySection(context, "Love", "love"),
                  _buildCategorySection(context, "Tech", "tech"),
                  _buildCategorySection(context, "Fiction", "fiction"),
                  _buildCategorySection(context, "History", "history"),
                  _buildCategorySection(context, "Comedy", "comedy"),

                  // Column(
                  //   children: [
                  //     Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //           "Love",
                  //           style: TextStyle(
                  //               fontWeight: FontWeight.bold, fontSize: 20),
                  //         ),
                  //         SizedBox(
                  //           height: 10,
                  //         ),
                  //         SizedBox(
                  //           height: MediaQuery.of(context).size.height * 0.4,
                  //           child: BooksList(categoryName: "love"),
                  //         ),
                  //       ],
                  //     ),
                  //     SizedBox(
                  //       height: 10,
                  //     ),
                  //     Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //           "Tech",
                  //           style: TextStyle(
                  //               fontWeight: FontWeight.bold, fontSize: 20),
                  //         ),
                  //         SizedBox(
                  //           height: 10,
                  //         ),
                  //         SizedBox(
                  //           height: MediaQuery.of(context).size.height * 0.4,
                  //           child: BooksList(categoryName: "tech"),
                  //         ),
                  //       ],
                  //     ),
                  //     SizedBox(
                  //       height: 10,
                  //     ),
                  //     Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //           "Fiction",
                  //           style: TextStyle(
                  //               fontWeight: FontWeight.bold, fontSize: 20),
                  //         ),
                  //         SizedBox(
                  //           height: 10,
                  //         ),
                  //         SizedBox(
                  //           height: MediaQuery.of(context).size.height * 0.4,
                  //           child: BooksList(categoryName: "fiction"),
                  //         ),
                  //       ],
                  //     ),
                  //     SizedBox(
                  //       height: 10,
                  //     ),
                  //     Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //           "History",
                  //           style: TextStyle(
                  //               fontWeight: FontWeight.bold, fontSize: 20),
                  //         ),
                  //         SizedBox(
                  //           height: 10,
                  //         ),
                  //         SizedBox(
                  //           height: MediaQuery.of(context).size.height * 0.4,
                  //           child: BooksList(categoryName: "history"),
                  //         ),
                  //       ],
                  //     ),
                  //     SizedBox(
                  //       height: 10,
                  //     ),
                  //     Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //           "Comedy",
                  //           style: TextStyle(
                  //               fontWeight: FontWeight.bold, fontSize: 20),
                  //         ),
                  //         SizedBox(
                  //           height: 10,
                  //         ),
                  //         SizedBox(
                  //           height: MediaQuery.of(context).size.height * 0.4,
                  //           child: BooksList(categoryName: "comedy"),
                  //         ),
                  //       ],
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategorySection(
      BuildContext context, String title, String category) {
    return Consumer<ApiCallsProvider>(builder: (context, apiProvider, child) {
      final books = apiProvider.getHomePageCategoryBooks(category);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CategoryBooksPage(category: category),
                      ),
                    );
                  },
                  child: Text(
                    'See all',
                    style: TextStyle(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: BooksList(
              categoryName: category,
              books: books,
              isHomePage: true,
            ),
          ),
        ],
      );
    });
  }
}
