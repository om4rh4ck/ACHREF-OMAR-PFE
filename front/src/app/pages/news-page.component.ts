import { CommonModule } from '@angular/common';
import { Component, DestroyRef, OnInit, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { interval } from 'rxjs';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { AppShellComponent } from '../components/app-shell.component';
import { NewsItem } from '../models';
import { ApiService } from '../services/api.service';
import { AuthService } from '../services/auth.service';

@Component({
  selector: 'app-news-page',
  standalone: true,
  imports: [CommonModule, FormsModule, AppShellComponent],
  template: `
    <app-shell [user]="auth.user()" title="Actualites RH" (logout)="auth.logout()">
      <div class="panel-grid">
        <section class="section-card">
          <div class="section-heading">
            <div>
              <p class="eyebrow">Communication interne</p>
              <h2 class="section-title">Fil d'actualites</h2>
            </div>
          </div>

          <div class="stack-list">
            <article
              class="stack-item stack-item-clickable"
              *ngFor="let item of news()"
              [class.selected]="selectedNewsId() === item.id"
              (click)="openNews(item.id)"
            >
              <div class="d-flex justify-content-between gap-3 flex-wrap">
                <div>
                  <h3 class="mb-2">{{ item.title }}</h3>
                  <p class="text-secondary mb-2">{{ item.content | slice:0:90 }}{{ item.content.length > 90 ? '...' : '' }}</p>
                  <div class="message-meta">{{ item.author_name || 'RH' }} | {{ item.created_at | date:'dd/MM/yyyy HH:mm' }}</div>
                </div>
              </div>
            </article>
            <div class="empty-state" *ngIf="!news().length">Aucune actualite disponible.</div>
          </div>
        </section>

        <section class="section-card" *ngIf="selectedNews(); else publishBlock">
          <div class="section-heading">
            <div>
              <p class="eyebrow">Detail</p>
              <h2 class="section-title">{{ selectedNews()!.title }}</h2>
            </div>
          </div>

          <div class="stack-item">
            <p class="mb-3" style="white-space: pre-line">{{ selectedNews()!.content }}</p>
            <div class="message-meta">{{ selectedNews()!.author_name || 'RH' }} | {{ selectedNews()!.created_at | date:'dd/MM/yyyy HH:mm' }}</div>
          </div>
        </section>

        <ng-template #publishBlock>
          <section class="section-card" *ngIf="canPublish">
            <div class="section-heading">
              <div>
                <p class="eyebrow">Publication</p>
                <h2 class="section-title">Nouvelle annonce</h2>
              </div>
            </div>

            <form class="row g-3" (ngSubmit)="publish()">
              <div class="col-12">
                <input class="form-control app-input" [(ngModel)]="form.title" name="title" placeholder="Titre de l'annonce" required />
              </div>
              <div class="col-12">
                <textarea class="form-control app-input" [(ngModel)]="form.content" name="content" rows="8" placeholder="Contenu de l'actualite" required></textarea>
              </div>
              <div class="col-12">
                <button class="primary-btn w-100" type="submit">Publier</button>
              </div>
            </form>
          </section>
        </ng-template>
      </div>
    </app-shell>
  `
})
export class NewsPageComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly api = inject(ApiService);
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly destroyRef = inject(DestroyRef);

  readonly news = signal<NewsItem[]>([]);
  readonly selectedNewsId = signal<number | null>(null);
  readonly selectedNews = computed(() => this.news().find((item) => item.id === this.selectedNewsId()) ?? null);
  readonly form = {
    title: '',
    content: ''
  };

  get canPublish(): boolean {
    return ['HR_ADMIN', 'MANAGER', 'RECRUITER'].includes(this.auth.user()?.role ?? '');
  }

  ngOnInit(): void {
    this.route.queryParamMap.subscribe((params) => {
      const focus = Number(params.get('focus'));
      this.selectedNewsId.set(Number.isFinite(focus) && focus > 0 ? focus : null);
    });
    this.loadNews();

    interval(20000).pipe(takeUntilDestroyed(this.destroyRef)).subscribe(() => {
      if (this.auth.user()) {
        this.loadNews();
      }
    });
  }

  loadNews(): void {
    this.api.getNews().subscribe({
      next: (items) => {
        const safe = Array.isArray(items) ? items : [];
        this.news.set(safe);
        if (!this.selectedNewsId() && safe.length) {
          this.selectedNewsId.set(safe[0].id);
        }
      },
      error: () => this.news.set([])
    });
  }

  openNews(id: number): void {
    this.selectedNewsId.set(id);
    this.router.navigate([], {
      relativeTo: this.route,
      queryParams: { focus: id },
      queryParamsHandling: 'merge'
    });
  }

  publish(): void {
    if (!this.canPublish) {
      return;
    }

    this.api.publishNews(this.form).subscribe({
      next: (item) => {
        this.form.title = '';
        this.form.content = '';
        this.loadNews();
        if (item?.id) {
          this.openNews(item.id);
        }
      }
    });
  }
}
