import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { AppShellComponent } from '../components/app-shell.component';
import { UiIconComponent } from '../components/ui-icon.component';
import { DocumentRequest, LeaveRequest, SalaryRequest } from '../models';
import { ApiService } from '../services/api.service';
import { AuthService } from '../services/auth.service';

@Component({
  selector: 'app-requests-page',
  standalone: true,
  imports: [CommonModule, FormsModule, AppShellComponent, UiIconComponent],
  template: `
    <app-shell [user]="auth.user()" title="Mes demandes RH" (logout)="auth.logout()">
      <section class="section-card">
        <div class="section-heading">
          <div>
            <p class="eyebrow">Espace employe</p>
            <h2 class="section-title">Demandes & documents</h2>
          </div>
        </div>

        <div class="row g-4" [class.salary-focus]="focusTab === 'salary'">
          <div class="col-lg-6">
            <div class="stack-item">
              <div class="fw-semibold mb-2">Demande de conge</div>
              <form class="row g-2" (ngSubmit)="submitLeave()">
                <div class="col-12">
                  <select class="form-select app-input" [(ngModel)]="leaveForm.type" name="leaveType">
                    <option value="CONGE_PAYE">Conge paye</option>
                    <option value="CONGE_SANS_SOLDE">Conge sans solde</option>
                    <option value="MALADIE">Maladie</option>
                  </select>
                </div>
                <div class="col-6">
                  <input type="date" class="form-control app-input" [(ngModel)]="leaveForm.start_date" name="leaveStart" required />
                </div>
                <div class="col-6">
                  <input type="date" class="form-control app-input" [(ngModel)]="leaveForm.end_date" name="leaveEnd" required />
                </div>
                <div class="col-12">
                  <textarea class="form-control app-input" rows="3" [(ngModel)]="leaveForm.reason" name="leaveReason" placeholder="Raison / details" required></textarea>
                </div>
                <div class="col-12">
                  <button class="primary-btn w-100" type="submit">
                    <span class="btn-icon"><app-ui-icon name="leave" /></span>
                    Envoyer la demande
                  </button>
                </div>
              </form>

              <div class="stack-list mt-3">
                <div class="stack-item request-card" *ngFor="let item of myLeaves()">
                  <div class="d-flex justify-content-between align-items-start gap-2">
                    <div>
                      <div class="d-flex align-items-center gap-2">
                        <span class="request-pill">{{ leaveLabel(item.type) }}</span>
                        <span class="text-secondary small">{{ item.start_date }} → {{ item.end_date }}</span>
                      </div>
                      <div class="text-secondary small mt-1">{{ item.reason || '---' }}</div>
                    </div>
                    <span class="status-badge" [ngClass]="statusClass(item.status)">{{ statusLabel(item.status) }}</span>
                  </div>
                </div>
                <div class="empty-state" *ngIf="!myLeaves().length">Aucune demande de conge.</div>
              </div>
            </div>
          </div>

          <div class="col-lg-6">
            <div class="stack-item">
              <div class="fw-semibold mb-2">Fiche de paie (salaire)</div>
              <form class="row g-2" (ngSubmit)="submitSalary()">
                <div class="col-6">
                  <input type="number" min="1" max="12" class="form-control app-input" [(ngModel)]="salaryForm.month" name="salaryMonth" placeholder="Mois" required />
                </div>
                <div class="col-6">
                  <input type="number" min="2000" class="form-control app-input" [(ngModel)]="salaryForm.year" name="salaryYear" placeholder="Annee" required />
                </div>
                <div class="col-12">
                  <textarea class="form-control app-input" rows="3" [(ngModel)]="salaryForm.details" name="salaryDetails" placeholder="Precision / note"></textarea>
                </div>
                <div class="col-12">
                  <button class="primary-btn w-100" type="submit">
                    <span class="btn-icon"><app-ui-icon name="salary" /></span>
                    Demander la fiche
                  </button>
                </div>
              </form>

              <div class="mt-3">
                <div class="fw-semibold mb-2">Historique salaire</div>
                <div class="data-table-wrap" *ngIf="mySalaries().length; else noSalary">
                  <table class="data-table">
                    <thead>
                      <tr>
                        <th>Periode</th>
                        <th>Details</th>
                        <th>Statut</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr *ngFor="let item of mySalaries()">
                        <td>{{ item.month }}/{{ item.year }}</td>
                        <td class="text-secondary">{{ item.details || '---' }}</td>
                        <td>
                          <span class="status-badge" [ngClass]="statusClass(item.status)">{{ statusLabel(item.status) }}</span>
                          <button class="ghost-btn ghost-btn-sm ms-2 doc-btn" type="button" *ngIf="item.file_data" (click)="openFile(item.file_data, item.file_name || 'fiche-paie.pdf')">Ouvrir</button>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
                <ng-template #noSalary>
                  <div class="empty-state">Aucun historique de salaire.</div>
                </ng-template>
              </div>
            </div>
          </div>

          <div class="col-12">
            <div class="stack-item">
              <div class="fw-semibold mb-2">Documents personnels</div>
              <form class="row g-2" (ngSubmit)="submitDocument()">
                <div class="col-md-6">
                  <select class="form-select app-input" [(ngModel)]="documentForm.type" name="docType">
                    <option value="ATTESTATION_TRAVAIL">Attestation de travail</option>
                    <option value="ATTESTATION_SALAIRE">Attestation de salaire</option>
                    <option value="CONTRAT">Contrat</option>
                  </select>
                </div>
                <div class="col-md-6">
                  <input class="form-control app-input" [(ngModel)]="documentForm.details" name="docDetails" placeholder="Details / precision" />
                </div>
                <div class="col-12">
                  <button class="primary-btn" type="submit">
                    <span class="btn-icon"><app-ui-icon name="document" /></span>
                    Demander un document
                  </button>
                </div>
              </form>

              <div class="stack-list mt-3">
                <div class="stack-item request-card" *ngFor="let item of myDocuments()">
                  <div class="d-flex justify-content-between align-items-start gap-2">
                    <div>
                      <div class="d-flex align-items-center gap-2">
                        <span class="request-pill">{{ documentLabel(item.type) }}</span>
                        <span class="text-secondary small">{{ item.details || '---' }}</span>
                      </div>
                    </div>
                    <div class="d-flex align-items-center gap-2">
                      <span class="status-badge" [ngClass]="statusClass(item.status)">{{ statusLabel(item.status) }}</span>
                      <button class="ghost-btn ghost-btn-sm doc-btn" type="button" *ngIf="item.file_data" (click)="openFile(item.file_data, item.file_name || 'document.pdf')">Ouvrir</button>
                    </div>
                  </div>
                </div>
                <div class="empty-state" *ngIf="!myDocuments().length">Aucune demande de document.</div>
              </div>
            </div>
          </div>
        </div>
      </section>
    </app-shell>
  `
})
export class RequestsPageComponent implements OnInit {
  private readonly api = inject(ApiService);
  readonly auth = inject(AuthService);

  readonly myLeaves = signal<LeaveRequest[]>([]);
  readonly mySalaries = signal<SalaryRequest[]>([]);
  readonly myDocuments = signal<DocumentRequest[]>([]);

  focusTab: 'salary' | 'leave' | 'documents' = 'leave';

  leaveForm = { type: 'CONGE_PAYE', start_date: '', end_date: '', reason: '' };
  salaryForm = { month: new Date().getMonth() + 1, year: new Date().getFullYear(), details: '' };
  documentForm = { type: 'ATTESTATION_TRAVAIL', details: '' };

  ngOnInit(): void {
    this.reloadAll();
    const params = new URLSearchParams(window.location.search);
    const tab = params.get('tab');
    if (tab === 'salary' || tab === 'leave' || tab === 'documents') {
      this.focusTab = tab;
    }
  }

  private reloadAll(): void {
    this.api.getMyLeaves().subscribe({ next: (list) => this.myLeaves.set(list), error: () => this.myLeaves.set([]) });
    this.api.getMySalaries().subscribe({ next: (list) => this.mySalaries.set(list), error: () => this.mySalaries.set([]) });
    this.api.getMyDocuments().subscribe({ next: (list) => this.myDocuments.set(list), error: () => this.myDocuments.set([]) });
  }

  submitLeave(): void {
    this.api.createLeave(this.leaveForm).subscribe({
      next: () => {
        this.leaveForm = { type: 'CONGE_PAYE', start_date: '', end_date: '', reason: '' };
        this.reloadAll();
      }
    });
  }

  submitSalary(): void {
    this.api.createSalaryRequest(this.salaryForm).subscribe({
      next: () => {
        this.salaryForm = { month: new Date().getMonth() + 1, year: new Date().getFullYear(), details: '' };
        this.reloadAll();
      }
    });
  }

  submitDocument(): void {
    this.api.createDocumentRequest(this.documentForm).subscribe({
      next: () => {
        this.documentForm = { type: 'ATTESTATION_TRAVAIL', details: '' };
        this.reloadAll();
      }
    });
  }

  openFile(dataUrl: string, filename: string): void {
    const link = document.createElement('a');
    link.href = dataUrl;
    link.download = filename;
    link.target = '_blank';
    link.click();
  }

  statusClass(status: string): string {
    const s = (status || '').toUpperCase();
    if (['APPROVED', 'COMPLETED', 'VALIDATED'].includes(s)) return 'is-success';
    if (['REJECTED'].includes(s)) return 'is-danger';
    return 'is-warning';
  }

  statusLabel(status: string): string {
    const s = (status || '').toUpperCase();
    if (s === 'APPROVED') return 'Approuve';
    if (s === 'REJECTED') return 'Refuse';
    return 'En attente';
  }

  leaveLabel(type?: string): string {
    const t = (type || '').toUpperCase();
    if (t === 'CONGE_PAYE') return 'Congé payé';
    if (t === 'CONGE_SANS_SOLDE') return 'Congé sans solde';
    if (t === 'MALADIE') return 'Congé maladie';
    return type || 'Congé';
  }

  documentLabel(type?: string): string {
    const t = (type || '').toUpperCase();
    if (t === 'ATTESTATION_TRAVAIL') return 'Attestation de travail';
    if (t === 'ATTESTATION_SALAIRE') return 'Attestation de salaire';
    if (t === 'CONTRAT') return 'Contrat';
    if (t === 'FICHE_PAIE') return 'Fiche de paie';
    return type || 'Document';
  }
}
