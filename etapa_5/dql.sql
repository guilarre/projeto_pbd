-- =========================================================
-- PARTE 1: JOIN
-- =========================================================

-- Pergunta: quais são os itens de frigobar consumidos por cada reserva? E nome de quem essa reserva está?
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
INNER JOIN pessoa p
    ON r.cpf = p.cpf
LEFT JOIN consumofrigobar cf
    ON r.idreserva = cf.idreserva
LEFT JOIN item i
    ON cf.iditem = i.iditem
GROUP BY r.idreserva, p.cpf, p.nome
ORDER BY r.idreserva;

-- Pergunta: qual o valor total do consumo de cada reserva?
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

-- =========================================================
-- PARTE 2: GROUP BY
-- =========================================================

-- Pergunta: quantas limpezas estão pendentes no hotel?

-- WITH cria uma cte que é tipo uma "tabela temporaria" para ficar melhor a leitura dos dados
WITH ResumoLimpezas AS (
    SELECT
        status,
        COUNT(idLimpeza) AS quantidade_limpezas
    FROM Limpeza
    WHERE status = 'PENDENTE'
    GROUP BY status
)
SELECT
    l.status,
    r.quantidade_limpezas,
    l.idLimpeza,
    l.dataHora,
    l.observacao,
    l.cpf
FROM Limpeza l
JOIN ResumoLimpezas r ON l.status = r.status
WHERE l.status = 'PENDENTE'
ORDER BY l.dataHora;
