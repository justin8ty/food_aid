import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../models/food_bank.dart';

final foodBankServiceProvider = Provider((ref) => FoodBankService());

class FoodBankService {
  Future<List<FoodBank>> loadFoodBanks() async {
    final jsonString = await rootBundle.loadString('assets/food_banks1.json');
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    
    final foodBanks = <FoodBank>[];
    jsonMap.forEach((key, value) {
      for (var item in value as List) {
        foodBanks.add(FoodBank.fromJson(item));
      }
    });
    
    return foodBanks;
  }

  Future<List<FoodBank>> searchFoodBanks(String query) async {
    if (query.isEmpty) return [];
    
    final allFoodBanks = await loadFoodBanks();
    final lowerQuery = query.toLowerCase();
    
    return allFoodBanks.where((bank) {
      return bank.name.toLowerCase().contains(lowerQuery) ||
             bank.address.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
