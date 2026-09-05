class AdminProductOption {
  final String id;
  final String name;
  final String? logoUrl;

  const AdminProductOption({
    required this.id,
    required this.name,
    this.logoUrl,
  });
}