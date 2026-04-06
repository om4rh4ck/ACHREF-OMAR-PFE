import { CommonModule } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { AppShellComponent } from '../components/app-shell.component';
import { ApiService } from '../services/api.service';
import { AuthService } from '../services/auth.service';

@Component({
  selector: 'app-profile-page',
  standalone: true,
  imports: [CommonModule, FormsModule, AppShellComponent],
  template: `
    <app-shell [user]="auth.user()" title="Mon profil" (logout)="auth.logout()">
      <section class="section-card profile-card">
        <div class="section-heading">
          <div>
            <p class="eyebrow">Informations personnelles</p>
            <h2 class="section-title">Mettre a jour le profil</h2>
          </div>
        </div>

        <form class="row g-3" (ngSubmit)="save()">
          <div class="col-12 d-flex align-items-center gap-3">
            <div class="avatar-large" *ngIf="avatarPreview(); else initials">
              <img [src]="avatarPreview()" alt="Profil" />
            </div>
            <ng-template #initials>
              <div class="avatar-large avatar-large-fallback">{{ initials }}</div>
            </ng-template>
            <div>
              <label class="form-label">Photo de profil</label>
              <input type="file" class="form-control app-input" accept="image/*" (change)="onAvatarSelected($event)" />
              <div class="small text-secondary mt-1">PNG, JPG - 1 Mo max.</div>
            </div>
          </div>
          <div class="col-md-6"><input class="form-control app-input" [(ngModel)]="form.full_name" name="full_name" placeholder="Nom complet" required /></div>
          <div class="col-md-6"><input class="form-control app-input" [(ngModel)]="form.email" name="email" placeholder="Email" disabled /></div>
          <div class="col-md-6"><input class="form-control app-input" [(ngModel)]="form.department" name="department" placeholder="Departement" /></div>
          <div class="col-md-6"><input class="form-control app-input" [(ngModel)]="form.position" name="position" placeholder="Poste" /></div>
          <div class="col-md-6"><input class="form-control app-input" [(ngModel)]="form.phone" name="phone" placeholder="Telephone" /></div>
          <div class="col-md-6"><input class="form-control app-input" [(ngModel)]="form.diploma" name="diploma" placeholder="Diplome" /></div>
          <div class="col-md-6"><input class="form-control app-input" [(ngModel)]="form.country" name="country" placeholder="Pays" /></div>
          <div class="col-md-6"><input class="form-control app-input" [(ngModel)]="form.city" name="city" placeholder="Ville" /></div>
          <div class="col-12" *ngIf="message()">
            <div class="alert alert-success py-2 mb-0">{{ message() }}</div>
          </div>
          <div class="col-12"><button class="primary-btn" type="submit">Enregistrer</button></div>
        </form>
      </section>
    </app-shell>
  `
})
export class ProfilePageComponent {
  readonly auth = inject(AuthService);
  private readonly api = inject(ApiService);
  readonly message = signal('');
  readonly avatarPreview = signal<string>('');

  readonly form = {
    full_name: this.auth.user()?.full_name ?? '',
    email: this.auth.user()?.email ?? '',
    department: this.auth.user()?.department ?? '',
    position: this.auth.user()?.position ?? '',
    phone: this.auth.user()?.phone ?? '',
    diploma: this.auth.user()?.diploma ?? '',
    country: this.auth.user()?.country ?? '',
    city: this.auth.user()?.city ?? '',
    avatar_base64: this.auth.user()?.avatar_url ?? this.auth.user()?.avatarUrl ?? ''
  };

  constructor() {
    const existing = this.form.avatar_base64;
    if (existing) {
      this.avatarPreview.set(existing);
    }
  }

  get initials(): string {
    return (this.form.full_name || this.form.email || 'U')
      .split(' ')
      .map((part) => part[0])
      .slice(0, 2)
      .join('')
      .toUpperCase();
  }

  onAvatarSelected(event: Event): void {
    const input = event.target as HTMLInputElement;
    const file = input.files?.[0];
    if (!file) return;
    if (file.size > 1024 * 1024) {
      this.message.set('Image trop grande (max 1 Mo).');
      return;
    }
    const reader = new FileReader();
    reader.onload = () => {
      const result = typeof reader.result === 'string' ? reader.result : '';
      this.form.avatar_base64 = result;
      this.avatarPreview.set(result);
    };
    reader.readAsDataURL(file);
  }

  save(): void {
    this.api.updateProfile(this.form).subscribe({
      next: ({ user }) => {
        this.auth.user.set(user);
        this.message.set('Profil mis a jour.');
      }
    });
  }
}
