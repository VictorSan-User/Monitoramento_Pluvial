function numero(valor, casas = 1) {
    return Number(valor || 0).toLocaleString("pt-BR", {
        minimumFractionDigits: casas,
        maximumFractionDigits: casas
    });
}

async function carregarRelatorios() {
    const tabela = document.getElementById("tabelaRelatorios");
    if (!tabela) return;

    try {
        const resposta = await fetch("../api/dashboard.php");
        const dados = await resposta.json();
        const linhas = dados.por_bairro || [];

        if (!linhas.length) {
            tabela.innerHTML = `<tr><td colspan="6" class="text-center text-secondary py-4">Nenhum dado consolidado encontrado.</td></tr>`;
            return;
        }

        tabela.innerHTML = linhas.map(item => `
            <tr>
                <td>${item.bairro}</td>
                <td>${item.total_bueiros}</td>
                <td>${item.bueiros_criticos}</td>
                <td>${numero(item.media_obstrucao_percentual)}%</td>
                <td>${numero(item.media_pluviometrica_mm)} mm</td>
                <td>${numero(item.media_vazao_litros_segundo)} L/s</td>
            </tr>
        `).join("");
    } catch (erro) {
        tabela.innerHTML = `<tr><td colspan="6" class="text-danger py-4">Falha ao carregar relatório: ${erro.message}</td></tr>`;
    }
}

carregarRelatorios();
