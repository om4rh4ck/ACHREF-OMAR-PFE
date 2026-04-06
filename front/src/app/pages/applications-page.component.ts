import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal, computed } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { AppShellComponent } from '../components/app-shell.component';
import { Application } from '../models';
import { ApiService } from '../services/api.service';
import { AuthService } from '../services/auth.service';

@Component({
  selector: 'app-applications-page',
  standalone: true,
  imports: [CommonModule, FormsModule, AppShellComponent],
  template: `
    <app-shell [user]="auth.user()" title="Candidatures" (logout)="auth.logout()">
      <section class="section-card applications-page">
        <div class="section-heading">
          <div>
            <p class="eyebrow">{{ canModerate ? 'Validation RH / manager' : 'Suivi candidat' }}</p>
            <h2 class="section-title">{{ canModerate ? 'Pipeline de recrutement' : 'Mes candidatures' }}</h2>
          </div>
        </div>

        <div class="mb-3" *ngIf="canModerate">
          <input type="text" class="form-control app-input" placeholder="Rechercher (candidat, email, poste...)" [ngModel]="searchQuery()" (ngModelChange)="searchQuery.set($event)" />
        </div>

        <div class="data-table-wrap" *ngIf="filteredApplications().length; else empty">
          <table class="data-table">
            <thead>
              <tr>
                <th>Poste</th>
                <th>Candidat</th>
                <th>Coordonnees</th>
                <th>Date</th>
                <th>Statut</th>
                <th>Details</th>
                <th *ngIf="canModerate">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr *ngFor="let item of filteredApplications()" [class.row-rejected]="item.status === 'REJECTED'">
                <td>
                  <div class="fw-semibold">{{ item.job_title || 'Offre interne' }}</div>
                  <div class="small text-secondary">{{ item.cover_letter || 'Aucune lettre jointe' }}</div>
                </td>
                <td>
                  <div class="fw-semibold">{{ item.full_name }}</div>
                  <div class="small text-secondary">{{ item.email }}</div>
                </td>
                <td>{{ item.phone }}<br /><span class="small text-secondary">{{ item.city }}, {{ item.country }}</span></td>
                <td>{{ item.applied_at | date:'dd/MM/yyyy HH:mm' }}</td>
                <td><span class="status-badge" [ngClass]="statusClass(item.status)">{{ statusLabel(item.status) }}</span></td>
                <td>
                  <button class="ghost-btn ghost-btn-sm" type="button" (click)="openDetails(item)">Voir</button>
                </td>
                <td *ngIf="canModerate">
                  <div class="inline-actions">
                    <button class="ghost-btn" type="button" (click)="updateStatus(item.id, 'REJECTED')">Refuser</button>
                    <button class="primary-btn" type="button" (click)="updateStatus(item.id, 'APPROVED')">Valider</button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <ng-template #empty>
          <div class="empty-state">Aucune candidature disponible.</div>
        </ng-template>
      </section>

      <div class="modal-overlay" *ngIf="selectedApplication()" (click)="selectedApplication.set(null)">
        <div class="modal-card modal-card-wide" (click)="$event.stopPropagation()">
          <div class="section-heading">
            <div>
              <p class="eyebrow">Candidat</p>
              <h2 class="section-title">{{ selectedApplication()!.full_name }}</h2>
              <p class="text-secondary mb-0">{{ selectedApplication()!.email }} · {{ selectedApplication()!.phone }}</p>
            </div>
            <button class="ghost-btn" type="button" (click)="selectedApplication.set(null)">Fermer</button>
          </div>

          <div class="row g-3">
            <div class="col-md-6">
              <div class="stack-item">
                <div class="fw-semibold">Profil</div>
                <div class="text-secondary small">Ville: {{ selectedApplication()!.city }}</div>
                <div class="text-secondary small">Pays: {{ selectedApplication()!.country }}</div>
                <div class="text-secondary small">Poste: {{ selectedApplication()!.job_title || 'Offre' }}</div>
                <div class="text-secondary small">Date: {{ selectedApplication()!.applied_at | date:'dd/MM/yyyy HH:mm' }}</div>
              </div>
            </div>
            <div class="col-md-6">
              <div class="stack-item">
                <div class="fw-semibold">Documents</div>
                <div class="inline-actions mt-2">
                  <button class="ghost-btn ghost-btn-sm doc-btn doc-btn-cv" type="button" *ngIf="docUrl(selectedApplication()!, 'cv')" (click)="openDoc(selectedApplication()!, 'cv')">CV</button>
                  <button class="ghost-btn ghost-btn-sm doc-btn doc-btn-cin" type="button" *ngIf="docUrl(selectedApplication()!, 'cin')" (click)="openDoc(selectedApplication()!, 'cin')">CIN</button>
                  <button class="ghost-btn ghost-btn-sm doc-btn doc-btn-diploma" type="button" *ngIf="docUrl(selectedApplication()!, 'diploma')" (click)="openDoc(selectedApplication()!, 'diploma')">Diplome</button>
                </div>
                <div class="text-secondary small mt-2" *ngIf="!docUrl(selectedApplication()!, 'cv') && !docUrl(selectedApplication()!, 'cin') && !docUrl(selectedApplication()!, 'diploma')">
                  Aucun document joint.
                </div>
              </div>
            </div>
            <div class="col-12">
              <div class="stack-item">
                <div class="fw-semibold">Lettre de motivation</div>
                <p class="text-secondary mb-0">{{ selectedApplication()!.cover_letter || 'Aucune lettre jointe.' }}</p>
              </div>
            </div>
          </div>

          <div class="d-flex justify-content-end gap-2 mt-3" *ngIf="canModerate">
            <button class="ghost-btn" type="button" (click)="updateStatus(selectedApplication()!.id, 'REJECTED')">Refuser</button>
            <button class="primary-btn" type="button" (click)="updateStatus(selectedApplication()!.id, 'APPROVED')">Valider</button>
          </div>
        </div>
      </div>
    </app-shell>
  `
})
export class ApplicationsPageComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly api = inject(ApiService);
  readonly applications = signal<Application[]>([]);
  readonly selectedApplication = signal<Application | null>(null);
  searchQuery = signal('');

  readonly filteredApplications = computed(() => {
    const list = [...this.applications()];
    list.sort((a, b) => new Date(b.applied_at).getTime() - new Date(a.applied_at).getTime());
    const q = (this.searchQuery() || '').toLowerCase().trim();
    if (!q) {
      const rejected = list.filter((a) => a.status === 'REJECTED');
      const others = list.filter((a) => a.status !== 'REJECTED');
      return [...others, ...rejected];
    }
    const filtered = list.filter(
      (a) =>
        (a.full_name && a.full_name.toLowerCase().includes(q)) ||
        (a.email && a.email.toLowerCase().includes(q)) ||
        (a.job_title && a.job_title.toLowerCase().includes(q)) ||
        (a.cover_letter && a.cover_letter.toLowerCase().includes(q))
    );
    const rejected = filtered.filter((a) => a.status === 'REJECTED');
    const others = filtered.filter((a) => a.status !== 'REJECTED');
    return [...others, ...rejected];
  });

  get canModerate(): boolean {
    return ['HR_ADMIN', 'MANAGER', 'RECRUITER'].includes(this.auth.user()?.role ?? '');
  }

  ngOnInit(): void {
    this.loadApplications();
  }

  loadApplications(): void {
    this.api.getApplications().subscribe({
      next: (items) => this.applications.set(Array.isArray(items) ? items : []),
      error: () => this.applications.set([])
    });
  }

  updateStatus(id: number, status: string): void {
    if (!this.canModerate) {
      return;
    }

    this.api.updateApplicationStatus(id, status).subscribe({
      next: () => this.loadApplications()
    });
  }

  openDetails(item: Application): void {
    this.selectedApplication.set(item);
  }

  docUrl(item: Application, type: 'cv' | 'cin' | 'diploma'): string {
    if (type === 'cv') return item.cv_file || item.cvFile || '';
    if (type === 'cin') return item.cin_file || item.cinFile || '';
    return item.diploma_file || item.diplomaFile || '';
  }

  openDoc(item: Application, type: 'cv' | 'cin' | 'diploma'): void {
    const url = this.docUrl(item, type);
    if (!url) {
      return;
    }

    if (url.startsWith('data:')) {
      const match = url.match(/^data:(.*?);base64,(.*)$/);
      if (!match) {
        window.open(url, '_blank');
        return;
      }
      const mime = match[1] || 'application/octet-stream';
      const base64 = match[2];
      const binary = atob(base64);
      const len = binary.length;
      const bytes = new Uint8Array(len);
      for (let i = 0; i < len; i += 1) {
        bytes[i] = binary.charCodeAt(i);
      }
      const blob = new Blob([bytes], { type: mime });
      const objectUrl = URL.createObjectURL(blob);
      window.open(objectUrl, '_blank');
      setTimeout(() => URL.revokeObjectURL(objectUrl), 10000);
      return;
    }

    window.open(url, '_blank');
  }

  statusClass(status: string): string {
    if (['APPROVED', 'HIRED'].includes(status)) return 'is-success';
    if (['PENDING', 'SHORTLISTED', 'INTERVIEW_SCHEDULED'].includes(status)) return 'is-warning';
    if (status === 'REJECTED') return 'is-danger';
    return '';
  }

  statusLabel(status: string): string {
    switch (status) {
      case 'PENDING':
      case 'SHORTLISTED':
        return 'En attente';
      case 'APPROVED':
        return 'Valide';
      case 'INTERVIEW_SCHEDULED':
        return 'Entretien planifie';
      case 'REJECTED':
        return 'Refuse';
      case 'HIRED':
        return 'Recrute';
      default:
        return status;
    }
  }
}
