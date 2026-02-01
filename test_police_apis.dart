#!/usr/bin/env dart

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Command-line tool to test real police APIs
void main(List<String> args) async {
  print('🚔 Testing Real Police APIs\n');
  print('=' * 50);
  
  final tester = PoliceApiTester();
  await tester.runAllTests();
  
  print('\n' + '=' * 50);
  print('✅ API testing complete!');
}

class PoliceApiTester {
  final http.Client _client = http.Client();
  
  Future<void> runAllTests() async {
    await testUKPoliceApi();
    await testOpenOversight();
    await testChicagoDataPortal();
    await testWashingtonPostData();
    await testFatalEncounters();
  }
  
  Future<void> testUKPoliceApi() async {
    print('\n🇬🇧 Testing UK Police API');
    print('-' * 30);
    
    try {
      // Test 1: Get all forces
      print('📍 Getting all police forces...');
      final forcesResponse = await _client.get(
        Uri.parse('https://data.police.uk/api/forces'),
        headers: {'User-Agent': 'CopStopper-Test/1.0'},
      ).timeout(Duration(seconds: 10));
      
      if (forcesResponse.statusCode == 200) {
        final forces = jsonDecode(forcesResponse.body) as List;
        print('✅ Found ${forces.length} police forces');
        
        // Show first few forces
        for (int i = 0; i < (forces.length > 3 ? 3 : forces.length); i++) {
          final force = forces[i];
          print('   - ${force['name']} (${force['id']})');
        }
        
        // Test 2: Get senior officers for Metropolitan Police
        if (forces.any((f) => f['id'] == 'metropolitan')) {
          print('\n👮 Getting Metropolitan Police senior officers...');
          final officersResponse = await _client.get(
            Uri.parse('https://data.police.uk/api/forces/metropolitan/senior-officers'),
            headers: {'User-Agent': 'CopStopper-Test/1.0'},
          ).timeout(Duration(seconds: 10));
          
          if (officersResponse.statusCode == 200) {
            final officers = jsonDecode(officersResponse.body) as List;
            print('✅ Found ${officers.length} senior officers');
            
            // Show first few officers
            for (int i = 0; i < (officers.length > 2 ? 2 : officers.length); i++) {
              final officer = officers[i];
              print('   - ${officer['name']} (${officer['rank']})');
            }
          } else {
            print('❌ Failed to get officers: ${officersResponse.statusCode}');
          }
        }
        
        // Test 3: Get crime data for a location (London)
        print('\n🔍 Getting crime data for London...');
        final crimeResponse = await _client.get(
          Uri.parse('https://data.police.uk/api/crimes-street/all-crime?lat=51.5074&lng=-0.1278'),
          headers: {'User-Agent': 'CopStopper-Test/1.0'},
        ).timeout(Duration(seconds: 10));
        
        if (crimeResponse.statusCode == 200) {
          final crimes = jsonDecode(crimeResponse.body) as List;
          print('✅ Found ${crimes.length} recent crimes in London area');
        } else {
          print('❌ Failed to get crime data: ${crimeResponse.statusCode}');
        }
        
      } else {
        print('❌ Failed to get forces: ${forcesResponse.statusCode}');
      }
    } catch (e) {
      print('❌ UK Police API error: $e');
    }
  }
  
  Future<void> testOpenOversight() async {
    print('\n🔍 Testing OpenOversight');
    print('-' * 30);
    
    try {
      // Test main website
      final response = await _client.get(
        Uri.parse('https://openoversight.com/'),
        headers: {'User-Agent': 'CopStopper-Test/1.0'},
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        print('✅ OpenOversight website accessible');
        
        // Check if they mention API in their content
        if (response.body.toLowerCase().contains('api')) {
          print('📡 Website mentions API - may have endpoints');
        } else {
          print('ℹ️  No obvious API mentioned on main page');
        }
      } else {
        print('❌ OpenOversight not accessible: ${response.statusCode}');
      }
      
      // Try potential API endpoints
      final apiEndpoints = [
        'https://openoversight.com/api/officers',
        'https://openoversight.com/api/v1/officers',
        'https://openoversight.com/api/departments',
      ];
      
      for (final endpoint in apiEndpoints) {
        try {
          print('🔍 Trying endpoint: $endpoint');
          final apiResponse = await _client.get(
            Uri.parse(endpoint),
            headers: {'User-Agent': 'CopStopper-Test/1.0'},
          ).timeout(Duration(seconds: 5));
          
          if (apiResponse.statusCode == 200) {
            print('✅ API endpoint found: $endpoint');
            try {
              final data = jsonDecode(apiResponse.body);
              print('   Response type: ${data.runtimeType}');
            } catch (e) {
              print('   Response is not JSON');
            }
          } else {
            print('   ❌ ${apiResponse.statusCode}');
          }
        } catch (e) {
          print('   ❌ Error: $e');
        }
      }
      
    } catch (e) {
      print('❌ OpenOversight error: $e');
    }
  }
  
  Future<void> testChicagoDataPortal() async {
    print('\n🏙️ Testing Chicago Data Portal');
    print('-' * 30);
    
    try {
      // Test Socrata API
      final response = await _client.get(
        Uri.parse('https://data.cityofchicago.org/api/views/metadata/v1'),
        headers: {'User-Agent': 'CopStopper-Test/1.0'},
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        print('✅ Chicago Data Portal API accessible');
        
        // Try to get police-related datasets
        final datasetsResponse = await _client.get(
          Uri.parse('https://data.cityofchicago.org/api/views.json?limitTo=datasets&q=police'),
          headers: {'User-Agent': 'CopStopper-Test/1.0'},
        ).timeout(Duration(seconds: 10));
        
        if (datasetsResponse.statusCode == 200) {
          final datasets = jsonDecode(datasetsResponse.body) as List;
          print('✅ Found ${datasets.length} police-related datasets');
          
          // Show first few datasets
          for (int i = 0; i < (datasets.length > 3 ? 3 : datasets.length); i++) {
            final dataset = datasets[i];
            print('   - ${dataset['name']}');
          }
        }
      } else {
        print('❌ Chicago Data Portal not accessible: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Chicago Data Portal error: $e');
    }
  }
  
  Future<void> testWashingtonPostData() async {
    print('\n📰 Testing Washington Post Police Shootings Data');
    print('-' * 30);
    
    try {
      final response = await _client.get(
        Uri.parse('https://raw.githubusercontent.com/washingtonpost/data-police-shootings/master/fatal-police-shootings-data.csv'),
        headers: {'User-Agent': 'CopStopper-Test/1.0'},
      ).timeout(Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final lines = response.body.split('\n');
        print('✅ Washington Post data accessible');
        print('   Total records: ${lines.length - 1}'); // -1 for header
        
        // Show header and first record
        if (lines.length > 1) {
          print('   Header: ${lines[0]}');
          if (lines.length > 2) {
            print('   Sample: ${lines[1]}');
          }
        }
      } else {
        print('❌ Washington Post data not accessible: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Washington Post data error: $e');
    }
  }
  
  Future<void> testFatalEncounters() async {
    print('\n💀 Testing Fatal Encounters');
    print('-' * 30);
    
    try {
      final response = await _client.get(
        Uri.parse('https://fatalencounters.org/'),
        headers: {'User-Agent': 'CopStopper-Test/1.0'},
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        print('✅ Fatal Encounters website accessible');
        
        // Check for data download links
        if (response.body.toLowerCase().contains('download') || 
            response.body.toLowerCase().contains('csv') ||
            response.body.toLowerCase().contains('data')) {
          print('📊 Website mentions data downloads');
        }
        
        // Try to find Google Sheets link (they often use Google Sheets)
        if (response.body.contains('docs.google.com') || 
            response.body.contains('sheets.google.com')) {
          print('📋 Found Google Sheets references');
        }
      } else {
        print('❌ Fatal Encounters not accessible: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Fatal Encounters error: $e');
    }
  }
}