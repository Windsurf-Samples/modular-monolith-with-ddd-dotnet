# Setup Guide for Modular Monolith with DDD .NET Application

This guide explains how to complete the setup of this .NET modular monolith application to run it locally.

## Current Setup Status

✅ **Completed by Devin Setup Agent:**
- .NET 8.0 SDK installed
- NuGet packages restored
- Project builds successfully (with vulnerability warnings suppressed)
- Unit tests and architecture tests configured

## Manual Setup Required

### 1. Database Setup

This application requires SQL Server. You have several options:

#### Option A: SQL Server Express (Recommended for Windows)
```bash
# Download and install SQL Server Express from Microsoft
# https://www.microsoft.com/en-us/sql-server/sql-server-downloads
```

#### Option B: SQL Server in Docker (Cross-platform)
```bash
# Run SQL Server in Docker
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=YourStrong@Passw0rd" \
   -p 1433:1433 --name sqlserver --hostname sqlserver \
   -d mcr.microsoft.com/mssql/server:2022-latest
```

#### Option C: Azure SQL Database
- Create an Azure SQL Database instance
- Note the connection string

### 2. Database Initialization

Once you have SQL Server running:

1. **Create the database:**
   ```bash
   # Use the appropriate script based on your OS
   # For Linux/Docker:
   sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -i src/Database/CompanyName.MyMeetings.Database/Scripts/CreateDatabase_Linux.sql
   
   # For Windows:
   sqlcmd -S (localdb)\mssqllocaldb -E -i src/Database/CompanyName.MyMeetings.Database/Scripts/CreateDatabase_Windows.sql
   ```

2. **Run database migrations:**
   ```bash
   # Navigate to the root folder and run migrations
   cd ~/repos/modular-monolith-with-ddd-dotnet
   ./build.sh MigrateDatabase
   ```

3. **Seed test data (optional):**
   ```bash
   sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -d MyMeetings -i src/Database/CompanyName.MyMeetings.Database/Scripts/SeedDatabase.sql
   ```

### 3. Configuration Setup

#### Update Connection String
Edit `src/API/CompanyName.MyMeetings.API/appsettings.json`:

```json
{
  "ConnectionStrings": {
    "MeetingsConnectionString": "Server=localhost;Database=MyMeetings;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=true;"
  }
}
```

**For different database setups:**
- **SQL Server Express (Windows):** `"Server=(localdb)\\mssqllocaldb;Database=MyMeetings;Trusted_Connection=True;"`
- **Docker SQL Server:** `"Server=localhost;Database=MyMeetings;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=true;"`
- **Azure SQL:** Use your Azure SQL connection string

#### Email Configuration (Optional)
Update the email settings in `appsettings.json` if you want email functionality:

```json
{
  "EmailsConfiguration": {
    "FromEmail": "your-email@domain.com",
    "SmtpServer": "smtp.gmail.com",
    "SmtpPort": 587,
    "SmtpUsername": "your-username",
    "SmtpPassword": "your-password"
  }
}
```

### 4. Security Configuration

The application uses IdentityServer4 for authentication. The current setup has known security vulnerabilities that were suppressed for development purposes.

**For production use, you should:**
1. Upgrade to a newer authentication system (IdentityServer6+ or ASP.NET Core Identity)
2. Update the `TextEncryptionKey` in `appsettings.json` to a secure value
3. Configure proper SSL certificates

### 5. Running the Application

Once the database and configuration are set up:

```bash
# Navigate to the API project
cd ~/repos/modular-monolith-with-ddd-dotnet/src/API/CompanyName.MyMeetings.API

# Run the application
dotnet run
```

The API will be available at:
- HTTP: `http://localhost:5000`
- HTTPS: `https://localhost:5001`
- Swagger UI: `https://localhost:5001/swagger`

### 6. Authentication for API Testing

To test the API endpoints, you'll need to authenticate:

1. **Get an access token** using OAuth2 Resource Owner Password Grant:
   ```bash
   curl -X POST "https://localhost:5001/connect/token" \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -d "client_id=ro.client&client_secret=secret&grant_type=password&username=testMember@mail.com&password=testMemberPass&scope=myMeetingsAPI openid profile"
   ```

2. **Use the token** in subsequent API calls:
   ```bash
   curl -X GET "https://localhost:5001/api/meetings" \
     -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
   ```

## Development Workflow

### Building the Project
```bash
cd ~/repos/modular-monolith-with-ddd-dotnet/src
dotnet build --disable-build-servers
```

### Running Tests
```bash
# Unit and Architecture tests (no database required)
dotnet test --filter "FullyQualifiedName~UnitTests|FullyQualifiedName~ArchTests" --no-build

# All tests (requires database setup)
dotnet test --no-build
```

### Code Quality
The project includes:
- **StyleCop** for code style analysis
- **.editorconfig** for consistent formatting
- **Architecture tests** to enforce design patterns
- **Unit tests** for domain logic

## Troubleshooting

### Common Issues

1. **Database Connection Errors:**
   - Verify SQL Server is running
   - Check connection string format
   - Ensure database exists and migrations are applied

2. **IdentityServer4 Vulnerabilities:**
   - These are suppressed for development
   - Consider upgrading for production use

3. **Build Errors:**
   - Use `--disable-build-servers` flag if you encounter caching issues
   - Clear NuGet cache: `dotnet nuget locals all --clear`

4. **Port Conflicts:**
   - Change ports in `launchSettings.json` if 5000/5001 are in use

### Logs and Debugging
- Application logs are written to the console
- Enable detailed logging by setting log levels in `appsettings.json`
- Use Visual Studio or VS Code debugger for step-through debugging

## Next Steps

After completing this setup:

1. **Explore the API** using Swagger UI
2. **Review the architecture** - this is an excellent example of DDD and modular monolith patterns
3. **Run integration tests** to verify full functionality
4. **Consider the frontend** - there's a separate React frontend repository available

## Additional Resources

- [Project README](README.md) - Comprehensive architecture documentation
- [Frontend Repository](https://github.com/kgrzybek/modular-monolith-with-ddd-fe-react)
- [Domain-Driven Design Reference](http://domainlanguage.com/ddd/reference/)

## Security Note

⚠️ **Important:** This setup includes development-only configurations. Before deploying to production:
- Update all default passwords and secrets
- Configure proper SSL certificates
- Upgrade IdentityServer4 to a supported version
- Review and harden all security configurations