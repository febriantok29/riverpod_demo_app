import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/product_service.dart';
import '../../states/product_state.dart';

/// Providers untuk Product Module
class ProductProviders {
  // Provider untuk ProductService (singleton)
  static final service = Provider<ProductService>((ref) {
    return ProductService();
  });

  // StateNotifierProvider untuk Product List dengan Pagination
  static final list =
      StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
        final service = ref.watch(ProductProviders.service);
        return ProductListNotifier(service);
      });

  // StateNotifierProvider untuk Product Form operations
  static final form =
      StateNotifierProvider<ProductFormNotifier, ProductFormState>((ref) {
        final service = ref.watch(ProductProviders.service);
        return ProductFormNotifier(service);
      });

  // StateNotifierProvider untuk Product Detail
  static final detail =
      StateNotifierProvider<ProductDetailNotifier, ProductDetailState>((ref) {
        final service = ref.watch(ProductProviders.service);
        return ProductDetailNotifier(service);
      });
}

/// Notifier untuk mengelola Product List dengan Infinite Scroll
class ProductListNotifier extends StateNotifier<ProductListState> {
  final ProductService _service;

  ProductListNotifier(this._service) : super(ProductListState()) {
    // Load initial products saat notifier dibuat
    loadInitial();
  }

  /// Load initial products (page pertama)
  Future<void> loadInitial() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentPage: 0,
      products: [],
    );

    try {
      final response = await _service.getProducts(limit: state.limit, skip: 0);

      state = state.copyWith(
        products: response.products,
        currentPage: 0,
        total: response.total,
        isLoading: false,
        hasMore: response.hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Load more products untuk infinite scroll
  Future<void> loadMore() async {
    // Prevent multiple calls dan cek apakah masih ada data
    if (state.isLoadingMore || !state.hasMore || state.isLoading) {
      print(
        '⛔️ LOAD MORE BLOCKED: isLoadingMore=${state.isLoadingMore}, hasMore=${state.hasMore}, isLoading=${state.isLoading}',
      );
      return;
    }

    print(
      '✅ LOAD MORE STARTED: currentPage=${state.currentPage}, skip=${state.skip}',
    );
    state = state.copyWith(isLoadingMore: true, errorMessage: null);

    try {
      final nextPage = state.currentPage + 1;
      final skip = nextPage * state.limit;

      print('🌐 API CALL: skip=$skip, limit=${state.limit}');
      final response = state.isSearchMode
          ? await _service.searchProducts(
              query: state.searchQuery!,
              limit: state.limit,
              skip: skip,
            )
          : await _service.getProducts(limit: state.limit, skip: skip);

      print(
        '📦 API RESPONSE: got ${response.products.length} products, hasMore=${response.hasMore}',
      );

      state = state.copyWith(
        products: [...state.products, ...response.products],
        currentPage: nextPage,
        total: response.total,
        isLoadingMore: false,
        hasMore: response.hasMore,
      );

      print('✅ LOAD MORE COMPLETE: total products=${state.products.length}');
    } catch (e) {
      print('❌ LOAD MORE ERROR: $e');
      state = state.copyWith(isLoadingMore: false, errorMessage: e.toString());
    }
  }

  /// Refresh products (pull to refresh)
  Future<void> refresh() async {
    if (state.isSearchMode) {
      await search(state.searchQuery!);
    } else {
      await loadInitial();
    }
  }

  /// Search products
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      // Kalau query kosong, kembali ke load all products
      state = state.copyWith(searchQuery: null);
      await loadInitial();
      return;
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      searchQuery: query,
      currentPage: 0,
      products: [],
    );

    try {
      final response = await _service.searchProducts(
        query: query,
        limit: state.limit,
        skip: 0,
      );

      state = state.copyWith(
        products: response.products,
        currentPage: 0,
        total: response.total,
        isLoading: false,
        hasMore: response.hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Clear search dan kembali ke all products
  Future<void> clearSearch() async {
    state = state.copyWith(searchQuery: null);
    await loadInitial();
  }
}

/// Notifier untuk mengelola Product Form (Create/Edit)
class ProductFormNotifier extends StateNotifier<ProductFormState> {
  final ProductService _service;

  ProductFormNotifier(this._service) : super(ProductFormState());

  /// Create new product
  Future<void> createProduct({
    required String title,
    required String description,
    required String category,
    required double price,
    required int stock,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _service.createProduct(
        title: title,
        description: description,
        category: category,
        price: price,
        stock: stock,
      );

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Update existing product
  Future<void> updateProduct({
    required int id,
    required String title,
    required String description,
    required String category,
    required double price,
    required int stock,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _service.updateProduct(
        id: id,
        title: title,
        description: description,
        category: category,
        price: price,
        stock: stock,
      );

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Delete product
  Future<void> deleteProduct(int id) async {
    try {
      await _service.deleteProduct(id);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Reset state
  void resetState() {
    state = ProductFormState();
  }
}

/// Notifier untuk mengelola Product Detail
class ProductDetailNotifier extends StateNotifier<ProductDetailState> {
  final ProductService _service;

  ProductDetailNotifier(this._service) : super(ProductDetailState());

  /// Load product detail by ID
  Future<void> loadProduct(int id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final product = await _service.getProduct(id);

      state = state.copyWith(product: product, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Reset state
  void resetState() {
    state = ProductDetailState();
  }
}
