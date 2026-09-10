# Production Security Checklist

- Use HTTPS.
- Replace the demo admin password.
- Use a strong unique database password.
- Add CSRF tokens to all POST forms.
- Add server-side authorization checks for every module.
- Add login rate limiting.
- Store secrets outside the web root.
- Disable PHP error display in production.
- Schedule encrypted database backups.
- Add audit logs for payments, grades, attendance and user changes.
- Validate uploads and store them outside executable directories.
