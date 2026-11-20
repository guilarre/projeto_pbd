-- [TESTE 6 - UNIQUE 1:1] Deve falhar: Quarto 2 já possui um frigobar associado
INSERT INTO Frigobar (idQuarto, status) VALUES (2, 'ATIVO');
-- Erro esperado: duplicate key value violates unique constraint "frigobar_idquarto_key"
