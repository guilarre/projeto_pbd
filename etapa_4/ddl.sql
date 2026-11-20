\set ON_ERROR_STOP on --já que vamos rodar via psql, p parar no primeiro erro

BEGIN;

-- Padronizamos os valores de VARCHAR possíveis como: 10, 20, 50 ou 100
-- ENUMs
CREATE TYPE status_instalacao AS ENUM ('ATIVO', 'INATIVO', 'MANUTENCAO');
CREATE TYPE tipo_pagamento AS ENUM ('DEBITO', 'CREDITO', 'A_VISTA', 'PIX');
CREATE TYPE tipo_turno AS ENUM ('MANHA', 'TARDE', 'NOITE', 'INTEGRAL');
CREATE TYPE status_limpeza AS ENUM ('PENDENTE', 'EM ANDAMENTO', 'CONCLUIDA');
CREATE TYPE status_quarto AS ENUM ('DISPONIVEL', 'OCUPADO', 'RESERVADO', 'INTERDITADO');
CREATE TYPE status_frigobar AS ENUM('ATIVO', 'INATIVO', 'MANUTENCAO');
CREATE TYPE status_reserva AS ENUM ('PENDENTE', 'CONFIRMADA', 'CANCELADA', 'CHECKIN', 'CHECKOUT');
CREATE TYPE status_pagamento AS ENUM ('PENDENTE', 'PAGO', 'CANCELADO', 'ESTORNADO');

-- Entidades Independentes
CREATE TABLE Pessoa (
  cpf VARCHAR(20) PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  dataNascimento DATE NOT NULL
);

CREATE TABLE EnderecoCobranca (
  cep VARCHAR(20) PRIMARY KEY,
  rua VARCHAR(50) NOT NULL,
  bairro VARCHAR(50) NOT NULL,
  cidade VARCHAR(50) NOT NULL,
  estado VARCHAR(50) NOT NULL
);

CREATE TABLE Cargo (
  idCargo SERIAL PRIMARY KEY,
  nomeCargo VARCHAR(50) NOT NULL,
  salarioBase DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Instalacao (
  idInstalacao SERIAL PRIMARY KEY,
  tipo VARCHAR(50) NOT NULL,
  horarioAberto TIME NOT NULL,
  horarioFechado TIME NOT NULL,
  status status_instalacao NOT NULL
);

CREATE TABLE Item (
  idItem SERIAL PRIMARY KEY,
  nome VARCHAR(50) NOT NULL,
  preco DECIMAL(10, 2) NOT NULL CHECK (preco >= 0)
);

CREATE TABLE TipoQuarto (
  idTipoQuarto SERIAL PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  capacidade INT NOT NULL CHECK (capacidade > 0),
  valorDiaria DECIMAL(10, 2) NOT NULL CHECK (valorDiaria >= 0),
  qtdCamas INT NOT NULL CHECK (qtdCamas > 0)
);

-- Entidades dependentes
CREATE TABLE TelefonePessoa (
  idTelefone SERIAL PRIMARY KEY,
  cpf VARCHAR(20) NOT NULL REFERENCES Pessoa(cpf) ON UPDATE CASCADE,
  ddd VARCHAR(10),
  numeroTelefone VARCHAR(20) NOT NULL
);

CREATE TABLE Funcionario (
  cpf VARCHAR(20) PRIMARY KEY REFERENCES Pessoa(cpf) ON UPDATE CASCADE,
  idCargo INT NOT NULL REFERENCES Cargo(idCargo),
  salarioAdicional DECIMAL(10, 2),
  dataAdmissao DATE,
  turno tipo_turno NOT NULL
);

CREATE TABLE Supervisao (
  idSupervisao SERIAL PRIMARY KEY,
  cpfSupervisor VARCHAR(20) REFERENCES Pessoa(cpf) ON UPDATE CASCADE,
  cpfSupervisionado VARCHAR(20) REFERENCES Pessoa(cpf) ON UPDATE CASCADE,
  dataInicio DATE,
  dataFim DATE
);

CREATE TABLE Hospede (
  cpf VARCHAR(20) PRIMARY KEY REFERENCES Pessoa(cpf) ON UPDATE CASCADE,
  cep VARCHAR(20) NOT NULL REFERENCES EnderecoCobranca(cep),
  numeroEndereco VARCHAR(20) NOT NULL,
  complementoEndereco VARCHAR(100)
);

CREATE TABLE Quarto (
  idQuarto SERIAL PRIMARY KEY,
  idTipoQuarto INT NOT NULL REFERENCES TipoQuarto(idTipoQuarto),
  status status_quarto NOT NULL
);

CREATE TABLE Limpeza (
  idLimpeza SERIAL PRIMARY KEY,
  dataHora TIMESTAMP NOT NULL,
  status status_limpeza NOT NULL,
  observacao VARCHAR(250),
  cpf VARCHAR(20) REFERENCES Pessoa(cpf)
);

-- Entidades de relacionamento
CREATE TABLE LimpezaQuarto (
  idLimpeza INT REFERENCES Limpeza(idLimpeza),
  idQuarto INT REFERENCES Quarto(idQuarto),
  PRIMARY KEY (idLimpeza, idQuarto)
);

CREATE TABLE LimpezaInstalacao (
  idLimpeza INT PRIMARY KEY REFERENCES Limpeza(idLimpeza),
  idInstalacao INT REFERENCES Instalacao(idInstalacao)
);

CREATE TABLE Reserva (
  idReserva SERIAL PRIMARY KEY,
  cpf VARCHAR(20) NOT NULL REFERENCES Hospede(cpf),
  valorTotal DECIMAL(10,2) NOT NULL CHECK (valorTotal >= 0),
  dataReserva TIMESTAMP NOT NULL,
  status status_reserva NOT NULL,
  checkin TIMESTAMP,
  checkout TIMESTAMP,
  -- chk_checkout = check checkout (restrição de validação para checkout)
  CONSTRAINT chk_checkout CHECK (checkout IS NULL OR checkin IS NULL OR checkout > checkin)
);

CREATE TABLE ReservaQuarto (
  idReserva INT NOT NULL,
  idQuarto INT NOT NULL,
  valorDiaria DECIMAL(10, 2) NOT NULL CHECK (valorDiaria >= 0),
  PRIMARY KEY (idReserva, idQuarto),
  FOREIGN KEY (idReserva) REFERENCES Reserva(idReserva),
  FOREIGN KEY (idQuarto) REFERENCES Quarto(idQuarto)
);

CREATE TABLE Pagamento (
  idPagamento SERIAL PRIMARY KEY,
  idReserva INT NOT NULL REFERENCES Reserva(idReserva),
  valorPago NUMERIC(10, 2) NOT NULL,
  status status_pagamento NOT NULL,
  tipoPagamento tipo_pagamento NOT NULL
);

CREATE TABLE Frigobar (
  idFrigobar SERIAL PRIMARY KEY,
  idQuarto INT UNIQUE NOT NULL REFERENCES Quarto(idQuarto),
  status status_frigobar NOT NULL
);

CREATE TABLE FrigobarItem (
  idFrigobar INT NOT NULL REFERENCES Frigobar(idFrigobar),
  idItem INT NOT NULL REFERENCES Item(idItem),
  qtdDisponivel INT NOT NULL CHECK (qtdDisponivel >=0),
  qtdColocada INT NOT NULL CHECK (qtdColocada >=0),
  PRIMARY KEY (idFrigobar, idItem),
  CONSTRAINT chk_qtd CHECK (qtdDisponivel <= qtdColocada)
);

CREATE TABLE ConsumoFrigobar (
  idConsumo SERIAL PRIMARY KEY,
  idReserva INT NOT NULL,
  idQuarto INT NOT NULL,
  idItem INT NOT NULL REFERENCES Item(idItem),
  dataHora TIMESTAMP NOT NULL,
  quantidade INT NOT NULL CHECK (quantidade > 0),
  valorUnitario DECIMAL(10,2) NOT NULL CHECK (valorUnitario >= 0),
  FOREIGN KEY (idReserva, idQuarto) REFERENCES ReservaQuarto(idReserva, idQuarto)
);

COMMIT;
