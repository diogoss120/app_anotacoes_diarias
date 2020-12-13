import 'package:bloco_de_notas/anotacao.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'banco.dart';
import 'anotacao.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    ),
  );
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController titulo = TextEditingController();
  TextEditingController descricao = TextEditingController();
  Banco _banco = Banco();
  List<Anotacao> _anotacoes = List();

  _salvarAnotacao() async {
    Anotacao anotacao =
        Anotacao(titulo.text, descricao.text, DateTime.now().toString());
    int retorno = await _banco.salvarNota(anotacao);
    print('retorno do insert: ' + retorno.toString());
    titulo.clear();
    descricao.clear();
    _carregarAnotacoes();
  }

  _carregarAnotacoes() async {
    List listaTemporaria = await _banco.carregarAnotacoes();
    _anotacoes.clear();
    for (var item in listaTemporaria) {
      Anotacao anotacao = Anotacao.fromMap(item);
      setState(() {
        _anotacoes.add(anotacao);
      });
    }
    listaTemporaria = null;
  }

  _atualizarBanco(Anotacao anotacao) async {
    anotacao.data = DateTime.now().toString();
    anotacao.titulo = titulo.text;
    anotacao.descricao = descricao.text;
    print(anotacao.titulo.toString());
    _banco.atualizarAnotacao(anotacao);

    titulo.clear();
    descricao.clear();
  }

  _formatarData(String data) {
    initializeDateFormatting('pt_BR');
    DateTime dataConvertida = DateTime.parse(data);
    var formatador = DateFormat('dd/MM/y hh:mm');
    return formatador.format(dataConvertida);
  }

  _removerAnotacao(int id) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmação'),
          content: Text('Deseja realmente excluir a anotação?'),
          actions: [
            FlatButton(
              child: Text('Sim'),
              onPressed: () {
                _banco.removerAnotacao(id);
                _carregarAnotacoes();
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text('Não'),
              onPressed: () {
                _carregarAnotacoes();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _carregarAnotacoes();
  }

  _novaAnotacao() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Nova nota'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                textCapitalization: TextCapitalization.sentences,
                controller: titulo,
                decoration:
                    InputDecoration(labelText: 'Titulo', hintText: 'Digite...'),
                autofocus: true,
              ),
              TextField(
                controller: descricao,
                decoration: InputDecoration(
                    labelText: 'Descrição', hintText: 'Digite...'),
              ),
            ],
          ),
          actions: [
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
                titulo.clear();
                descricao.clear();
              },
              child: Text('Cancelar'),
            ),
            FlatButton(
              onPressed: () {
                _salvarAnotacao();
                Navigator.pop(context);
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  _atualizarAnotacao(Anotacao anotacao) {
    titulo.text = anotacao.titulo;
    descricao.text = anotacao.descricao;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar nota'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                textCapitalization: TextCapitalization.sentences,
                controller: titulo,
                decoration:
                    InputDecoration(labelText: 'Titulo', hintText: 'Digite...'),
                autofocus: true,
              ),
              TextField(
                controller: descricao,
                decoration: InputDecoration(
                    labelText: 'Descrição', hintText: 'Digite...'),
              ),
            ],
          ),
          actions: [
            FlatButton(
              onPressed: () {
                titulo.clear();
                descricao.clear();
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            FlatButton(
              onPressed: () {
                _atualizarBanco(anotacao);
                _carregarAnotacoes();
                Navigator.pop(context);
              },
              child: Text('Atualizar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notas diarias'),
        centerTitle: true,
        backgroundColor: Colors.lightGreen,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _anotacoes.length,
              itemBuilder: (context, index) {
                Anotacao anotacao = _anotacoes[index];
                return Dismissible(
                  background: Container(
                    color: Colors.red,
                  ),
                  onDismissed: (direction) {
                    _removerAnotacao(anotacao.id);
                  },
                  key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
                  child: Card(
                    child: ListTile(
                      title: Text(anotacao.titulo),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(anotacao.descricao,
                              style: TextStyle(fontSize: 15)),
                          Text(
                            _formatarData(anotacao.data),
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: (Icon(Icons.edit)),
                        color: Colors.blue,
                        onPressed: () {
                          _atualizarAnotacao(anotacao);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => _novaAnotacao(),
        child: Icon(Icons.add),
      ),
    );
  }
}
