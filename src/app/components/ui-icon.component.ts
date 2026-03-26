import { CommonModule } from '@angular/common';
import { Component, Input } from '@angular/core';

@Component({
  selector: 'app-ui-icon',
  standalone: true,
  imports: [CommonModule],
  template: `
    <svg class="ui-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" [ngSwitch]="name">
      <ng-container *ngSwitchCase="'dashboard'">
        <rect x="3" y="3" width="7" height="7" rx="1.5"></rect>
        <rect x="14" y="3" width="7" height="4.5" rx="1.5"></rect>
        <rect x="14" y="10.5" width="7" height="10.5" rx="1.5"></rect>
        <rect x="3" y="13" width="7" height="8" rx="1.5"></rect>
      </ng-container>
      <ng-container *ngSwitchCase="'jobs'">
        <rect x="3" y="7" width="18" height="12" rx="2"></rect>
        <path d="M8 7V5.5A1.5 1.5 0 0 1 9.5 4h5A1.5 1.5 0 0 1 16 5.5V7"></path>
        <path d="M3 12h18"></path>
      </ng-container>
      <ng-container *ngSwitchCase="'news'">
        <path d="M5 6.5h11"></path>
        <path d="M5 10.5h14"></path>
        <path d="M5 14.5h14"></path>
        <path d="M5 18.5h10"></path>
        <path d="M18 5v4"></path>
      </ng-container>
      <ng-container *ngSwitchCase="'messages'">
        <path d="M4 6.5A2.5 2.5 0 0 1 6.5 4h11A2.5 2.5 0 0 1 20 6.5v7A2.5 2.5 0 0 1 17.5 16H9l-5 4v-3.9A2.5 2.5 0 0 1 4 13.5z"></path>
      </ng-container>
      <ng-container *ngSwitchCase="'search'">
        <circle cx="11" cy="11" r="6.5"></circle>
        <path d="M16.2 16.2l3.3 3.3"></path>
      </ng-container>
      <ng-container *ngSwitchCase="'profile'">
        <circle cx="12" cy="8" r="3.5"></circle>
        <path d="M5 19a7 7 0 0 1 14 0"></path>
      </ng-container>
      <ng-container *ngSwitchCase="'applications'">
        <path d="M8 4.5h8"></path>
        <rect x="5" y="3" width="14" height="18" rx="2"></rect>
        <path d="M8 9h8"></path>
        <path d="M8 13h8"></path>
      </ng-container>
      <ng-container *ngSwitchCase="'interviews'">
        <rect x="3.5" y="5" width="17" height="15" rx="2"></rect>
        <path d="M8 3.5v3"></path>
        <path d="M16 3.5v3"></path>
        <path d="M3.5 10h17"></path>
        <path d="M12 13v4"></path>
        <path d="M10 15h4"></path>
      </ng-container>
      <ng-container *ngSwitchCase="'users'">
        <circle cx="9" cy="9" r="3"></circle>
        <path d="M4.5 18a4.5 4.5 0 0 1 9 0"></path>
        <circle cx="17.5" cy="10" r="2.5"></circle>
        <path d="M15.5 18a3.5 3.5 0 0 1 5 0"></path>
      </ng-container>
      <ng-container *ngSwitchCase="'notifications'">
        <path d="M8 18h8"></path>
        <path d="M10 21h4"></path>
        <path d="M6 18V10a6 6 0 0 1 12 0v8l2 1H4z"></path>
      </ng-container>
      <ng-container *ngSwitchCase="'team'">
        <circle cx="8" cy="9" r="2.5"></circle>
        <circle cx="16" cy="9" r="2.5"></circle>
        <path d="M4.5 18a3.5 3.5 0 0 1 7 0"></path>
        <path d="M12.5 18a3.5 3.5 0 0 1 7 0"></path>
      </ng-container>
      <ng-container *ngSwitchCase="'leave'">
        <path d="M12 3v18"></path>
        <path d="M6 9h12"></path>
        <path d="M7.5 4.5c1.4 1.2 2.4 2.8 2.8 4.5"></path>
        <path d="M16.5 19.5c-1.4-1.2-2.4-2.8-2.8-4.5"></path>
      </ng-container>
      <ng-container *ngSwitchCase="'document'">
        <path d="M7 3h6l4 4v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2z"></path>
        <path d="M13 3v5h5"></path>
        <path d="M9 13h6"></path>
        <path d="M9 17h6"></path>
      </ng-container>
      <ng-container *ngSwitchCase="'salary'">
        <rect x="4" y="5" width="16" height="14" rx="2"></rect>
        <path d="M8 9h8"></path>
        <path d="M8 13h6"></path>
      </ng-container>
      <ng-container *ngSwitchCase="'role'">
        <path d="M12 3l7 4v5c0 4.5-3 7.8-7 9-4-1.2-7-4.5-7-9V7z"></path>
        <path d="M9.5 12.5l1.7 1.7L15 10.4"></path>
      </ng-container>
      <ng-container *ngSwitchCase="'mobility'">
        <path d="M7 7h10"></path>
        <path d="M7 12h8"></path>
        <path d="M7 17h10"></path>
        <path d="M16 9l3-2-3-2"></path>
        <path d="M8 15l-3 2 3 2"></path>
      </ng-container>
      <ng-container *ngSwitchCase="'list'">
        <path d="M8 6h12"></path>
        <path d="M8 12h12"></path>
        <path d="M8 18h12"></path>
        <circle cx="5" cy="6" r="1"></circle>
        <circle cx="5" cy="12" r="1"></circle>
        <circle cx="5" cy="18" r="1"></circle>
      </ng-container>
      <ng-container *ngSwitchCase="'logout'">
        <path d="M10 17l5-5-5-5"></path>
        <path d="M4 12h11"></path>
        <path d="M13 4h3a3 3 0 0 1 3 3v10a3 3 0 0 1-3 3h-3"></path>
      </ng-container>
      <ng-container *ngSwitchDefault>
        <circle cx="12" cy="12" r="8"></circle>
      </ng-container>
    </svg>
  `
})
export class UiIconComponent {
  @Input() name = 'dashboard';
}
