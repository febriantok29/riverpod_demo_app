import 'package:riverpod_demo_app/app/models/product.dart';

/// State untuk Product List dengan Pagination & Infinite Scroll
class ProductListState {
  final List<Product> products;
  final int currentPage;
  final int limit;
  final int total;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;
  final String? searchQuery;

  ProductListState({
    this.products = const [],
    this.currentPage = 0,
    this.limit = 10,
    this.total = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
    this.searchQuery,
  });

  ProductListState copyWith({
    List<Product>? products,
    int? currentPage,
    int? limit,
    int? total,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? errorMessage,
    String? searchQuery,
  }) {
    return ProductListState(
      products: products ?? this.products,
      currentPage: currentPage ?? this.currentPage,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  // Helper untuk calculate skip value untuk pagination
  int get skip => currentPage * limit;

  // Helper untuk check apakah sedang dalam mode search
  bool get isSearchMode => searchQuery != null && searchQuery!.isNotEmpty;
}

/// State untuk Product Form (Create/Edit)
class ProductFormState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  ProductFormState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  ProductFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return ProductFormState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

/// State untuk Product Detail
class ProductDetailState {
  final Product? product;
  final bool isLoading;
  final String? errorMessage;

  ProductDetailState({this.product, this.isLoading = false, this.errorMessage});

  ProductDetailState copyWith({
    Product? product,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProductDetailState(
      product: product ?? this.product,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
