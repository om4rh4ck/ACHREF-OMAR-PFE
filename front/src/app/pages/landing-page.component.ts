import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { UiIconComponent } from '../components/ui-icon.component';
import { ApiService } from '../services/api.service';
import { AuthService } from '../services/auth.service';
import { JobOffer } from '../models';

@Component({
  selector: 'app-landing-page',
  standalone: true,
  imports: [CommonModule, RouterLink, UiIconComponent],
  template: `
    <div class="landing-page">
      <header class="marketing-nav">
        <a class="brand-block" routerLink="/">
          <span class="brand-wordmark" aria-label="vermeg">
            <span class="brand-slash">/</span><span class="brand-name">vermeg</span>
          </span>
        </a>

        <div class="d-flex gap-2">
          <a class="ghost-btn" routerLink="/jobs">
            <span class="btn-icon"><app-ui-icon name="jobs" /></span>
            Offres
          </a>
          <a class="primary-btn" [routerLink]="auth.user() ? auth.routeForRole(auth.user()!.role) : '/auth/login'">
            <span class="btn-icon"><app-ui-icon [name]="auth.user() ? 'dashboard' : 'role'" /></span>
            {{ auth.user() ? 'Mon espace' : 'Connexion' }}
          </a>
        </div>
      </header>

      <section class="hero-panel hero-modern">
        <div class="hero-copy">
          <p class="eyebrow">Plateforme SIRH VERMEG</p>
          <h1 class="hero-title">L'experience RH digitale de VERMEG, du recrutement <span class="hero-accent">EXTERNE</span> a la decision manageriale.</h1>
          <p class="hero-subtitle">
            Un portail unifie pour les collaborateurs, managers, recruteurs et RH,
            avec suivi des offres, candidatures et communications internes.
          </p>

          <div class="d-flex flex-wrap gap-3 mt-4">
            <a class="primary-btn" routerLink="/jobs">
              <span class="btn-icon"><app-ui-icon name="jobs" /></span>
              Voir les offres
            </a>
            <a class="ghost-btn" routerLink="/auth/login">
              <span class="btn-icon"><app-ui-icon name="dashboard" /></span>
              Acceder a la plateforme
            </a>
          </div>

        </div>

        <div class="hero-visual">
          <div class="hero-frame">
            <div class="hero-frame-top">
              <span class="brand-mini">
                <span class="brand-slash">/</span><span class="brand-name">vermeg</span>
              </span>
              <div class="hero-frame-actions">
                <span class="pill"><app-ui-icon name="notifications" /> Alertes</span>
                <span class="pill primary"><app-ui-icon name="dashboard" /> Tableau</span>
              </div>
            </div>
            <div class="hero-frame-body">
              <div class="frame-sidebar">
                <span class="nav-chip active"><app-ui-icon name="dashboard" /></span>
                <span class="nav-chip"><app-ui-icon name="jobs" /></span>
                <span class="nav-chip"><app-ui-icon name="messages" /></span>
                <span class="nav-chip"><app-ui-icon name="applications" /></span>
              </div>
              <div class="frame-content">
                <div class="frame-card">
                  <div class="frame-title">Offres publiees</div>
                  <div class="frame-value">{{ jobs().length }}</div>
                </div>
                <div class="frame-card">
                  <div class="frame-title">Espaces metier</div>
                  <div class="frame-value">4</div>
                </div>
                <div class="frame-card">
                  <div class="frame-title">Suivi RH</div>
                  <div class="frame-value">24/7</div>
                </div>
                <div class="frame-chart">
                  <span class="chart-line"></span>
                  <span class="chart-line"></span>
                  <span class="chart-line"></span>
                </div>
              </div>
            </div>
          </div>
          <div class="hero-orb"></div>
          <div class="feature-grid hero-feature-grid">
            <article class="feature-card">
              <span class="feature-icon"><app-ui-icon name="users" /></span>
              <h3>Espace candidat</h3>
              <p class="text-secondary">Centralisez votre profil, vos documents et votre suivi.</p>
            </article>
            <article class="feature-card">
              <span class="feature-icon"><app-ui-icon name="jobs" /></span>
              <h3>Recrutement externe</h3>
              <p class="text-secondary">Accedez aux offres publiques et suivez vos candidatures.</p>
            </article>
            <article class="feature-card">
              <span class="feature-icon"><app-ui-icon name="messages" /></span>
              <h3>Communication interne</h3>
              <p class="text-secondary">Facilitez les echanges RH et collaborateurs au quotidien.</p>
            </article>
          </div>
        </div>
      </section>

      <section class="content-section">
        <div class="section-heading">
          <div>
            <p class="eyebrow">Recrutement externe</p>
            <h2 class="section-title">Opportunites disponibles</h2>
          </div>
          <a class="ghost-btn" routerLink="/jobs">Tout voir</a>
        </div>

        <div class="row g-4">
          <div class="col-lg-4 col-md-6" *ngFor="let job of jobs()">
            <article class="job-card h-100">
              <div class="job-card-top">
                <span class="chip">Offre</span>
                <span class="text-secondary small">Cloture {{ job.closing_date | date:'dd/MM/yyyy' }}</span>
              </div>
              <h3>{{ job.title }}</h3>
              <p class="text-secondary">{{ job.department }} · {{ job.salary_range }}</p>
              <p class="job-description">{{ job.description }}</p>
              <a class="text-link mt-auto" routerLink="/jobs">Consulter</a>
            </article>
          </div>
        </div>
      </section>
    </div>
  `
})
export class LandingPageComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly api = inject(ApiService);
  readonly jobs = signal<JobOffer[]>([]);

  ngOnInit(): void {
    this.api.getPublicJobs().subscribe({
      next: (jobs) => this.jobs.set(Array.isArray(jobs) ? jobs : []),
      error: () => this.jobs.set([])
    });
  }
}
