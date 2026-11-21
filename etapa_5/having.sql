-- =========================================================
-- PARTE 2: GROUP BY
-- =========================================================

-- CONSULTA 1: Valor acumulado de reservas por hospede


-- Pergunta de negocio: Quais hospedes possuem um valor acumulado de reservas maior que 700, desconsiderando reservas canceladas?

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

-- Exclui as reservas canceladas antes da agregacao
WHERE r.status <> 'CANCELADA'

-- Agrupa as reservas por hospede
GROUP BY
    h.cpf,
    p.nome

-- Retorna somente hospedes com o valor acumulado das reservas que seja maior a 700
HAVING SUM(r.valorTotal) > 700

-- Ordena pelo valor acumulado, do maior para o menor.
ORDER BY SUM(r.valorTotal) DESC;


-- CONSULTA 2: Consumo de produtos do frigobar por hospede


-- Pergunta: Quais produtos foram consumidos por cada hospede durante suas respectivas reservas e qual foi a quantidade total consumida de cada produto?

SELECT
    h.cpf AS "CPF do hospede",
    p.nome AS "Nome do hospede",
    r.idReserva AS "Reserva",
    i.nome AS "Produto",
    SUM(cf.quantidade) AS "Quantidade consumida"

FROM Pessoa p

-- Relaciona a pessoa ao seu cadastro de hospede
INNER JOIN Hospede h
    ON h.cpf = p.cpf

-- Busca as reservas realizadas pelo hospede
INNER JOIN Reserva r
    ON h.cpf = r.cpf

-- Busca os consumos registrados em cada reserva
INNER JOIN ConsumoFrigobar cf
    ON r.idReserva = cf.idReserva

-- Identifica os produtos consumidos
INNER JOIN Item i
    ON cf.idItem = i.idItem

-- Agrupa por hospede, reserva e produto para somar as quantidades consumidas
GROUP BY
    h.cpf,
    p.nome,
    r.idReserva,
    i.idItem,
    i.nome

-- Organiza os resultados pela quantidade consumida
ORDER BY SUM(cf.quantidade) DESC;


