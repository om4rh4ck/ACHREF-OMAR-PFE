import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { AppShellComponent } from '../components/app-shell.component';
import { UiIconComponent } from '../components/ui-icon.component';
import { DocumentRequest, LeaveRequest, SalaryRequest, User } from '../models';
import { ApiService } from '../services/api.service';
import { AuthService } from '../services/auth.service';

@Component({
  selector: 'app-hr-requests-page',
  standalone: true,
  imports: [CommonModule, FormsModule, AppShellComponent, UiIconComponent],
  template: `
    <app-shell [user]="auth.user()" title="Demandes RH" (logout)="auth.logout()">
      <section class="section-card hr-requests-page">
        <div class="section-heading">
          <div>
            <p class="eyebrow">Administration RH</p>
            <h2 class="section-title">Conges, salaires & documents</h2>
          </div>
        </div>

        <div class="row g-4">
          <div class="col-12">
            <div class="stack-item">
              <div class="fw-semibold mb-2">Ajouter un conge</div>
              <form class="row g-2 mb-3" (ngSubmit)="createLeaveManual()">
                <div class="col-md-4">
                  <select class="form-select app-input" [(ngModel)]="leaveAdminForm.employee_email" name="leaveEmp" required>
                    <option value="" disabled>Employe</option>
                    <option *ngFor="let emp of employees()" [ngValue]="emp.email">{{ emp.full_name }}</option>
                  </select>
                </div>
                <div class="col-md-3">
                  <select class="form-select app-input" [(ngModel)]="leaveAdminForm.type" name="leaveType">
                    <option value="CONGE_PAYE">Conge paye</option>
                    <option value="CONGE_SANS_SOLDE">Conge sans solde</option>
                    <option value="MALADIE">Maladie</option>
                  </select>
                </div>
                <div class="col-md-2">
                  <input type="date" class="form-control app-input" [(ngModel)]="leaveAdminForm.start_date" name="leaveStart" required />
                </div>
                <div class="col-md-2">
                  <input type="date" class="form-control app-input" [(ngModel)]="leaveAdminForm.end_date" name="leaveEnd" required />
                </div>
                <div class="col-md-12">
                  <input class="form-control app-input" [(ngModel)]="leaveAdminForm.reason" name="leaveReason" placeholder="Raison / details" />
                </div>
                <div class="col-md-12">
                  <button class="primary-btn" type="submit">
                    <span class="btn-icon"><app-ui-icon name="leave" /></span>
                    Ajouter conge
                  </button>
                </div>
              </form>

              <div class="data-table-wrap" *ngIf="pendingLeaves().length; else noLeaves">
                <table class="data-table">
                  <thead>
                    <tr>
                      <th>Employe</th>
                      <th>Periode</th>
                      <th>Raison</th>
                      <th>Statut</th>
                      <th>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr *ngFor="let item of pendingLeaves()">
                      <td>
                        <div class="fw-semibold">{{ userName(item.employee_email) }}</div>
                        <div class="small text-secondary">{{ item.employee_email }}</div>
                      </td>
                      <td>{{ item.start_date }} → {{ item.end_date }}</td>
                      <td class="text-secondary">{{ item.reason || '---' }}</td>
                      <td><span class="status-badge" [ngClass]="statusClass(item.status)">{{ statusLabel(item.status) }}</span></td>
                      <td>
                        <div class="inline-actions">
                          <button class="ghost-btn" type="button" (click)="updateLeave(item.id, 'REJECTED')">Refuser</button>
                          <button class="primary-btn" type="button" (click)="updateLeave(item.id, 'APPROVED')">Accepter</button>
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
              <ng-template #noLeaves>
                <div class="empty-state">Aucun conge enregistre.</div>
              </ng-template>
            </div>
          </div>

          <div class="col-12">
            <div class="stack-item">
              <div class="fw-semibold mb-2">Ajouter une fiche de paie</div>
              <form class="row g-2 mb-3" (ngSubmit)="createSalaryManual()">
                <div class="col-md-4">
                  <select class="form-select app-input" [(ngModel)]="salaryAdminForm.employee_email" name="salaryEmp" required>
                    <option value="" disabled>Employe</option>
                    <option *ngFor="let emp of employees()" [ngValue]="emp.email">{{ emp.full_name }}</option>
                  </select>
                </div>
                <div class="col-md-2">
                  <input type="number" min="1" max="12" class="form-control app-input" [(ngModel)]="salaryAdminForm.month" name="salaryMonth" placeholder="Mois" required />
                </div>
                <div class="col-md-2">
                  <input type="number" min="2000" class="form-control app-input" [(ngModel)]="salaryAdminForm.year" name="salaryYear" placeholder="Annee" required />
                </div>
                <div class="col-md-4">
                  <input class="form-control app-input" [(ngModel)]="salaryAdminForm.details" name="salaryDetails" placeholder="Details" />
                </div>
                <div class="col-md-6">
                  <input type="file" class="form-control app-input" (change)="onSalaryFile($event)" />
                </div>
                <div class="col-12">
                  <button class="primary-btn" type="submit">
                    <span class="btn-icon"><app-ui-icon name="salary" /></span>
                    Ajouter fiche
                  </button>
                </div>
              </form>

              <div class="data-table-wrap" *ngIf="pendingSalaries().length; else noSalaries">
                <table class="data-table">
                  <thead>
                    <tr>
                      <th>Employe</th>
                      <th>Periode</th>
                      <th>Details</th>
                      <th>Statut</th>
                      <th>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr *ngFor="let item of pendingSalaries()">
                      <td>
                        <div class="fw-semibold">{{ userName(item.employee_email) }}</div>
                        <div class="small text-secondary">{{ item.employee_email }}</div>
                      </td>
                      <td>{{ item.month }}/{{ item.year }}</td>
                      <td class="text-secondary">{{ item.details || '---' }}</td>
                      <td><span class="status-badge" [ngClass]="statusClass(item.status)">{{ statusLabel(item.status) }}</span></td>
                      <td>
                        <div class="inline-actions">
                          <button class="ghost-btn" type="button" (click)="updateSalary(item.id, 'REJECTED')">Refuser</button>
                          <button class="primary-btn" type="button" (click)="updateSalary(item.id, 'APPROVED')">Accepter</button>
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
              <ng-template #noSalaries>
                <div class="empty-state">Aucune fiche de paie ajoutee.</div>
              </ng-template>
            </div>
          </div>

          <div class="col-12">
            <div class="stack-item">
              <div class="fw-semibold mb-2">Ajouter un document</div>
              <form class="row g-2 mb-3" (ngSubmit)="createDocumentManual()">
                <div class="col-md-4">
                  <select class="form-select app-input" [(ngModel)]="documentAdminForm.employee_email" name="docEmp" required>
                    <option value="" disabled>Employe</option>
                    <option *ngFor="let emp of employees()" [ngValue]="emp.email">{{ emp.full_name }}</option>
                  </select>
                </div>
                <div class="col-md-4">
                  <select class="form-select app-input" [(ngModel)]="documentAdminForm.type" name="docType">
                    <option value="ATTESTATION_TRAVAIL">Attestation de travail</option>
                    <option value="ATTESTATION_SALAIRE">Attestation de salaire</option>
                    <option value="CONTRAT">Contrat</option>
                    <option value="FICHE_PAIE">Fiche de paie</option>
                  </select>
                </div>
                <div class="col-md-4">
                  <input class="form-control app-input" [(ngModel)]="documentAdminForm.details" name="docDetails" placeholder="Details" />
                </div>
                <div class="col-md-6">
                  <input type="file" class="form-control app-input" (change)="onDocumentFile($event)" />
                </div>
                <div class="col-12">
                  <button class="primary-btn" type="submit">
                    <span class="btn-icon"><app-ui-icon name="document" /></span>
                    Ajouter document
                  </button>
                </div>
              </form>

              <div class="data-table-wrap" *ngIf="pendingDocuments().length; else noDocuments">
                <table class="data-table">
                  <thead>
                    <tr>
                      <th>Employe</th>
                      <th>Type</th>
                      <th>Details</th>
                      <th>Statut</th>
                      <th>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr *ngFor="let item of pendingDocuments()">
                      <td>
                        <div class="fw-semibold">{{ userName(item.employee_email) }}</div>
                        <div class="small text-secondary">{{ item.employee_email }}</div>
                      </td>
                      <td>{{ item.type }}</td>
                      <td class="text-secondary">{{ item.details || '---' }}</td>
                      <td><span class="status-badge" [ngClass]="statusClass(item.status)">{{ statusLabel(item.status) }}</span></td>
                      <td>
                        <div class="inline-actions">
                          <button class="ghost-btn" type="button" (click)="updateDocument(item.id, 'REJECTED')">Refuser</button>
                          <button class="primary-btn" type="button" (click)="updateDocument(item.id, 'APPROVED')">Accepter</button>
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
              <ng-template #noDocuments>
                <div class="empty-state">Aucun document ajoute.</div>
              </ng-template>
            </div>
          </div>
        </div>
      </section>

      <section class="section-card mt-4">
        <div class="section-heading">
          <div>
            <p class="eyebrow">Contrats</p>
            <h2 class="section-title">Employes & contrats</h2>
          </div>
        </div>
        <div class="row g-2 mb-3">
          <div class="col-md-4">
            <select class="form-select app-input" [(ngModel)]="filterContract">
              <option value="">Tous les contrats</option>
              <option *ngFor="let c of contractTypes()" [ngValue]="c.name">{{ c.name }}</option>
            </select>
          </div>
          <div class="col-md-4">
            <select class="form-select app-input" [(ngModel)]="filterDepartment">
              <option value="">Tous les departements</option>
              <option *ngFor="let d of departments()" [ngValue]="d.name">{{ d.name }}</option>
            </select>
          </div>
        </div>
        <div class="data-table-wrap" *ngIf="employees().length; else noEmployees">
          <table class="data-table">
            <thead>
              <tr>
                <th>Employe</th>
                <th>Departement</th>
                <th>Contrat</th>
                <th>Salaire (DT)</th>
                <th>Maj contrat & salaire</th>
              </tr>
            </thead>
            <tbody>
              <tr *ngFor="let emp of filteredEmployees()">
                <td>
                  <div class="fw-semibold">{{ emp.full_name }}</div>
                  <div class="small text-secondary">{{ emp.email }}</div>
                </td>
                <td>{{ emp.department || 'N/A' }}</td>
                <td>{{ emp.contract_type || emp.contractType || 'Non defini' }}</td>
                <td>{{ emp.salary ?? 'Non defini' }}</td>
                <td>
                  <div class="inline-actions">
                    <select class="form-select app-input" [(ngModel)]="draftContracts[emp.id]" [name]="'contract-' + emp.id">
                      <option value="" disabled>Contrat</option>
                      <option *ngFor="let c of contractTypes()" [ngValue]="c.name">{{ c.name }}</option>
                    </select>
                    <input class="form-control app-input" type="number" min="0" step="0.01" [(ngModel)]="draftSalaries[emp.id]" [name]="'salary-' + emp.id" placeholder="Salaire" />
                    <button class="primary-btn" type="button" (click)="updateEmployeeContract(emp)">
                      <span class="btn-icon"><app-ui-icon name="users" /></span>
                      Enregistrer
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <ng-template #noEmployees>
          <div class="empty-state">Aucun employe.</div>
        </ng-template>
      </section>
    </app-shell>
  `
})
export class HrRequestsPageComponent implements OnInit {
  private readonly api = inject(ApiService);
  readonly auth = inject(AuthService);

  readonly pendingLeaves = signal<LeaveRequest[]>([]);
  readonly pendingSalaries = signal<SalaryRequest[]>([]);
  readonly pendingDocuments = signal<DocumentRequest[]>([]);
  readonly users = signal<User[]>([]);
  readonly employees = signal<User[]>([]);
  readonly departments = signal<{ id: number; name: string; description?: string }[]>([]);
  readonly contractTypes = signal<{ id: number; name: string; description?: string }[]>([]);
  filterContract = '';
  filterDepartment = '';
  draftContracts: Record<number, string> = {};
  draftSalaries: Record<number, number | null> = {};
  leaveAdminForm = { employee_email: '', type: 'CONGE_PAYE', start_date: '', end_date: '', reason: '' };
  salaryAdminForm = { employee_email: '', month: new Date().getMonth() + 1, year: new Date().getFullYear(), details: '', file_data: '', file_name: '' };
  documentAdminForm = { employee_email: '', type: 'ATTESTATION_TRAVAIL', details: '', file_data: '', file_name: '' };

  ngOnInit(): void {
    this.reloadAll();
    this.api.getUsers().subscribe({
      next: (list) => {
        this.users.set(list);
        const emps = list.filter((u) => u.role === 'EMPLOYEE');
        this.employees.set(emps);
        this.draftContracts = emps.reduce<Record<number, string>>((acc, u) => {
          acc[u.id] = u.contract_type || u.contractType || '';
          return acc;
        }, {});
        this.draftSalaries = emps.reduce<Record<number, number | null>>((acc, u) => {
          acc[u.id] = u.salary ?? null;
          return acc;
        }, {});
      },
      error: () => {
        this.users.set([]);
        this.employees.set([]);
      }
    });
    this.api.getDepartments().subscribe({
      next: (items) => this.departments.set(Array.isArray(items) ? items : []),
      error: () => this.departments.set([])
    });
    this.api.getContractTypes().subscribe({
      next: (items) => this.contractTypes.set(Array.isArray(items) ? items : []),
      error: () => this.contractTypes.set([])
    });
  }

  private reloadAll(): void {
    this.api.getPendingLeaves().subscribe({ next: (list) => this.pendingLeaves.set(list), error: () => this.pendingLeaves.set([]) });
    this.api.getPendingSalaries().subscribe({ next: (list) => this.pendingSalaries.set(list), error: () => this.pendingSalaries.set([]) });
    this.api.getPendingDocuments().subscribe({ next: (list) => this.pendingDocuments.set(list), error: () => this.pendingDocuments.set([]) });
  }

  updateLeave(id: number, status: string): void {
    this.api.updateLeaveStatus(id, status).subscribe({ next: () => this.reloadAll() });
  }

  updateSalary(id: number, status: string): void {
    this.api.updateSalaryStatus(id, status).subscribe({ next: () => this.reloadAll() });
  }

  updateDocument(id: number, status: string): void {
    this.api.updateDocumentStatus(id, status).subscribe({ next: () => this.reloadAll() });
  }

  updateEmployeeContract(emp: User): void {
    const contractType = this.draftContracts[emp.id] || '';
    const salaryValue = this.draftSalaries[emp.id];
    const salary = salaryValue === null || salaryValue === undefined || Number.isNaN(Number(salaryValue))
      ? null
      : Number(salaryValue);
    this.api.updateUser(emp.id, { contract_type: contractType || null, salary }).subscribe({
      next: () => {
        this.api.getUsers().subscribe({
          next: (list) => {
            this.users.set(list);
            const emps = list.filter((u) => u.role === 'EMPLOYEE');
            this.employees.set(emps);
            this.draftSalaries = emps.reduce<Record<number, number | null>>((acc, u) => {
              acc[u.id] = u.salary ?? null;
              return acc;
            }, {});
          }
        });
      }
    });
  }

  createLeaveManual(): void {
    this.api.createLeaveByAdmin(this.leaveAdminForm).subscribe({
      next: () => {
        this.leaveAdminForm = { employee_email: '', type: 'CONGE_PAYE', start_date: '', end_date: '', reason: '' };
        this.reloadAll();
      }
    });
  }

  createSalaryManual(): void {
    this.api.createSalaryByAdmin(this.salaryAdminForm).subscribe({
      next: () => {
        this.salaryAdminForm = { employee_email: '', month: new Date().getMonth() + 1, year: new Date().getFullYear(), details: '', file_data: '', file_name: '' };
        this.reloadAll();
      }
    });
  }

  createDocumentManual(): void {
    this.api.createDocumentByAdmin(this.documentAdminForm).subscribe({
      next: () => {
        this.documentAdminForm = { employee_email: '', type: 'ATTESTATION_TRAVAIL', details: '', file_data: '', file_name: '' };
        this.reloadAll();
      }
    });
  }

  onSalaryFile(event: Event): void {
    const input = event.target as HTMLInputElement;
    const file = input.files?.[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = () => {
      const result = typeof reader.result === 'string' ? reader.result : '';
      this.salaryAdminForm.file_data = result;
      this.salaryAdminForm.file_name = file.name;
    };
    reader.readAsDataURL(file);
  }

  onDocumentFile(event: Event): void {
    const input = event.target as HTMLInputElement;
    const file = input.files?.[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = () => {
      const result = typeof reader.result === 'string' ? reader.result : '';
      this.documentAdminForm.file_data = result;
      this.documentAdminForm.file_name = file.name;
    };
    reader.readAsDataURL(file);
  }

  userName(email?: string): string {
    if (!email) return 'Employe';
    const user = this.users().find((u) => u.email === email);
    return user?.full_name || 'Employe';
  }

  filteredEmployees(): User[] {
    const contract = this.filterContract.trim().toLowerCase();
    const dept = this.filterDepartment.trim().toLowerCase();
    return this.employees().filter((u) => {
      const ct = (u.contract_type || u.contractType || '').toLowerCase();
      const d = (u.department || '').toLowerCase();
      const okContract = !contract || ct.includes(contract);
      const okDept = !dept || d.includes(dept);
      return okContract && okDept;
    });
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
}
