// DATA E HORA
function atualizarRelogio() {

    const agora = new Date();

    document.getElementById("horaAtual").innerHTML =
        agora.toLocaleTimeString('pt-BR');

    document.getElementById("dataAtual").innerHTML =
        agora.toLocaleDateString('pt-BR',{
            weekday:'long',
            day:'2-digit',
            month:'long',
            year:'numeric'
        });
}

setInterval(atualizarRelogio,1000);

atualizarRelogio();


// DADOS DE TESTE
document.getElementById("bueirosCriticos").innerText = 5;
document.getElementById("indicePluviometrico").innerText = 39;
document.getElementById("vazaoMedia").innerText = 251.5;


// GRAFICO BAIRROS
new Chart(
document.getElementById("graficoBairros"),
{
    type:"bar",
    data:{
        labels:[
            "Centro",
            "Santa Cruz",
            "Santa Zita",
            "Dário Grossi",
            "Limoeiro",
            "Aparecida"
        ],
        datasets:[{
            label:"Obstrução %",
            data:[80,90,78,74,55,42]
        }]
    }
});

// GRAFICO CHUVA
new Chart(
document.getElementById("graficoChuva"),
{
    type:"line",
    data:{
        labels:[
            "02h",
            "03h",
            "04h",
            "05h",
            "06h",
            "07h",
            "08h"
        ],
        datasets:[
        {
            label:"Precipitação",
            data:[22,35,26,13,45,34,14]
        },
        {
            label:"Vazão",
            data:[150,240,180,80,300,250,120]
        }]
    }
});

// TABELA
const sensores = [
{
    id:1,
    local:"Centro",
    obstrucao:89,
    chuva:39,
    vazao:251,
    status:"Crítico"
},
{
    id:2,
    local:"Santa Cruz",
    obstrucao:50,
    chuva:25,
    vazao:190,
    status:"Normal"
}
];

let html = "";
sensores.forEach(sensor => {

    html += `
        <tr>
            <td>${sensor.id}</td>
            <td>${sensor.local}</td>
            <td>${sensor.obstrucao}%</td>
            <td>${sensor.chuva} mm</td>
            <td>${sensor.vazao} L/s</td>
            <td>${sensor.status}</td>
        </tr>
    `;
});

document.getElementById("tabelaSensores").innerHTML = html;