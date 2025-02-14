<?php
// CORS ayarları
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

// Veritabanı bağlantısı için gerekli ayarlar
$servername = "localhost"; // Veritabanı sunucu adresi
$username = "root"; // Veritabanı kullanıcı adı
$password = ""; // Veritabanı şifresi
$dbname = "bakteri"; // Veritabanı adı

// Veritabanı bağlantısını oluştur
$conn = new mysqli($servername, $username, $password, $dbname);

// Bağlantıyı kontrol et
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]));
}

// Gelen JSON verisini al
$data = json_decode(file_get_contents("php://input"), true);

// JSON verisini kontrol et
if (json_last_error() !== JSON_ERROR_NONE) {
    echo json_encode(["status" => "error", "message" => "Geçersiz JSON verisi: " . json_last_error_msg()]);
    exit();
}

// Gerekli alanların kontrolü
if (!isset($data['name']) || !isset($data['surname']) || !isset($data['email']) || !isset($data['password'])) {
    echo json_encode(["status" => "error", "message" => "Eksik veri."]);
    exit();
}

// Kullanıcı bilgilerini değişkenlere al
$name = $data['name'];
$surname = $data['surname'];
$email = $data['email'];
$password = $data['password'];

// Şifreyi hashle
$hashed_password = password_hash($password, PASSWORD_DEFAULT);

// Kullanıcıyı veritabanına eklemek için SQL sorgusunu oluştur
// Parametreli sorgu kullanarak güvenli bir şekilde kullanıcı verilerini ekleyelim
$stmt = $conn->prepare("INSERT INTO users (name, surname, email, password) VALUES (?, ?, ?, ?)");
$stmt->bind_param("ssss", $name, $surname, $email, $hashed_password);

// Sorguyu çalıştır
if ($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => "Kayıt başarılı."]);
} else {
    echo json_encode(["status" => "error", "message" => "Kayıt hatası: " . $stmt->error]);
}

// Veritabanı bağlantısını kapat
$stmt->close();
$conn->close();
?>
