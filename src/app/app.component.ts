import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterOutlet } from '@angular/router';
import { AuthService } from './services/auth.service';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, RouterOutlet],
  template: `
    <ng-container *ngIf="!auth.loading(); else splash">
      <router-outlet />
    </ng-container>

    <ng-template #splash>
      <div class="app-splash">
        <span class="brand-wordmark brand-wordmark-splash" aria-label="vermeg">
          <span class="brand-slash">/</span><span class="brand-name">vermeg</span>
        </span>
        <p>Chargement de l'application...</p>
      </div>
    </ng-template>
  `
})
export class AppComponent implements OnInit {
  readonly auth = inject(AuthService);

  ngOnInit(): void {
    void this.auth.restoreSession();
  }
}
