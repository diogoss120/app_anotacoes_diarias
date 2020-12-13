import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'anotacao.dart';

class Banco {
  static final Banco _dbUnico = Banco._instanciar();
  final String tblNome = 'notas';

  //construtor nomeado para auxiliar na no singueton
  Banco._instanciar();

  factory Banco() {
    return _dbUnico;
  }

  Database _db;

  get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await _getDadabase();
      return _db;
    }
  }

  _getDadabase() async {
    var bancoPath = await getDatabasesPath();
    var path = join(bancoPath, 'banco.db');

    Database data = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      String sql =
          'CREATE TABLE notas (id INTEGER PRIMARY KEY AUTOINCREMENT, titulo TEXT, descricao TEXT, data DATETIME)';
      await db.execute(sql);
    });
    return data;
  }

  Future<int> salvarNota(Anotacao anotacao) async {
    var banco = await db;
    int retornoId = await banco.insert(tblNome, anotacao.toMap());
    return retornoId;
  }

  Future<List> carregarAnotacoes() async {
    var banco = await db;
    String sql = 'SELECT * FROM notas ORDER BY data DESC';
    List anotacoes = await banco.rawQuery(sql);
    return anotacoes;
  }

  atualizarAnotacao(Anotacao anotacao) async {
    var banco = await db;

    await banco.update(
      "notas",
      anotacao.toMap(),
      where: "id = ?",
      whereArgs: [anotacao.id],
    );
  }

  removerAnotacao(int id) async {
    var banco = await db;
    await banco.delete(
      'notas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
