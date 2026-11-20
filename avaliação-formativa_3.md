# Desafio: projeto de normalização de um banco de dados de vendas

> Aluno: Guilherme Raposo Gonçalves de Melo Larré

> RA: 00000860657

## 1. Contexto

Uma empresa realiza vendas de produtos e armazena todas as informações em uma única tabela. Com o crescimento das operações, foram identificados problemas relacionados à repetição de dados, inconsistências e dificuldades para atualizar as informações.

A empresa solicitou a reorganização da estrutura do banco de dados, aplicando os conceitos de dependência funcional e normalização.

Tabela: VENDA

| id_venda | data_venda | cpf_cliente | nome_cliente | id_produto | nome_produto | preco | quantidade |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 101 | 10/10/2026 | 111 | Ana | P01 | Teclado | 120,00 | 2 |
| 101 | 10/10/2026 | 111 | Ana | P02 | Mouse | 60,00 | 1 |
| 102 | 11/10/2026 | 222 | Carlos | P01 | Teclado | 120,00 | 1 |
| 103 | 12/10/2026 | 111 | Ana | P03 | Monitor | 850,00 | 1 |


*Observação: Considere que uma venda pode conter vários produtos e que um mesmo produto pode aparecer em diferentes vendas.

## 2. Análise das dependências funcionais

a) A chave primária composta que identifica cada item de venda é (id_venda, id_produto)

b)

- id_venda -> `data_venda, cpf_cliente, nome_cliente`
- id_produto -> `nome_produto, preco`
- cpf_cliente -> `nome_cliente`
- (id_venda, id_produto) -> `quantidade`

c) Porque ela se repete ao longo da tabela (as duas primeiras tuplas são id_venda 101, por exemplo). Isso viola o princípio da unicidade das chaves primárias. Apenas a chave composta (id_venda, id_produto) define tuplas únicas.

d) `quantidade` depende da chave composta; `data_venda, cpf_cliente, nome_cliente` dependem unicamente de **id_venda** e `nome_produto, preco` depende unicamente de **id_produto**;

e)

- **Redudâncias de dados:** nome e preço de um produto e o cpf de um cliente se repetem conforme vamos inserindo vendas com o mesmo cliente, ou vendas de um mesmo produto;
- **Anomalias de inserção:** não podemos cadastrar um novo produto ou um novo cliente sem que haja uma venda associada. Nesse caso, estaríamos gerando ou NULL, ou valores errados;
- **Anomalias de atualização:** ao atualizar um dos cadastros (de produto, ou cliente), a atualização não será propagada em outras linhas onde esse mesmo produto/cliente se repete, o que gera muitas inconsistências ao longo do tempo;
- **Anomalias de exclusão:** se a última venda de um cliente for apagada, perde-se o registro completo daquele cliente no sistema.

## 3. Aplicação das formas normais

### 1FN:

- Todos os atributos já estão na 1FN;
- Chave primária: (id_venda, id_produto);
- Estrutura após a 1FN: mantém-se igual;
- A estrutura atende à 1FN, pois seus atributos não representam valores divisíveis (listas, matrizes, repetições, atributos multivalorados...)

### 2FN:

- **Dependências funcionais parciais:**

    - id_venda -> `data_venda, cpf_cliente, nome_cliente`
    - id_produto -> `nome_produto, preco`

- Separamos as dependências funcionais parciais em tabelas próprias (em postgres):

```sql
CREATE TABLE VENDA (
    id_venda SERIAL PRIMARY KEY,
    data_venda DATE NOT NULL,
    cpf_cliente VARCHAR(20) NOT NULL,
    nome_cliente VARCHAR(100) NOT NULL
);

CREATE TABLE PRODUTO (
    id_produto SERIAL PRIMARY KEY,
    nome_produto VARCHAR(100) NOT NULL,
    preco NUMERIC(10, 2) NOT NULL
);

CREATE TABLE ITEM_VENDA (
    id_venda INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL,
    PRIMARY KEY (id_venda, id_produto),
    CONSTRAINT fk_venda FOREIGN KEY (id_venda) REFERENCES venda(id_venda),
    CONSTRAINT fk_produto FOREIGN KEY (id_produto) REFERENCES produto(id_produto)
);
```

- Chaves primárias:
    - VENDA -> PK: id_venda
    - PRODUTO -> PK: id_produto
    - ITEM_VENDA -> PK composta: (id_venda, id_produto)

### 3FN

- Dependências funcionais ainda existentes após 2FN:
    - id_venda -> `cpf_cliente`
    - cpf_cliente -> `nome_cliente`

- As dependências funcionais identificadas acima configuram dependência transitiva, onde `nome_cliente` acaba dependendo de `id_venda`.

- Iremos tratá-las separando os dados do cliente em uma tabela `CLIENTE` que conterá o cpf como PK e nome do cliente, retirando também `nome_cliente` da tabela VENDA, referenciando o cliente apenas pelo cpf como FK.

## 4. Consolidação do projeto relacional

Em postgres:

```sql
CREATE TABLE CLIENTE (
    cpf_cliente VARCHAR(20) PRIMARY KEY,
    nome_cliente VARCHAR(100) NOT NULL
);

CREATE TABLE VENDA (
    id_venda SERIAL PRIMARY KEY,
    data_venda DATE NOT NULL,
    cpf_cliente VARCHAR(20) NOT NULL,
    CONSTRAINT fk_cpf_cliente FOREIGN KEY (cpf_cliente) REFERENCES cliente(cpf_cliente)
);

CREATE TABLE PRODUTO (
    id_produto SERIAL PRIMARY KEY,
    nome_produto VARCHAR(100) NOT NULL,
    preco NUMERIC(10, 2) NOT NULL
);

CREATE TABLE ITEM_VENDA (
    id_venda INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL,
    PRIMARY KEY (id_venda, id_produto),
    CONSTRAINT fk_venda FOREIGN KEY (id_venda) REFERENCES venda(id_venda),
    CONSTRAINT fk_produto FOREIGN KEY (id_produto) REFERENCES produto(id_produto)
);
```

Na notação pedida:

```
CLIENTE (
    cpf_cliente (PK),
    nome_cliente
)

PRODUTO (
    id_produto (PK),
    nome_produto,
    preco
)

VENDA (
    id_venda (PK),
    data_venda,
    cpf_cliente (FK)
)

ITEM_VENDA (
    id_venda (PK/FK),
    id_produto (PK/FK),
    quantidade
)
```

## 5. Validação estrutural do modelo

a) Todas as tabelas possuem uma chave primária definida?

    Sim:

    CLIENTE -> cpf_cliente
    PRODUTO -> id_produto
    VENDA -> id_venda
    ITEM_VENDA -> id_venda, id_produto

b) As chaves estrangeiras referenciam corretamente as chaves primárias de outras tabelas?

    Sim.

    O atributo 'cpf_cliente' em VENDA referencia 'cpf_cliente' em CLIENTE; e as chaves em ITEM_VENDA referenciam corretamente as tabelas VENDA e PRODUTO.

c) Os relacionamentos representam adequadamente as regras do negócio?

    Sim.

    É perfeitamente possível registrar um cliente sem vendas imediatas, cadastrar produtos antecipadamente e registrar múltiplas compras de diferentes produtos em uma mesma venda.

d) Existem atributos repetidos ou informações armazenadas desnecessariamente?

    Não.

    A redundância de nomes de clientes e produtos foi totalmente eliminada com a divisão em tabelas normalizadas.

e) O modelo apresenta redundâncias que poderiam provocar inconsistências?

    Não.

    Como cada dado atômico possui um local único de armazenamento (por exemplo, o nome do produto fica apenas na tabela PRODUTO), atualizações refletem instantaneamente em todo o sistema, evitando anomalias.

f) A estrutura final atende à 3FN?

    Sim.

    O modelo está livre de dependências parciais (atendido na 2FN) e de dependências transitivas (atendido na 3FN, com a separação da entidade CLIENTE).
