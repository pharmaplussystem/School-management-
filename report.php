<?php
session_start();
require_once __DIR__ . '/../config/database.php';
if (!isset($_SESSION['user'])) { header('Location: index.php'); exit; }
$student_id = (int)($_GET['student_id'] ?? 0);
$stmt = $pdo->prepare("SELECT s.*, c.name class_name, c.section FROM students s LEFT JOIN classes c ON c.id=s.class_id WHERE s.id=?");
$stmt->execute([$student_id]);
$student = $stmt->fetch();
if (!$student) die('Student not found.');
$r = $pdo->prepare("SELECT r.*, sub.name subject_name FROM results r JOIN subjects sub ON sub.id=r.subject_id WHERE r.student_id=? ORDER BY sub.name");
$r->execute([$student_id]);
$results = $r->fetchAll();
?>
<!doctype html><html><head><meta charset="utf-8"><title>Student Report</title>
<style>body{font-family:Arial;margin:40px;color:#111}h1,h2{text-align:center}.meta{margin:25px 0}.meta div{margin:6px 0}table{width:100%;border-collapse:collapse;margin-top:20px}th,td{border:1px solid #999;padding:10px;text-align:left}@media print{.no-print{display:none}}</style></head>
<body>
<button class="no-print" onclick="window.print()">Print report</button>
<h1>STUDENT ACADEMIC REPORT</h1>
<h2>School Management System</h2>
<div class="meta">
<div><b>Admission No:</b> <?=htmlspecialchars($student['admission_no'])?></div>
<div><b>Student:</b> <?=htmlspecialchars($student['first_name'].' '.$student['last_name'])?></div>
<div><b>Gender:</b> <?=htmlspecialchars($student['gender'])?></div>
<div><b>Class:</b> <?=htmlspecialchars(($student['class_name']??'-').' '.($student['section']??''))?></div>
</div>
<table><tr><th>Subject</th><th>Term</th><th>Score</th><th>Grade</th><th>Remarks</th></tr>
<?php foreach($results as $x): ?><tr><td><?=htmlspecialchars($x['subject_name'])?></td><td><?=htmlspecialchars($x['term'])?></td><td><?=htmlspecialchars($x['score'])?></td><td><?=htmlspecialchars($x['grade'])?></td><td><?=htmlspecialchars($x['remarks'])?></td></tr><?php endforeach; ?>
</table>
</body></html>