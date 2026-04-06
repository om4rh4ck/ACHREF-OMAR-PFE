import { CommonModule } from '@angular/common';
import { Component, DestroyRef, OnInit, inject, signal } from '@angular/core';
import { Router } from '@angular/router';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { interval, startWith } from 'rxjs';
import { AppShellComponent } from '../components/app-shell.component';
import { UiIconComponent } from '../components/ui-icon.component';
import { ApiService } from '../services/api.service';
import { AuthService } from '../services/auth.service';
import { Application, Interview, NewsItem, NotificationItem, Stats, User } from '../models';

@Component({
  selector: 'app-dashboard-page',
  standalone: true,
  imports: [CommonModule, AppShellComponent, UiIconComponent],
  template: `
    <app-shell [user]="user" [title]="pageTitle" (logout)="auth.logout()">
      <section class="dashboard-hero">
        <div>
          <p class="eyebrow">{{ heroEyebrow }}</p>
          <h1 class="dashboard-hero-title">{{ heroTitle }}</h1>
          <p class="dashboard-hero-copy">{{ heroCopy }}</p>
        </div>
        <div class="hero-kpis">
          <div class="hero-kpi-card">
            <span class="kpi-icon"><app-ui-icon name="notifications" /></span>
            <span class="hero-kpi-label">Notifications</span>
            <strong>{{ unreadNotifications() }}</strong>
          </div>
          <div class="hero-kpi-card">
            <span class="kpi-icon"><app-ui-icon name="messages" /></span>
            <span class="hero-kpi-label">Messages</span>
            <strong>{{ messageCount() }}</strong>
          </div>
          <div class="hero-kpi-card">
            <span class="kpi-icon"><app-ui-icon name="jobs" /></span>
            <span class="hero-kpi-label">Offres visibles</span>
            <ng-container *ngIf="!statsLoading(); else kpiSkeleton">
              <strong>{{ jobsCount() }}</strong>
            </ng-container>
            <ng-template #kpiSkeleton>
              <span class="skeleton" style="height:28px;width:64px;display:inline-block;"></span>
            </ng-template>
          </div>
        </div>
      </section>

      <div class="row g-4">
        <div class="col-xl-3 col-md-6">
          <article class="metric-card metric-card-accent h-100">
            <span class="metric-icon"><app-ui-icon [name]="cardOneIcon" /></span>
            <span class="metric-value" *ngIf="!statsLoading(); else metricSkeleton">{{ cardOneValue }}</span>
            <span class="metric-label">{{ cardOneLabel }}</span>
          </article>
        </div>
        <div class="col-xl-3 col-md-6">
          <article class="metric-card h-100">
            <span class="metric-icon"><app-ui-icon [name]="cardTwoIcon" /></span>
            <span class="metric-value" *ngIf="!statsLoading(); else metricSkeleton">{{ cardTwoValue }}</span>
            <span class="metric-label">{{ cardTwoLabel }}</span>
          </article>
        </div>
        <div class="col-xl-3 col-md-6">
          <article class="metric-card h-100">
            <span class="metric-icon"><app-ui-icon [name]="cardThreeIcon" /></span>
            <span class="metric-value" *ngIf="!statsLoading(); else metricSkeleton">{{ cardThreeValue }}</span>
            <span class="metric-label">{{ cardThreeLabel }}</span>
          </article>
        </div>
        <div class="col-xl-3 col-md-6">
          <article class="metric-card h-100">
            <span class="metric-icon"><app-ui-icon [name]="cardFourIcon" /></span>
            <span class="metric-value" *ngIf="!statsLoading(); else metricSkeleton">{{ cardFourValue }}</span>
            <span class="metric-label">{{ cardFourLabel }}</span>
          </article>
        </div>
        <ng-template #metricSkeleton>
          <span class="skeleton" style="height:34px;width:84px;display:inline-block;"></span>
        </ng-template>
      </div>

      <div class="row g-4 mt-3">
        <div class="col-lg-4">
          <section class="section-card h-100">
            <div class="section-heading">
              <div>
                <p class="eyebrow">Alertes</p>
                <h2 class="section-title">Centre de notifications</h2>
              </div>
            </div>
            <div class="stack-list">
              <article class="stack-item notification-item stack-item-clickable" *ngFor="let item of notifications() | slice:0:4" [class.is-read]="item.isRead" (click)="openNotification(item)">
                <span class="stack-icon"><app-ui-icon name="notifications" /></span>
                <div class="fw-semibold">{{ item.type || 'INFO' }}</div>
                <div class="text-secondary small">{{ item.message }}</div>
                <div class="message-meta">{{ item.createdAt | date:'dd/MM/yyyy HH:mm' }}</div>
              </article>
              <div class="empty-state" *ngIf="!notifications().length">Aucune notification recente.</div>
            </div>
          </section>
        </div>

        <div class="col-lg-8">
          <section class="section-card h-100">
            <div class="section-heading">
              <div>
                <p class="eyebrow">Priorites</p>
                <h2 class="section-title">Pilotage rapide</h2>
              </div>
            </div>
            <div class="priority-grid">
              <article class="priority-card">
                <span class="stack-icon"><app-ui-icon [name]="priorityOneIcon" /></span>
                <span class="priority-label">Actions ouvertes</span>
                <strong>{{ priorityOneValue }}</strong>
                <p>{{ priorityOneText }}</p>
              </article>
              <article class="priority-card">
                <span class="stack-icon"><app-ui-icon [name]="priorityTwoIcon" /></span>
                <span class="priority-label">Suivi recrutement</span>
                <strong>{{ priorityTwoValue }}</strong>
                <p>{{ priorityTwoText }}</p>
              </article>
              <article class="priority-card">
                <span class="stack-icon"><app-ui-icon name="messages" /></span>
                <span class="priority-label">Communication</span>
                <strong>{{ messageCount() }}</strong>
                <p>Messages internes a traiter ou a transmettre.</p>
              </article>
            </div>
          </section>
        </div>
      </div>

      <div class="row g-4 mt-1">
        <div class="col-lg-7">
          <section class="section-card h-100">
            <div class="section-heading">
              <div>
                <p class="eyebrow">Actualites</p>
                <h2 class="section-title">Dernieres informations RH</h2>
              </div>
            </div>
            <div class="stack-list">
              <article class="stack-item stack-item-clickable" *ngFor="let item of news()" (click)="openNews(item.id)">
                <span class="stack-icon"><app-ui-icon name="news" /></span>
                <div>
                  <h3>{{ item.title }}</h3>
                  <p class="text-secondary mb-1">{{ item.content }}</p>
                  <span class="small text-secondary">{{ item.author_name || 'RH' }} · {{ item.created_at | date:'dd/MM/yyyy HH:mm' }}</span>
                </div>
              </article>
              <div class="empty-state" *ngIf="!news().length">Aucune actualite disponible.</div>
            </div>
          </section>
        </div>

        <div class="col-lg-5">
          <section class="section-card h-100">
            <div class="section-heading">
              <div>
                <p class="eyebrow">{{ secondarySectionEyebrow }}</p>
                <h2 class="section-title">{{ secondarySectionTitle }}</h2>
              </div>
            </div>

            <div *ngIf="user?.role === 'HR_ADMIN'" class="stack-list">
              <article class="stack-item" *ngFor="let app of applications()">
                <span class="stack-icon"><app-ui-icon name="applications" /></span>
                <div>
                  <h3>{{ app.full_name }}</h3>
                  <p class="text-secondary mb-1">{{ app.job_title }} · {{ app.email }}</p>
                  <span class="status-badge" [ngClass]="statusClass(app.status)">{{ statusLabel(app.status) }}</span>
                </div>
              </article>
            </div>

            <div *ngIf="user?.role === 'MANAGER' || user?.role === 'RECRUITER'" class="stack-list">
              <article class="stack-item" *ngFor="let member of team()">
                <span class="stack-icon"><app-ui-icon name="team" /></span>
                <div>
                  <h3>{{ member.full_name }}</h3>
                  <p class="text-secondary mb-1">{{ member.position }} · {{ member.department }}</p>
                  <span class="small text-secondary">{{ member.email }}</span>
                </div>
              </article>
              <article class="stack-item" *ngIf="teamStats()">
                <span class="stack-icon"><app-ui-icon name="dashboard" /></span>
                <div>
                  <h3>Statistiques d'equipe</h3>
                  <p class="text-secondary mb-1">Effectif: {{ teamStats()!.teamSize }} · Conges en attente: {{ teamStats()!.pendingLeaves }}</p>
                  <p class="text-secondary mb-0">Performance: {{ teamStats()!.performanceAvg }} · Formation: {{ teamStats()!.trainingCompletion }}</p>
                </div>
              </article>
              <button class="primary-btn w-100" type="button" (click)="sendTeamReport()" *ngIf="teamStats()">Envoyer rapport RH</button>
            </div>

            <div *ngIf="user?.role === 'EMPLOYEE'" class="stack-list">
              <article class="stack-item">
                <span class="stack-icon"><app-ui-icon name="mobility" /></span>
                <div>
                  <h3>Mobilite interne</h3>
                  <p class="text-secondary mb-1">Consulte les opportunites ouvertes et les actualites de ton espace.</p>
                </div>
              </article>
            </div>

            <div *ngIf="user?.role === 'CANDIDATE'" class="stack-list">
              <article class="stack-item" *ngFor="let app of applications()">
                <span class="stack-icon"><app-ui-icon name="applications" /></span>
                <div>
                  <h3>{{ app.job_title }}</h3>
                  <p class="text-secondary mb-1">Statut: <span class="status-badge" [ngClass]="statusClass(app.status)">{{ statusLabel(app.status) }}</span></p>
                  <span class="small text-secondary">{{ app.applied_at | date:'dd/MM/yyyy' }}</span>
                </div>
              </article>

              <article class="stack-item" *ngFor="let interview of candidateInterviews()">
                <span class="stack-icon"><app-ui-icon name="interviews" /></span>
                <div>
                  <h3>Entretien planifie</h3>
                  <p class="text-secondary mb-1">{{ interview.job_title || 'Offre' }}</p>
                  <span class="status-badge" [ngClass]="statusClass(interview.status)">{{ statusLabel(interview.status) }}</span>
                  <div class="small text-secondary">{{ interview.date | date:'dd/MM/yyyy HH:mm' }}</div>
                </div>
              </article>
            </div>
          </section>
        </div>
      </div>

      <section class="section-card mt-4" *ngIf="user?.role === 'HR_ADMIN' || user?.role === 'MANAGER' || user?.role === 'RECRUITER'">
        <div class="section-heading">
          <div>
            <p class="eyebrow">Entretiens</p>
            <h2 class="section-title">Planning et suivi</h2>
          </div>
        </div>
        <div class="row g-3">
          <div class="col-md-6" *ngFor="let interview of interviews()">
            <article class="job-card">
              <div class="job-card-top">
                <span class="chip">{{ interview.status }}</span>
                <span class="small text-secondary">{{ interview.date | date:'dd/MM/yyyy HH:mm' }}</span>
              </div>
              <span class="stack-icon"><app-ui-icon name="interviews" /></span>
              <h3>{{ interview.candidate_name }}</h3>
              <p class="text-secondary">{{ interview.job_title }}</p>
              <p class="small text-secondary mb-0" *ngIf="interview.score">Score {{ interview.score }}/100</p>
            </article>
          </div>
        </div>
      </section>
    </app-shell>
  `
})
export class DashboardPageComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly api = inject(ApiService);
  private readonly router = inject(Router);
  private readonly destroyRef = inject(DestroyRef);
  readonly user = this.auth.user();

  readonly stats = signal<Stats | null>(null);
  readonly statsLoading = signal(true);
  readonly jobsCount = signal(0);
  readonly applicationsCount = signal(0);
  readonly news = signal<NewsItem[]>([]);
  readonly team = signal<User[]>([]);
  readonly teamStats = signal<{ teamSize: number; pendingLeaves: number; performanceAvg: string; trainingCompletion: string } | null>(null);
  readonly applications = signal<Application[]>([]);
  readonly interviews = signal<Interview[]>([]);
  readonly notifications = signal<NotificationItem[]>([]);
  readonly messageCount = signal(0);
  readonly unreadNotifications = signal(0);

  get pageTitle(): string {
    switch (this.user?.role) {
      case 'HR_ADMIN':
        return 'Espace RH';
      case 'MANAGER':
      case 'RECRUITER':
        return 'Espace manager';
      case 'CANDIDATE':
        return 'Espace candidat';
      default:
        return 'Tableau de bord employe';
    }
  }

  get cardOneLabel(): string {
    if (this.user?.role === 'CANDIDATE') return 'Mes candidatures';
    if (this.user?.role === 'EMPLOYEE') return 'Salaire';
    return 'Effectif';
  }
  get cardOneValue(): string | number {
    if (this.user?.role === 'CANDIDATE') return this.applications().length;
    if (this.user?.role === 'EMPLOYEE') {
      const salary = this.user?.salary;
      return salary !== null && salary !== undefined ? `${salary} DT` : 'Non defini';
    }
    return this.stats()?.employees ?? 0;
  }
  get cardOneIcon(): string {
    if (this.user?.role === 'CANDIDATE') return 'applications';
    if (this.user?.role === 'EMPLOYEE') return 'salary';
    return 'users';
  }
  get cardTwoLabel(): string {
    if (this.user?.role === 'MANAGER') return 'Projet';
    return this.user?.role === 'EMPLOYEE' ? 'Conges disponibles' : 'Offres ouvertes';
  }
  get cardTwoValue(): string | number {
    if (this.user?.role === 'MANAGER') return this.user?.project || 'Non defini';
    return this.user?.role === 'EMPLOYEE' ? `${this.user?.leave_balance ?? 25} j` : this.jobsCount();
  }
  get cardTwoIcon(): string {
    if (this.user?.role === 'MANAGER') return 'project';
    return this.user?.role === 'EMPLOYEE' ? 'leave' : 'jobs';
  }
  get cardThreeLabel(): string { return this.user?.role === 'MANAGER' ? 'Mon equipe' : 'Candidatures'; }
  get cardThreeValue(): string | number {
    if (this.user?.role === 'MANAGER') return this.team().length;
    if (this.user?.role === 'HR_ADMIN' || this.user?.role === 'RECRUITER') return this.applicationsCount();
    return this.applications().length;
  }
  get cardThreeIcon(): string { return this.user?.role === 'MANAGER' ? 'team' : 'applications'; }
  get cardFourLabel(): string {
    if (this.user?.role === 'HR_ADMIN') return 'Mobilite interne';
    if (this.user?.role === 'EMPLOYEE') return 'Contrat';
    if (this.user?.role === 'MANAGER') return 'Budget';
    return 'Role';
  }
  get cardFourValue(): string | number {
    if (this.user?.role === 'HR_ADMIN') return this.stats()?.mobilityRate ?? '18%';
    if (this.user?.role === 'EMPLOYEE') return this.user?.contract_type || this.user?.contractType || 'Non defini';
    if (this.user?.role === 'MANAGER') {
      const budget = this.user?.budget;
      return budget !== null && budget !== undefined ? `${budget} DT` : 'Non defini';
    }
    return this.user?.role ?? '-';
  }
  get cardFourIcon(): string {
    if (this.user?.role === 'HR_ADMIN') return 'mobility';
    if (this.user?.role === 'EMPLOYEE') return 'contract';
    if (this.user?.role === 'MANAGER') return 'budget';
    return 'role';
  }

  get secondarySectionEyebrow(): string {
    if (this.user?.role === 'HR_ADMIN') return 'Validation RH';
    if (this.user?.role === 'CANDIDATE') return 'Suivi';
    if (this.user?.role === 'EMPLOYEE') return 'Actions';
    return 'Equipe';
  }

  get secondarySectionTitle(): string {
    if (this.user?.role === 'HR_ADMIN') return 'Candidatures recentes';
    if (this.user?.role === 'CANDIDATE') return 'Mes candidatures';
    if (this.user?.role === 'EMPLOYEE') return 'Mes priorites';
    return 'Mon equipe';
  }

  get heroEyebrow(): string {
    return this.user?.role === 'HR_ADMIN' ? 'Decision RH' : this.user?.role === 'MANAGER' || this.user?.role === 'RECRUITER' ? 'Management & recrutement' : this.user?.role === 'CANDIDATE' ? 'Suivi de candidature' : 'Experience collaborateur';
  }

  get heroTitle(): string {
    return this.user?.role === 'HR_ADMIN'
      ? 'Piloter les validations, les mobilites et la charge RH.'
      : this.user?.role === 'MANAGER' || this.user?.role === 'RECRUITER'
      ? 'Superviser les equipes et accelerer les recrutements.'
      : this.user?.role === 'CANDIDATE'
      ? 'Suivre vos opportunites et vos candidatures en temps reel.'
      : 'Retrouver vos services RH et opportunites internes dans un seul espace.';
  }

  get heroCopy(): string {
    return 'Chaque tableau de bord concentre les indicateurs critiques, les notifications et les actions prioritaires pour votre role.';
  }

  get priorityOneValue(): string | number {
    if (this.user?.role === 'EMPLOYEE') return `${this.user?.leave_balance ?? 25} j`;
    if (this.user?.role === 'CANDIDATE') return this.applications().length;
    return this.unreadNotifications();
  }

  get priorityOneText(): string {
    if (this.user?.role === 'EMPLOYEE') return 'Solde de conges et demandes RH disponibles.';
    if (this.user?.role === 'CANDIDATE') return 'Dossiers de candidature actuellement suivis.';
    return 'Notifications non traitees sur votre espace.';
  }

  get priorityOneIcon(): string {
    if (this.user?.role === 'EMPLOYEE') return 'leave';
    if (this.user?.role === 'CANDIDATE') return 'applications';
    return 'notifications';
  }

  get priorityTwoValue(): string | number {
    if (this.user?.role === 'HR_ADMIN' || this.user?.role === 'MANAGER' || this.user?.role === 'RECRUITER') return this.interviews().length;
    return this.jobsCount();
  }

  get priorityTwoText(): string {
    if (this.user?.role === 'HR_ADMIN' || this.user?.role === 'MANAGER' || this.user?.role === 'RECRUITER') return 'Entretiens et validations a planifier ou finaliser.';
    return 'Opportunites actuellement ouvertes dans le portail.';
  }

  get priorityTwoIcon(): string {
    return this.user?.role === 'HR_ADMIN' || this.user?.role === 'MANAGER' || this.user?.role === 'RECRUITER' ? 'interviews' : 'jobs';
  }

  statusClass(status: string): string {
    if (['APPROVED', 'HIRED'].includes(status)) return 'is-success';
    if (['PENDING', 'SHORTLISTED', 'INTERVIEW_SCHEDULED', 'SCHEDULED'].includes(status)) return 'is-warning';
    if (status === 'REJECTED') return 'is-danger';
    return '';
  }

  statusLabel(status: string): string {
    switch (status) {
      case 'PENDING':
      case 'SHORTLISTED':
        return 'En attente';
      case 'APPROVED':
        return 'Accepte';
      case 'SCHEDULED':
        return 'Entretien planifie';
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

  ngOnInit(): void {
    this.api.getStats().subscribe({
      next: (stats) => {
        this.stats.set(stats);
        this.statsLoading.set(false);
      },
      error: () => {
        this.stats.set(null);
        this.statsLoading.set(false);
      }
    });
    this.api.getNews().subscribe({ next: (items) => this.news.set(items), error: () => this.news.set([]) });
    interval(10000).pipe(startWith(0), takeUntilDestroyed(this.destroyRef)).subscribe(() => {
      this.loadMessageCount();
      this.loadNotifications();
      this.loadDashboardCounts();
    });

    if (this.user?.role === 'MANAGER' || this.user?.role === 'RECRUITER') {
      this.api.getTeam().subscribe({ next: (members) => this.team.set(members), error: () => this.team.set([]) });
      this.api.getTeamStats().subscribe({ next: (stats) => this.teamStats.set(stats), error: () => this.teamStats.set(null) });
    }

    if (this.user?.role === 'HR_ADMIN' || this.user?.role === 'CANDIDATE') {
      this.api.getApplications().subscribe({ next: (items) => this.applications.set(items), error: () => this.applications.set([]) });
    }

    if (this.user?.role === 'HR_ADMIN' || this.user?.role === 'MANAGER' || this.user?.role === 'RECRUITER' || this.user?.role === 'CANDIDATE') {
      this.api.getInterviews().subscribe({ next: (items) => this.interviews.set(items), error: () => this.interviews.set([]) });
    }

    this.loadDashboardCounts();
  }

  candidateInterviews(): Interview[] {
    if (this.user?.role !== 'CANDIDATE') {
      return [];
    }
    const email = this.user?.email ?? '';
    const name = this.user?.full_name ?? '';
    return this.interviews().filter((i) =>
      (i.candidate_email && i.candidate_email === email) ||
      (i.candidateEmail && i.candidateEmail === email) ||
      (i.candidate_name && i.candidate_name === name)
    );
  }

  sendTeamReport(): void {
    const stats = this.teamStats();
    if (!stats) {
      return;
    }
    const title = `Rapport equipe - ${this.user?.full_name ?? 'Manager'}`;
    const content = `Effectif: ${stats.teamSize}. Conges en attente: ${stats.pendingLeaves}. Performance: ${stats.performanceAvg}. Formation: ${stats.trainingCompletion}.`;
    this.api.publishNews({ title, content }).subscribe();
  }

  private loadMessageCount(): void {
    this.api.getMessages().subscribe({
      next: (items) => {
        const list = Array.isArray(items) ? items : [];
        const myId = this.user?.id;
        const receivedUnread = myId ? list.filter((m: { receiver_id: number; is_read?: boolean }) => m.receiver_id === myId && m.is_read !== true).length : 0;
        this.messageCount.set(receivedUnread);
      },
      error: () => this.messageCount.set(0)
    });
  }

  private loadNotifications(): void {
    this.api.getNotifications().subscribe({
      next: (items) => {
        const safe = Array.isArray(items) ? items : [];
        this.notifications.set(safe);
        this.unreadNotifications.set(safe.filter((item) => !item.isRead).length);
      },
      error: () => {
        this.notifications.set([]);
        this.unreadNotifications.set(0);
      }
    });
  }

  private loadDashboardCounts(): void {
    if (this.user?.role === 'HR_ADMIN' || this.user?.role === 'RECRUITER' || this.user?.role === 'MANAGER') {
      this.api.getJobs().subscribe({ next: (items) => this.jobsCount.set(items.length), error: () => this.jobsCount.set(0) });
      this.api.getApplications().subscribe({ next: (items) => this.applicationsCount.set(items.length), error: () => this.applicationsCount.set(0) });
      return;
    }

    if (this.user?.role === 'EMPLOYEE' || this.user?.role === 'CANDIDATE') {
      this.api.getVisibleJobs().subscribe({ next: (items) => this.jobsCount.set(items.length), error: () => this.jobsCount.set(0) });
      if (this.user?.role === 'CANDIDATE') {
        this.api.getApplications().subscribe({ next: (items) => this.applicationsCount.set(items.length), error: () => this.applicationsCount.set(0) });
      }
      return;
    }

    this.jobsCount.set(0);
    this.applicationsCount.set(0);
  }
  openNews(id: number): void {
    this.router.navigate(['/news'], { queryParams: { focus: id } });
  }


  openNotification(item: NotificationItem): void {
    const type = (item.type || '').toUpperCase();
    if (type === 'MESSAGE') {
      this.router.navigate(['/messages']);
      return;
    }

    this.router.navigate(['/news']);
  }
}
