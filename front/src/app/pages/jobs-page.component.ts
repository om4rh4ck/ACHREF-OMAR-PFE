import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { AppShellComponent } from '../components/app-shell.component';
import { Application, JobOffer } from '../models';
import { ApiService } from '../services/api.service';
import { AuthService } from '../services/auth.service';

@Component({
  selector: 'app-jobs-page',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink, AppShellComponent],
  template: `
    <ng-container *ngIf="auth.user(); else publicJobs">
      <app-shell [user]="auth.user()" title="Offres de recrutement" (logout)="auth.logout()">
        <section class="section-card">
          <div class="section-heading">
            <div>
              <p class="eyebrow">Mobilite & recrutement</p>
              <h2 class="section-title">{{ jobsSectionTitle }}</h2>
            </div>
            <button
              *ngIf="canPublish"
              class="primary-btn"
              type="button"
              (click)="toggleCreate()"
            >
              {{ showCreate() ? 'Fermer' : 'Nouvelle offre' }}
            </button>
          </div>

          <form *ngIf="showCreate()" class="row g-3 mb-4" (ngSubmit)="saveJob()">
            <div class="col-md-6"><input class="form-control app-input" [(ngModel)]="jobForm.title" name="title" placeholder="Titre" required /></div>
            <div class="col-md-6">
              <ng-container *ngIf="!isManager(); else managerDept">
                <select class="form-select app-input" [(ngModel)]="jobForm.department" name="department" required>
                  <option value="" disabled>Departement</option>
                  <option *ngFor="let dept of departments()" [ngValue]="dept.name">{{ dept.name }}</option>
                </select>
              </ng-container>
              <ng-template #managerDept>
                <input class="form-control app-input" [value]="auth.user()?.department || 'Non defini'" readonly />
              </ng-template>
            </div>
            <div class="col-md-6"><input class="form-control app-input" [(ngModel)]="jobForm.salary_range" name="salary_range" placeholder="Salaire" required /></div>
            <div class="col-md-6" *ngIf="jobForm.type === 'INTERNAL'">
              <input class="form-control app-input" [(ngModel)]="jobForm.project" name="project" placeholder="Projet / mission (ex: Swift Dev)" />
            </div>
            <div class="col-md-6"><input class="form-control app-input" type="date" [(ngModel)]="jobForm.opening_date" name="opening_date" required /></div>
            <div class="col-md-6"><input class="form-control app-input" type="date" [(ngModel)]="jobForm.closing_date" name="closing_date" required /></div>
            <div class="col-md-6" *ngIf="canChooseType()">
              <select class="form-select app-input" [(ngModel)]="jobForm.type" name="type">
                <option value="INTERNAL">Interne</option>
                <option value="EXTERNAL">Externe</option>
              </select>
            </div>
            <div class="col-md-6">
              <select class="form-select app-input" [(ngModel)]="jobForm.status" name="status">
                <option value="DRAFT">Brouillon</option>
                <option value="PUBLISHED">Publiee</option>
                <option value="CLOSED">Cloturee</option>
                <option value="FILLED">Pourvue</option>
              </select>
            </div>
            <div class="col-md-6" *ngIf="isHrAdmin()">
              <select class="form-select app-input" [(ngModel)]="jobForm.recruiter_id" name="recruiter_id">
                <option [ngValue]="null" disabled>Responsable recruteur</option>
                <option *ngFor="let user of recruiters()" [ngValue]="user.id">{{ user.full_name }}</option>
              </select>
            </div>
            <div class="col-md-6"><input class="form-control app-input" [(ngModel)]="jobForm.requirements" name="requirements" placeholder="Requirements" /></div>
            <div class="col-12"><textarea class="form-control app-input" [(ngModel)]="jobForm.description" name="description" rows="4" placeholder="Description" required></textarea></div>
            <div class="col-12 d-flex gap-2 flex-wrap">
              <button class="primary-btn" type="submit">{{ editJob() ? 'Mettre a jour' : 'Publier' }}</button>
              <button class="ghost-btn" type="button" (click)="cancelEdit()">Annuler</button>
            </div>
          </form>

          <div class="row g-4">
            <div class="col-xl-4 col-md-6" *ngFor="let job of filteredJobs()">
              <article class="job-card h-100">
                <div class="job-card-top">
                  <span class="chip">{{ job.type }}</span>
                  <span class="small text-secondary">Ouverture {{ job.opening_date | date:'dd/MM/yyyy' }} · Cloture {{ job.closing_date | date:'dd/MM/yyyy' }}</span>
                </div>
                <h3>{{ job.title }}</h3>
                <p class="text-secondary">{{ job.department }} · {{ job.salary_range }}</p>
                <p class="small text-secondary" *ngIf="job.project">Projet: {{ job.project }}</p>
                <p class="small text-secondary">Statut: <span class="status-badge" [ngClass]="statusClass(job.status)">{{ statusLabel(job.status) }}</span></p>
                <p class="job-description">{{ job.description }}</p>
                <div class="d-flex gap-2 mt-auto flex-wrap">
                  <button *ngIf="!canPublish" class="ghost-btn" type="button" (click)="selectJob(job)">Postuler</button>
                  <button *ngIf="canPublish" class="ghost-btn" type="button" (click)="startEdit(job)">Modifier</button>
                  <button *ngIf="canPublish" class="ghost-btn" type="button" (click)="deleteJob(job.id)">Supprimer</button>
                </div>
              </article>
            </div>
          </div>
        </section>

        <div class="modal-overlay" *ngIf="selectedJob()" (click)="selectedJob.set(null)">
          <div class="modal-card modal-card-wide" (click)="$event.stopPropagation()">
            <div class="section-heading">
              <div>
                <p class="eyebrow">Candidature</p>
                <h2 class="section-title">{{ selectedJob()!.title }}</h2>
              </div>
              <button class="ghost-btn" type="button" (click)="selectedJob.set(null)">Fermer</button>
            </div>

            <form class="row g-3" (ngSubmit)="apply()">
            <div class="col-md-6">
              <label class="input-shell">
                <span class="input-icon" aria-hidden="true">
                  <svg viewBox="0 0 24 24" role="img" focusable="false" aria-hidden="true">
                    <circle cx="12" cy="8" r="4" fill="none" stroke="currentColor" stroke-width="1.8"/>
                    <path d="M4 20c1.7-3.6 5-5.5 8-5.5s6.3 1.9 8 5.5" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
                  </svg>
                </span>
                <input class="form-control app-input" [(ngModel)]="applicationForm.full_name" name="full_name" placeholder="Nom complet" required />
              </label>
            </div>
            <div class="col-md-6">
              <label class="input-shell">
                <span class="input-icon" aria-hidden="true">
                  <svg viewBox="0 0 24 24" role="img" focusable="false" aria-hidden="true">
                    <rect x="3" y="5" width="18" height="14" rx="2" ry="2" fill="none" stroke="currentColor" stroke-width="1.8"/>
                    <path d="M3 7l9 6 9-6" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                  </svg>
                </span>
                <input class="form-control app-input" [(ngModel)]="applicationForm.email" name="email" placeholder="Email" required />
              </label>
            </div>
            <div class="col-md-4">
              <label class="input-shell">
                <span class="input-icon" aria-hidden="true">
                  <svg viewBox="0 0 24 24" role="img" focusable="false" aria-hidden="true">
                    <path d="M7 4h3l1 4-2 1.5a12 12 0 0 0 5.5 5.5L16 13l4 1v3c0 1-1 2-2 2A14 14 0 0 1 4 6c0-1 1-2 3-2z" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                  </svg>
                </span>
                <input class="form-control app-input" [(ngModel)]="applicationForm.phone" name="phone" placeholder="Telephone" required />
              </label>
            </div>
            <div class="col-md-4">
              <label class="input-shell">
                <span class="input-icon" aria-hidden="true">
                  <svg viewBox="0 0 24 24" role="img" focusable="false" aria-hidden="true">
                    <path d="M12 21s6-5.3 6-10a6 6 0 1 0-12 0c0 4.7 6 10 6 10z" fill="none" stroke="currentColor" stroke-width="1.8"/>
                    <circle cx="12" cy="11" r="2.5" fill="none" stroke="currentColor" stroke-width="1.8"/>
                  </svg>
                </span>
                <input class="form-control app-input" [(ngModel)]="applicationForm.city" name="city" placeholder="Ville" required />
              </label>
            </div>
            <div class="col-md-4">
              <label class="input-shell">
                <span class="input-icon" aria-hidden="true">
                  <svg viewBox="0 0 24 24" role="img" focusable="false" aria-hidden="true">
                    <circle cx="12" cy="12" r="9" fill="none" stroke="currentColor" stroke-width="1.8"/>
                    <path d="M3 12h18M12 3a14 14 0 0 1 0 18M12 3a14 14 0 0 0 0 18" fill="none" stroke="currentColor" stroke-width="1.2" stroke-linecap="round"/>
                  </svg>
                </span>
                <input class="form-control app-input" [(ngModel)]="applicationForm.country" name="country" placeholder="Pays" required />
              </label>
            </div>

            <div class="col-md-6">
              <label class="file-input">
                <span class="file-icon" aria-hidden="true">
                  <svg viewBox="0 0 24 24" role="img" focusable="false" aria-hidden="true">
                    <path d="M7 3h6l4 4v14H7z" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/>
                    <path d="M13 3v4h4" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/>
                  </svg>
                </span>
                <div class="file-copy">
                  <strong>CV (PDF)</strong>
                  <span>{{ cvName || 'Choisir un fichier' }}</span>
                </div>
                <input class="file-hidden" type="file" accept=".pdf,.doc,.docx" (change)="onFileChange($event, 'cv')" />
              </label>
            </div>
            <div class="col-md-6">
              <label class="file-input">
                <span class="file-icon" aria-hidden="true">
                  <svg viewBox="0 0 24 24" role="img" focusable="false" aria-hidden="true">
                    <rect x="3" y="6" width="18" height="12" rx="2" fill="none" stroke="currentColor" stroke-width="1.8"/>
                    <path d="M7 10h6M7 14h4" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
                  </svg>
                </span>
                <div class="file-copy">
                  <strong>CIN (scan)</strong>
                  <span>{{ cinName || 'Choisir un fichier' }}</span>
                </div>
                <input class="file-hidden" type="file" accept=".pdf,.jpg,.jpeg,.png" (change)="onFileChange($event, 'cin')" />
              </label>
            </div>
            <div class="col-md-6">
              <label class="file-input">
                <span class="file-icon" aria-hidden="true">
                  <svg viewBox="0 0 24 24" role="img" focusable="false" aria-hidden="true">
                    <path d="M12 5l9 4-9 4-9-4 9-4z" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M6 11v4c0 2 4 3 6 3s6-1 6-3v-4" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                  </svg>
                </span>
                <div class="file-copy">
                  <strong>Diplome (optionnel)</strong>
                  <span>{{ diplomaName || 'Choisir un fichier' }}</span>
                </div>
                <input class="file-hidden" type="file" accept=".pdf,.jpg,.jpeg,.png" (change)="onFileChange($event, 'diploma')" />
              </label>
            </div>

            <div class="col-12" *ngIf="selectedJob()?.type === 'INTERNAL' && selectedJob()?.project">
              <input class="form-control app-input" [value]="selectedJob()?.project" readonly />
            </div>
            <div class="col-12">
              <textarea class="form-control app-input" [(ngModel)]="applicationForm.cover_letter" name="cover_letter" rows="4" placeholder="Lettre de motivation"></textarea>
            </div>
            <div class="col-12" *ngIf="applyError()">
              <div class="alert alert-danger py-2 mb-0">{{ applyError() }}</div>
            </div>
            <div class="col-12"><button class="primary-btn" type="submit">Envoyer ma candidature</button></div>
            </form>
          </div>
        </div>
      </app-shell>
    </ng-container>

    <ng-template #publicJobs>
      <div class="landing-page">
        <header class="marketing-nav">
          <a class="brand-block" routerLink="/">
            <span class="brand-wordmark" aria-label="vermeg">
              <span class="brand-slash">/</span><span class="brand-name">vermeg</span>
            </span>
          </a>
          <div class="d-flex gap-2">
            <a class="ghost-btn" routerLink="/">Accueil</a>
            <a class="primary-btn" routerLink="/auth/login">Connexion</a>
          </div>
        </header>
        <section class="content-section pt-4">
          <div class="section-heading">
            <div>
              <p class="eyebrow">Portail carriere</p>
              <h2 class="section-title">Toutes les offres disponibles</h2>
            </div>
          </div>
          <div class="row g-4">
            <div class="col-xl-4 col-md-6" *ngFor="let job of publicJobsFiltered()">
              <article class="job-card h-100">
                <div class="job-card-top">
                  <span class="chip">{{ job.type }}</span>
                  <span class="small text-secondary">Ouverture {{ job.opening_date | date:'dd/MM/yyyy' }} · Cloture {{ job.closing_date | date:'dd/MM/yyyy' }}</span>
                </div>
                <h3>{{ job.title }}</h3>
                <p class="text-secondary">{{ job.department }} · {{ job.salary_range }}</p>
                <p class="small text-secondary" *ngIf="job.project">Projet: {{ job.project }}</p>
                <p class="job-description">{{ job.description }}</p>
                <a class="text-link mt-auto" routerLink="/auth/login">Se connecter pour postuler</a>
              </article>
            </div>
          </div>
        </section>
      </div>
    </ng-template>
  `
})
export class JobsPageComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly api = inject(ApiService);

  readonly jobs = signal<JobOffer[]>([]);
  readonly showCreate = signal(false);
  readonly selectedJob = signal<JobOffer | null>(null);
  readonly editJob = signal<JobOffer | null>(null);
  readonly departments = signal<{ id: number; name: string; description?: string }[]>([]);
  readonly recruiters = signal<{ id: number; full_name: string; role: string }[]>([]);

  readonly jobForm = {
    title: '',
    department: '',
    description: '',
    salary_range: '',
    project: '',
    requirements: '',
    opening_date: '',
    closing_date: '',
    type: 'INTERNAL',
    status: 'PUBLISHED',
    recruiter_id: null as number | null
  };

  readonly applicationForm = {
    full_name: this.auth.user()?.full_name ?? '',
    email: this.auth.user()?.email ?? '',
    phone: this.auth.user()?.phone ?? '',
    city: this.auth.user()?.city ?? '',
    country: this.auth.user()?.country ?? '',
    cover_letter: '',
    cv_file: '',
    cin_file: '',
    diploma_file: ''
  };
  readonly applyError = signal('');
  cvName = '';
  cinName = '';
  diplomaName = '';

  get canPublish(): boolean {
    return ['HR_ADMIN', 'MANAGER', 'RECRUITER'].includes(this.auth.user()?.role ?? '');
  }

  get jobsSectionTitle(): string {
    const role = this.auth.user()?.role;
    if (role === 'CANDIDATE') return 'Offres externes disponibles';
    if (role === 'EMPLOYEE') return 'Offres internes disponibles';
    return 'Offres internes et externes';
  }

  ngOnInit(): void {
    this.loadJobs();
  }

  loadJobs(): void {
    const user = this.auth.user();
    const load = !user
      ? this.api.getPublicJobs()
      : (user.role === 'CANDIDATE' ? this.api.getPublicJobs() : (this.canPublish ? this.api.getJobs() : this.api.getVisibleJobs()));
    load.subscribe({
      next: (jobs) => this.jobs.set(Array.isArray(jobs) ? jobs : []),
      error: () => this.jobs.set([])
    });

    if (this.canPublish) {
      this.loadMeta();
    }
  }

  saveJob(): void {
    const editing = this.editJob();
    if (this.isManager()) {
      this.jobForm.type = 'INTERNAL';
      this.jobForm.department = this.auth.user()?.department || this.jobForm.department;
    }
    if (!this.jobForm.recruiter_id && (this.isManager() || this.isRecruiter())) {
      this.jobForm.recruiter_id = this.auth.user()?.id ?? null;
    }
    const action = editing ? this.api.updateJob(editing.id, this.jobForm) : this.api.createJob(this.jobForm);
    action.subscribe({
      next: () => {
        this.resetJobForm();
        this.loadJobs();
      }
    });
  }

  selectJob(job: JobOffer): void {
    this.selectedJob.set(job);
  }

  toggleCreate(): void {
    this.showCreate.set(!this.showCreate());
    if (!this.showCreate()) {
      this.cancelEdit();
    }
  }

  startEdit(job: JobOffer): void {
    this.editJob.set(job);
    this.showCreate.set(true);
    this.jobForm.title = job.title;
    this.jobForm.department = job.department;
    this.jobForm.description = job.description;
    this.jobForm.salary_range = job.salary_range;
    this.jobForm.project = job.project || '';
    this.jobForm.requirements = job.requirements;
    this.jobForm.opening_date = job.opening_date || '';
    this.jobForm.closing_date = job.closing_date;
    this.jobForm.type = job.type;
    this.jobForm.status = job.status || 'PUBLISHED';
    this.jobForm.recruiter_id = job.recruiter_id ?? null;
  }

  cancelEdit(): void {
    this.resetJobForm();
  }

  deleteJob(id: number): void {
    this.api.deleteJob(id).subscribe({
      next: () => this.loadJobs()
    });
  }

  apply(): void {
    const job = this.selectedJob();
    if (!job) {
      return;
    }

    const role = this.auth.user()?.role;
    const dept = this.auth.user()?.department || '';
    if (role === 'EMPLOYEE' && job.type !== 'INTERNAL') {
      this.applyError.set('Les employes peuvent postuler uniquement aux offres internes.');
      return;
    }
    if (role === 'CANDIDATE' && job.type !== 'EXTERNAL') {
      this.applyError.set('Les candidats peuvent postuler uniquement aux offres externes.');
      return;
    }
    if (role === 'EMPLOYEE' && job.type === 'INTERNAL' && job.department && dept && job.department !== dept) {
      this.applyError.set('Cette offre interne est reservee a un autre departement.');
      return;
    }

    if ((role === 'CANDIDATE' || job.type === 'EXTERNAL') && (!this.applicationForm.cv_file || !this.applicationForm.cin_file)) {
      this.applyError.set('Veuillez joindre votre CV et votre CIN.');
      return;
    }

    this.api.applyToJob(job.id, this.applicationForm).subscribe({
      next: () => {
        this.selectedJob.set(null);
        this.applyError.set('');
        this.resetApplicationForm();
      },
      error: (err) => {
        this.applyError.set(err?.error?.error || 'Demande impossible. Verifiez les informations.');
      }
    });
  }

  filteredJobs(): JobOffer[] {
    const list = this.jobs();
    const role = this.auth.user()?.role;
    if (role === 'CANDIDATE') {
      return list.filter((job) => job.type === 'EXTERNAL' && job.status === 'PUBLISHED');
    }
    if (role === 'EMPLOYEE') {
      return list.filter((job) => job.status === 'PUBLISHED' && job.type === 'INTERNAL');
    }
    if (role === 'MANAGER' || role === 'RECRUITER') {
      return list;
    }
    return list;
  }

  publicJobsFiltered(): JobOffer[] {
    return this.jobs().filter((job) => job.type === 'EXTERNAL' && job.status === 'PUBLISHED');
  }

  private resetJobForm(): void {
    this.editJob.set(null);
    this.showCreate.set(false);
    this.jobForm.title = '';
    this.jobForm.department = this.isManager() ? (this.auth.user()?.department || '') : '';
    this.jobForm.description = '';
    this.jobForm.salary_range = '';
    this.jobForm.project = '';
    this.jobForm.requirements = '';
    this.jobForm.opening_date = '';
    this.jobForm.closing_date = '';
    this.jobForm.type = this.isManager() ? 'INTERNAL' : 'INTERNAL';
    this.jobForm.status = 'PUBLISHED';
    this.jobForm.recruiter_id = null;
  }

  private loadMeta(): void {
    this.api.getDepartments().subscribe({
      next: (items) => this.departments.set(Array.isArray(items) ? items : []),
      error: () => this.departments.set([])
    });
    this.api.getUsers().subscribe({
      next: (items) => {
        const safe = Array.isArray(items) ? items : [];
        this.recruiters.set(safe.filter((u) => ['RECRUITER', 'MANAGER', 'HR_ADMIN'].includes(u.role)));
      },
      error: () => this.recruiters.set([])
    });
  }

  statusClass(status: string): string {
    if (status === 'PUBLISHED') return 'is-success';
    if (status === 'DRAFT') return 'is-warning';
    if (status === 'CLOSED') return 'is-danger';
    if (status === 'FILLED') return 'is-success';
    return '';
  }

  statusLabel(status: string): string {
    switch (status) {
      case 'DRAFT':
        return 'Brouillon';
      case 'PUBLISHED':
        return 'Publiee';
      case 'CLOSED':
        return 'Cloturee';
      case 'FILLED':
        return 'Pourvue';
      default:
        return status;
    }
  }

  isHrAdmin(): boolean {
    return this.auth.user()?.role === 'HR_ADMIN';
  }

  canChooseType(): boolean {
    return this.auth.user()?.role === 'HR_ADMIN' || this.auth.user()?.role === 'RECRUITER';
  }

  isManager(): boolean {
    return this.auth.user()?.role === 'MANAGER';
  }

  isRecruiter(): boolean {
    return this.auth.user()?.role === 'RECRUITER';
  }

  private resetApplicationForm(): void {
    this.applicationForm.full_name = this.auth.user()?.full_name ?? '';
    this.applicationForm.email = this.auth.user()?.email ?? '';
    this.applicationForm.phone = this.auth.user()?.phone ?? '';
    this.applicationForm.city = this.auth.user()?.city ?? '';
    this.applicationForm.country = this.auth.user()?.country ?? '';
    this.applicationForm.cover_letter = '';
    this.applicationForm.cv_file = '';
    this.applicationForm.cin_file = '';
    this.applicationForm.diploma_file = '';
    this.cvName = '';
    this.cinName = '';
    this.diplomaName = '';
  }

  onFileChange(event: Event, type: 'cv' | 'cin' | 'diploma'): void {
    const input = event.target as HTMLInputElement;
    const file = input.files?.[0];
    if (!file) {
      return;
    }
    const reader = new FileReader();
    reader.onload = () => {
      const result = typeof reader.result === 'string' ? reader.result : '';
      if (type === 'cv') {
        this.applicationForm.cv_file = result;
        this.cvName = file.name;
      } else if (type === 'cin') {
        this.applicationForm.cin_file = result;
        this.cinName = file.name;
      } else {
        this.applicationForm.diploma_file = result;
        this.diplomaName = file.name;
      }
    };
    reader.readAsDataURL(file);
  }
}
