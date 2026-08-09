import 'cart_item_entity.dart';

class CartEntity {
  final List<CartItemEntity> items;

  const CartEntity({
    required this.items,
  });

  int get totalItems {
    return items.fold(
      0,
          (sum, item) => sum + item.quantity,
    );
  }

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;
}