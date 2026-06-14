fetch('/api/dashboard')
.then(response => response.json())
.then(data => {

    document.getElementById("bueirosCriticos")
        .innerText = data.bueiros_criticos;

    document.getElementById("indicePluviometrico")
        .innerText = data.pluviometrico;

    document.getElementById("vazaoMedia")
        .innerText = data.vazao;

});