import { CommonModule } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../services/auth.service';

@Component({
  selector: 'app-login-page',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  template: `
    <div class="auth-page">
      <div class="auth-card">
        <a class="brand-block auth-brand mb-4" routerLink="/">
          <span class="brand-wordmark" aria-label="vermeg">
            <span class="brand-slash">/</span><span class="brand-name">vermeg</span>
          </span>
        </a>

        <p class="eyebrow text-center">Connexion</p>
        <h1 class="text-center page-title mb-2">Acceder a votre espace</h1>
        <p class="text-center text-secondary mb-4">Connectez-vous a votre portail VERMEG SIRH pour acceder a vos services RH.</p>

        <div class="auth-divider"><span>Connectez-vous avec votre compte professionnel</span></div>

        <form class="d-flex flex-column gap-3" (ngSubmit)="submit()">
          <label class="input-shell">
            <span class="input-icon" aria-hidden="true">
              <svg viewBox="0 0 24 24" role="img" focusable="false" aria-hidden="true">
                <rect x="3" y="5" width="18" height="14" rx="2" ry="2" fill="none" stroke="currentColor" stroke-width="1.8"/>
                <path d="M3 7l9 6 9-6" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
            </span>
            <input class="form-control app-input" type="email" [(ngModel)]="email" name="email" placeholder="nom@vermeg.com" required />
          </label>
          <label class="input-shell">
            <span class="input-icon" aria-hidden="true">
              <svg viewBox="0 0 24 24" role="img" focusable="false" aria-hidden="true">
                <rect x="5" y="10" width="14" height="10" rx="2" ry="2" fill="none" stroke="currentColor" stroke-width="1.8"/>
                <path d="M8 10V8a4 4 0 0 1 8 0v2" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
              </svg>
            </span>
            <input class="form-control app-input" type="password" [(ngModel)]="password" name="password" placeholder="Mot de passe" required />
          </label>
          <div class="d-flex justify-content-end">
            <button class="auth-link-btn" type="button" (click)="auth.forgotPassword()">Mot de passe oublie ?</button>
          </div>
          <div *ngIf="error()" class="alert alert-danger py-2 mb-0">{{ error() }}</div>
          <button class="primary-btn w-100" type="submit" [disabled]="loading()">
            {{ loading() ? 'Connexion...' : 'Se connecter' }}
          </button>
        </form>

        <div class="mt-4 pt-4 border-top text-center">
          <p class="small text-secondary mb-2">Pas encore de compte ?</p>
          <a routerLink="/auth/register" class="text-link">Creer un compte candidat</a>
        </div>
      </div>
    </div>
  `
})
export class LoginPageComponent {
  readonly auth = inject(AuthService);
  private readonly router = inject(Router);

  email = '';
  password = '';
  readonly loading = signal(false);
  readonly error = signal('');

  async submit(): Promise<void> {
    this.loading.set(true);
    this.error.set('');
    try {
      const user = await this.auth.login({ email: this.email, password: this.password });
      await this.router.navigateByUrl(this.auth.routeForRole(user.role));
    } catch (e: unknown) {
      const msg = (e as { error?: { error?: string } })?.error?.error;
      this.error.set(msg || 'Identifiants invalides ou backend indisponible.');
    } finally {
      this.loading.set(false);
    }
  }
}
