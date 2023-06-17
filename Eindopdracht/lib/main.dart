import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

final String amiibosEndpoint = 'https://www.amiiboapi.com/api/amiibo';
final String amiiboDetailsEndpoint = 'https://www.amiiboapi.com/api/amiibo';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amiibos App',
      home: AmiiboList(),
    );
  }
}

class AmiiboList extends StatefulWidget {
  @override
  _AmiiboListState createState() => _AmiiboListState();
}

class _AmiiboListState extends State<AmiiboList> {
  late Future<List<Amiibo>> _amiibos;

  Future<List<Amiibo>> fetchAmiibos() async {
    final response = await http.get(Uri.parse(amiibosEndpoint));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      print(jsonData['amiibo']);
      final amiiboList =
          (jsonData['amiibo'] as List).map((e) => Amiibo.fromJson(e)).toList();
      return amiiboList;
    } else {
      throw Exception('Failed to load amiibos');
    }
  }

  @override
  void initState() {
    super.initState();
    _amiibos = fetchAmiibos();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Amiibo-Dex'),
            backgroundColor: Colors.red,
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.home)),
              ],
            ),
          ),
          body:
          FutureBuilder<List<Amiibo>>(

            future: _amiibos,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final amiibos = snapshot.data!;
                return ListView.builder(
                  itemCount: amiibos.length,
                  itemBuilder: (context, index) {
                    final amiibo = amiibos[index];
                    return ListTile(
                      leading: Image.network(amiibo.imageUrl),
                      title: Text(amiibo.name),
                      subtitle: Text('Game Series: ${amiibo.gameSeries}'),
                      onTap: () {
                        print('key ${amiibo}');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AmiiboDetails(amiibo: amiibo),
                          ),
                        );
                      },
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('${snapshot.error}'),
                );
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ));
  }
}


class Amiibo {
  final String key;
  final String name;
  final String imageUrl;
  final String gameSeries;
  final String amiiboSeries;
  final String type;

  Amiibo({
    required this.key,
    required this.name,
    required this.imageUrl,
    required this.gameSeries,
    required this.amiiboSeries,
    required this.type,
  });

  factory Amiibo.fromJson(Map<String, dynamic> json) {
    return Amiibo(
      key: json['key'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['image'] ?? '',
      gameSeries: json['gameSeries'] ?? '',
      amiiboSeries: json['amiiboSeries'] ?? '',
      type: json['type'] ?? '',
    );
  }
}

get amiiboSeries => null;

get type => null;

class AmiiboDetails extends StatefulWidget {
  final Amiibo amiibo;
  const AmiiboDetails({Key? key, required this.amiibo}) : super(key: key);

  @override
  _AmiiboDetailsState createState() => _AmiiboDetailsState();
}

class _AmiiboDetailsState extends State<AmiiboDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Amiibo Details'),
      ),
      body: Center(
        child: widget.amiibo != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    widget.amiibo!.imageUrl,
                    width: 200,
                    height: 200,
                  ),
                  SizedBox(height: 16),
                  Text(
                    widget.amiibo!.name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Series: ${widget.amiibo!.amiiboSeries}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Type: ${widget.amiibo!.type}',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              )
            : CircularProgressIndicator(),
      ),
    );
  }

  AmiiboAPI() {}
}
