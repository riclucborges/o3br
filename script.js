const listaChamados = document.getElementById("listaChamados");
const idSocorristaTeste = "socorrista_biker_007"; 

// 1. O "Radar": Cria uma query para escutar apenas chamados com status "Buscando"
const q = window.fs.query(
    window.fs.collection(window.db, "Chamados_SOS"), 
    window.fs.where("statusChamado", "==", "Buscando")
);

// 2. Escuta ativa (onSnapshot) reage instantaneamente a novos registros
window.fs.onSnapshot(q, (snapshot) => {
    listaChamados.innerHTML = ""; // Limpa a tela para atualizar

    if (snapshot.empty) {
        listaChamados.innerHTML = "<p>Nenhum chamado ativo no momento.</p>";
        return;
    }

    snapshot.forEach((documento) => {
        const chamado = documento.data();
        const idChamado = documento.id;

        // Cria o card visual do chamado na tela
        const card = document.createElement("div");
        card.style.border = "1px solid #ccc";
        card.style.padding = "10px";
        card.style.marginTop = "10px";
        card.style.borderRadius = "5px";

        card.innerHTML = `
            <strong>🚨 Serviço:</strong> ${chamado.diagnostico}<br>
            <strong>📍 Plus Code:</strong> ${chamado.localizacao}<br>
            <button onclick="aceitarChamado('${idChamado}', '${chamado.localizacao}')" 
                    style="margin-top: 10px; background: #28a745;">
                Aceitar e Navegar
            </button>
        `;
        listaChamados.appendChild(card);
    });
});

// 3. Ação de Aceite: Trava o chamado e abre o GPS nativo
window.aceitarChamado = async (idChamado, plusCodeDestino) => {
    try {
        const chamadoRef = window.fs.doc(window.db, "Chamados_SOS", idChamado);

        // Atualiza o banco, retirando o chamado do radar dos outros socorristas
        await window.fs.updateDoc(chamadoRef, {
            socorristaUid: idSocorristaTeste,
            statusChamado: "Em Rota"
        });

        alert("Chamado aceito! Abrindo rota no mapa...");

        // Abre o Google Maps traçando a rota direto para o Plus Code
        const urlNavegacao = `https://www.google.com/maps/dir/?api=1&destination=${encodeURIComponent(plusCodeDestino)}`;
        window.open(urlNavegacao, '_blank');

    } catch (error) {
        console.error("Erro ao aceitar:", error);
        alert("Erro ao travar o chamado. Outro socorrista pode ter aceito antes.");
    }
};