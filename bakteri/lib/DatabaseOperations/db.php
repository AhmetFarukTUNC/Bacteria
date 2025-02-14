<?php
$host = "localhost";
$user = "root";
$password = "";
$dbname = "bakteri";

$conn = mysqli_connect($host, $user, $password, $dbname);
if (!$conn) {
    die("Veritabanı bağlantı hatası: " . mysqli_connect_error());
}
?>
