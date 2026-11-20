-- Mostrando TUDO quando damos join
SELECT * FROM reserva JOIN pessoa ON reserva.cpf = pessoa.cpf;

-- Mostrando os nomes dos hóspedes e CPFs
SELECT
    reserva.cpf AS "CPF",
    pessoa.nome AS "Nome"
FROM reserva
JOIN pessoa ON reserva.cpf = pessoa.cpf;

-- Os hóspedes com status CHECKIN
SELECT
    reserva.cpf AS "CPF",
    pessoa.nome AS "Nome",
    reserva.idreserva AS "ID da reserva",
    reserva.status AS "Status da reserva",
    reserva.valortotal AS "Valor total"
FROM reserva
JOIN pessoa ON reserva.cpf = pessoa.cpf
WHERE reserva.status = 'CHECKIN'
LIMIT 3;


