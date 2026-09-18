// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Ecossistema_O3BR {

    // --- VARIÁVEIS DE GOVERNANÇA E ECONOMIA ---
    address public governanca;
    uint256 public tetoMaximo;
    uint256 public supplyAtual;
    uint256 public multiplicadorRecompensa;

    // --- SALDOS DO TOKEN W3O3BR ---
    mapping(address => uint256) public saldoO3BR;

    // --- ESTRUTURAS DE AGENTES ---
    struct AgenteAmbiental {
        uint256 pontosAprovados;
        uint256 totalRecebido;
    }

    struct Comerciante {
        uint256 volumeRecebido;
        uint256 descontoAplicado;
    }

    // --- MAPEAMENTOS ---
    mapping(address => AgenteAmbiental) public agentesAmbientais;
    mapping(address => Comerciante) public comerciantes;

    // --- EVENTOS ---
    event AcaoRegistrada(address indexado, uint256 pontos);
    event TokensEmitidos(address beneficiario, uint256 valor);
    event TransacaoComercial(address de, address para, uint256 valor);

    // --- CONSTRUTOR ---
    constructor() {
        governanca = msg.sender; 
        tetoMaximo = 1000000 * 10**18;
        multiplicadorRecompensa = 10;
    }

    // --- MODIFICADORES ---
    modifier apenasGovernanca() {
        require(msg.sender == governanca, "Acesso negado: Apenas a Governanca pode executar.");
        _;
    }

    // --- FUNÇÃO 1: PROVA DE AÇÃO E EMISSÃO (MINT) ---
    function registrarAcaoAmbiental(address _agente, uint256 _pontosAprovados) public apenasGovernanca {
        agentesAmbientais[_agente].pontosAprovados += _pontosAprovados;
        
        uint256 recompensaEmTokens = _pontosAprovados * multiplicadorRecompensa * 10**18;
        require(supplyAtual + recompensaEmTokens <= tetoMaximo, "Teto de emissao de O3BR atingido!");
        
        saldoO3BR[_agente] += recompensaEmTokens;
        agentesAmbientais[_agente].totalRecebido += recompensaEmTokens;
        supplyAtual += recompensaEmTokens;
        
        emit AcaoRegistrada(_agente, _pontosAprovados);
        emit TokensEmitidos(_agente, recompensaEmTokens);
    }

    // --- FUNÇÃO 2: PAGAMENTO NO COMÉRCIO LOCAL ---
    function pagarComerciante(address _comerciante, uint256 _valorPagamento) public {
        uint256 valorComDecimais = _valorPagamento * 10**18;
        
        // Verifica se quem está pagando tem saldo suficiente
        require(saldoO3BR[msg.sender] >= valorComDecimais, "Saldo insuficiente de O3BR!");

        // Move o dinheiro
        saldoO3BR[msg.sender] -= valorComDecimais;
        saldoO3BR[_comerciante] += valorComDecimais;
        
        // Registra o volume para o comerciante
        comerciantes[_comerciante].volumeRecebido += valorComDecimais;

        emit TransacaoComercial(msg.sender, _comerciante, valorComDecimais);
    }
}