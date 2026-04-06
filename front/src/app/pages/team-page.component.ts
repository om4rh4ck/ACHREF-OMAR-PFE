import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { AppShellComponent } from '../components/app-shell.component';
import { UiIconComponent } from '../components/ui-icon.component';
import { User } from '../models';
import { ApiService } from '../services/api.service';
import { AuthService } from '../services/auth.service';

@Component({
  selector: 'app-team-page',
  standalone: true,
  imports: [CommonModule, FormsModule, AppShellComponent, UiIconComponent],
  template: `
    <app-shell [user]="auth.user()" title="Mon equipe" (logout)="auth.logout()">
      <section class="section-card">
        <div class="section-heading">
          <div>
            <p class="eyebrow">Management</p>
            <h2 class="section-title">Equipe rattachee</h2>
          </div>
        </div>

        <div class="mb-3">
          <input class="form-control app-input" [(ngModel)]="searchTerm" (ngModelChange)="applyFilter()" placeholder="Rechercher un membre..." />
        </div>

        <div class="stack-list">
          <article class="stack-item" *ngFor="let member of filteredTeam()">
            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
              <div class="d-flex align-items-center gap-2">
                <span class="avatar-pill">
                  <ng-container *ngIf="avatarOf(member); else fallbackAvatar">
                    <img [src]="avatarOf(member)" alt="Profil" />
                  </ng-container>
                  <ng-template #fallbackAvatar>{{ initialsFor(member) }}</ng-template>
                </span>
                <div>
                  <div class="fw-semibold">{{ member.full_name }}</div>
                  <div class="small text-secondary">{{ member.email }}</div>
                  <div class="small text-secondary">{{ member.position || 'Poste non defini' }} · {{ member.department || 'Departement' }}</div>
                </div>
              </div>
              <div class="inline-actions">
                <button class="ghost-btn" type="button" (click)="message(member.id)">
                  <span class="btn-icon"><app-ui-icon name="messages" /></span>
                  Messager
                </button>
                <button class="ghost-btn ghost-btn-danger" type="button" (click)="remove(member.id)">
                  <span class="btn-icon"><app-ui-icon name="role" /></span>
                  Supprimer
                </button>
              </div>
            </div>
          </article>
          <div class="empty-state" *ngIf="!filteredTeam().length">Aucun collaborateur dans votre equipe.</div>
        </div>
      </section>
    </app-shell>
  `
})
export class TeamPageComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly api = inject(ApiService);
  private readonly router = inject(Router);
  readonly team = signal<User[]>([]);
  searchTerm = '';

  readonly filteredTeam = signal<User[]>([]);

  ngOnInit(): void {
    this.loadTeam();
  }

  loadTeam(): void {
    this.api.getTeam().subscribe({
      next: (items) => {
        const list = Array.isArray(items) ? items : [];
        this.team.set(list);
        this.applyFilter();
      },
      error: () => {
        this.team.set([]);
        this.applyFilter();
      }
    });
  }

  message(userId: number): void {
    this.router.navigate(['/messages'], { queryParams: { to: userId } });
  }

  remove(userId: number): void {
    if (!confirm('Supprimer cet employe ?')) return;
    this.api.deleteUser(userId).subscribe({
      next: () => this.loadTeam(),
      error: (err) => {
        alert(err.error?.error || 'Suppression impossible');
      }
    });
  }

  applyFilter(): void {
    const q = this.searchTerm.trim().toLowerCase();
    if (!q) {
      this.filteredTeam.set(this.team());
      return;
    }
    this.filteredTeam.set(this.team().filter((m) =>
      [m.full_name, m.email, m.position, m.department].some((val) => (val ?? '').toLowerCase().includes(q))
    ));
  }

  avatarOf(user: User): string {
    const src = user.avatar_url || user.avatarUrl || '';
    return this.isValidAvatar(src) ? src : '';
  }

  initialsFor(user: User): string {
    return (user.full_name ?? user.email ?? 'U')
      .split(' ')
      .map((part) => part[0])
      .slice(0, 2)
      .join('')
      .toUpperCase();
  }

  private isValidAvatar(src: string): boolean {
    if (!src) return false;
    return src.startsWith('data:image') || src.startsWith('http://') || src.startsWith('https://');
  }
}
