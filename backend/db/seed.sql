-- Seed data for VERMEG SIRH PostgreSQL
-- Safe to run multiple times (idempotent inserts).

-- Users
INSERT INTO users (email, full_name, role, department, position, experience, leave_balance, total_hours, manager_id)
VALUES
  ('admin@vermeg.com', 'Admin VERMEG', 'HR_ADMIN', 'RH', 'Directeur RH', '10 ans', 25, 1600, NULL),
  ('manager@vermeg.com', 'Marc Manager', 'MANAGER', 'IT', 'Engineering Manager', '8 ans', 22, 1450, NULL),
  ('recruiter@vermeg.com', 'Rita Recruteur', 'RECRUITER', 'RH', 'Talent Acquisition', '5 ans', 20, 1200, NULL),
  ('employee@vermeg.com', 'Eric Employe', 'EMPLOYEE', 'IT', 'Developpeur Fullstack', '2 ans', 15, 800, NULL),
  ('candidate@vermeg.com', 'Camille Candidate', 'CANDIDATE', 'IT', 'Developpeur React', '1 an', 25, 0, NULL)
ON CONFLICT (email) DO NOTHING;

-- Link employee to manager
UPDATE users e
SET manager_id = m.id
FROM users m
WHERE e.email = 'employee@vermeg.com'
  AND m.email = 'manager@vermeg.com'
  AND (e.manager_id IS NULL OR e.manager_id <> m.id);

-- Departments
INSERT INTO departments (name, description)
VALUES
  ('RH', 'Ressources Humaines'),
  ('IT', 'Technologies de l''information'),
  ('Product', 'Gestion de produit')
ON CONFLICT (name) DO NOTHING;

-- Contract types
INSERT INTO contract_types (name, description)
VALUES
  ('CDI', 'Contrat a Duree Indeterminee'),
  ('CDD', 'Contrat a Duree Determinee'),
  ('SIVP', 'Stage d''Initiation a la Vie Professionnelle')
ON CONFLICT (name) DO NOTHING;

-- News
INSERT INTO news (title, content, author_id, created_at)
SELECT
  'Bienvenue sur VERMEG SIRH',
  'La plateforme RH microservices est operationnelle.',
  u.id,
  NOW()
FROM users u
WHERE u.email = 'admin@vermeg.com'
  AND NOT EXISTS (
    SELECT 1 FROM news n WHERE n.title = 'Bienvenue sur VERMEG SIRH'
  );

-- Job offers
INSERT INTO job_offers (title, department, description, requirements, eligibility_criteria, status, type, created_at, closing_date, salary_range)
VALUES
  (
    'Senior Developer React',
    'IT',
    'Nous recherchons un expert React pour nos projets internes.',
    '5+ ans, TypeScript, React, communication',
    'Minimum 2 ans dans un poste developpement frontend',
    'PUBLISHED',
    'INTERNAL',
    NOW(),
    CURRENT_DATE + INTERVAL '45 days',
    '45k - 60k'
  ),
  (
    'Product Manager',
    'Product',
    'Pilotage roadmap et coordination equipe produit.',
    'Experience SaaS, Agile, communication',
    'Connaissance secteur FinTech appreciee',
    'PUBLISHED',
    'EXTERNAL',
    NOW(),
    CURRENT_DATE + INTERVAL '60 days',
    '50k - 70k'
  )
ON CONFLICT DO NOTHING;

-- Candidate application on first published offer
INSERT INTO applications (job_id, job_title, user_id, status, applied_at, cover_letter, phone, city, country, full_name, email)
SELECT
  j.id,
  j.title,
  c.id,
  'PENDING',
  NOW(),
  'Je suis motive(e) et disponible rapidement.',
  '+21622333444',
  'Tunis',
  'Tunisie',
  c.full_name,
  c.email
FROM users c
JOIN job_offers j ON j.status = 'PUBLISHED'
WHERE c.email = 'candidate@vermeg.com'
  AND NOT EXISTS (
    SELECT 1 FROM applications a WHERE a.email = 'candidate@vermeg.com' AND a.job_id = j.id
  )
LIMIT 1;

-- Notifications for employee
INSERT INTO notifications (user_id, message, type, is_read, created_at)
SELECT
  u.id,
  'Votre espace RH est pret. Vous pouvez soumettre vos demandes.',
  'INFO',
  false,
  NOW()
FROM users u
WHERE u.email = 'employee@vermeg.com'
  AND NOT EXISTS (
    SELECT 1 FROM notifications n WHERE n.user_id = u.id AND n.message = 'Votre espace RH est pret. Vous pouvez soumettre vos demandes.'
  );
