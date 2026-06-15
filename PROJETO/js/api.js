fetch("../api/dashboard.php")
    .then(response => response.json())
    .then(data => {
        const resumo = data.resumo || {};

        document.getElementById("bueirosCriticos").innerText = resumo.bueiros_criticos ?? 0;
        document.getElementById("indicePluviometrico").innerText = resumo.pluviometrico_medio ?? 0;
        document.getElementById("vazaoMedia").innerText = resumo.vazao_media ?? 0;
    });
