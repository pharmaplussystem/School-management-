<!doctype html>
<html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>School Management System - Login</title><link rel="stylesheet" href="assets/style.css"></head>
<body class="login-body"><form method="post" class="login-card">
<h1>School Management System</h1><p class="muted">Sign in to continue</p>
<?php if(isset($error)): ?><div class="alert"><?=htmlspecialchars($error)?></div><?php endif; ?>
<label>Username<input name="username" required></label>
<label>Password<input type="password" name="password" required></label>
<button>Sign in</button><small>Demo: admin / admin123</small>
</form></body></html>
