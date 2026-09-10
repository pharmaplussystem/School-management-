<?php
session_start();
require_once __DIR__ . '/../config/database.php';

if (!isset($_SESSION['user'])) {
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $stmt = $pdo->prepare("SELECT * FROM users WHERE username=? LIMIT 1");
        $stmt->execute([$_POST['username'] ?? '']);
        $u = $stmt->fetch();
        if ($u && password_verify($_POST['password'] ?? '', $u['password_hash'])) {
            $_SESSION['user'] = ['id'=>$u['id'],'name'=>$u['full_name'],'role'=>$u['role']];
            header('Location: index.php'); exit;
        }
        $error = 'Invalid username or password.';
    }
    include __DIR__ . '/login.php'; exit;
}

$view = $_GET['view'] ?? 'dashboard';
$allowed = ['dashboard','students','teachers','classes','attendance','fees','results'];
if (!in_array($view, $allowed, true)) $view = 'dashboard';

$counts = [
 'students' => (int)$pdo->query("SELECT COUNT(*) FROM students WHERE status='Active'")->fetchColumn(),
 'teachers' => (int)$pdo->query("SELECT COUNT(*) FROM teachers")->fetchColumn(),
 'classes' => (int)$pdo->query("SELECT COUNT(*) FROM classes")->fetchColumn(),
 'fees' => (float)$pdo->query("SELECT COALESCE(SUM(amount),0) FROM payments")->fetchColumn(),
];
include __DIR__ . '/layout.php';
