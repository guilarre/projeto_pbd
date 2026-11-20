\set ON_ERROR_STOP on --já que vamos rodar via psql, p parar no primeiro erro

BEGIN;

-- 1. TABELAS INDEPENDENTES (BASE)

-- Inserindo Pessoas (Funcionários e Hóspedes)
INSERT INTO Pessoa (cpf, nome, dataNascimento) VALUES
('111.222.333-44', 'Carlos Silva', '1985-03-12'),
('222.333.444-55', 'Ana Souza', '1992-07-25'),
('333.444.555-66', 'Mariana Oliveira', '1990-11-05'),
('444.555.666-77', 'Roberto Santos', '1982-01-19'),
('555.666.777-88', 'Fernanda Lima', '1998-09-30');

-- Inserindo Endereços de Cobrança
INSERT INTO EnderecoCobranca (cep, rua, bairro, cidade, estado) VALUES
('50000-000', 'Av. Boa Viagem', 'Boa Viagem', 'Recife', 'PE'),
('01000-000', 'Av. Paulista', 'Bela Vista', 'São Paulo', 'SP');

-- Inserindo Cargos (idCargo gerado automaticamente: 1, 2, 3)
INSERT INTO Cargo (nomeCargo, salarioBase) VALUES
('Gerente Geral', 4500.00),
('Recepcionista', 2200.00),
('Camareiro(a)', 1800.00);

-- Inserindo Instalações do Hotel (idInstalacao gerado automaticamente: 1, 2)
INSERT INTO Instalacao (tipo, horarioAberto, horarioFechado, status) VALUES
('Piscina', '08:00:00', '22:00:00', 'ATIVO'),
('Academia', '06:00:00', '23:00:00', 'ATIVO');

-- Inserindo Itens de Frigobar (idItem gerado automaticamente: 1, 2, 3, 4)
INSERT INTO Item (nome, preco) VALUES
('Água Mineral 500ml', 5.00),
('Refrigerante Lata', 7.50),
('Chocolate KitKat', 8.00),
('Cerveja Long Neck', 12.00);

-- Inserindo Tipos de Quarto (idTipoQuarto gerado automaticamente: 1, 2, 3)
INSERT INTO TipoQuarto (nome, capacidade, valorDiaria, qtdCamas) VALUES
('Standard Solteiro', 1, 150.00, 1),
('Luxo Casal', 2, 320.00, 1),
('Suíte Master', 4, 650.00, 2);


-- 2. TABELAS DEPENDENTES (NÍVEL 1)

-- Inserindo Telefones das Pessoas
INSERT INTO TelefonePessoa (cpf, ddd, numeroTelefone) VALUES
('111.222.333-44', '81', '98888-1111'),
('222.333.444-55', '81', '97777-2222'),
('333.444.555-66', '11', '99999-3333'),
('444.555.666-77', '11', '98888-4444'),
('555.666.777-88', '81', '96666-5555');

-- Inserindo Funcionários (Vinculados a Pessoa e Cargo)
INSERT INTO Funcionario (cpf, idCargo, salarioAdicional, dataAdmissao, turno) VALUES
('111.222.333-44', 1, 500.00, '2020-01-15', 'INTEGRAL'), -- Gerente
('222.333.444-55', 3, 150.00, '2022-05-10', 'MANHA'),    -- Camareira
('555.666.777-88', 2, 200.00, '2023-03-01', 'TARDE');    -- Recepcionista

-- Inserindo Supervisão (Carlos gerencia a Ana)
INSERT INTO Supervisao (cpfSupervisor, cpfSupervisionado, dataInicio, dataFim) VALUES
('111.222.333-44', '222.333.444-55', '2022-05-10', NULL);

-- Inserindo Hóspedes (Vinculados a Pessoa e EnderecoCobranca)
INSERT INTO Hospede (cpf, cep, numeroEndereco, complementoEndereco) VALUES
('333.444.555-66', '01000-000', '1000', 'Apto 402'),
('444.555.666-77', '50000-000', '250', 'Bloco B');

-- Inserindo Quartos (idQuarto gerado automaticamente: 1, 2, 3)
INSERT INTO Quarto (idTipoQuarto, status) VALUES
(1, 'DISPONIVEL'), -- Quarto 1 (Standard)
(2, 'OCUPADO'),    -- Quarto 2 (Luxo)
(3, 'RESERVADO');  -- Quarto 3 (Suíte)

-- Inserindo Registros de Limpeza (idLimpeza gerado automaticamente: 1, 2)
INSERT INTO Limpeza (dataHora, status, observacao, cpf) VALUES
('2026-11-10 08:00:00', 'CONCLUIDA', 'Limpeza padrão pós-checkout', '222.333.444-55'),
('2026-11-10 06:00:00', 'CONCLUIDA', 'Higienização diária da piscina', '222.333.444-55');


-- 3. TABELAS DE RELACIONAMENTO E TRANSAÇÕES (NÍVEL 2)

-- Relacionando Limpeza aos Quartos e Instalações
INSERT INTO LimpezaQuarto (idLimpeza, idQuarto) VALUES (1, 1);
INSERT INTO LimpezaInstalacao (idLimpeza, idInstalacao) VALUES (2, 1);

-- Inserindo Reservas (idReserva gerado automaticamente: 1, 2)
INSERT INTO Reserva (cpf, valorTotal, dataReserva, status, checkin, checkout) VALUES
('333.444.555-66', 960.00, '2026-11-01 10:00:00', 'CHECKOUT', '2026-11-05 14:00:00', '2026-11-08 11:00:00'),
('444.555.666-77', 650.00, '2026-11-10 15:00:00', 'CONFIRMADA', NULL, NULL);

-- Associando Quartos às Reservas
INSERT INTO ReservaQuarto (idReserva, idQuarto, valorDiaria) VALUES
(1, 2, 320.00), -- Reserva 1 ficou no Quarto 2 (Luxo: 3 diárias = 960.00)
(2, 3, 650.00); -- Reserva 2 reservou o Quarto 3 (Suíte: 1 diária = 650.00)

-- Inserindo Pagamento referente à Reserva 1
INSERT INTO Pagamento (idReserva, valorPago, status, tipoPagamento) VALUES
(1, 960.00, 'PAGO', 'PIX');

-- Inserindo Frigobares nos Quartos 2 e 3 (idFrigobar gerado: 1, 2)
INSERT INTO Frigobar (idQuarto, status) VALUES
(2, 'ATIVO'),
(3, 'ATIVO');

-- Abastecendo os Frigobares com Itens (FrigobarItem)
INSERT INTO FrigobarItem (idFrigobar, idItem, qtdDisponivel, qtdColocada) VALUES
(1, 1, 3, 4), -- Frigobar do Quarto 2 tem Água (3 restam de 4 colocadas)
(1, 2, 1, 2), -- Frigobar do Quarto 2 tem Refrigerante (1 resta de 2 colocadas)
(2, 3, 2, 2); -- Frigobar do Quarto 3 tem Chocolate (2 restam de 2 colocadas)

-- Registrando Consumo no Frigobar durante a Reserva 1
INSERT INTO ConsumoFrigobar (idReserva, idQuarto, idItem, dataHora, quantidade, valorUnitario) VALUES
(1, 2, 1, '2026-11-06 20:00:00', 1, 5.00); -- Hóspede consumiu 1 água no dia 06/11

COMMIT;
