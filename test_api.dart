import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🧪 Testing Supabase Edge Function directly...');
  
  const String url = 'https://skqsuxmdfqxbkhmselaz.supabase.co/functions/v1/certification-crud';
  const String apiKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrcXN1eG1kZnF4YmtobXNlbGF6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYwNjQxMDMsImV4cCI6MjA3MTY0MDEwM30.NkwMkK6wZVPv2G_U39Q-rOMT5yUKLvPePnfXHKMR6JU';
  
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
    'apikey': apiKey,
  };
  
  try {
    print('🌐 URL: $url');
    print('🔑 Headers: $headers');
    
    final response = await http.get(Uri.parse(url), headers: headers);
    
    print('📡 Response Status: ${response.statusCode}');
    print('📄 Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Success! Data: $data');
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('💥 Exception: $e');
  }
}
