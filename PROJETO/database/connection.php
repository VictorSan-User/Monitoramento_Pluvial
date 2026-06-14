<?php 
    $host = "localhost";
    $dbname = "BUEIROS_URBANOS_CARATINGA";
    $usuario = "root";
    $password = "";

    try{
        $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $usuario, $password);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    }catch(PDOException $e) {
        die("Erro de conexao ao banco de dados:". $e->getMessage());
    }

?>