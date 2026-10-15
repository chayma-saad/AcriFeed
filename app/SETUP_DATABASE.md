# Database Setup Instructions

## Quick Setup (Using phpMyAdmin - Recommended)

1. **Start XAMPP** and ensure MySQL service is running (green in XAMPP Control Panel)

2. **Open phpMyAdmin**:
   - Go to: http://localhost/phpmyadmin
   - Or click "Admin" button next to MySQL in XAMPP

3. **Import the Database**:
   - Click on the **"SQL"** tab at the top
   - Open the file `database/schema.sql` in a text editor
   - Copy ALL the contents
   - Paste into the SQL text area in phpMyAdmin
   - Click the **"Go"** button at the bottom

4. **Verify Setup**:
   - You should see a success message
   - Check the left sidebar - you should see `locust_monitoring` database
   - Click on it and verify you see tables: `users`, `environmental_data`, `predictions`, etc.

## Alternative: Using Command Line

If MySQL is in your PATH:

```bash
mysql -u root -p < database/schema.sql
```

Or if using XAMPP MySQL directly:

```bash
C:\xampp\mysql\bin\mysql.exe -u root < database\schema.sql
```

## Verify Admin User

After setup, you can verify the admin user exists:

1. In phpMyAdmin, select `locust_monitoring` database
2. Click on `users` table
3. Click "Browse" tab
4. You should see a user with username "admin"

## Default Login Credentials

- **Username**: `admin`
- **Password**: `admin123`

## Troubleshooting

### "Access denied" error
- Check if MySQL root user has a password
- If yes, update the connection string in `backend/LocustMonitoring.API/appsettings.json`
- Or use phpMyAdmin instead

### "Database already exists" error
- The database might already be created
- Try dropping it first: `DROP DATABASE IF EXISTS locust_monitoring;`
- Then run the schema script again

### "Table already exists" error
- Some tables might already exist
- You can either:
  - Drop the database and recreate: `DROP DATABASE locust_monitoring;`
  - Or manually delete existing tables and re-import

