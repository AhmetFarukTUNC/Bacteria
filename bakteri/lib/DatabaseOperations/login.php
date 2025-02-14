<?php
include 'db.php';

$email = $_POST['email'];
$password = $_POST['password'];

$sql = "SELECT * FROM users WHERE email='$email'";
$result = mysqli_query($conn, $sql);
$user = mysqli_fetch_assoc($result);

if ($user && password_verify($password, $user['password'])) {
    echo json_encode(["status" => "success", "message" => "Giriş başarılı", "user" => $user]);
} else {
    echo json_encode(["status" => "error", "message" => "Geçersiz giriş bilgileri"]);
}
?>
