import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/init/cache/locale_manager.dart';
import 'core/init/dotenv/dotenv_manager.dart';
import 'helper/custom_route.dart';
import 'models/order.dart';
import 'models/product.dart';
import 'providers/auth_notifier.dart';
import 'providers/cart_notifier.dart';
import 'providers/orders_notifier.dart';
import 'providers/products_notifier.dart';
import 'screens/auth_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/edit_product_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/products_overview_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/user_products_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DotEnvManager.initEnv();
  await LocaleManager.prefrencesInit();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => AuthNotifier()),
        ChangeNotifierProxyProvider<AuthNotifier, ProductsNotifier>(
          update: (ctx, auth, prevProds) => ProductsNotifier(
            auth.token,
            auth.userId,
            prevProds?.items ?? <Product>[],
          ),
          create: (ctx) => ProductsNotifier(null, null, <Product>[]),
        ),
        ChangeNotifierProvider(create: (ctx) => CartNotifier()),
        ChangeNotifierProxyProvider<AuthNotifier, OrdersNotifier>(
          update: (ctx, auth, prevOrders) => OrdersNotifier(
            auth.token,
            auth.userId,
            prevOrders?.orders ?? <Order>[],
          ),
          create: (ctx) => OrdersNotifier(null, null, <Order>[]),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Material App',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          colorScheme: const ColorScheme.light().copyWith(
            secondary: Colors.deepOrange,
            onSecondary: Colors.white,
            error: Colors.red.shade700,
          ),
          fontFamily: 'Lato',
          pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CustomPageTransitionBuilder(),
              TargetPlatform.iOS: CustomPageTransitionBuilder(),
            },
          ),
        ),
        initialRoute: '/',
        home: Consumer<AuthNotifier>(
          builder: (ctx, auth, _) {
            return auth.isAuth
                ? const ProductOverviewScreen()
                : FutureBuilder<bool>(
                    future:
                        Future.delayed(Duration.zero).then((value) async => auth.tryAutoLogin()),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SplashScreen();
                      } else {
                        return const AuthScreen();
                      }
                    },
                  );
          },
        ),
        routes: {
          ProductDetailScreen.routeName: (ctx) => const ProductDetailScreen(),
          CartScreen.routeName: (ctx) => const CartScreen(),
          OrdersScreen.routeName: (ctx) => const OrdersScreen(),
          UserProductsScreen.routeName: (ctx) => const UserProductsScreen(),
          EditProductScreen.routeName: (ctx) => const EditProductScreen(),
        },
      ),
    );
  }
}
