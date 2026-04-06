import { CommonModule } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../services/auth.service';

@Component({
  selector: 'app-register-page',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  template: `
    <div class="auth-page">
      <div class="auth-card auth-card-wide">
        <a class="brand-block auth-brand mb-4" routerLink="/">
          <span class="brand-wordmark" aria-label="vermeg">
            <span class="brand-slash">/</span><span class="brand-name">vermeg</span>
          </span>
        </a>

        <p class="eyebrow text-center">Inscription candidat</p>
        <h1 class="text-center page-title mb-4">Rejoindre VERMEG</h1>

        <div class="social-auth-grid mb-4">
          <button class="social-btn social-google" type="button" (click)="auth.socialLogin('google')">
            <span class="social-icon" aria-hidden="true">
              <svg viewBox="0 0 24 24" role="img" focusable="false" aria-hidden="true">
                <path fill="#EA4335" d="M12 10.2v3.9h5.4c-.2 1.3-1.5 3.9-5.4 3.9A6 6 0 0 1 12 6c1.6 0 2.6.7 3.2 1.3l2.2-2.2C16 3.5 14.2 2.5 12 2.5A9.5 9.5 0 1 0 21.5 12c0-.6-.1-1.1-.2-1.8H12z"/>
                <path fill="#4285F4" d="M21.3 10.2h-9.3v3.9h5.4c-.5 1.4-1.9 2.4-5.4 2.4a6 6 0 0 1 0-12c1.6 0 2.6.7 3.2 1.3l2.2-2.2C16 3.5 14.2 2.5 12 2.5a9.5 9.5 0 1 0 0 19c5.5 0 9.1-3.9 9.1-9.4 0-.6-.1-1.3-.3-1.9z"/>
                <path fill="#FBBC05" d="M5.1 14.3l-3.1 2.4A9.5 9.5 0 0 0 12 21.5c2.8 0 5.2-.9 6.9-2.6l-3.2-2.5c-.9.6-2.1 1-3.7 1a6 6 0 0 1-5.7-4.1z"/>
                <path fill="#34A853" d="M5.1 9.7a6.2 6.2 0 0 1 0-3.4L2 3.9a9.5 9.5 0 0 0 0 8.2l3.1-2.4z"/>
              </svg>
            </span>
            <span>S'inscrire avec Google</span>
          </button>
          <button class="social-btn social-facebook" type="button" (click)="auth.socialLogin('facebook')">
            <span class="social-icon" aria-hidden="true">
              <svg viewBox="0 0 24 24" role="img" focusable="false" aria-hidden="true">
                <path fill="#1877F2" d="M24 12.1C24 5.4 18.6 0 12 0S0 5.4 0 12.1c0 6 4.4 11 10.1 11.9v-8.4H7.1V12h3V9.4c0-3 1.8-4.7 4.5-4.7 1.3 0 2.7.2 2.7.2v3h-1.5c-1.5 0-2 .9-2 1.9V12h3.5l-.6 3.6h-2.9V24C19.6 23.1 24 18.1 24 12.1z"/>
              </svg>
            </span>
            <span>S'inscrire avec Facebook</span>
          </button>
        </div>

        <div class="auth-divider"><span>ou completez le formulaire candidat</span></div>

        <form class="row g-3" (ngSubmit)="submit()">
          <div class="col-md-6">
            <label class="input-shell">
              <span class="input-icon" aria-hidden="true">
                <svg viewBox="0 0 24 24" role="img" focusable="false" aria-hidden="true">
                  <circle cx="12" cy="8" r="4" fill="none" stroke="currentColor" stroke-width="1.8"/>
                  <path d="M4 20c1.7-3.6 5-5.5 8-5.5s6.3 1.9 8 5.5" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
                </svg>
              </span>
              <input class="form-control app-input" [(ngModel)]="form.full_name" name="full_name" placeholder="Nom complet" required />
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
              <input class="form-control app-input" type="email" [(ngModel)]="form.email" name="email" placeholder="Email" required />
            </label>
          </div>
          <div class="col-md-6">
            <label class="input-shell">
              <span class="input-icon" aria-hidden="true">
                <svg viewBox="0 0 24 24" role="img" focusable="false" aria-hidden="true">
                  <rect x="5" y="10" width="14" height="10" rx="2" ry="2" fill="none" stroke="currentColor" stroke-width="1.8"/>
                  <path d="M8 10V8a4 4 0 0 1 8 0v2" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
                </svg>
              </span>
              <input class="form-control app-input" type="password" [(ngModel)]="form.password" name="password" placeholder="Mot de passe" required />
            </label>
          </div>
          <div class="col-md-6">
            <label class="input-shell">
              <span class="input-icon" aria-hidden="true">
                <svg viewBox="0 0 24 24" role="img" focusable="false" aria-hidden="true">
                  <rect x="5" y="10" width="14" height="10" rx="2" ry="2" fill="none" stroke="currentColor" stroke-width="1.8"/>
                  <path d="M8 10V8a4 4 0 0 1 8 0v2" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
                  <path d="M9 15l2 2 4-4" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
              </span>
              <input class="form-control app-input" type="password" [(ngModel)]="confirmPassword" name="confirmPassword" placeholder="Confirmer le mot de passe" required />
            </label>
          </div>
          <div class="col-md-6">
            <label class="input-shell">
              <span class="input-icon" aria-hidden="true">
                <svg viewBox="0 0 24 24" role="img" focusable="false" aria-hidden="true">
                  <path d="M7 4h3l1 4-2 1.5a12 12 0 0 0 5.5 5.5L16 13l4 1v3c0 1-1 2-2 2A14 14 0 0 1 4 6c0-1 1-2 3-2z" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
              </span>
              <input class="form-control app-input" [(ngModel)]="form.phone" name="phone" placeholder="Telephone" />
            </label>
          </div>
          <div class="col-md-6">
            <label class="input-shell">
              <span class="input-icon" aria-hidden="true">
                <svg viewBox="0 0 24 24" role="img" focusable="false" aria-hidden="true">
                  <circle cx="12" cy="12" r="9" fill="none" stroke="currentColor" stroke-width="1.8"/>
                  <path d="M3 12h18M12 3a14 14 0 0 1 0 18M12 3a14 14 0 0 0 0 18" fill="none" stroke="currentColor" stroke-width="1.2" stroke-linecap="round"/>
                </svg>
              </span>
              <input class="form-control app-input" [(ngModel)]="form.country" name="country" placeholder="Pays" />
            </label>
          </div>
          <div class="col-md-6">
            <label class="input-shell">
              <span class="input-icon" aria-hidden="true">
                <svg viewBox="0 0 24 24" role="img" focusable="false" aria-hidden="true">
                  <path d="M12 21s6-5.3 6-10a6 6 0 1 0-12 0c0 4.7 6 10 6 10z" fill="none" stroke="currentColor" stroke-width="1.8"/>
                  <circle cx="12" cy="11" r="2.5" fill="none" stroke="currentColor" stroke-width="1.8"/>
                </svg>
              </span>
              <input class="form-control app-input" [(ngModel)]="form.city" name="city" placeholder="Ville" />
            </label>
          </div>
          <div class="col-md-6">
            <label class="input-shell">
              <span class="input-icon" aria-hidden="true">
                <svg viewBox="0 0 24 24" role="img" focusable="false" aria-hidden="true">
                  <rect x="3" y="7" width="18" height="12" rx="2" ry="2" fill="none" stroke="currentColor" stroke-width="1.8"/>
                  <path d="M9 7V5a3 3 0 0 1 6 0v2" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
                  <path d="M3 12h18" fill="none" stroke="currentColor" stroke-width="1.4"/>
                </svg>
              </span>
              <input class="form-control app-input" [(ngModel)]="form.position" name="position" placeholder="Poste souhaite" />
            </label>
          </div>
          <div class="col-md-6">
            <label class="input-shell">
              <span class="input-icon" aria-hidden="true">
                <svg viewBox="0 0 24 24" role="img" focusable="false" aria-hidden="true">
                  <rect x="4" y="4" width="7" height="7" rx="1.5" fill="none" stroke="currentColor" stroke-width="1.8"/>
                  <rect x="13" y="4" width="7" height="7" rx="1.5" fill="none" stroke="currentColor" stroke-width="1.8"/>
                  <rect x="4" y="13" width="7" height="7" rx="1.5" fill="none" stroke="currentColor" stroke-width="1.8"/>
                  <rect x="13" y="13" width="7" height="7" rx="1.5" fill="none" stroke="currentColor" stroke-width="1.8"/>
                </svg>
              </span>
              <input class="form-control app-input" [(ngModel)]="form.department" name="department" placeholder="Departement" />
            </label>
          </div>
          <div class="col-12">
            <label class="input-shell">
              <span class="input-icon" aria-hidden="true">
                <svg viewBox="0 0 24 24" role="img" focusable="false" aria-hidden="true">
                  <path d="M12 5l9 4-9 4-9-4 9-4z" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                  <path d="M6 11v4c0 2 4 3 6 3s6-1 6-3v-4" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
              </span>
              <input class="form-control app-input" [(ngModel)]="form.diploma" name="diploma" placeholder="Diplome" />
            </label>
          </div>
          <div class="col-12" *ngIf="error()">
            <div class="alert alert-danger py-2 mb-0">{{ error() }}</div>
          </div>
          <div class="col-12" *ngIf="success()">
            <div class="alert alert-success py-2 mb-0">{{ success() }}</div>
          </div>
          <div class="col-12">
            <button class="primary-btn w-100" type="submit" [disabled]="loading()">
              {{ loading() ? 'Creation...' : 'Creer mon compte' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  `
})
export class RegisterPageComponent {
  readonly auth = inject(AuthService);
  private readonly router = inject(Router);

  readonly loading = signal(false);
  readonly error = signal('');
  readonly success = signal('');
  confirmPassword = '';
  readonly form = {
    full_name: '',
    email: '',
    password: '',
    phone: '',
    country: '',
    city: '',
    position: '',
    department: '',
    diploma: ''
  };

  async submit(): Promise<void> {
    this.loading.set(true);
    this.error.set('');
    this.success.set('');
    const fullName = this.form.full_name.trim();
    const nameParts = fullName.split(/\s+/).filter(Boolean);
    if (nameParts.length < 2) {
      this.error.set('Le nom complet doit contenir au moins deux mots (prenom + nom).');
      this.loading.set(false);
      return;
    }
    this.form.full_name = nameParts.join(' ');
    if (this.form.password !== this.confirmPassword) {
      this.error.set('La confirmation du mot de passe ne correspond pas.');
      this.loading.set(false);
      return;
    }
    try {
      const user = await this.auth.register(this.form);
      if (user) {
        await this.router.navigateByUrl(this.auth.routeForRole(user.role));
      } else {
        this.success.set('Compte cree. Veuillez vous connecter.');
        await this.router.navigateByUrl('/auth/login');
      }
    } catch (e: unknown) {
      const msg = (e as { error?: { error?: string } })?.error?.error;
      this.error.set(msg || 'Inscription impossible. Verifiez la configuration du service.');
    } finally {
      this.loading.set(false);
    }
  }
}
