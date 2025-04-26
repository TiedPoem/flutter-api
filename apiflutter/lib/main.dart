import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consumo de API',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CadastroPage(),
    );
  }
}

class CadastroPage extends StatefulWidget {
  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();

  Future<void> adicionarCadastro() async {
  final nome = nomeController.text.trim();
  final email = emailController.text.trim();
  final telefone = telefoneController.text.trim();

  if (nome.isEmpty || email.isEmpty || telefone.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Preencha todos os campos!'))
    );
    return;
  }

  final response = await http.post(
    Uri.parse('https://680924031f1a52874cdc029b.mockapi.io/lista/v1/lista'),
    headers: {'Content-Type': 'application/json; charset=utf-8'},
    body: json.encode({
      'nome': nome,
      'email': email,
      'telefone': telefone,
    }),
  );

  if (response.statusCode == 201) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cadastro enviado com sucesso!'))
    );
    nomeController.clear();
    emailController.clear();
    telefoneController.clear();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao enviar cadastro'))
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro de Usuário')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: telefoneController,
              decoration: InputDecoration(labelText: 'Telefone'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: adicionarCadastro,
              child: Text('Cadastrar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HomePage()));
              },
              child: Text('Ver Lista'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> products = [];

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    final response =
        await http.get(
          Uri.parse('https://680924031f1a52874cdc029b.mockapi.io/lista/v1/lista'),
          headers: {'Content-Type': 'application/json; charset=utf8'}
          );

    if (response.statusCode == 200) {
      setState(() {

        String data = utf8.decode(response.bodyBytes);
        products = json.decode(data);
      
      });
    } else {
      throw Exception('Failed to load posts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Cadastros'),
      ),
      body: ListView.separated(
        itemCount: products.length,
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(products[index]['nome']),
            subtitle: Text('Email: ${products[index]['email']}, Tel: ${products[index]['telefone']}')
          );
        },
      ),
    );
  }
}
