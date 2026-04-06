import express from "express";
import { createServer as createViteServer } from "vite";
import Database from "better-sqlite3";
import jwt from "jsonwebtoken";
import bcrypt from "bcryptjs";
import path from "path";

const db = new Database("vermeg_sirh.db");
const JWT_SECRET = process.env.JWT_SECRET || "nexus-secret-key";

// Initialize Database
db.exec(`
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT UNIQUE,
    password TEXT,
    full_name TEXT,
    role TEXT DEFAULT 'EMPLOYEE',
    department TEXT,
    position TEXT,
    avatar TEXT,
    experience TEXT,
    leave_balance INTEGER DEFAULT 25,
    total_hours INTEGER DEFAULT 0,
    phone TEXT,
    country TEXT,
    city TEXT,
    diploma TEXT
  );
`);

// Ensure new columns exist for existing databases
try { db.exec("ALTER TABLE users ADD COLUMN phone TEXT"); } catch(e) {}
try { db.exec("ALTER TABLE users ADD COLUMN country TEXT"); } catch(e) {}
try { db.exec("ALTER TABLE users ADD COLUMN city TEXT"); } catch(e) {}
try { db.exec("ALTER TABLE users ADD COLUMN diploma TEXT"); } catch(e) {}
try { db.exec("ALTER TABLE users ADD COLUMN manager_id INTEGER"); } catch(e) {}

db.exec(`
  CREATE TABLE IF NOT EXISTS leave_requests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    type TEXT,
    start_date TEXT,
    end_date TEXT,
    reason TEXT,
    status TEXT DEFAULT 'PENDING',
    created_at TEXT,
    FOREIGN KEY(user_id) REFERENCES users(id)
  );

  CREATE TABLE IF NOT EXISTS document_requests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    type TEXT,
    status TEXT DEFAULT 'PENDING',
    created_at TEXT,
    FOREIGN KEY(user_id) REFERENCES users(id)
  );

  CREATE TABLE IF NOT EXISTS messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sender_id INTEGER,
    receiver_id INTEGER,
    content TEXT,
    created_at TEXT,
    FOREIGN KEY(sender_id) REFERENCES users(id),
    FOREIGN KEY(receiver_id) REFERENCES users(id)
  );

  CREATE TABLE IF NOT EXISTS news (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT,
    content TEXT,
    author_id INTEGER,
    created_at TEXT,
    FOREIGN KEY(author_id) REFERENCES users(id)
  );

  CREATE TABLE IF NOT EXISTS employees (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name TEXT,
    email TEXT UNIQUE,
    department TEXT,
    position TEXT,
    status TEXT DEFAULT 'ACTIVE',
    join_date TEXT,
    salary REAL,
    manager_id INTEGER,
    FOREIGN KEY(manager_id) REFERENCES employees(id)
  );

  CREATE TABLE IF NOT EXISTS job_offers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT,
    department TEXT,
    description TEXT,
    requirements TEXT,
    eligibility_criteria TEXT,
    status TEXT DEFAULT 'PUBLISHED', -- DRAFT, PUBLISHED, CLOSED, FILLED
    type TEXT DEFAULT 'EXTERNAL', -- INTERNAL, EXTERNAL
    recruiter_id INTEGER,
    created_at TEXT,
    closing_date TEXT,
    salary_range TEXT,
    FOREIGN KEY(recruiter_id) REFERENCES users(id)
  );

  CREATE TABLE IF NOT EXISTS applications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    job_id INTEGER,
    user_id INTEGER,
    status TEXT DEFAULT 'PENDING', -- PENDING, PRE_SELECTED, INTERVIEW_SCHEDULED, RETAINED, WAITING_LIST, REJECTED
    applied_at TEXT,
    cover_letter TEXT,
    cv_file TEXT,
    diploma_file TEXT,
    cin_file TEXT,
    phone TEXT,
    city TEXT,
    country TEXT,
    full_name TEXT,
    email TEXT,
    FOREIGN KEY(job_id) REFERENCES job_offers(id),
    FOREIGN KEY(user_id) REFERENCES users(id)
  );

  CREATE TABLE IF NOT EXISTS interviews (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    application_id INTEGER,
    date TEXT,
    evaluator_id INTEGER,
    score INTEGER,
    comments TEXT,
    status TEXT DEFAULT 'SCHEDULED', -- SCHEDULED, COMPLETED, CANCELLED
    FOREIGN KEY(application_id) REFERENCES applications(id),
    FOREIGN KEY(evaluator_id) REFERENCES users(id)
  );

  CREATE TABLE IF NOT EXISTS notifications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    message TEXT,
    type TEXT,
    is_read INTEGER DEFAULT 0,
    created_at TEXT,
    FOREIGN KEY(user_id) REFERENCES users(id)
  );

  CREATE TABLE IF NOT EXISTS departments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE,
    description TEXT
  );

  CREATE TABLE IF NOT EXISTS positions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT,
    department_id INTEGER,
    description TEXT,
    FOREIGN KEY(department_id) REFERENCES departments(id)
  );

  CREATE TABLE IF NOT EXISTS contract_types (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE,
    description TEXT
  );
`);

// Ensure new columns exist for job_offers
try { db.exec("ALTER TABLE job_offers ADD COLUMN eligibility_criteria TEXT"); } catch(e) {}
try { db.exec("ALTER TABLE job_offers ADD COLUMN type TEXT DEFAULT 'EXTERNAL'"); } catch(e) {}
try { db.exec("ALTER TABLE job_offers ADD COLUMN closing_date TEXT"); } catch(e) {}
try { db.exec("ALTER TABLE job_offers ADD COLUMN salary_range TEXT"); } catch(e) {}

// Ensure new columns exist for applications
try { db.exec("ALTER TABLE applications ADD COLUMN cv_file TEXT"); } catch(e) {}
try { db.exec("ALTER TABLE applications ADD COLUMN diploma_file TEXT"); } catch(e) {}
try { db.exec("ALTER TABLE applications ADD COLUMN cin_file TEXT"); } catch(e) {}
try { db.exec("ALTER TABLE applications ADD COLUMN phone TEXT"); } catch(e) {}
try { db.exec("ALTER TABLE applications ADD COLUMN city TEXT"); } catch(e) {}
try { db.exec("ALTER TABLE applications ADD COLUMN country TEXT"); } catch(e) {}
try { db.exec("ALTER TABLE applications ADD COLUMN full_name TEXT"); } catch(e) {}
try { db.exec("ALTER TABLE applications ADD COLUMN email TEXT"); } catch(e) {}

// Seed initial data if empty
const userCount = db.prepare("SELECT COUNT(*) as count FROM users").get() as { count: number };
if (userCount.count === 0) {
  const salt = 10;
  
  // HR Admin
  db.prepare("INSERT INTO users (email, password, full_name, role, department, position, experience, leave_balance, total_hours) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)")
    .run("admin@vermeg.com", bcrypt.hashSync("admin123", salt), "Admin VERMEG", "HR_ADMIN", "RH", "Directeur RH", "10 ans", 25, 1600);
  
  // Manager
  db.prepare("INSERT INTO users (email, password, full_name, role, department, position, experience, leave_balance, total_hours) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)")
    .run("manager@vermeg.com", bcrypt.hashSync("manager123", salt), "Marc Manager", "MANAGER", "IT", "Engineering Manager", "8 ans", 22, 1450);

  // Recruiter
  db.prepare("INSERT INTO users (email, password, full_name, role, department, position, experience, leave_balance, total_hours) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)")
    .run("recruiter@vermeg.com", bcrypt.hashSync("recruiter123", salt), "Rita Recruteur", "RECRUITER", "RH", "Talent Acquisition", "5 ans", 20, 1200);

  // Employee
  db.prepare("INSERT INTO users (email, password, full_name, role, department, position, experience, leave_balance, total_hours, manager_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)")
    .run("employee@vermeg.com", bcrypt.hashSync("employee123", salt), "Eric Employé", "EMPLOYEE", "IT", "Développeur Fullstack", "2 ans", 15, 800, 2); // Manager is Marc Manager (id 2)
  
  db.prepare("INSERT INTO departments (name, description) VALUES (?, ?)")
    .run("RH", "Ressources Humaines");
  db.prepare("INSERT INTO departments (name, description) VALUES (?, ?)")
    .run("IT", "Technologies de l'information");
  db.prepare("INSERT INTO departments (name, description) VALUES (?, ?)")
    .run("Product", "Gestion de produit");

  db.prepare("INSERT INTO positions (title, department_id, description) VALUES (?, ?, ?)")
    .run("Développeur Fullstack", 2, "Développement web");
  db.prepare("INSERT INTO positions (title, department_id, description) VALUES (?, ?, ?)")
    .run("Engineering Manager", 2, "Gestion d'équipe technique");

  db.prepare("INSERT INTO contract_types (name, description) VALUES (?, ?)")
    .run("CDI", "Contrat à Durée Indéterminée");
  db.prepare("INSERT INTO contract_types (name, description) VALUES (?, ?)")
    .run("CDD", "Contrat à Durée Déterminée");
  db.prepare("INSERT INTO contract_types (name, description) VALUES (?, ?)")
    .run("SIVP", "Stage d'Initiation à la Vie Professionnelle");

  db.prepare("INSERT INTO employees (full_name, email, department, position, join_date, salary, manager_id) VALUES (?, ?, ?, ?, ?, ?, ?)")
    .run("Admin VERMEG", "admin@vermeg.com", "RH", "Directeur RH", "2023-01-01", 5500, null);
    
  db.prepare("INSERT INTO employees (full_name, email, department, position, join_date, salary, manager_id) VALUES (?, ?, ?, ?, ?, ?, ?)")
    .run("Eric Employé", "employee@vermeg.com", "IT", "Développeur Fullstack", "2023-06-01", 3200, 2);
    
  db.prepare("INSERT INTO job_offers (title, department, description, requirements, created_at, closing_date, salary_range) VALUES (?, ?, ?, ?, ?, ?, ?)")
    .run("Senior Developer React", "IT", "Nous recherchons un expert React pour nos projets internes.", "5+ ans exp, TypeScript, Tailwind", "2024-02-20", "2024-04-30", "45k - 60k");

  db.prepare("INSERT INTO job_offers (title, department, description, requirements, created_at, closing_date, salary_range) VALUES (?, ?, ?, ?, ?, ?, ?)")
    .run("Product Manager", "Product", "Gestion de la roadmap produit NexusHR.", "Expérience SaaS, Agile", "2024-03-01", "2024-05-15", "50k - 70k");
}

async function startServer() {
  const app = express();
  app.use(express.json());

  // Auth Middleware
  const authenticateToken = (req: any, res: any, next: any) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    jwt.verify(token, JWT_SECRET, (err: any, user: any) => {
      if (err) return res.sendStatus(403);
      req.user = user;
      next();
    });
  };

  // API Routes
  app.post("/api/auth/login", (req, res) => {
    const { email, password } = req.body;
    const user = db.prepare("SELECT * FROM users WHERE email = ?").get(email) as any;
    
    if (user && bcrypt.compareSync(password, user.password)) {
      const token = jwt.sign({ id: user.id, email: user.email, role: user.role }, JWT_SECRET);
      const { password: _, ...userWithoutPassword } = user;
      res.json({ token, user: userWithoutPassword });
    } else {
      res.status(401).json({ error: "Identifiants invalides" });
    }
  });

  app.post("/api/auth/register", (req, res) => {
    const { email, password, full_name, phone, country, city, position, department, diploma } = req.body;
    const salt = 10;
    try {
      const hashedPassword = bcrypt.hashSync(password, salt);
      const result = db.prepare(`
        INSERT INTO users (email, password, full_name, role, phone, country, city, position, department, diploma)
        VALUES (?, ?, ?, 'CANDIDATE', ?, ?, ?, ?, ?, ?)
      `).run(email, hashedPassword, full_name, phone, country, city, position, department, diploma);
      
      const user = db.prepare("SELECT * FROM users WHERE id = ?").get(result.lastInsertRowid) as any;
      const token = jwt.sign({ id: user.id, email: user.email, role: user.role }, JWT_SECRET);
      const { password: _, ...userWithoutPassword } = user;
      res.json({ token, user: userWithoutPassword });
    } catch (err) {
      res.status(400).json({ error: "Cet email est déjà utilisé" });
    }
  });

  app.get("/api/auth/me", authenticateToken, (req: any, res) => {
    const user = db.prepare("SELECT id, email, full_name, role, department, position, experience, leave_balance, total_hours, phone, country, city, diploma FROM users WHERE id = ?").get(req.user.id);
    res.json({ user });
  });

  app.put("/api/auth/profile", authenticateToken, (req: any, res) => {
    const { full_name, email, department, position, phone, country, city, diploma } = req.body;
    try {
      db.prepare("UPDATE users SET full_name = ?, email = ?, department = ?, position = ?, phone = ?, country = ?, city = ?, diploma = ? WHERE id = ?")
        .run(full_name, email, department, position, phone, country, city, diploma, req.user.id);
      const updatedUser = db.prepare("SELECT id, email, full_name, role, department, position, experience, leave_balance, total_hours, phone, country, city, diploma FROM users WHERE id = ?").get(req.user.id);
      res.json({ user: updatedUser });
    } catch (err) {
      res.status(400).json({ error: "Erreur lors de la mise à jour (l'email est peut-être déjà utilisé)" });
    }
  });

  app.get("/api/public/jobs", (req, res) => {
    const jobs = db.prepare("SELECT id, title, department, description, salary_range, closing_date, requirements, eligibility_criteria, type FROM job_offers WHERE status = 'PUBLISHED'").all();
    res.json(jobs);
  });

  // Leave Requests
  app.get("/api/leaves", authenticateToken, (req: any, res) => {
    let leaves;
    if (req.user.role === 'HR_ADMIN') {
      leaves = db.prepare(`
        SELECT l.*, u.full_name as user_name 
        FROM leave_requests l 
        JOIN users u ON l.user_id = u.id 
        ORDER BY l.created_at DESC
      `).all();
    } else {
      leaves = db.prepare("SELECT * FROM leave_requests WHERE user_id = ? ORDER BY created_at DESC").all(req.user.id);
    }
    res.json(leaves);
  });

  app.post("/api/leaves", authenticateToken, (req: any, res) => {
    const { type, start_date, end_date, reason } = req.body;
    db.prepare("INSERT INTO leave_requests (user_id, type, start_date, end_date, reason, created_at) VALUES (?, ?, ?, ?, ?, ?)")
      .run(req.user.id, type, start_date, end_date, reason, new Date().toISOString());
    res.json({ success: true });
  });

  app.put("/api/leaves/:id", authenticateToken, (req: any, res) => {
    if (req.user.role !== 'HR_ADMIN') return res.status(403).json({ error: "Unauthorized" });
    const { status } = req.body;
    db.prepare("UPDATE leave_requests SET status = ? WHERE id = ?").run(status, req.params.id);
    res.json({ success: true });
  });

  // Document Requests
  app.get("/api/documents", authenticateToken, (req: any, res) => {
    const docs = db.prepare("SELECT * FROM document_requests WHERE user_id = ? ORDER BY created_at DESC").all(req.user.id);
    res.json(docs);
  });

  app.post("/api/documents", authenticateToken, (req: any, res) => {
    const { type } = req.body;
    db.prepare("INSERT INTO document_requests (user_id, type, created_at) VALUES (?, ?, ?)")
      .run(req.user.id, type, new Date().toISOString());
    res.json({ success: true });
  });

  // News
  app.get("/api/news", authenticateToken, (req: any, res) => {
    const news = db.prepare(`
      SELECT n.*, u.full_name as author_name 
      FROM news n 
      JOIN users u ON n.author_id = u.id 
      ORDER BY n.created_at DESC
    `).all();
    res.json(news);
  });

  app.post("/api/news", authenticateToken, (req: any, res) => {
    if (req.user.role !== 'HR_ADMIN') return res.status(403).json({ error: "Unauthorized" });
    const { title, content } = req.body;
    db.prepare("INSERT INTO news (title, content, author_id, created_at) VALUES (?, ?, ?, ?)")
      .run(title, content, req.user.id, new Date().toISOString());
    res.json({ success: true });
  });

  // Messages
  app.get("/api/messages", authenticateToken, (req: any, res) => {
    const messages = db.prepare(`
      SELECT m.*, s.full_name as sender_name, r.full_name as receiver_name
      FROM messages m
      JOIN users s ON m.sender_id = s.id
      JOIN users r ON m.receiver_id = r.id
      WHERE m.sender_id = ? OR m.receiver_id = ?
      ORDER BY m.created_at ASC
    `).all(req.user.id, req.user.id);
    res.json(messages);
  });

  app.post("/api/messages", authenticateToken, (req: any, res) => {
    const { content, receiver_id } = req.body;
    // If employee sending to HR, receiver_id should be an HR admin
    // For simplicity, we'll just use the provided receiver_id
    db.prepare("INSERT INTO messages (sender_id, receiver_id, content, created_at) VALUES (?, ?, ?, ?)")
      .run(req.user.id, receiver_id, content, new Date().toISOString());
    res.json({ success: true });
  });

  app.get("/api/hr-admins", authenticateToken, (req: any, res) => {
    if (req.user.role === 'HR_ADMIN') {
      // If HR, they might want to see employees to chat with
      const employees = db.prepare("SELECT id, full_name FROM users WHERE role IN ('EMPLOYEE', 'CANDIDATE')").all();
      res.json(employees);
    } else {
      const admins = db.prepare("SELECT id, full_name FROM users WHERE role = 'HR_ADMIN'").all();
      res.json(admins);
    }
  });

  app.post("/api/jobs", authenticateToken, (req: any, res) => {
    if (req.user.role !== 'HR_ADMIN') return res.status(403).json({ error: "Unauthorized" });
    const { title, department, description, salary_range, closing_date, requirements, eligibility_criteria, type, status } = req.body;
    const now = new Date().toISOString();
    try {
      db.prepare(`
        INSERT INTO job_offers (title, department, description, salary_range, closing_date, requirements, eligibility_criteria, type, status, recruiter_id, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `).run(title, department, description, salary_range, closing_date, requirements, eligibility_criteria, type || 'EXTERNAL', status || 'PUBLISHED', req.user.id, now);
      res.json({ success: true });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: "Erreur lors de la création de l'offre" });
    }
  });

  app.put("/api/jobs/:id", authenticateToken, (req: any, res) => {
    if (req.user.role !== 'HR_ADMIN') return res.status(403).json({ error: "Unauthorized" });
    const { id } = req.params;
    const { title, department, description, salary_range, closing_date, requirements, eligibility_criteria, type, status } = req.body;
    try {
      db.prepare(`
        UPDATE job_offers
        SET title = ?, department = ?, description = ?, salary_range = ?, closing_date = ?, requirements = ?, eligibility_criteria = ?, type = ?, status = ?
        WHERE id = ?
      `).run(title, department, description, salary_range, closing_date, requirements, eligibility_criteria, type, status, id);
      res.json({ success: true });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: "Erreur lors de la mise a jour de l'offre" });
    }
  });

  app.delete("/api/jobs/:id", authenticateToken, (req: any, res) => {
    if (req.user.role !== 'HR_ADMIN') return res.status(403).json({ error: "Unauthorized" });
    const { id } = req.params;
    try {
      db.prepare("DELETE FROM job_offers WHERE id = ?").run(id);
      res.json({ success: true });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: "Erreur lors de la suppression de l'offre" });
    }
  });

  app.get("/api/jobs", authenticateToken, (req, res) => {
    const jobs = db.prepare("SELECT * FROM job_offers ORDER BY created_at DESC").all();
    res.json(jobs);
  });

  app.get("/api/employees", authenticateToken, (req, res) => {
    const employees = db.prepare("SELECT * FROM employees").all();
    res.json(employees);
  });

  app.get("/api/stats", authenticateToken, (req, res) => {
    const empCount = db.prepare("SELECT COUNT(*) as count FROM employees").get() as any;
    const jobCount = db.prepare("SELECT COUNT(*) as count FROM job_offers WHERE status = 'PUBLISHED'").get() as any;
    const appCount = db.prepare("SELECT COUNT(*) as count FROM applications WHERE status = 'PENDING'").get() as any;
    
    res.json({
      employees: empCount.count,
      openJobs: jobCount.count,
      totalApplications: appCount.count,
      departmentStats: db.prepare("SELECT department, COUNT(*) as count FROM employees GROUP BY department").all(),
      mobilityRate: "12%", // Simulated
      avgRecruitmentTime: "18 jours" // Simulated
    });
  });

  // Departments, Positions, Contract Types
  app.get("/api/departments", authenticateToken, (req, res) => {
    const departments = db.prepare("SELECT * FROM departments").all();
    res.json(departments);
  });

  app.post("/api/departments", authenticateToken, (req: any, res) => {
    if (req.user.role !== 'HR_ADMIN') return res.status(403).json({ error: "Unauthorized" });
    const { name, description } = req.body;
    db.prepare("INSERT INTO departments (name, description) VALUES (?, ?)").run(name, description);
    res.json({ success: true });
  });

  app.get("/api/positions", authenticateToken, (req, res) => {
    const positions = db.prepare(`
      SELECT p.*, d.name as department_name 
      FROM positions p 
      JOIN departments d ON p.department_id = d.id
    `).all();
    res.json(positions);
  });

  app.post("/api/positions", authenticateToken, (req: any, res) => {
    if (req.user.role !== 'HR_ADMIN') return res.status(403).json({ error: "Unauthorized" });
    const { title, department_id, description } = req.body;
    db.prepare("INSERT INTO positions (title, department_id, description) VALUES (?, ?, ?)").run(title, department_id, description);
    res.json({ success: true });
  });

  app.get("/api/contract-types", authenticateToken, (req, res) => {
    const types = db.prepare("SELECT * FROM contract_types").all();
    res.json(types);
  });

  app.post("/api/contract-types", authenticateToken, (req: any, res) => {
    if (req.user.role !== 'HR_ADMIN') return res.status(403).json({ error: "Unauthorized" });
    const { name, description } = req.body;
    db.prepare("INSERT INTO contract_types (name, description) VALUES (?, ?)").run(name, description);
    res.json({ success: true });
  });

  // User Management
  app.get("/api/users", authenticateToken, (req: any, res) => {
    if (req.user.role !== 'HR_ADMIN') return res.status(403).json({ error: "Unauthorized" });
    const users = db.prepare("SELECT id, email, full_name, role, department, position FROM users").all();
    res.json(users);
  });

  app.put("/api/users/:id/role", authenticateToken, (req: any, res) => {
    if (req.user.role !== 'HR_ADMIN') return res.status(403).json({ error: "Unauthorized" });
    const { role } = req.body;
    db.prepare("UPDATE users SET role = ? WHERE id = ?").run(role, req.params.id);
    res.json({ success: true });
  });

  // Manager Space
  app.get("/api/team", authenticateToken, (req: any, res) => {
    if (req.user.role !== 'MANAGER' && req.user.role !== 'HR_ADMIN') return res.status(403).json({ error: "Unauthorized" });
    const team = db.prepare("SELECT id, email, full_name, role, department, position, experience, leave_balance, total_hours FROM users WHERE manager_id = ?").all(req.user.id);
    res.json(team);
  });

  app.get("/api/team/stats", authenticateToken, (req: any, res) => {
    if (req.user.role !== 'MANAGER' && req.user.role !== 'HR_ADMIN') return res.status(403).json({ error: "Unauthorized" });
    const teamCount = db.prepare("SELECT COUNT(*) as count FROM users WHERE manager_id = ?").get(req.user.id) as any;
    const leaveCount = db.prepare(`
      SELECT COUNT(*) as count 
      FROM leave_requests l
      JOIN users u ON l.user_id = u.id
      WHERE u.manager_id = ? AND l.status = 'PENDING'
    `).get(req.user.id) as any;
    
    res.json({
      teamSize: teamCount.count,
      pendingLeaves: leaveCount.count,
      performanceAvg: "85%", // Simulated
      trainingCompletion: "92%" // Simulated
    });
  });

  // Applications
  app.post("/api/jobs/:id/apply", authenticateToken, (req: any, res) => {
    const jobId = req.params.id;
    const { cover_letter, diploma_file, cin_file, phone, city, country, full_name, email } = req.body;
    
    try {
      db.prepare(`
        INSERT INTO applications (job_id, user_id, status, applied_at, cover_letter, diploma_file, cin_file, phone, city, country, full_name, email)
        VALUES (?, ?, 'PENDING', ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `).run(jobId, req.user.id, new Date().toISOString(), cover_letter, diploma_file, cin_file, phone, city, country, full_name, email);
      res.json({ success: true });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: "Erreur lors de la candidature" });
    }
  });

  app.get("/api/applications", authenticateToken, (req: any, res) => {
    if (req.user.role === 'HR_ADMIN') {
      const apps = db.prepare(`
        SELECT a.*, j.title as job_title 
        FROM applications a
        JOIN job_offers j ON a.job_id = j.id
        ORDER BY a.applied_at DESC
      `).all();
      res.json(apps);
    } else {
      const apps = db.prepare(`
        SELECT a.*, j.title as job_title 
        FROM applications a
        JOIN job_offers j ON a.job_id = j.id
        WHERE a.user_id = ?
        ORDER BY a.applied_at DESC
      `).all(req.user.id);
      res.json(apps);
    }
  });

  app.put("/api/applications/:id/status", authenticateToken, (req: any, res) => {
    if (req.user.role !== 'HR_ADMIN') return res.status(403).json({ error: "Unauthorized" });
    const { status } = req.body;
    db.prepare("UPDATE applications SET status = ? WHERE id = ?").run(status, req.params.id);
    
    // Send notification
    const app = db.prepare("SELECT a.*, j.title as job_title FROM applications a JOIN job_offers j ON a.job_id = j.id WHERE a.id = ?").get(req.params.id) as any;
    if (app) {
      db.prepare("INSERT INTO notifications (user_id, message, type, created_at) VALUES (?, ?, ?, ?)")
        .run(app.user_id, `Le statut de votre candidature pour "${app.job_title}" est passé à: ${status}`, 'APPLICATION_STATUS', new Date().toISOString());
    }
    
    res.json({ success: true });
  });

  // Interviews
  app.get("/api/interviews", authenticateToken, (req: any, res) => {
    let interviews;
    if (req.user.role === 'HR_ADMIN') {
      interviews = db.prepare(`
        SELECT i.*, a.full_name as candidate_name, j.title as job_title
        FROM interviews i
        JOIN applications a ON i.application_id = a.id
        JOIN job_offers j ON a.job_id = j.id
        ORDER BY i.date ASC
      `).all();
    } else {
      interviews = db.prepare(`
        SELECT i.*, a.full_name as candidate_name, j.title as job_title
        FROM interviews i
        JOIN applications a ON i.application_id = a.id
        JOIN job_offers j ON a.job_id = j.id
        WHERE a.user_id = ?
        ORDER BY i.date ASC
      `).all(req.user.id);
    }
    res.json(interviews);
  });

  app.post("/api/interviews", authenticateToken, (req: any, res) => {
    if (req.user.role !== 'HR_ADMIN') return res.status(403).json({ error: "Unauthorized" });
    const { application_id, date, evaluator_id } = req.body;
    db.prepare("INSERT INTO interviews (application_id, date, evaluator_id) VALUES (?, ?, ?)")
      .run(application_id, date, evaluator_id);
    
    // Update application status
    db.prepare("UPDATE applications SET status = 'INTERVIEW_SCHEDULED' WHERE id = ?").run(application_id);
    
    // Notify candidate
    const app = db.prepare("SELECT a.*, j.title as job_title FROM applications a JOIN job_offers j ON a.job_id = j.id WHERE a.id = ?").get(application_id) as any;
    if (app) {
      db.prepare("INSERT INTO notifications (user_id, message, type, created_at) VALUES (?, ?, ?, ?)")
        .run(app.user_id, `Un entretien a été planifié pour le poste "${app.job_title}" le ${new Date(date).toLocaleString()}`, 'INTERVIEW_SCHEDULED', new Date().toISOString());
    }
    
    res.json({ success: true });
  });

  app.put("/api/interviews/:id", authenticateToken, (req: any, res) => {
    if (req.user.role !== 'HR_ADMIN') return res.status(403).json({ error: "Unauthorized" });
    const { score, comments, status } = req.body;
    db.prepare("UPDATE interviews SET score = ?, comments = ?, status = ? WHERE id = ?")
      .run(score, comments, status, req.params.id);
    res.json({ success: true });
  });

  // Notifications
  app.get("/api/notifications", authenticateToken, (req: any, res) => {
    const notifications = db.prepare("SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC").all(req.user.id);
    res.json(notifications);
  });

  app.put("/api/notifications/:id/read", authenticateToken, (req: any, res) => {
    db.prepare("UPDATE notifications SET is_read = 1 WHERE id = ? AND user_id = ?").run(req.params.id, req.user.id);
    res.json({ success: true });
  });

  // Vite middleware for development
  if (process.env.NODE_ENV !== "production") {
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: "spa",
    });
    app.use(vite.middlewares);
  } else {
    app.use(express.static(path.join(__dirname, "dist")));
    app.get("*", (req, res) => {
      res.sendFile(path.join(__dirname, "dist/index.html"));
    });
  }

  const PORT = 3000;
  app.listen(PORT, "0.0.0.0", () => {
    console.log(`Server running on http://localhost:${PORT}`);
  });
}

startServer();
