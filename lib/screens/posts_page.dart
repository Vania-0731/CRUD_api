import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service_product.dart';
import '../services/database_helper.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final ApiServiceProduct _apiService = ApiServiceProduct();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final apiProducts = await _apiService.getProducts();
      final db = await _dbHelper.database;
      await db.delete('products');
      final productsToSave = apiProducts.take(20).toList();
      await _dbHelper.insertMultipleProducts(productsToSave);
      await _loadFromDatabase();
    } catch (e) {
      await _loadFromDatabase();
      _showSnackBar('Cargando datos locales');
    }
  }

  Future<void> _loadFromDatabase() async {
    try {
      final products = await _dbHelper.getProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _showProductDialog({Product? product}) async {
    final titleController = TextEditingController(text: product?.title ?? '');
    final descController = TextEditingController(text: product?.description ?? '');
    final priceController = TextEditingController(
      text: product != null ? product.price.toString() : '',
    );
    final isEditing = product != null;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar Producto' : 'Nuevo Producto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Producto',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Precio (\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty || 
                  priceController.text.isEmpty ||
                  descController.text.isEmpty) {
                _showSnackBar('Por favor completa todos los campos');
                return;
              }

              final price = double.tryParse(priceController.text);
              if (price == null) {
                _showSnackBar('Ingresa un precio válido');
                return;
              }

              Navigator.pop(context);

              if (isEditing) {
                final updatedProduct = Product(
                  id: product.id,
                  title: titleController.text,
                  description: descController.text,
                  price: price,
                  image: product.image,
                  category: product.category ?? 'general',
                );

                await _dbHelper.updateProduct(updatedProduct);
                await _loadFromDatabase();
                _showSnackBar('Producto actualizado ✓');

              } else {
                final newProduct = Product(
                  title: titleController.text,
                  description: descController.text,
                  price: price,
                  category: 'general',
                );
                await _dbHelper.insertProduct(newProduct);
                await _loadFromDatabase();
                _showSnackBar('Producto creado ✓');
              }
            },
            child: Text(isEditing ? 'Actualizar' : 'Crear'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text('¿Eliminar "${product.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _dbHelper.deleteProduct(product.id!);
      await _loadFromDatabase();
      _showSnackBar('Producto eliminado ✓');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD Productos'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFromDatabase,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? const Center(child: Text('No hay productos'))
              : RefreshIndicator(
                  onRefresh: _loadFromDatabase,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: product.image != null && product.image!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    product.image!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image),
                                    ),
                                  ),
                                )
                              : CircleAvatar(
                                  backgroundColor: Colors.deepPurple,
                                  child: Text(
                                    '${product.id}',
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                          title: Text(
                            product.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showProductDialog(product: product);
                              } else if (value == 'delete') {
                                _confirmDelete(product);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text('Editar'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Eliminar'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _showProductDialog(product: product),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductDialog(),
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nuevo', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
