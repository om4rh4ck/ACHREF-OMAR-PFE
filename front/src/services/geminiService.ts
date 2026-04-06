export async function generateJobDescription(title: string, department: string) {
  return `Nous recherchons un(e) ${title} pour rejoindre le departement ${department}.

Missions principales:
- Contribuer aux projets strategiques de VERMEG SIRH.
- Collaborer avec les equipes metier et techniques.
- Garantir la qualite, les delais et l'amelioration continue.

Profil recherche:
- Excellente communication et esprit d'equipe.
- Maitrise des pratiques professionnelles du poste.
- Sens de l'organisation et orientation resultat.`;
}

export async function screenCandidate(jobDescription: string, candidateProfile: string) {
  const jd = jobDescription.toLowerCase();
  const cp = candidateProfile.toLowerCase();
  let score = 50;

  if (cp.includes('react') && jd.includes('react')) score += 15;
  if (cp.includes('typescript') && jd.includes('typescript')) score += 15;
  if (cp.includes('agile') && jd.includes('agile')) score += 10;
  if (cp.includes('communication')) score += 5;
  if (score > 100) score = 100;

  return `Score: ${score}/100\nResume:\n- Points forts: profil coherent avec le poste, competences pertinentes detectees.\n- Points a verifier: details d'experience, disponibilite et adequation culturelle.`;
}