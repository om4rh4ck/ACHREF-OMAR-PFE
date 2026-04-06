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
    <div class="shell-layout" [class.sidebar-collapsed]="isSidebarCollapsed()">
      <aside class="shell-sidebar">
        <div class="sidebar-header">
          <a class="brand-block" routerLink="/">
            <span class="brand-wordmark" aria-label="vermeg">
              <span class="brand-slash">/</span><span class="brand-name">vermeg</span>
            </span>
          </a>
          <button class="icon-btn" type="button" (click)="toggleSidebar()" aria-label="Reduire le menu">
            <app-ui-icon name="menu" />
          </button>
        </div>

        <nav class="shell-nav">
          <a
            *ngFor="let item of navItems(); let idx = index"
            class="shell-nav-link"
            [routerLink]="item.route"
            routerLinkActive="active-link"
            [routerLinkActiveOptions]="{ exact: item.route !== '/jobs' }"
            (click)="onNavClick()"
            [style.animationDelay]="(idx * 60) + 'ms'"
            [attr.title]="isSidebarCollapsed() ? item.label : null"
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
          <span class="btn-label">Deconnexion</span>
        </button>
      </aside>

      <main class="shell-content">
        <header class="shell-topbar">
          <div class="topbar-row topbar-row-main">
            <div class="topbar-title">
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
              <button class="topbar-pill topbar-pill-btn topbar-pill-alert" type="button" (click)="toggleNotifications()" [class.has-unread]="unreadNotifications() > 0">
                <span class="pill-icon"><app-ui-icon name="notifications" /></span>
                <strong class="pill-count pill-count-alert">{{ unreadNotifications() }}</strong>
                Notifications
                <span class="notif-pulse" *ngIf="unreadNotifications() > 0"></span>
              </button>
            </div>

            <div class="search-popover-wrap">
              <button class="icon-btn topbar-search-icon" type="button" aria-label="Rechercher" (click)="toggleSearch()">
                <app-ui-icon name="search" />
              </button>
            </div>

            <div class="topbar-actions">
            <button class="icon-btn" type="button" (click)="toggleTheme()" aria-label="Basculer le theme">
              <app-ui-icon [name]="isDarkMode() ? 'sun' : 'moon'" />
            </button>

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
          </div>
        </header>

        <section class="page-body">
          <ng-content />
        </section>
      </main>
    </div>

    <div class="modal-overlay" *ngIf="notificationsOpen()" (click)="closeNotifications()">
      <div class="modal-card notifications-modal" (click)="$event.stopPropagation()">
        <div class="notifications-header">
          <div>
            <div class="fw-semibold">Notifications</div>
            <div class="small text-secondary">{{ unreadNotifications() }} non lues</div>
          </div>
          <div class="d-flex align-items-center gap-2">
            <button class="ghost-btn ghost-btn-sm" type="button" (click)="markAllNotificationsRead()" [disabled]="unreadNotifications() === 0">Tout marquer lu</button>
            <button class="icon-btn" type="button" (click)="closeNotifications()" aria-label="Fermer">
              <app-ui-icon name="close" />
            </button>
          </div>
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
    </div>

    <div class="modal-overlay" *ngIf="searchOpen()" (click)="closeSearch()">
      <div class="modal-card search-modal" (click)="$event.stopPropagation()">
        <div class="notifications-header">
          <div>
            <div class="fw-semibold">Recherche</div>
            <div class="small text-secondary">Trouver rapidement</div>
          </div>
          <button class="icon-btn" type="button" (click)="closeSearch()" aria-label="Fermer">
            <app-ui-icon name="close" />
          </button>
        </div>
        <div class="search-modal-body">
          <span class="search-icon"><app-ui-icon name="search" /></span>
          <input class="form-control app-input" type="search" placeholder="Rechercher..." />
        </div>
      </div>
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
  private lastMessageCount = 0;
  private lastApplicationCount = 0;
  private lastUnreadNotifications = 0;
  readonly notifications = signal<NotificationItem[]>([]);
  readonly notificationsOpen = signal(false);
  readonly isSidebarCollapsed = signal(false);
  readonly isDarkMode = signal(false);
  readonly searchOpen = signal(false);

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
    this.initUiPrefs();
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

  toggleSidebar(): void {
    const next = !this.isSidebarCollapsed();
    this.isSidebarCollapsed.set(next);
    try {
      localStorage.setItem('ui.sidebarCollapsed', next ? '1' : '0');
    } catch {
      // ignore
    }
  }

  onNavClick(): void {
    if (this.isSidebarCollapsed()) {
      this.isSidebarCollapsed.set(false);
      try {
        localStorage.setItem('ui.sidebarCollapsed', '0');
      } catch {
        // ignore
      }
    }
  }

  toggleTheme(): void {
    const next = !this.isDarkMode();
    this.isDarkMode.set(next);
    this.applyTheme(next);
    try {
      localStorage.setItem('ui.darkMode', next ? '1' : '0');
    } catch {
      // ignore
    }
  }

  toggleSearch(): void {
    this.searchOpen.set(!this.searchOpen());
  }

  closeSearch(): void {
    this.searchOpen.set(false);
  }

  private initUiPrefs(): void {
    try {
      const collapsed = localStorage.getItem('ui.sidebarCollapsed') === '1';
      const dark = localStorage.getItem('ui.darkMode') === '1';
      this.isSidebarCollapsed.set(collapsed);
      this.isDarkMode.set(dark);
      this.applyTheme(dark);
    } catch {
      this.applyTheme(false);
    }
  }

  private applyTheme(isDark: boolean): void {
    if (typeof document === 'undefined') return;
    document.body.classList.toggle('theme-dark', isDark);
  }

  private playAlertSound(): void {
    if (typeof window === 'undefined') return;
    try {
      const AudioCtx = (window as any).AudioContext || (window as any).webkitAudioContext;
      if (!AudioCtx) return;
      const ctx = new AudioCtx();
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = 'sine';
      osc.frequency.value = 720;
      gain.gain.value = 0.04;
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.start();
      setTimeout(() => {
        osc.stop();
        ctx.close();
      }, 80);
    } catch {
      // ignore
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
        if (receivedUnread > this.lastMessageCount) {
          this.playAlertSound();
        }
        this.lastMessageCount = receivedUnread;
      },
      error: () => this.messageCount.set(0)
    });
  }

  loadNotifications(): void {
    this.api.getNotifications().subscribe({
      next: (items) => {
        const safe = Array.isArray(items) ? items : [];
        const readIds = this.getStoredReadIds();
        const merged = safe.map((item) =>
          readIds.has(item.id) ? { ...item, isRead: true } : item
        );
        this.notifications.set(merged);
        const unread = merged.filter((item) => !item.isRead).length;
        this.unreadNotifications.set(unread);
        if (unread > this.lastUnreadNotifications) {
          this.playAlertSound();
        }
        this.lastUnreadNotifications = unread;
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
        if (list.length > this.lastApplicationCount) {
          this.playAlertSound();
        }
        this.lastApplicationCount = list.length;
      },
      error: () => this.applicationCount.set(0)
    });
  }

  toggleNotifications(): void {
    this.notificationsOpen.set(!this.notificationsOpen());
  }

  closeNotifications(): void {
    this.notificationsOpen.set(false);
  }

  markRead(item: NotificationItem): void {
    if (item.isRead) {
      return;
    }

    this.storeReadId(item.id);
    this.notifications.update((items) =>
      items.map((notif) => notif.id === item.id ? { ...notif, isRead: true } : notif)
    );
    this.unreadNotifications.set(this.notifications().filter((notif) => !notif.isRead).length);

    this.api.markNotificationRead(item.id).subscribe({
      next: () => this.loadNotifications()
    });
  }

  markAllNotificationsRead(): void {
    const items = this.notifications();
    if (!items.length) return;

    items.forEach((notif) => this.storeReadId(notif.id));
    this.notifications.set(items.map((notif) => ({ ...notif, isRead: true })));
    this.unreadNotifications.set(0);

    items.filter((notif) => !notif.isRead).forEach((notif) => {
      this.api.markNotificationRead(notif.id).subscribe();
    });
  }

  onNotificationClick(item: NotificationItem): void {
    this.notificationsOpen.set(false);

    if (!item.isRead) {
      this.markRead(item);
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

  private readStorageKey(): string {
    const userId = this.user?.id ?? 'anon';
    return `ui.notifications.read.${userId}`;
  }

  private getStoredReadIds(): Set<number> {
    if (typeof localStorage === 'undefined') return new Set();
    try {
      const raw = localStorage.getItem(this.readStorageKey());
      if (!raw) return new Set();
      const parsed = JSON.parse(raw);
      if (!Array.isArray(parsed)) return new Set();
      return new Set(parsed.map((id) => Number(id)).filter((id) => !Number.isNaN(id)));
    } catch {
      return new Set();
    }
  }

  private storeReadId(id: number): void {
    if (typeof localStorage === 'undefined') return;
    try {
      const set = this.getStoredReadIds();
      set.add(id);
      localStorage.setItem(this.readStorageKey(), JSON.stringify(Array.from(set)));
    } catch {
      // ignore
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
