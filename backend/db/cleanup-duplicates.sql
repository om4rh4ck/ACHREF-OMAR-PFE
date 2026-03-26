-- Supprimer les doublons (offres et candidatures) - a lancer une seule fois.
-- Ne modifie pas le code ni le seed.

-- Offres en double : garder une seule offre par (title, department), supprimer les autres
DELETE FROM job_offers a
USING job_offers b
WHERE a.id > b.id
  AND a.title = b.title
  AND a.department = b.department;

-- Candidatures en double : garder une seule par (job_id, email), supprimer les autres
DELETE FROM applications a
USING applications b
WHERE a.id > b.id
  AND a.job_id = b.job_id
  AND a.email = b.email;
