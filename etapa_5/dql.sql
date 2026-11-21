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

-- Pergunta: quais limpezas pendentes tem cada funcionário?

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
FROM Limpeza l
WHERE l.status = 'PENDENTE'
GROUP BY l.cpf;
