\set ON_ERROR_STOP on


\c postgres
DROP DATABASE IF EXISTS hotel_db;
CREATE DATABASE hotel_db;

\c hotel_db;

BEGIN;
SET client_encoding TO 'UTF8';


CREATE TYPE status_instalacao AS ENUM ('ATIVO', 'INATIVO', 'MANUTENCAO');
CREATE TYPE tipo_pagamento AS ENUM ('DEBITO', 'CREDITO', 'A_VISTA', 'PIX');
CREATE TYPE tipo_turno AS ENUM ('MANHA', 'TARDE', 'NOITE', 'INTEGRAL');
CREATE TYPE status_limpeza AS ENUM ('PENDENTE', 'EM ANDAMENTO', 'CONCLUIDA');
CREATE TYPE status_quarto AS ENUM ('DISPONIVEL', 'OCUPADO', 'RESERVADO', 'INTERDITADO');
CREATE TYPE status_frigobar AS ENUM ('ATIVO', 'INATIVO', 'MANUTENCAO');
CREATE TYPE status_reserva AS ENUM ('PENDENTE', 'CONFIRMADA', 'CANCELADA', 'CHECKIN', 'CHECKOUT');
CREATE TYPE status_pagamento AS ENUM ('PENDENTE', 'PAGO', 'CANCELADO', 'ESTORNADO');

-- 2.1 Entidades Independentes
CREATE TABLE Pessoa (
    cpf VARCHAR(20) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    dataNascimento DATE NOT NULL
);

CREATE TABLE EnderecoCobranca (
    cep VARCHAR(20) PRIMARY KEY,
    rua VARCHAR(100) NOT NULL,
    bairro VARCHAR(50) NOT NULL,
    cidade VARCHAR(50) NOT NULL,
    estado VARCHAR(50) NOT NULL
);

CREATE TABLE Cargo (
    idCargo SERIAL PRIMARY KEY,
    nomeCargo VARCHAR(50) NOT NULL UNIQUE,
    salarioBase DECIMAL(10, 2) NOT NULL CHECK (salarioBase >= 0)
);

CREATE TABLE Instalacao (
    idInstalacao SERIAL PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL,
    horarioAberto TIME NOT NULL,
    horarioFechado TIME NOT NULL,
    status status_instalacao NOT NULL DEFAULT 'ATIVO'
);

CREATE TABLE Item (
    idItem SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE,
    preco DECIMAL(10, 2) NOT NULL CHECK (preco >= 0)
);

CREATE TABLE TipoQuarto (
    idTipoQuarto VARCHAR(20) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    capacidade INT NOT NULL CHECK (capacidade > 0),
    valorDiaria DECIMAL(10, 2) NOT NULL CHECK (valorDiaria >= 0),
    qtdCamas INT NOT NULL CHECK (qtdCamas > 0)
);

-- 2.2 Entidades Dependentes (Nível 1)
CREATE TABLE TelefonePessoa (
    idTelefone SERIAL PRIMARY KEY,
    cpf VARCHAR(20) NOT NULL REFERENCES Pessoa(cpf) ON UPDATE CASCADE ON DELETE CASCADE,
    ddd VARCHAR(10) NOT NULL,
    numeroTelefone VARCHAR(20) NOT NULL
);

CREATE TABLE Funcionario (
    cpf VARCHAR(20) PRIMARY KEY REFERENCES Pessoa(cpf) ON UPDATE CASCADE ON DELETE RESTRICT,
    idCargo INT NOT NULL REFERENCES Cargo(idCargo) ON UPDATE CASCADE ON DELETE RESTRICT,
    salarioAdicional DECIMAL(10, 2) DEFAULT 0.00 CHECK (salarioAdicional >= 0),
    dataAdmissao DATE NOT NULL,
    turno tipo_turno NOT NULL
);

CREATE TABLE Supervisao (
    idSupervisao SERIAL PRIMARY KEY,
    cpfSupervisor VARCHAR(20) NOT NULL REFERENCES Funcionario(cpf) ON UPDATE CASCADE ON DELETE RESTRICT,
    cpfSupervisionado VARCHAR(20) NOT NULL REFERENCES Funcionario(cpf) ON UPDATE CASCADE ON DELETE CASCADE,
    dataInicio DATE NOT NULL,
    dataFim DATE,
    CONSTRAINT chk_supervisao_diferente CHECK (cpfSupervisor <> cpfSupervisionado),
    CONSTRAINT chk_datas_supervisao CHECK (dataFim IS NULL OR dataFim >= dataInicio)
);

CREATE TABLE Hospede (
    cpf VARCHAR(20) PRIMARY KEY REFERENCES Pessoa(cpf) ON UPDATE CASCADE ON DELETE RESTRICT,
    cep VARCHAR(20) NOT NULL REFERENCES EnderecoCobranca(cep) ON UPDATE CASCADE ON DELETE RESTRICT,
    numeroEndereco VARCHAR(20) NOT NULL,
    complementoEndereco VARCHAR(100)
);

CREATE TABLE Quarto (
    idQuarto SERIAL PRIMARY KEY,
    idTipoQuarto VARCHAR(20) NOT NULL REFERENCES TipoQuarto(idTipoQuarto) ON UPDATE CASCADE ON DELETE RESTRICT,
    status status_quarto NOT NULL DEFAULT 'DISPONIVEL'
);

CREATE TABLE Limpeza (
    idLimpeza SERIAL PRIMARY KEY,
    dataHora TIMESTAMP NOT NULL,
    status status_limpeza NOT NULL DEFAULT 'PENDENTE',
    observacao VARCHAR(250),
    cpf VARCHAR(20) NOT NULL REFERENCES Funcionario(cpf) ON UPDATE CASCADE ON DELETE RESTRICT
);


CREATE TABLE LimpezaQuarto (
    idLimpeza INT PRIMARY KEY REFERENCES Limpeza(idLimpeza) ON UPDATE CASCADE ON DELETE CASCADE,
    idQuarto INT NOT NULL REFERENCES Quarto(idQuarto) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE LimpezaInstalacao (
    idLimpeza INT PRIMARY KEY REFERENCES Limpeza(idLimpeza) ON UPDATE CASCADE ON DELETE CASCADE,
    idInstalacao INT NOT NULL REFERENCES Instalacao(idInstalacao) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Reserva (
    idReserva SERIAL PRIMARY KEY,
    cpf VARCHAR(20) NOT NULL REFERENCES Hospede(cpf) ON UPDATE CASCADE ON DELETE RESTRICT,
    valorTotal DECIMAL(10, 2) NOT NULL CHECK (valorTotal >= 0),
    dataReserva DATE NOT NULL DEFAULT CURRENT_DATE,
    status status_reserva NOT NULL DEFAULT 'PENDENTE',
    checkin TIMESTAMP,
    checkout TIMESTAMP,
    CONSTRAINT chk_checkout CHECK (checkout IS NULL OR checkin IS NULL OR checkout > checkin)
);

CREATE TABLE ReservaQuarto (
    idReserva INT NOT NULL REFERENCES Reserva(idReserva) ON UPDATE CASCADE ON DELETE CASCADE,
    idQuarto INT NOT NULL REFERENCES Quarto(idQuarto) ON UPDATE CASCADE ON DELETE RESTRICT,
    qtdHospedes INT NOT NULL CHECK (qtdHospedes > 0),
    PRIMARY KEY (idReserva, idQuarto)
);

CREATE TABLE Pagamento (
    idPagamento SERIAL PRIMARY KEY,
    idReserva INT NOT NULL REFERENCES Reserva(idReserva) ON UPDATE CASCADE ON DELETE RESTRICT,
    valorPago DECIMAL(10, 2) NOT NULL CHECK (valorPago > 0),
    status status_pagamento NOT NULL DEFAULT 'PENDENTE',
    tipoPagamento tipo_pagamento NOT NULL
);

CREATE TABLE Frigobar (
    idFrigobar SERIAL PRIMARY KEY,
    idQuarto INT UNIQUE NOT NULL REFERENCES Quarto(idQuarto) ON UPDATE CASCADE ON DELETE CASCADE,
    status status_frigobar NOT NULL DEFAULT 'ATIVO'
);

CREATE TABLE FrigobarItem (
    idFrigobar INT NOT NULL REFERENCES Frigobar(idFrigobar) ON UPDATE CASCADE ON DELETE CASCADE,
    idItem INT NOT NULL REFERENCES Item(idItem) ON UPDATE CASCADE ON DELETE RESTRICT,
    qtdDisponivel INT NOT NULL CHECK (qtdDisponivel >= 0),
    qtdColocada INT NOT NULL CHECK (qtdColocada >= 0),
    PRIMARY KEY (idFrigobar, idItem),
    CONSTRAINT chk_qtd CHECK (qtdDisponivel <= qtdColocada)
);

CREATE TABLE ConsumoFrigobar (
    idConsumo SERIAL PRIMARY KEY,
    idReserva INT NOT NULL,
    idQuarto INT NOT NULL,
    idItem INT NOT NULL REFERENCES Item(idItem) ON UPDATE CASCADE ON DELETE RESTRICT,
    dataHora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    valorUnitario DECIMAL(10, 2) NOT NULL CHECK (valorUnitario >= 0),
    FOREIGN KEY (idReserva, idQuarto) REFERENCES ReservaQuarto(idReserva, idQuarto) ON UPDATE CASCADE ON DELETE RESTRICT
);


INSERT INTO Pessoa (cpf, nome, dataNascimento) VALUES
('111.222.333-44', 'Carlos Silva', '1985-03-12'),
('222.333.444-55', 'Ana Souza', '1992-07-25'),
('333.444.555-66', 'Mariana Oliveira', '1990-11-05'),
('444.555.666-77', 'Roberto Santos', '1982-01-19'),
('555.666.777-88', 'Fernanda Lima', '1998-09-30'),
('666.777.888-99', 'Eduardo Andrade', '1995-04-10'),
('777.888.999-00', 'Juliana Marques', '1988-12-01');

INSERT INTO EnderecoCobranca (cep, rua, bairro, cidade, estado) VALUES
('50000-000', 'Av. Boa Viagem', 'Boa Viagem', 'Recife', 'PE'),
('01000-000', 'Av. Paulista', 'Bela Vista', 'São Paulo', 'SP'),
('70000-000', 'Eixo Monumental', 'Asa Sul', 'Brasília', 'DF');

INSERT INTO Cargo (nomeCargo, salarioBase) VALUES
('Gerente Geral', 4500.00),
('Recepcionista', 2200.00),
('Camareiro(a)', 1800.00),
('Manutenção', 2000.00);

INSERT INTO Instalacao (tipo, horarioAberto, horarioFechado, status) VALUES
('Piscina', '08:00:00', '22:00:00', 'ATIVO'),
('Academia', '06:00:00', '23:00:00', 'ATIVO'),
('Sauna', '10:00:00', '20:00:00', 'MANUTENCAO');

INSERT INTO Item (nome, preco) VALUES
('Água Mineral 500ml', 5.00),
('Refrigerante Lata', 7.50),
('Chocolate KitKat', 8.00),
('Cerveja Long Neck', 12.00),
('Amendoim 100g', 10.00);

INSERT INTO TipoQuarto (idTipoQuarto, nome, capacidade, valorDiaria, qtdCamas) VALUES
('STD-SOL', 'Standard Solteiro', 1, 150.00, 1),
('LUX-CAS', 'Luxo Casal', 2, 320.00, 1),
('SUI-MST', 'Suíte Master', 4, 650.00, 2),
('FAM-01',  'Família', 5, 450.00, 3);


INSERT INTO TelefonePessoa (cpf, ddd, numeroTelefone) VALUES
('111.222.333-44', '81', '98888-1111'),
('222.333.444-55', '81', '97777-2222'),
('333.444.555-66', '11', '99999-3333'),
('333.444.555-66', '11', '3245-8899'), 
('666.777.888-99', '61', '99999-0000');

INSERT INTO Funcionario (cpf, idCargo, salarioAdicional, dataAdmissao, turno) VALUES
('111.222.333-44', 1, 500.00, '2020-01-15', 'INTEGRAL'),
('222.333.444-55', 3, 150.00, '2022-05-10', 'MANHA'),
('555.666.777-88', 2, 200.00, '2023-03-01', 'TARDE'),
('777.888.999-00', 4, 0.00,   '2024-01-20', 'NOITE');

INSERT INTO Supervisao (cpfSupervisor, cpfSupervisionado, dataInicio, dataFim) VALUES
('111.222.333-44', '222.333.444-55', '2022-05-10', NULL),
('111.222.333-44', '555.666.777-88', '2023-03-01', NULL),
('111.222.333-44', '777.888.999-00', '2024-01-20', '2025-12-31');

INSERT INTO Hospede (cpf, cep, numeroEndereco, complementoEndereco) VALUES
('333.444.555-66', '01000-000', '1000', 'Apto 402'),
('444.555.666-77', '50000-000', '250',  'Bloco B'),
('666.777.888-99', '70000-000', '12',   'Casa');

INSERT INTO Quarto (idTipoQuarto, status) VALUES
('STD-SOL', 'DISPONIVEL'),  
('LUX-CAS', 'OCUPADO'),     
('SUI-MST', 'RESERVADO'),  
('LUX-CAS', 'DISPONIVEL'),  
('FAM-01',  'INTERDITADO'); 

INSERT INTO Limpeza (dataHora, status, observacao, cpf) VALUES
('2026-11-08 12:00:00', 'CONCLUIDA',    'Limpeza padrão pós-checkout', '222.333.444-55'), -- idLimpeza = 1
('2026-11-10 06:00:00', 'CONCLUIDA',    'Higienização diária',         '222.333.444-55'), -- idLimpeza = 2
('2026-11-13 14:00:00', 'EM ANDAMENTO', 'Arrumação de quarto ocupado', '222.333.444-55'), -- idLimpeza = 3
('2026-11-13 18:00:00', 'PENDENTE',     'Manutenção preventiva',       '777.888.999-00'); -- idLimpeza = 4


INSERT INTO LimpezaQuarto (idLimpeza, idQuarto) VALUES
(1, 4),
(3, 2);

INSERT INTO LimpezaInstalacao (idLimpeza, idInstalacao) VALUES
(2, 1),
(4, 2);

INSERT INTO Reserva (cpf, valorTotal, dataReserva, status, checkin, checkout) VALUES
('333.444.555-66', 960.00, '2026-10-01', 'CHECKOUT',   '2026-11-05 14:00:00', '2026-11-08 11:00:00'), 
('444.555.666-77', 960.00, '2026-11-10', 'CHECKIN',    '2026-11-12 14:30:00', NULL),                  
('666.777.888-99', 450.00, '2026-11-11', 'CANCELADA',  NULL,                  NULL),                  
('333.444.555-66', 650.00, '2026-11-12', 'CONFIRMADA', NULL,                  NULL);                  

INSERT INTO ReservaQuarto (idReserva, idQuarto, qtdHospedes) VALUES
(1, 4, 2),
(2, 2, 2),
(3, 5, 4),
(4, 3, 3);

INSERT INTO Pagamento (idReserva, valorPago, status, tipoPagamento) VALUES
(1, 960.00, 'PAGO',      'PIX'),
(2, 480.00, 'PAGO',      'CREDITO'),
(2, 480.00, 'PENDENTE',  'A_VISTA'),
(3, 450.00, 'ESTORNADO', 'DEBITO'),
(4, 650.00, 'PAGO',      'PIX');

INSERT INTO Frigobar (idQuarto, status) VALUES
(2, 'ATIVO'), 
(3, 'ATIVO'), 
(4, 'ATIVO'); 

INSERT INTO FrigobarItem (idFrigobar, idItem, qtdDisponivel, qtdColocada) VALUES
(1, 1, 3, 4),
(1, 2, 1, 2),
(2, 3, 2, 2),
(2, 4, 0, 5),
(3, 1, 3, 4),
(3, 2, 1, 2);

INSERT INTO ConsumoFrigobar (idReserva, idQuarto, idItem, dataHora, quantidade, valorUnitario) VALUES
(1, 4, 1, '2026-11-06 20:00:00', 1, 5.00),
(1, 4, 2, '2026-11-07 15:00:00', 1, 7.50),
(2, 2, 4, '2026-11-12 21:00:00', 2, 12.00);

COMMIT;


UPDATE Pessoa SET cpf = '666.777.888-00' WHERE cpf = '666.777.888-99';


DELETE FROM Limpeza WHERE idLimpeza = 2;


SELECT COUNT(*) AS total_tabelas
FROM information_schema.tables
WHERE table_schema = 'public';

SELECT r.idReserva, p.nome AS hospede, rq.idQuarto, tq.nome AS tipo_quarto, r.status, r.valorTotal
FROM Reserva r
JOIN Hospede h ON r.cpf = h.cpf
JOIN Pessoa p ON h.cpf = p.cpf
JOIN ReservaQuarto rq ON r.idReserva = rq.idReserva
JOIN Quarto q ON rq.idQuarto = q.idQuarto
JOIN TipoQuarto tq ON q.idTipoQuarto = tq.idTipoQuarto
ORDER BY r.idReserva;
