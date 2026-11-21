-- Subconsulta: Escalar
-- Pergunta: Quais reservas possuem valor total acima da média das reservas não canceladas do hotel?

SELECT
    r.idreserva,
    p.nome AS nome_hospede,
    r.status,
    r.valortotal
FROM Reserva r
JOIN Hospede h ON r.cpf = h.cpf
JOIN Pessoa p ON h.cpf = p.cpf
WHERE r.valortotal > (
    SELECT AVG(r2.valortotal)
    FROM Reserva r2
    WHERE r2.status <> 'CANCELADA'
)
ORDER BY r.valortotal DESC, r.idreserva ASC;

-- Lógica:
-- A subconsulta interna calcula a média de valortotal na tabela Reserva apenas para registos com status <> 'CANCELADA',
-- devolvendo um único valor escalar.
-- A consulta externa filtra as reservas cujo valortotal é maior que essa média e realiza JOIN com Hospede e Pessoa para obter o nome do hóspede,
-- ordenando os resultados por valortotal decrescente e idreserva crescente

-- Recursos SQL utilizados: SELECT, JOIN, WHERE, subconsulta escalar com a função de agregação AVG() e ORDER BY

-- Justificativa: 

-- Subconsulta interna:
-- Calcula a média escalar de valorTotal na tabela Reserva,
-- desconsiderando as reservas com status 'CANCELADA'

-- Consulta externa:
-- Percorre as reservas, compara o valorTotal de cada uma com a média
-- retornada pela subconsulta e faz JOIN com Hospede e Pessoa para exibir
-- o identificador da reserva, o nome do hóspede, o status e o valor total.

--Benefício
-- Identifica reservas de alto valor, ajudando a gerência na análise de faturamento e em ações de fidelização
-- de hóspedes que geram maior receita.

-- Resultado esperado: 
-- Retorna as reservas que geraram valor acima da média das reservas válidas do resort (na base atual de hotel_resort.sql,
-- a reserva 1 de Mariana Oliveira com 960.00 em estado CHECKOUT e a reserva 2 de Roberto Santos com 960.00 em estado CHECKIN),
-- excluindo reservas de menor valor à média ou canceladas.