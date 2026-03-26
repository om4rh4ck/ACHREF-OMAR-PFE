import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { of, switchMap } from 'rxjs';
import { AppShellComponent } from '../components/app-shell.component';
import { Application, Interview, User } from '../models';
import { ApiService } from '../services/api.service';
import { AuthService } from '../services/auth.service';

@Component({
  selector: 'app-interviews-page',
  standalone: true,
  imports: [CommonModule, FormsModule, AppShellComponent],
  template: `
    <app-shell [user]="auth.user()" title="Entretiens" (logout)="auth.logout()">
      <div class="panel-grid">
        <section class="section-card">
          <div class="section-heading">
            <div>
              <p class="eyebrow">Planning recrutement</p>
              <h2 class="section-title">Entretiens planifies</h2>
            </div>
          </div>

          <div class="stack-list" *ngIf="interviews().length; else noInterview">
            <article class="stack-item" *ngFor="let interview of interviews()">
              <div class="d-flex justify-content-between gap-3 flex-wrap">
                <div>
                  <h3>{{ interview.candidate_name || 'Candidat' }}</h3>
                  <p class="text-secondary mb-2">{{ interview.job_title || 'Offre interne' }}</p>
                  <div class="message-meta">{{ interview.date | date:'dd/MM/yyyy HH:mm' }}</div>
                </div>
                <div class="text-end">
                  <span class="status-badge" [ngClass]="statusClass(interview.status)">{{ interview.status }}</span>
                  <div class="small text-secondary mt-2" *ngIf="interview.score">Score: {{ interview.score }}/100</div>
                </div>
              </div>

              <div class="row g-3 mt-2">
                <div class="col-md-4">
                  <input class="form-control app-input" type="number" min="0" max="100" [(ngModel)]="drafts[interview.id].score" [name]="'score-' + interview.id" placeholder="Score" />
                </div>
                <div class="col-md-5">
                  <input class="form-control app-input" [(ngModel)]="drafts[interview.id].comments" [name]="'comments-' + interview.id" placeholder="Commentaires" />
                </div>
                <div class="col-md-3">
                  <select class="form-select app-input" [(ngModel)]="drafts[interview.id].status" [name]="'status-' + interview.id">
                    <option value="SCHEDULED">SCHEDULED</option>
                    <option value="COMPLETED">COMPLETED</option>
                    <option value="CANCELLED">CANCELLED</option>
                  </select>
                </div>
                <div class="col-12">
                  <button class="primary-btn" type="button" (click)="saveInterview(interview.id)">Mettre a jour</button>
                </div>
              </div>
            </article>
          </div>

          <ng-template #noInterview>
            <div class="empty-state">Aucun entretien programme.</div>
          </ng-template>
        </section>

        <section class="section-card">
          <div class="section-heading">
            <div>
              <p class="eyebrow">Planification</p>
              <h2 class="section-title">Nouveau rendez-vous</h2>
            </div>
          </div>

          <form class="row g-3" (ngSubmit)="scheduleInterview()">
            <div class="col-12">
              <select class="form-select app-input" [(ngModel)]="scheduleForm.application_id" name="application_id" required>
                <option [ngValue]="0" disabled>Choisir une candidature</option>
                <option *ngFor="let application of applications()" [ngValue]="application.id">
                  {{ application.full_name }} - {{ application.job_title || 'Offre' }}
                </option>
              </select>
            </div>
            <div class="col-12">
              <input class="form-control app-input" type="datetime-local" [(ngModel)]="scheduleForm.date" name="date" required />
            </div>
            <div class="col-12">
              <button class="primary-btn w-100" type="submit">Planifier</button>
            </div>
          </form>
        </section>
      </div>
    </app-shell>
  `
})
export class InterviewsPageComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly api = inject(ApiService);

  readonly interviews = signal<Interview[]>([]);
  readonly applications = signal<Application[]>([]);
  readonly users = signal<User[]>([]);
  drafts: Record<number, { score: number | null; comments: string; status: string }> = {};

  readonly scheduleForm = {
    application_id: 0,
    date: ''
  };

  ngOnInit(): void {
    this.loadData();
  }

  loadData(): void {
    this.api.getInterviews().subscribe({
      next: (items) => {
        const safe = Array.isArray(items) ? items : [];
        this.interviews.set(safe);
        this.drafts = safe.reduce<Record<number, { score: number | null; comments: string; status: string }>>((acc, interview) => {
          acc[interview.id] = {
            score: interview.score ?? null,
            comments: interview.comments ?? '',
            status: interview.status ?? 'SCHEDULED'
          };
          return acc;
        }, {});
      },
      error: () => this.interviews.set([])
    });

    this.api.getApplications().subscribe({
      next: (items) => {
        const safe = Array.isArray(items) ? items : [];
        this.applications.set(safe.filter((item) => item.status === 'APPROVED'));
      },
      error: () => this.applications.set([])
    });

    this.api.getUsers().subscribe({
      next: (items) => this.users.set(Array.isArray(items) ? items : []),
      error: () => this.users.set([])
    });
  }

  scheduleInterview(): void {
    if (!this.scheduleForm.application_id) {
      return;
    }

    const application = this.applications().find((item) => item.id === this.scheduleForm.application_id);
    const candidate = this.users().find((user) => user.email === application?.email);
    const scheduledAt = this.scheduleForm.date;

    this.api.scheduleInterview(this.scheduleForm).pipe(
      switchMap(() => {
        if (!application) {
          return of(null);
        }

        const interviewDate = new Date(scheduledAt);
        const when = Number.isNaN(interviewDate.getTime()) ? scheduledAt : interviewDate.toLocaleString('fr-FR');
        const message = `Votre entretien pour ${application.job_title || 'l offre'} est programme le ${when}.`;

        return this.api.publishNews({
          title: 'Rendez-vous d entretien programme',
          content: `Date du rendez-vous : ${when}`
        }).pipe(
          switchMap(() => {
            if (!candidate?.id) {
              return of(null);
            }

            return this.api.createNotification({
              user_id: candidate.id,
              message,
              type: 'INTERVIEW'
            });
          })
        );
      })
    ).subscribe({
      next: () => {
        this.scheduleForm.application_id = 0;
        this.scheduleForm.date = '';
        this.loadData();
      }
    });
  }

  saveInterview(id: number): void {
    const draft = this.drafts[id];
    if (!draft) {
      return;
    }

    this.api.updateInterview(id, {
      score: draft.score ?? undefined,
      comments: draft.comments,
      status: draft.status
    }).subscribe({
      next: () => this.loadData()
    });
  }

  statusClass(status: string): string {
    if (status === 'COMPLETED') return 'is-success';
    if (status === 'CANCELLED') return 'is-danger';
    if (status === 'SCHEDULED') return 'is-warning';
    return '';
  }
}
