-- [TESTE 4 - CHECK DE DATAS] Deve falhar: checkout anterior ao checkin
INSERT INTO Reserva (cpf, valorTotal, status, checkin, checkout)
VALUES ('333.444.555-66', 320.00, 'CONFIRMADA', '2026-12-10 14:00:00', '2026-12-08 12:00:00');
-- Erro esperado: violates check constraint "chk_checkout"
