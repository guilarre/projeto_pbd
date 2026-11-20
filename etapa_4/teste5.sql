-- [TESTE 5 - CHECK DE AUTO-SUPERVISÃO] Deve falhar: supervisor igual ao supervisionado
INSERT INTO Supervisao (cpfSupervisor, cpfSupervisionado, dataInicio)
VALUES ('111.222.333-44', '111.222.333-44', '2026-01-01');
-- Erro esperado: violates check constraint "chk_supervisao_diferente"
