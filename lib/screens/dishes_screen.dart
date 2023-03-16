import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_homeconnect_flutter/provider.dart';
import 'package:sample_homeconnect_flutter/widgets/dish_widget.dart';

class DishesScreen extends ConsumerWidget {
  const DishesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeConnectApi = ref.watch(apiProvider2);
    List<Dish> dishes = ref.watch(dishesProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Dishes',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(children: [
        for (var dish in dishes) DishWidget(dish: dish, homeConnectApi: homeConnectApi),
      ]),
    );
  }
}
