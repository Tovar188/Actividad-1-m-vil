import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HTTP y Future Demo',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Map<String, String>>> fetchCompaneros() async {
    await Future.delayed(Duration(seconds: 2));
    final response = jsonEncode([
      {"nombre": "Miguel Ángel Tovar Reyes", "matricula": "201236"},
      {"nombre": "Moisés de Jesús Anzueto Gonzales", "matricula": "193243"},
      {"nombre": "Alfredo de Jesús Borraz Juárez", "matricula": "201244"}
    ]);

    final List<dynamic> decoded = json.decode(response);
    return decoded.map<Map<String, String>>((e) {
      return {
        "nombre": e["nombre"].toString(),
        "matricula": e["matricula"].toString(),
      };
    }).toList();
  }

  // Función para abrir aplicaciones de teléfono y mensajes
  Future<void> _launchPhone(String number) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'No se pudo abrir $number';
    }
  }

  Future<void> _launchSMS(String number) async {
    final Uri smsUri = Uri(scheme: 'sms', path: number);
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      throw 'No se pudo abrir mensajes a $number';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HTTP y Future Demo'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: fetchCompaneros(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay datos disponibles.'));
          }

          final companeros = snapshot.data!;
          return ListView.builder(
            itemCount: companeros.length,
            itemBuilder: (context, index) {
              final companero = companeros[index];
              return Card(
                margin: EdgeInsets.all(10.0),
                child: ListTile(
                  title: Text(companero['nombre']!),
                  subtitle: Text('Matrícula: ${companero['matricula']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.phone, color: Colors.green),
                        onPressed: () => _launchPhone("1234567890"),
                      ),
                      IconButton(
                        icon: Icon(Icons.message, color: Colors.blue),
                        onPressed: () => _launchSMS("1234567890"),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
