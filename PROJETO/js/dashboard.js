const API_BASE = "../api";
let graficoBairros = null;
let graficoChuva = null;

function atualizarRelogio() {
    const agora = new Date();
    const horaAtual = document.getElementById("horaAtual");
    const dataAtual = document.getElementById("dataAtual");

    if (horaAtual) {
        horaAtual.innerHTML = agora.toLocaleTimeString("pt-BR");
    }

    if (dataAtual) {
        dataAtual.innerHTML = agora.toLocaleDateString("pt-BR", {
            weekday: "long",
            day: "2-digit",
            month: "long",
            year: "numeric"
        });
    }
}

function numero(valor, casas = 1) {
    return Number(valor || 0).toLocaleString("pt-BR", {
        minimumFractionDigits: casas,
        maximumFractionDigits: casas
    });
}

function classeStatus(status) {
    const normalizado = String(status || "Normal").toLowerCase();
    if (normalizado.includes("critico")) return "table-danger";
    if (normalizado.includes("atencao")) return "table-warning";
    return "";
}

async function carregarJson(url) {
    const resposta = await fetch(url, { headers: { Accept: "application/json" } });
    if (!resposta.ok) {
        throw new Error(`Falha HTTP ${resposta.status}`);
    }
    return resposta.json();
}

function renderizarResumo(resumo) {
    document.getElementById("bueirosCriticos").innerText = resumo.bueiros_criticos ?? 0;
    document.getElementById("indicePluviometrico").innerText = numero(resumo.pluviometrico_medio);
    document.getElementById("vazaoMedia").innerText = numero(resumo.vazao_media);
}

function renderizarGraficos(dados) {
    const bairros = dados.por_bairro || [];
    const serie = dados.serie_temporal || [];

    if (graficoBairros) graficoBairros.destroy();
    graficoBairros = new Chart(document.getElementById("graficoBairros"), {
        type: "bar",
        data: {
            labels: bairros.map(item => item.bairro),
            datasets: [{
                label: "Obstrucao media (%)",
                data: bairros.map(item => Number(item.media_obstrucao_percentual || 0)),
                backgroundColor: "#1967ff"
            }]
        },
        options: {
            responsive: true,
            plugins: { legend: { display: false } },
            scales: { y: { beginAtZero: true, max: 100 } }
        }
    });

    if (graficoChuva) graficoChuva.destroy();
    graficoChuva = new Chart(document.getElementById("graficoChuva"), {
        type: "line",
        data: {
            labels: serie.map(item => item.horario),
            datasets: [
                {
                    label: "Precipitacao (mm)",
                    data: serie.map(item => Number(item.chuva || 0)),
                    borderColor: "#0d6efd",
                    backgroundColor: "rgba(13, 110, 253, .12)",
                    tension: .35
                },
                {
                    label: "Vazao (L/s)",
                    data: serie.map(item => Number(item.vazao || 0)),
                    borderColor: "#16a34a",
                    backgroundColor: "rgba(22, 163, 74, .12)",
                    tension: .35
                }
            ]
        },
        options: { responsive: true, interaction: { mode: "index", intersect: false } }
    });
}

function renderizarTabela(sensores) {
    const corpo = document.getElementById("tabelaSensores");
    if (!corpo) return;

    if (!sensores.length) {
        corpo.innerHTML = `<tr><td colspan="6" class="text-center text-secondary py-4">Nenhuma leitura encontrada.</td></tr>`;
        return;
    }

    corpo.innerHTML = sensores.map(sensor => `
        <tr class="${classeStatus(sensor.status_operacional)}">
            <td>${sensor.id_bueiro}</td>
            <td>${sensor.bairro}</td>
            <td>${numero(sensor.obstrucao_percentual)}%</td>
            <td>${numero(sensor.indice_pluviometrico_mm)} mm</td>
            <td>${numero(sensor.vazao_litros_segundo)} L/s</td>
            <td><span class="badge ${sensor.status_operacional === "Critico" ? "bg-danger" : sensor.status_operacional === "Atencao" ? "bg-warning text-dark" : "bg-success"}">${sensor.status_operacional}</span></td>
        </tr>
    `).join("");
}

function renderizarAlertas(sensores) {
    const painel = document.getElementById("painelAlertas");
    const total = document.getElementById("totalAlertas");
    if (!painel || !total) return;

    const criticos = sensores.filter(sensor => sensor.status_operacional === "Critico");
    total.innerText = criticos.length;

    if (!criticos.length) {
        painel.innerHTML = `<div class="alert-empty">Nenhum bueiro em nível crítico no momento.</div>`;
        return;
    }

    painel.innerHTML = criticos.slice(0, 6).map(sensor => `
        <div class="alert-item">
            <strong>${sensor.codigo_patrimonial}</strong>
            <span>${sensor.bairro}</span>
            <small>Obs. ${numero(sensor.obstrucao_percentual)}% | Chuva ${numero(sensor.indice_pluviometrico_mm)} mm | Vazao ${numero(sensor.vazao_litros_segundo)} L/s</small>
        </div>
    `).join("");
}

function mostrarErro(mensagem) {
    const corpo = document.getElementById("tabelaSensores");
    if (corpo) {
        corpo.innerHTML = `<tr><td colspan="6" class="text-danger py-4">${mensagem}</td></tr>`;
    }

    renderizarResumo({});
    renderizarGraficos({ por_bairro: [], serie_temporal: [] });
    renderizarAlertas([]);
}

async function carregarDashboard() {
    try {
        const [dashboard, sensores] = await Promise.all([
            carregarJson(`${API_BASE}/dashboard.php`),
            carregarJson(`${API_BASE}/sensores.php`)
        ]);

        renderizarResumo(dashboard.resumo || {});
        renderizarGraficos(dashboard);
        renderizarTabela(sensores.sensores || []);
        renderizarAlertas(sensores.sensores || []);
    } catch (erro) {
        mostrarErro(`Nao foi possivel carregar os dados da API: ${erro.message}`);
    }
}

setInterval(atualizarRelogio, 1000);
setInterval(carregarDashboard, 30000);
atualizarRelogio();
carregarDashboard();
