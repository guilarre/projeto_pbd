-- =========================================================
-- PARTE 1: JOIN
-- =========================================================

-- CONSULTA 1
-- Pergunta de negócio: quais são os itens de frigobar consumidos por cada reserva? E nome de quem essa reserva está?
SELECT
    r.idreserva AS "ID da reserva",
    p.cpf AS "CPF",
    p.nome AS "Nome do hóspede",
    -- a função COALESCE deixa a gente retornar o primeiro não nulo dos seus argumentos
    COALESCE(
        -- o STRING_AGG vai concatenar colunas diferentes separando pelo delimitador passado no 2o arg
        STRING_AGG(
            i.nome || ' (' || cf.quantidade || 'x R$' || cf.valorunitario || ')',
            ', '
        ),
        'Nenhum consumo'
    ) AS "Itens consumidos"
FROM reserva r
-- INNER JOIN retorna linhas com matches nas duas tabelas
INNER JOIN pessoa p
    ON r.cpf = p.cpf
-- LEFT JOIN retorna TODAS as linhas da tabela à esquerda, e apenas os matches da tabela à direita
LEFT JOIN consumofrigobar cf
    ON r.idreserva = cf.idreserva
LEFT JOIN item i
    ON cf.iditem = i.iditem
GROUP BY r.idreserva, p.cpf, p.nome
ORDER BY r.idreserva;

-- LÓGICA:
-- A consulta parte da tabela reserva (r) e realiza um INNER JOIN com pessoa (p) para identificar o titular da reserva.
-- Em seguida, utiliza LEFT JOIN com consumofrigobar (cf) e item (i) para manter todas as reservas no resultado, mesmo sem consumo registrado.
-- Os registros são agrupados por reserva e hóspede (GROUP BY), concatenando os itens consumidos com STRING_AGG
-- e substituindo valores nulos por 'Nenhum consumo' via COALESCE, ordenando ao final por r.idreserva.

-- RECURSOS SQL UTILIZADOS: SELECT, apelidos de coluna (AS), INNER JOIN, LEFT JOIN, STRING_AGG(), COALESCE(), concatenação (||), GROUP BY e ORDER BY

-- JUSTIFICATIVA:

-- Junções (INNER JOIN e LEFT JOIN):
-- Garante que toda reserva tenha um hóspede associado (INNER JOIN), sem descartar reservas que não tiveram
-- consumo no frigobar (LEFT JOIN).

-- Agregação e tratamento de nulos (STRING_AGG e COALESCE):
-- Consolida múltiplos itens consumidos de uma mesma reserva em uma única linha legível e EVITA retorno nulo
-- quando não há consumo registrado.

-- Benefício:
-- Fornece à recepção e à governança um resumo detalhado dos itens consumidos por reserva para conferência no check-out.

-- RESULTADO ESPERADO:
-- Retorna as 4 reservas ordenadas por ID, mostrando o que foi consumido por cada uma.


-- CONSULTA 2
-- Pergunta de negócio: qual o valor total do consumo de cada reserva?
SELECT
    r.idreserva AS "ID da reserva",
    p.cpf AS "CPF",
    p.nome AS "Nome do hóspede",
    COALESCE(
        'R$ ' || TO_CHAR(SUM(cf.quantidade * cf.valorunitario), 'FM999999990.00'),
        'R$ 0.00'
    ) AS "Total frigobar"
FROM reserva r
INNER JOIN pessoa p
    ON r.cpf = p.cpf
LEFT JOIN consumofrigobar cf
    ON r.idreserva = cf.idreserva
GROUP BY r.idreserva, p.cpf, p.nome
ORDER BY r.idreserva;

-- LÓGICA:
-- A consulta relaciona reserva (r) com pessoa (p) via INNER JOIN para obter os dados do titular e utiliza LEFT JOIN
-- com consumofrigobar (cf) para incluir todas as reservas, independentemente de haver consumo.
-- Agrupando por reserva e hóspede (GROUP BY), calcula a soma de cf.quantidade * cf.valorunitario para cada reserva,
-- formata o total em reais com TO_CHAR e exibe 'R$ 0.00' via COALESCE quando não há registros, ordenando por r.idreserva.

-- RECURSOS SQL UTILIZADOS: SELECT, apelidos de coluna (AS), INNER JOIN, LEFT JOIN, SUM(), TO_CHAR(), COALESCE(), concatenação (||), GROUP BY e ORDER BY

-- JUSTIFICATIVA:

-- Junções e agregação (LEFT JOIN e SUM):
-- Mantém todas as reservas no relatório e totaliza o gasto financeiro multiplicando a quantidade pelo valor unitário de cada consumo.

-- Formatação monetária (TO_CHAR e COALESCE):
-- Padroniza a exibição dos valores com duas casas decimais e substitui resultados nulos por 'R$ 0.00'.

-- Benefício:
-- Facilita o fechamento de conta e a auditoria financeira de receitas extras provenientes do frigobar por reserva.

-- RESULTADO ESPERADO:
-- Retorna as 4 reservas com o respectivo total de frigobar.


-- =========================================================
-- PARTE 2: GROUP BY
-- =========================================================

-- CONSULTA 1
-- Pergunta de negócio: quais limpezas pendentes tem cada funcionário?
SELECT
    l.cpf,
    STRING_AGG(
        CONCAT(
            'ID: ', l.idLimpeza,
            ' | Data: ', l.dataHora,
            ' | Observação: ', COALESCE(l.observacao, 'Sem observação')
        ),
        E'\n'
    ) AS limpezas_pendentes
FROM limpeza l
WHERE l.status = 'PENDENTE'
GROUP BY l.cpf;

-- LÓGICA:
-- A consulta filtra a tabela limpeza (l) pelo critério WHERE l.status = 'PENDENTE' para considerar apenas tarefas ainda não iniciadas.
-- Em seguida, agrupa os registros por funcionário (GROUP BY l.cpf) e utiliza STRING_AGG com CONCAT e COALESCE
-- para reunir em um único campo de texto (separado por quebra de linha) o ID, a data/hora e a observação de cada limpeza pendente.

-- RECURSOS SQL UTILIZADOS: SELECT, WHERE, GROUP BY, STRING_AGG(), CONCAT(), COALESCE() e apelido de coluna (AS)

-- JUSTIFICATIVA:

-- Filtragem e agrupamento (WHERE e GROUP BY):
-- Isola somente os registros com status 'PENDENTE' antes de consolidá-los por CPF, desconsiderando limpezas concluídas ou em andamento.

-- Consolidação textual (STRING_AGG, CONCAT e COALESCE):
-- Agrupa múltiplas pendências de um mesmo colaborador em uma única linha de saída e trata observações nulas com texto padrão.

-- Benefício:
-- Permite à supervisão operacional visualizar rapidamente a fila de tarefas pendentes atribuídas a cada funcionário.

-- RESULTADO ESPERADO:
-- Retorna 1 linha referente ao único registro pendente na base atual.


-- CONSULTA 2:
-- Pergunta de negócio: quantos quartos existem em cada situação no hotel?
SELECT
    status,
    COUNT(idquarto) AS quantidade_quartos
FROM quarto
-- com o GROUP BY, evitamos linhas diferentes para um mesmo status
GROUP BY status
ORDER BY quantidade_quartos DESC;

-- LÓGICA:
-- A consulta lê a tabela quarto, agrupa os registros pela coluna status (GROUP BY status) e aplica COUNT(idquarto)
-- para contabilizar quantos quartos existem em cada estado operacional, ordenando do maior para o menor volume (ORDER BY DESC).

-- RECURSOS SQL UTILIZADOS: SELECT, COUNT(), apelido de coluna (AS), GROUP BY e ORDER BY

-- JUSTIFICATIVA:

-- Agrupamento e contagem (GROUP BY e COUNT):
-- Consolida todas as unidades habitacionais por status, evitando linhas duplicadas para uma mesma situação.

-- Ordenação (ORDER BY ... DESC):
-- Destaca primeiro as situações com maior quantidade de quartos no hotel.

-- Benefício:
-- Oferece um panorama imediato da ocupação e disponibilidade das acomodações para apoio à recepção e à gerência.

-- RESULTADO ESPERADO:
-- Retorna 4 linhas representando a distribuição dos 5 quartos cadastrados, agrupando por status para evitar repetições desnecessárias.


-- =========================================================
-- PARTE 3: HAVING
-- =========================================================

-- Pergunta de negócio: Quais hospedes possuem um valor acumulado de reservas maior que 700, desconsiderando reservas canceladas?
SELECT
    h.cpf AS "CPF do hospede",
    p.nome AS "Nome do hospede",
    COUNT(r.idReserva) AS "Quantidade de reservas",
    SUM(r.valorTotal) AS "Valor acumulado"
FROM Hospede h
INNER JOIN Pessoa p
    ON h.cpf = p.cpf
INNER JOIN Reserva r
    ON h.cpf = r.cpf
-- Exclui as reservas canceladas antes da agregação
WHERE r.status <> 'CANCELADA'
-- Agrupa as reservas por hospede
GROUP BY
    h.cpf,
    p.nome
-- Retorna somente hospedes com o valor acumulado das reservas que seja maior a 700
HAVING SUM(r.valorTotal) > 700
-- Ordena pelo valor acumulado, do maior para o menor.
ORDER BY SUM(r.valorTotal) DESC;

-- LÓGICA:
-- A consulta une Hospede (h), Pessoa (p) e Reserva (r) via INNER JOIN para associar cada reserva ao respectivo titular.
-- Antes da agregação, o filtro WHERE r.status <> 'CANCELADA' elimina reservas canceladas.
-- Em seguida, agrupa por h.cpf e p.nome (GROUP BY), calcula a quantidade (COUNT) e o somatório (SUM) de r.valorTotal,
-- filtra os grupos com HAVING SUM(r.valorTotal) > 700 e ordena pelo valor acumulado de forma decrescente.

-- RECURSOS SQL UTILIZADOS: SELECT, apelidos de coluna (AS), INNER JOIN, WHERE, COUNT(), SUM(), GROUP BY, HAVING e ORDER BY

-- JUSTIFICATIVA:

-- Filtragem pré e pós-agregação (WHERE e HAVING):
-- O WHERE descarta reservas canceladas linha a linha antes do cálculo, enquanto o HAVING filtra o resultado já agregado
-- pela função SUM(), condição que não pode ser aplicada na cláusula WHERE.

-- Junções e agregação (INNER JOIN, COUNT e SUM):
-- Relaciona os dados cadastrais do hóspede ao seu histórico financeiro válido no hotel.

-- Benefício:
-- Identifica hóspedes com alto volume acumulado de gastos em reservas válidas para ações de fidelização e relacionamento VIP.

-- RESULTADO ESPERADO:
-- Retorna os hóspedes cuja soma de reservas não canceladas ultrapassa 700.00.


-- =========================================================
-- PARTE 4: SUBCONSULTA ESCALAR
-- =========================================================

-- Pergunta de negócio: Quais reservas possuem valor total acima da média das reservas não canceladas do hotel?
SELECT
    r.idreserva,
    p.nome AS nome_hospede,
    r.status,
    r.valortotal
FROM Reserva r
JOIN Hospede h ON r.cpf = h.cpf
JOIN Pessoa p ON h.cpf = p.cpf
WHERE r.valortotal > (
    -- nossa subconsulta
    SELECT
        AVG(r2.valortotal)
    FROM Reserva r2
    WHERE r2.status <> 'CANCELADA'
)
ORDER BY r.valortotal DESC, r.idreserva ASC;

-- LÓGICA:
-- A subconsulta interna calcula a média de valortotal na tabela Reserva apenas para registros com status <> 'CANCELADA',
-- devolvendo um único valor escalar.
-- A consulta externa filtra as reservas cujo valortotal é maior que essa média e realiza JOIN com Hospede e Pessoa para obter o nome do hóspede,
-- ordenando os resultados por valortotal decrescente e idreserva crescente

-- RECURSOS SQL UTILIZADOS: SELECT, JOIN, WHERE, subconsulta escalar com a função de agregação AVG() e ORDER BY

-- JUSTIFICATIVA:

-- Subconsulta interna:
-- Calcula a média escalar de valorTotal na tabela Reserva,
-- desconsiderando as reservas com status 'CANCELADA'

-- Consulta externa:
-- Percorre as reservas, compara o valorTotal de cada uma com a média
-- retornada pela subconsulta e faz JOIN com Hospede e Pessoa para exibir
-- o identificador da reserva, o nome do hóspede, o status e o valor total.

--Benefício:
-- Identifica reservas de alto valor, ajudando a gerência na análise de faturamento e em ações de fidelização
-- de hóspedes que geram maior receita.

-- RESULTADO ESPERADO: 
-- Retorna as reservas que geraram valor acima da média das reservas válidas do resort (na base atual de hotel_resort.sql,
-- a reserva 1 de Mariana Oliveira com 960.00 em estado CHECKOUT e a reserva 2 de Roberto Santos com 960.00 em estado CHECKIN),
-- excluindo reservas de menor valor à média ou canceladas.


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