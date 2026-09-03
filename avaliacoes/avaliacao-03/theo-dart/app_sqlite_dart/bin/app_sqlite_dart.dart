import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

void main() async {
  print('Iniciando operações no banco de dados...');
  await gerenciarBancoAlunos();
}

/// Função assíncrona responsável por gerenciar todo o fluxo do banco de dados
Future<void> gerenciarBancoAlunos() async {
  // Caminho absoluto para a raiz do projeto
  final caminhoBanco = p.join(Directory.current.path, 'alunos.db');
  Database? db;

  try {
    // 1. Abre ou cria o banco de dados na raiz do projeto (operação I/O assíncrona via Future)
    db = await Future(() {
      print('Acessando/Criando o arquivo do banco em: $caminhoBanco');
      return sqlite3.open(caminhoBanco);
    });

    // 2. Criação da tabela tb_alunos se não existir
    await Future(() {
      print('Criando a tabela "tb_alunos" (se não existir)...');
      db!.execute('''
        CREATE TABLE IF NOT EXISTS tb_alunos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nome TEXT NOT NULL,
          idade INTEGER NOT NULL
        );
      ''');
    });

    // 3. Inserção de três alunos na tabela
    await Future(() {
      print('Inserindo 3 alunos na tabela...');
      
      // Utiliza Prepared Statements para garantir segurança e performance
      final stmt = db!.prepare('INSERT INTO tb_alunos (nome, idade) VALUES (?, ?);');
      
      try {
        stmt.execute(['Théo Cardoso', 17]);
        stmt.execute(['Matheus Reis', 17]);
        stmt.execute(['Francisco Aldamir', 18]);
      } finally {
        stmt.dispose(); // Libera o statement da memória
      }
    });

    // 4. Listagem do conteúdo da tabela tb_alunos
    await Future(() {
      print('\n--- Lista de Alunos ---');
      final ResultSet resultados = db!.select('SELECT id, nome, idade FROM tb_alunos;');

      if (resultados.isEmpty) {
        print('Nenhum aluno encontrado.');
      } else {
        for (final Row linha in resultados) {
          print('ID: ${linha['id']} | Nome: ${linha['nome']} | Idade: ${linha['idade']}');
        }
      }
      print('-----------------------\n');
    });

  } on SqliteException catch (e) {
    // Tratamento de exceção específico para erros do SQLite
    print('❌ Erro de Banco de Dados (SQLite): ${e.message}');
    print('Código de erro: ${e.extendedResultCode}');
  } on FileSystemException catch (e) {
    // Tratamento de exceção para falhas no sistema de arquivos
    print('❌ Erro no sistema de arquivos: ${e.message}');
  } catch (e, stackTrace) {
    // Tratamento genérico para qualquer outra exceção não prevista
    print('❌ Ocorreu um erro inesperado: $e');
    print(stackTrace);
  } finally {
    // Garantir o fechamento da conexão com o banco de dados
    if (db != null) {
      try {
        db.dispose();
        print('Conexão com o banco de dados encerrada com sucesso.');
     } catch (e, _) {
        print('Erro ao fechar o banco de dados: $e');
      }
    }
  }
}
