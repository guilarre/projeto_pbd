-- =========================================================
-- PARTE 5: EXISTS / NOT EXISTS
-- =========================================================

-- CONSULTA 1
-- Pergunta de negócio: Quais funcionários possuem alguma limpeza registrada no sistema?
SELECT
    f.cpf AS "CPF",
    p.nome AS "Nome do funcionário",
    c.nomeCargo AS "Cargo"
FROM Funcionario f
INNER JOIN Pessoa p
    ON f.cpf = p.cpf
INNER JOIN Cargo c
    ON f.idCargo = c.idCargo
-- Verifica se existe pelo menos uma limpeza atribuída ao funcionário
WHERE EXISTS (
    SELECT 1
    FROM Limpeza l
    WHERE l.cpf = f.cpf
)
ORDER BY p.nome;

-- LÓGICA:
-- A consulta relaciona Funcionario (f), Pessoa (p) e Cargo (c) via INNER JOIN para obter o CPF, o nome e o cargo
-- de cada colaborador cadastrado.
-- Na cláusula WHERE, o operador EXISTS executa uma subconsulta correlacionada na tabela Limpeza (l)
-- verificando se há ao menos um registro vinculado ao funcionário (l.cpf = f.cpf), ordenando pelo nome.

-- RECURSOS SQL UTILIZADOS: SELECT, apelidos de coluna (AS), INNER JOIN, WHERE, EXISTS, subconsulta correlacionada e ORDER BY

-- JUSTIFICATIVA:

-- Uso de EXISTS em vez de JOIN:
-- Como um mesmo funcionário pode ter várias limpezas registradas (Ana Souza possui dois registros em Limpeza),
-- um INNER JOIN direto duplicaria o colaborador no resultado. O EXISTS interrompe a busca ao encontrar a primeira
-- ocorrência e retorna cada funcionário uma única vez.

-- Benefício:
-- Permite à gerência identificar quais membros da equipe já possuem atividades operacionais de limpeza registradas.

-- RESULTADO ESPERADO:
-- Retorna 2 linhas: Ana Souza (Camareiro(a)) e Juliana Marques (Manutenção), que são os únicos funcionários
-- com registros na tabela Limpeza após a execução completa de hotel_resort.sql.


-- CONSULTA 2
-- Pergunta de negócio: Quais instalações do resort não possuem nenhuma limpeza registrada?
SELECT
    i.idInstalacao AS "ID da instalação",
    i.tipo AS "Tipo",
    i.status AS "Status"
FROM Instalacao i
-- Mantém apenas as instalações que não têm correspondência na tabela LimpezaInstalacao
WHERE NOT EXISTS (
    SELECT 1
    FROM LimpezaInstalacao li
    WHERE li.idInstalacao = i.idInstalacao
)
ORDER BY i.idInstalacao;

-- LÓGICA:
-- A consulta lê a tabela Instalacao (i) e aplica na cláusula WHERE o operador NOT EXISTS com uma subconsulta
-- correlacionada em LimpezaInstalacao (li), filtrando apenas as áreas comuns cujo idInstalacao não possui
-- nenhum registro de limpeza associado, ordenando por i.idInstalacao.

-- RECURSOS SQL UTILIZADOS: SELECT, apelidos de coluna (AS), WHERE, NOT EXISTS, subconsulta correlacionada e ORDER BY

-- JUSTIFICATIVA:

-- Uso de NOT EXISTS:
-- Verifica diretamente a ausência de registros relacionados em LimpezaInstalacao, expressando de forma clara
-- e segura a busca por instalações sem histórico de limpeza.

-- Benefício:
-- Auxilia a supervisão operacional a identificar áreas comuns que ainda não passaram por higienização registrada.

-- RESULTADO ESPERADO:
-- Retorna 2 linhas: instalação 1 (Piscina, ATIVO — cuja limpeza de ID 2 foi removida pelo DELETE ao final do script)
-- e instalação 3 (Sauna, MANUTENCAO).