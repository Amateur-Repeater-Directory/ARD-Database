# ARD Database

<img src="https://github.com/user-attachments/assets/b677c6cf-5a66-459f-bd1f-95d3ee820921"
     width="160" height="160"
     alt="ARD Logo"
     style="float:left; margin:0 1em 1em 0;" />
<h3>Free, Verified, Community-Maintained</h3>

This repository contains the **SQL Server database schema** for the  
[Amateur Repeater Directory](https://amateurrepeaterdirectory.org) project.

It is published as a **Visual Studio SQL Server Database Project**.  
Each table, view, and stored procedure is its own `.sql` file for easy browsing and version control.  
Building the project produces a portable **`.dacpac`** that can be deployed to SQL Server.

---

## 🚀 Getting Started

### 1) Install prerequisites

- **SQL Server 2022 Developer Edition** (free)  
  👉 https://www.microsoft.com/en-us/sql-server/sql-server-downloads

- **SQL Server Management Studio (SSMS) v20 or later**  
  👉 https://aka.ms/ssmsfullsetup

- **Visual Studio Community 2022 or later** with **SQL Server Data Tools (SSDT)**  
  👉 https://visualstudio.microsoft.com/vs/community/  
  > If Visual Studio is already installed, open **Visual Studio Installer → Modify → Workloads → Data storage and processing (SQL Server Data Tools)**.

---

### 2) Get the source code

You can clone the repository in two ways:

#### Option A — Using Visual Studio (no command line required)

1. Open **Visual Studio**.  
2. On the start window, click **Clone a repository**.  
3. In the “Repository location” box, paste:

   ```
   https://github.com/AmateurRepeaterDirectory/ARD-Database.git
   ```

4. Choose a local path on your computer where you want the project saved.  
5. Click **Clone**. Visual Studio will fetch the repo and open the solution.

---

#### Option B — Using Git from the command line

```bash
git clone https://github.com/AmateurRepeaterDirectory/ARD-Database.git
cd ARD-Database
```


---

### 3) Open and build the project

1. Launch **Visual Studio**.
2. Open the solution file: `ARD_Database.sln`.
3. In Solution Explorer, right-click the **ARD_Database** project → **Build**.
4. After a successful build, look in:

   ```bash
   /bin/Debug/
   ```

   You’ll find:
   - `ARD_Database.dacpac` → compiled database package  
   - `ARD_Database.sql` → (optional) full deployment script

---

## 📦 Deploying the Database

You can deploy the schema into your own SQL Server instance in two ways.

### Option A — SSMS “Deploy Data-tier Application” (simplest)

1. Open **SSMS** and connect to your SQL Server 2022 instance.
2. Right-click **Databases** → **Deploy Data-tier Application…**
3. Select `ARD_Database.dacpac` (from `/bin/Debug/`).
4. For the database name, enter:

   ```
   AmateurRepeaterDirectory
   ```

5. Click **Finish**. SSMS will create all objects in the correct order.

---

### Option B — Generate a deployment script from Visual Studio

1. In Visual Studio, right-click the project → **Publish…**
2. Edit the connection to point to your SQL Server instance.
3. Check **Generate Script** (instead of publishing directly).
4. Save the script, open it in **SSMS**, and run it against a database named `AmateurRepeaterDirectory`.

---

## 🔄 Updating an Existing Database (diff script workflow)

When the schema changes:

1. Pull the latest changes from this repo.
2. Open the solution in Visual Studio and **Build**.
3. Right-click project → **Publish…** → **Generate Script** (don’t execute from VS).
4. Review the generated script.
5. Run it in **SSMS** on your existing `AmateurRepeaterDirectory` database.

> **Safety tips**
>
> - Keep **Block on data loss** enabled unless you *intend* to drop/alter columns.  
> - Do **not** use **Always re-create database** on production.  
> - Always review scripts before executing.

---

## 📂 Repository Layout

```
/ARD_Database.sln           Visual Studio solution
/ARD_Database/              Database project
  dbo/
    Tables/                 One .sql per table
    Views/                  One .sql per view
    Stored Procedures/      One .sql per stored procedure
    User Defined Types/     Scalar/table types
  Properties/               Project settings
  References/               External references (if any)
/docs/                      Optional diagrams or docs
```

- Each object lives in its own `.sql` file for clean diffs and PRs.  
- `bin/` and `obj/` are build outputs (should not be committed).

---

## 🌱 Seed Data

By default, this project contains **schema only**.  
If you need initial rows (e.g., lookup values like modes or offset types):

- Add them to a **Post-Deployment Script** inside the project, **or**
- Provide `.sql`/`.csv` files under `/data/seed/` and run them manually.

No production data is included in this repository.

---

## 🛠 Everyday Development Workflow

1. Edit schema in the project’s `.sql` files.
2. **Build** → produces a new `.dacpac`.
3. **Publish → Generate Script** → review and run in SSMS.
4. Commit `.sql` object changes to GitHub.
5. (Optional) Create a GitHub Release and attach the `.dacpac` for easy download.

---

## ❓ Troubleshooting

- **Can’t find the `.dacpac`?**  
  Make sure you built the project; check `/bin/Debug/` or `/bin/Release/`.

- **Foreign key / ordering errors when deploying?**  
  Deploy via the **.dacpac** or use a **script generated by SSDT**. These handle object dependency order automatically.

- **Database shows compatibility level 150 (SQL 2019) on a 2022 instance?**  
  Set it to 160:

  ```sql
  ALTER DATABASE [AmateurRepeaterDirectory] SET COMPATIBILITY_LEVEL = 160;
  ```

---

## 📜 License

- Database schema: **Apache-2.0**  

---

## 🤝 Contributing

Pull requests are welcome.

1. Fork the repo.  
2. Make your schema changes in the project’s `.sql` files.  
3. Build to ensure it compiles.  
4. Open a PR with a clear description of the change.


