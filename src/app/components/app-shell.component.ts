import { CommonModule } from '@angular/common';
import { Component, DestroyRef, EventEmitter, Input, OnInit, Output, computed, inject, signal } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { Router, RouterLink, RouterLinkActive } from '@angular/router';
import { interval, startWith } from 'rxjs';
import { UiIconComponent } from './ui-icon.component';
import { NotificationItem, User } from '../models';
import { ApiService } from '../services/api.service';

interface NavItem {
  label: string;
  route: string;
  icon: string;
  badge?: number | null;
}

@Component({
  selector: 'app-shell',
  standalone: true,
  imports: [CommonModule, RouterLink, RouterLinkActive, UiIconComponent],
  template: `
    <div class="shell-layout">
      <aside class="shell-sidebar">
        <a class="brand-block" routerLink="/">
          <span class="brand-wordmark" aria-label="vermeg">
            <span class="brand-slash">/</span><span class="brand-name">vermeg</span>
          </span>
        </a>

        <nav class="shell-nav">
          <a
            *ngFor="let item of navItems()"
            class="shell-nav-link"
            [routerLink]="item.route"
            routerLinkActive="active-link"
            [routerLinkActiveOptions]="{ exact: item.route !== '/jobs' }"
          >
            <span class="nav-label-wrap">
              <span class="nav-icon"><app-ui-icon [name]="item.icon" /></span>
              <span>{{ item.label }}</span>
            </span>
            <span class="nav-badge" *ngIf="item.badge">{{ item.badge }}</span>
          </a>
        </nav>

        <button class="ghost-btn mt-auto w-100" type="button" (click)="logout.emit()">
          <span class="btn-icon"><app-ui-icon name="logout" /></span>
          Deconnexion
        </button>
      </aside>

      <main class="shell-content">
        <header class="shell-topbar">
          <div class="topbar-main">
            <div>
              <p class="eyebrow">{{ user?.role?.replace('_', ' ') }}</p>
              <h2 class="page-title">{{ title }}</h2>
            </div>

            <div class="topbar-pills">
              <a class="topbar-pill topbar-pill-link" routerLink="/jobs">
                <span class="pill-icon"><app-ui-icon name="jobs" /></span>
                <strong class="pill-count">{{ jobCount() }}</strong>
                Offres
              </a>
              <a class="topbar-pill topbar-pill-link" routerLink="/messages">
                <span class="pill-icon"><app-ui-icon name="messages" /></span>
                <strong class="pill-count">{{ messageCount() }}</strong>
                Messages
              </a>
              <button class="topbar-pill topbar-pill-btn topbar-pill-alert" type="button" (click)="toggleNotifications()">
                <span class="pill-icon"><app-ui-icon name="notifications" /></span>
                <strong class="pill-count pill-count-alert">{{ unreadNotifications() }}</strong>
                Notifications
              </button>
            </div>
          </div>

          <div class="topbar-side">
            <div class="notifications-panel" *ngIf="notificationsOpen()">
              <div class="notifications-header">
                <span class="fw-semibold">Notifications</span>
                <span class="small text-secondary">{{ unreadNotifications() }} non lues</span>
              </div>

              <div class="stack-list">
              <article class="stack-item notification-item" *ngFor="let item of notifications(); let i = index" [class.is-read]="item.isRead" (click)="onNotificationClick(item)">
                <div class="d-flex justify-content-between gap-2">
                  <div>
                    <div class="fw-semibold">{{ item.type || 'INFO' }}</div>
                    <div class="text-secondary small">{{ item.message }}</div>
                    <div class="message-meta">{{ item.createdAt | date:'dd/MM/yyyy HH:mm' }}</div>
                  </div>
                  <div class="d-flex flex-column align-items-end gap-2">
                    <span class="notif-badge">#{{ i + 1 }}</span>
                    <button class="ghost-btn ghost-btn-sm" type="button" *ngIf="!item.isRead" (click)="markRead(item); $event.stopPropagation()">Lu</button>
                  </div>
                </div>
              </article>
                <div class="empty-state" *ngIf="!notifications().length">Aucune notification.</div>
              </div>
            </div>

            <div class="topbar-user">
              <span class="avatar-pill">
                <ng-container *ngIf="avatarSrc(); else fallbackAvatar">
                  <img [src]="avatarSrc()" alt="Profil" />
                </ng-container>
                <ng-template #fallbackAvatar>{{ initials }}</ng-template>
              </span>
              <div>
                <div class="fw-semibold">{{ user?.full_name }}</div>
                <div class="small text-secondary">{{ user?.email }}</div>
              </div>
            </div>
          </div>
        </header>

        <section class="page-body">
          <ng-content />
        </section>
      </main>
    </div>
  `
})
export class AppShellComponent implements OnInit {
  private readonly api = inject(ApiService);
  private readonly router = inject(Router);
  private readonly destroyRef = inject(DestroyRef);

  @Input() title = 'Tableau de bord';
  @Input() user: User | null = null;
  @Output() readonly logout = new EventEmitter<void>();

  readonly jobCount = signal(0);
  readonly messageCount = signal(0);
  readonly applicationCount = signal(0);
  readonly unreadNotifications = signal(0);
  readonly notifications = signal<NotificationItem[]>([]);
  readonly notificationsOpen = signal(false);

  readonly navItems = computed<NavItem[]>(() => {
    const user = this.user;
    if (!user) {
      return [{ label: 'Offres', route: '/jobs', icon: 'jobs', badge: this.jobCount() }];
    }

    switch (user.role) {
      case 'EMPLOYEE':
        return [
          { label: 'Dashboard', route: '/employee/dashboard', icon: 'dashboard' },
          { label: 'Offres', route: '/jobs', icon: 'jobs', badge: this.jobCount() },
          { label: 'Salaire & Contrat', route: '/requests', icon: 'salary' },
          { label: 'Actualites', route: '/news', icon: 'news' },
          { label: 'Messages', route: '/messages', icon: 'messages', badge: this.messageCount() },
          { label: 'Profil', route: '/profile', icon: 'profile' }
        ];
      case 'MANAGER':
      case 'RECRUITER':
        return [
          { label: 'Dashboard', route: '/manager', icon: 'dashboard' },
          ...(user.role === 'MANAGER' ? [{ label: 'Mon equipe', route: '/team', icon: 'team' }] : []),
          { label: 'Offres', route: '/jobs', icon: 'jobs', badge: this.jobCount() },
          { label: 'Candidatures', route: '/applications', icon: 'applications', badge: this.applicationCount() },
          { label: 'Entretiens', route: '/interviews', icon: 'interviews' },
          { label: 'Actualites', route: '/news', icon: 'news' },
          { label: 'Messages', route: '/messages', icon: 'messages', badge: this.messageCount() },
          { label: 'Profil', route: '/profile', icon: 'profile' }
        ];
      case 'HR_ADMIN':
        return [
          { label: 'Dashboard', route: '/admin-rh', icon: 'dashboard' },
          { label: 'Offres', route: '/jobs', icon: 'jobs', badge: this.jobCount() },
          { label: 'Candidatures', route: '/applications', icon: 'applications', badge: this.applicationCount() },
          { label: 'Entretiens', route: '/interviews', icon: 'interviews' },
          { label: 'Contrats & Salaires', route: '/hr-requests', icon: 'salary' },
          { label: 'Utilisateurs', route: '/users', icon: 'users' },
          { label: 'Actualites', route: '/news', icon: 'news' },
          { label: 'Messages', route: '/messages', icon: 'messages', badge: this.messageCount() },
          { label: 'Profil', route: '/profile', icon: 'profile' }
        ];
      case 'CANDIDATE':
        return [
          { label: 'Dashboard', route: '/candidate', icon: 'dashboard' },
          { label: 'Offres', route: '/jobs', icon: 'jobs', badge: this.jobCount() },
          { label: 'Mes candidatures', route: '/applications', icon: 'applications', badge: this.applicationCount() },
          { label: 'Messages', route: '/messages', icon: 'messages', badge: this.messageCount() },
          { label: 'Profil', route: '/profile', icon: 'profile' }
        ];
      default:
        return [{ label: 'Offres', route: '/jobs', icon: 'jobs', badge: this.jobCount() }];
    }
  });

  ngOnInit(): void {
    this.api.getPublicJobs().subscribe({
      next: (jobs) => this.jobCount.set(Array.isArray(jobs) ? jobs.length : 0),
      error: () => this.jobCount.set(0)
    });

    if (this.user) {
      interval(10000).pipe(startWith(0), takeUntilDestroyed(this.destroyRef)).subscribe(() => {
        this.loadMessageCount();
        this.loadNotifications();
        this.loadApplicationCount();
      });
    }
  }

  loadMessageCount(): void {
    const myId = this.user?.id;
    if (!myId) {
      this.messageCount.set(0);
      return;
    }

    this.api.getMessages().subscribe({
      next: (messages) => {
        const list = Array.isArray(messages) ? messages : [];
        const receivedUnread = list.filter((m: { receiver_id: number; is_read?: boolean }) => m.receiver_id === myId && m.is_read !== true).length;
        this.messageCount.set(receivedUnread);
      },
      error: () => this.messageCount.set(0)
    });
  }

  loadNotifications(): void {
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

  loadApplicationCount(): void {
    this.api.getApplications().subscribe({
      next: (items) => {
        const list = Array.isArray(items) ? items : [];
        this.applicationCount.set(list.length);
      },
      error: () => this.applicationCount.set(0)
    });
  }

  toggleNotifications(): void {
    this.notificationsOpen.set(!this.notificationsOpen());
  }

  markRead(item: NotificationItem): void {
    if (item.isRead) {
      return;
    }

    this.api.markNotificationRead(item.id).subscribe({
      next: () => this.loadNotifications()
    });
  }

  onNotificationClick(item: NotificationItem): void {
    this.notificationsOpen.set(false);

    if (!item.isRead) {
      this.api.markNotificationRead(item.id).subscribe();
    }

    const route = this.notificationRoute(item);
    this.router.navigate(route.path, route.queryParams ? { queryParams: route.queryParams } : undefined);
  }

  private notificationRoute(item: NotificationItem): { path: string[]; queryParams?: Record<string, string | number> } {
    switch ((item.type || '').toUpperCase()) {
      case 'MESSAGE':
        return { path: ['/messages'] };
      case 'INTERVIEW':
      case 'NEWS':
      case 'INFO':
      default:
        return { path: ['/news'] };
    }
  }

  get initials(): string {
    return (this.user?.full_name ?? 'U')
      .split(' ')
      .map((part) => part[0])
      .slice(0, 2)
      .join('')
      .toUpperCase();
  }

  avatarSrc(): string {
    const src = this.user?.avatar_url || this.user?.avatarUrl || '';
    return this.isValidAvatar(src) ? src : '';
  }

  private isValidAvatar(src: string): boolean {
    if (!src) return false;
    return src.startsWith('data:image') || src.startsWith('http://') || src.startsWith('https://');
  }
}
