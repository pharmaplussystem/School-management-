<!doctype html>
<html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>School Management System</title><link rel="stylesheet" href="assets/style.css"></head>
<body>
<div class="app">
<aside class="sidebar"><div class="brand">SMS<span>+</span></div>
<nav>
<a class="<?=$view==='dashboard'?'active':''?>" href="?view=dashboard">Dashboard</a>
<a class="<?=$view==='students'?'active':''?>" href="?view=students">Students</a>
<a class="<?=$view==='teachers'?'active':''?>" href="?view=teachers">Teachers</a>
<a class="<?=$view==='classes'?'active':''?>" href="?view=classes">Classes</a>
<a class="<?=$view==='attendance'?'active':''?>" href="?view=attendance">Attendance</a>
<a class="<?=$view==='fees'?'active':''?>" href="?view=fees">Fees & Payments</a>
<a class="<?=$view==='results'?'active':''?>" href="?view=results">Exams & Results</a>
</nav>
<div class="sidebar-bottom"><a href="logout.php">Logout</a></div></aside>
<main class="main"><header><div><h2><?=ucfirst(str_replace('_',' ',$view))?></h2><span class="muted">School Administration Portal</span></div>
<div class="user"><?=htmlspecialchars($_SESSION['user']['name'])?> · <?=htmlspecialchars($_SESSION['user']['role'])?></div></header>
<section class="content">
<?php
if($view==='dashboard'){
 echo '<div class="cards">';
 foreach([['Students',$counts['students'],'students'],['Teachers',$counts['teachers'],'teachers'],['Classes',$counts['classes'],'classes'],['Collected Fees','UGX '.number_format($counts['fees']),'fees']] as $c)
   echo '<div class="card"><span>'.$c[0].'</span><strong>'.$c[1].'</strong><a href="?view='.$c[2].'">View details →</a></div>';
 echo '</div><div class="panel"><h3>Quick actions</h3><div class="actions"><a href="?view=students">Register student</a><a href="?view=attendance">Record attendance</a><a href="?view=fees">Record payment</a><a href="?view=results">Enter results</a></div></div>';
}
elseif($view==='students') {
 if($_SERVER['REQUEST_METHOD']==='POST' && isset($_POST['admission_no'])){
  $stmt=$pdo->prepare("INSERT INTO students(admission_no,first_name,last_name,gender,date_of_birth,guardian_name,guardian_phone,class_id) VALUES(?,?,?,?,?,?,?,?)");
  $stmt->execute([$_POST['admission_no'],$_POST['first_name'],$_POST['last_name'],$_POST['gender'],$_POST['date_of_birth']?:null,$_POST['guardian_name'],$_POST['guardian_phone'],$_POST['class_id']?:null]);
 }
 $classes=$pdo->query("SELECT * FROM classes ORDER BY name")->fetchAll();
 $rows=$pdo->query("SELECT s.*,c.name class_name FROM students s LEFT JOIN classes c ON c.id=s.class_id ORDER BY s.id DESC")->fetchAll();
 echo '<div class="panel"><h3>Register student</h3><form class="gridform" method="post">
 <input name="admission_no" placeholder="Admission No." required><input name="first_name" placeholder="First name" required><input name="last_name" placeholder="Last name" required>
 <select name="gender"><option>Male</option><option>Female</option><option>Other</option></select><input type="date" name="date_of_birth">
 <input name="guardian_name" placeholder="Guardian name"><input name="guardian_phone" placeholder="Guardian phone"><select name="class_id"><option value="">Select class</option>';
 foreach($classes as $c) echo '<option value="'.$c['id'].'">'.htmlspecialchars($c['name'].' '.$c['section']).'</option>';
 echo '</select><button>Add student</button></form></div>';
 echo '<div class="panel"><h3>Students</h3><table><tr><th>Admission</th><th>Name</th><th>Gender</th><th>Class</th><th>Status</th></tr>';
 foreach($rows as $r) echo '<tr><td>'.htmlspecialchars($r['admission_no']).'</td><td>'.htmlspecialchars($r['first_name'].' '.$r['last_name']).'</td><td>'.$r['gender'].'</td><td>'.htmlspecialchars($r['class_name']??'-').'</td><td>'.$r['status'].'</td></tr>';
 echo '</table></div>';
}
elseif($view==='teachers') {
 if($_SERVER['REQUEST_METHOD']==='POST' && isset($_POST['employee_no'])){
  $stmt=$pdo->prepare("INSERT INTO teachers(employee_no,full_name,phone,email,subject) VALUES(?,?,?,?,?)");
  $stmt->execute([$_POST['employee_no'],$_POST['full_name'],$_POST['phone'],$_POST['email'],$_POST['subject']]);
 }
 $rows=$pdo->query("SELECT * FROM teachers ORDER BY id DESC")->fetchAll();
 echo '<div class="panel"><h3>Add teacher</h3><form class="gridform" method="post"><input name="employee_no" placeholder="Employee No." required><input name="full_name" placeholder="Full name" required><input name="phone" placeholder="Phone"><input name="email" placeholder="Email"><input name="subject" placeholder="Main subject"><button>Add teacher</button></form></div>';
 echo '<div class="panel"><h3>Teachers</h3><table><tr><th>Employee No.</th><th>Name</th><th>Phone</th><th>Email</th><th>Subject</th></tr>';
 foreach($rows as $r) echo '<tr><td>'.htmlspecialchars($r['employee_no']).'</td><td>'.htmlspecialchars($r['full_name']).'</td><td>'.htmlspecialchars($r['phone']).'</td><td>'.htmlspecialchars($r['email']).'</td><td>'.htmlspecialchars($r['subject']).'</td></tr>';
 echo '</table></div>';
}
elseif($view==='classes') {
 if($_SERVER['REQUEST_METHOD']==='POST' && isset($_POST['class_name'])){
  $stmt=$pdo->prepare("INSERT INTO classes(name,section,class_teacher) VALUES(?,?,?)");
  $stmt->execute([$_POST['class_name'],$_POST['section'],$_POST['class_teacher']]);
 }
 $rows=$pdo->query("SELECT * FROM classes ORDER BY name")->fetchAll();
 echo '<div class="panel"><h3>Add class</h3><form class="gridform" method="post"><input name="class_name" placeholder="Class e.g. Senior 3" required><input name="section" placeholder="Section"><input name="class_teacher" placeholder="Class teacher"><button>Add class</button></form></div>';
 echo '<div class="panel"><h3>Classes</h3><table><tr><th>Class</th><th>Section</th><th>Class Teacher</th></tr>';
 foreach($rows as $r) echo '<tr><td>'.htmlspecialchars($r['name']).'</td><td>'.htmlspecialchars($r['section']).'</td><td>'.htmlspecialchars($r['class_teacher']).'</td></tr>';
 echo '</table></div>';
}
elseif($view==='attendance') {
 if($_SERVER['REQUEST_METHOD']==='POST' && isset($_POST['student_id'])){
  $stmt=$pdo->prepare("INSERT INTO attendance(student_id,attendance_date,status) VALUES(?,?,?) ON DUPLICATE KEY UPDATE status=VALUES(status)");
  $stmt->execute([$_POST['student_id'],$_POST['attendance_date'],$_POST['status']]);
 }
 $students=$pdo->query("SELECT id,admission_no,first_name,last_name FROM students WHERE status='Active' ORDER BY first_name")->fetchAll();
 echo '<div class="panel"><h3>Record attendance</h3><form class="gridform" method="post"><select name="student_id" required><option value="">Select student</option>';
 foreach($students as $s) echo '<option value="'.$s['id'].'">'.htmlspecialchars($s['admission_no'].' - '.$s['first_name'].' '.$s['last_name']).'</option>';
 echo '</select><input type="date" name="attendance_date" value="'.date('Y-m-d').'" required><select name="status"><option>Present</option><option>Absent</option><option>Late</option><option>Excused</option></select><button>Save attendance</button></form></div>';
}
elseif($view==='fees') {
 if($_SERVER['REQUEST_METHOD']==='POST' && isset($_POST['amount'])){
  $stmt=$pdo->prepare("INSERT INTO payments(student_id,amount,payment_date,method,reference,description) VALUES(?,?,?,?,?,?)");
  $stmt->execute([$_POST['student_id'],$_POST['amount'],$_POST['payment_date'],$_POST['method'],$_POST['reference'],$_POST['description']]);
 }
 $students=$pdo->query("SELECT id,admission_no,first_name,last_name FROM students ORDER BY first_name")->fetchAll();
 $rows=$pdo->query("SELECT p.*,s.admission_no,s.first_name,s.last_name FROM payments p JOIN students s ON s.id=p.student_id ORDER BY p.id DESC LIMIT 30")->fetchAll();
 echo '<div class="panel"><h3>Record payment</h3><form class="gridform" method="post"><select name="student_id" required><option value="">Select student</option>';
 foreach($students as $s) echo '<option value="'.$s['id'].'">'.htmlspecialchars($s['admission_no'].' - '.$s['first_name'].' '.$s['last_name']).'</option>';
 echo '</select><input type="number" step="0.01" name="amount" placeholder="Amount (UGX)" required><input type="date" name="payment_date" value="'.date('Y-m-d').'"><select name="method"><option>Cash</option><option>Mobile Money</option><option>Bank</option><option>Other</option></select><input name="reference" placeholder="Reference"><input name="description" placeholder="Description"><button>Save payment</button></form></div>';
 echo '<div class="panel"><h3>Recent payments</h3><table><tr><th>Date</th><th>Student</th><th>Amount</th><th>Method</th><th>Reference</th></tr>';
 foreach($rows as $r) echo '<tr><td>'.$r['payment_date'].'</td><td>'.htmlspecialchars($r['first_name'].' '.$r['last_name']).'</td><td>UGX '.number_format($r['amount']).'</td><td>'.$r['method'].'</td><td>'.htmlspecialchars($r['reference']).'</td></tr>';
 echo '</table></div>';
}
elseif($view==='results') {
 if($_SERVER['REQUEST_METHOD']==='POST' && isset($_POST['score'])){
  $score=(float)$_POST['score']; $grade=$score>=80?'A':($score>=70?'B':($score>=60?'C':($score>=50?'D':'F')));
  $stmt=$pdo->prepare("INSERT INTO results(student_id,subject_id,term,score,grade,remarks) VALUES(?,?,?,?,?,?)");
  $stmt->execute([$_POST['student_id'],$_POST['subject_id'],$_POST['term'],$score,$grade,$_POST['remarks']]);
 }
 $students=$pdo->query("SELECT id,admission_no,first_name,last_name FROM students ORDER BY first_name")->fetchAll();
 $subjects=$pdo->query("SELECT * FROM subjects ORDER BY name")->fetchAll();
 echo '<div class="panel"><h3>Enter result</h3><form class="gridform" method="post"><select name="student_id" required><option value="">Select student</option>';
 foreach($students as $s) echo '<option value="'.$s['id'].'">'.htmlspecialchars($s['admission_no'].' - '.$s['first_name'].' '.$s['last_name']).'</option>';
 echo '</select><select name="subject_id" required><option value="">Select subject</option>';
 foreach($subjects as $s) echo '<option value="'.$s['id'].'">'.htmlspecialchars($s['name']).'</option>';
 echo '</select><input name="term" placeholder="Term 1" required><input type="number" min="0" max="100" step="0.01" name="score" placeholder="Score" required><input name="remarks" placeholder="Remarks"><button>Save result</button></form></div>';
}
?>
</section></main></div></body></html>
