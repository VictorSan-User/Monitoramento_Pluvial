const API_BASE = "../api";

function numero(valor, casas = 1) {
    return Number(valor || 0).toLocaleString("pt-BR", {
        minimumFractionDigits: casas,
        maximumFractionDigits: casas
    });
}

function classeStatus(status) {
    if (status === "Critico") return "critico";
    if (status === "Atencao") return "atencao";
    return "normal";
}

function renderizarSensores(sensores, destino) {
    if (!sensores.length) {
        destino.innerHTML = `<div class="sensor-card text-secondary">Nenhum sensor encontrado.</div>`;
        return;
    }

    destino.innerHTML = sensores.map(sensor => `
        <article class="sensor-card">
            <div class="sensor-top">
                <div>
                    <div class="sensor-id">${sensor.codigo_patrimonial}</div>
                    <div class="localizacao">${sensor.bairro} | ${sensor.latitude}, ${sensor.longitude}</div>
                </div>
                <span class="status ${classeStatus(sensor.status_operacional)}">${sensor.status_operacional}</span>
            </div>

            <div class="obstrucao">
                <div class="d-flex justify-content-between mb-1">
                    <span>Obstrução</span>
                    <strong>${numero(sensor.obstrucao_percentual)}%</strong>
                </div>
                <div class="progress">
                    <div class="progress-bar bg-danger" style="width:${Math.min(Number(sensor.obstrucao_percentual || 0), 100)}%"></div>
                </div>
            </div>

            <div class="info">
                <span>Chuva: ${numero(sensor.indice_pluviometrico_mm)} mm</span>
                <span>Vazão: ${numero(sensor.vazao_litros_segundo)} L/s</span>
                <span>Última coleta: ${sensor.ultima_coleta || "-"}</span>
            </div>
        </article>
    `).join("");
}

async function carregarSensores() {
    const destino = document.getElementById("listaSensores");
    if (!destino) return;

    const campoBusca = document.getElementById("buscarSensor");
    const somenteAlertas = document.body.dataset.page === "alertas";
    const endpoint = somenteAlertas ? "alertas.php" : "sensores.php";
    const query = campoBusca && campoBusca.value ? `?q=${encodeURIComponent(campoBusca.value)}` : "";

    try {
        const resposta = await fetch(`${API_BASE}/${endpoint}${query}`);
        const dados = await resposta.json();
        const sensores = somenteAlertas ? (dados.alertas || []) : (dados.sensores || []);
        renderizarSensores(sensores, destino);
    } catch (erro) {
        destino.innerHTML = `<div class="sensor-card text-danger">Falha ao carregar dados da API: ${erro.message}</div>`;
    }
}

document.getElementById("buscarSensor")?.addEventListener("input", () => {
    window.clearTimeout(window.__timerBuscaSensores);
    window.__timerBuscaSensores = window.setTimeout(carregarSensores, 250);
});

carregarSensores();
setInterval(carregarSensores, 30000);
