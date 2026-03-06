import 'package:flutter/material.dart';

import 'screens/splash/splash_screen.dart';
import 'screens/auth/phone_entry/phone_entry_screen.dart';
import 'screens/auth/otp/otp_screen.dart';
import 'screens/registration/registration_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/menu/menu_screen.dart';
import 'screens/menu/add_item_screen.dart';
import 'screens/menu/edit_item_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/orders/order_detail_screen.dart';
import 'screens/profile/profile_screen.dart';

final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName:       (context) => const SplashScreen(),
  PhoneEntryScreen.routeName:   (context) => const PhoneEntryScreen(),
  OtpScreen.routeName:          (context) => const OtpScreen(),
  RegistrationScreen.routeName: (context) => const RegistrationScreen(),
  HomeScreen.routeName:         (context) => const HomeScreen(),
  MenuScreen.routeName:         (context) => const MenuScreen(),
  AddItemScreen.routeName:      (context) => const AddItemScreen(),
  EditItemScreen.routeName:     (context) => const EditItemScreen(),
  OrdersScreen.routeName:       (context) => const OrdersScreen(),
  OrderDetailScreen.routeName:  (context) => const OrderDetailScreen(),
  ProfileScreen.routeName:      (context) => const ProfileScreen(),
};