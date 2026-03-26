import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { AppShellComponent } from '../components/app-shell.component';
import { UiIconComponent } from '../components/ui-icon.component';
import { User } from '../models';
import { ApiService } from '../services/api.service';
import { AuthService } from '../services/auth.service';

@Component({
  selector: 'app-users-page',
  standalone: true,
  imports: [CommonModule, FormsModule, AppShellComponent, UiIconComponent],
  template: `
    <app-shell [user]="auth.user()" title="Utilisateurs" (logout)="auth.logout()">
      <section class="section-card users-page">
        <div class="section-heading d-flex justify-content-between align-items-center flex-wrap gap-2">
          <div>
            <p class="eyebrow">Espace RH</p>
            <h2 class="section-title">Gestion des acces et profils</h2>
          </div>
          <button class="primary-btn" type="button" (click)="showAddUser = true">
            <span class="btn-icon"><app-ui-icon name="users" /></span>
            Ajout
          </button>
        </div>

        <div class="modal-overlay" *ngIf="showAddUser" (click)="showAddUser = false">
          <div class="modal-card" (click)="$event.stopPropagation()">
            <div class="d-flex justify-content-between align-items-center mb-3">
              <h3 class="section-title mb-0">Ajout</h3>
              <button class="ghost-btn ghost-btn-sm" type="button" (click)="showAddUser = false">Fermer</button>
            </div>
            <form (ngSubmit)="addUser()">
              <div class="mb-2">
                <label class="form-label">Email</label>
                <input type="email" class="form-control app-input" [(ngModel)]="newUser.email" name="newEmail" required />
              </div>
              <div class="mb-2">
                <label class="form-label">Nom complet</label>
                <input type="text" class="form-control app-input" [(ngModel)]="newUser.full_name" name="newFullName" required />
              </div>
              <div class="mb-2">
                <label class="form-label">Mot de passe</label>
                <input type="password" class="form-control app-input" [(ngModel)]="newUser.password" name="newPassword" required />
              </div>
              <div class="mb-3">
                <label class="form-label">Role</label>
                <select class="form-select app-input" [(ngModel)]="newUser.role" name="newRole">
                  <option *ngFor="let role of roles" [value]="role">{{ role }}</option>
                </select>
              </div>
              <div class="mb-3">
                <label class="form-label">Departement</label>
                <select class="form-select app-input" [(ngModel)]="newUser.department" name="newDepartment">
                  <option value="" disabled>Choisir un departement</option>
                  <option *ngFor="let dept of departments()" [ngValue]="dept.name">{{ dept.name }}</option>
                </select>
              </div>
              <div class="mb-3" *ngIf="newUser.role === 'EMPLOYEE'">
                <label class="form-label">Manager</label>
                <select class="form-select app-input" [(ngModel)]="newUser.manager_id" name="newManager">
                  <option [ngValue]="null">Aucun</option>
                  <option *ngFor="let mgr of managers()" [ngValue]="mgr.id">{{ mgr.full_name }}</option>
                </select>
              </div>
              <p class="text-danger small mb-2" *ngIf="addUserError">{{ addUserError }}</p>
              <button class="primary-btn w-100" type="submit">
                <span class="btn-icon"><app-ui-icon name="users" /></span>
                Ajout
              </button>
            </form>
          </div>
        </div>

        <div class="data-table-wrap" *ngIf="users().length; else empty">
          <table class="data-table">
            <thead>
              <tr>
                <th>Collaborateur</th>
                <th>Departement</th>
                <th>Poste</th>
                <th>Manager</th>
                <th>Role</th>
                <th>Maj role</th>
                <th>Maj profil</th>
              </tr>
            </thead>
            <tbody>
              <tr *ngFor="let user of users()">
                <td>
                  <div class="fw-semibold">{{ user.full_name }}</div>
                  <div class="small text-secondary">{{ user.email }}</div>
                </td>
                <td>{{ user.department || 'N/A' }}</td>
                <td>{{ user.position || 'N/A' }}</td>
                <td>{{ managerName(user.manager_id ?? user.managerId) }}</td>
                <td><span class="status-badge">{{ user.role }}</span></td>
                <td>
                  <div class="inline-actions">
                    <select class="form-select app-input" [(ngModel)]="draftRoles[user.id]" [name]="'role-' + user.id">
                      <option *ngFor="let role of roles" [value]="role">{{ role }}</option>
                    </select>
                    <button class="primary-btn" type="button" (click)="saveRole(user.id)">
                      <span class="btn-icon"><app-ui-icon name="role" /></span>
                      Enregistrer
                    </button>
                  </div>
                </td>
                <td>
                  <div class="inline-actions">
                    <select class="form-select app-input" [(ngModel)]="draftDepartments[user.id]" [name]="'dept-' + user.id">
                      <option value="" disabled>Departement</option>
                      <option *ngFor="let dept of departments()" [ngValue]="dept.name">{{ dept.name }}</option>
                    </select>
                    <select class="form-select app-input" [(ngModel)]="draftManagers[user.id]" [name]="'manager-' + user.id" [disabled]="user.role !== 'EMPLOYEE'">
                      <option [ngValue]="null">Aucun</option>
                      <option *ngFor="let mgr of managers()" [ngValue]="mgr.id">{{ mgr.full_name }}</option>
                    </select>
                    <select class="form-select app-input" *ngIf="user.role === 'EMPLOYEE'" [(ngModel)]="draftContracts[user.id]" [name]="'contract-' + user.id">
                      <option value="" disabled>Contrat</option>
                      <option *ngFor="let c of contractTypes()" [ngValue]="c.name">{{ c.name }}</option>
                    </select>
                    <input class="form-control app-input" type="number" *ngIf="user.role === 'EMPLOYEE'" [(ngModel)]="draftSalaries[user.id]" [name]="'salary-' + user.id" placeholder="Salaire" />
                    <button class="primary-btn" type="button" (click)="saveProfile(user.id)">
                      <span class="btn-icon"><app-ui-icon name="users" /></span>
                      Mettre a jour
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <ng-template #empty>
          <div class="empty-state">Aucun utilisateur disponible.</div>
        </ng-template>
      </section>

      <section class="section-card mt-4">
        <div class="section-heading">
          <div>
            <p class="eyebrow">Organisation</p>
            <h2 class="section-title">Departements & postes</h2>
          </div>
        </div>

        <div class="row g-3">
          <div class="col-lg-6">
            <div class="stack-item">
              <div class="fw-semibold mb-2">Departements</div>
              <div class="stack-list mb-3">
                <div *ngFor="let dept of departments()" class="d-flex justify-content-between align-items-center">
                  <div>
                    <div class="fw-semibold">{{ dept.name }}</div>
                    <div class="small text-secondary">{{ dept.description || '---' }}</div>
                  </div>
                </div>
                <div class="small text-secondary" *ngIf="!departments().length">Aucun departement.</div>
              </div>
              <form class="row g-2" (ngSubmit)="addDepartment()">
                <div class="col-12"><input class="form-control app-input" [(ngModel)]="newDepartment.name" name="deptName" placeholder="Nouveau departement" required /></div>
                <div class="col-12"><input class="form-control app-input" [(ngModel)]="newDepartment.description" name="deptDesc" placeholder="Description" /></div>
                <div class="col-12"><button class="primary-btn w-100" type="submit">Ajouter</button></div>
              </form>
            </div>
          </div>

          <div class="col-lg-6">
            <div class="stack-item">
              <div class="fw-semibold mb-2">Postes</div>
              <div class="stack-list mb-3">
                <div *ngFor="let pos of positions()" class="d-flex justify-content-between align-items-center">
                  <div>
                    <div class="fw-semibold">{{ pos.title }}</div>
                    <div class="small text-secondary">{{ pos.department || '---' }}</div>
                  </div>
                  <button class="ghost-btn ghost-btn-sm" type="button" (click)="deletePosition(pos.id)">Supprimer</button>
                </div>
                <div class="small text-secondary" *ngIf="!positions().length">Aucun poste.</div>
              </div>
              <form class="row g-2" (ngSubmit)="addPosition()">
                <div class="col-12"><input class="form-control app-input" [(ngModel)]="newPosition.title" name="posTitle" placeholder="Nouveau poste" required /></div>
                <div class="col-12">
                  <select class="form-select app-input" [(ngModel)]="newPosition.department" name="posDept">
                    <option value="" disabled>Departement</option>
                    <option *ngFor="let dept of departments()" [ngValue]="dept.name">{{ dept.name }}</option>
                  </select>
                </div>
                <div class="col-12"><button class="primary-btn w-100" type="submit">Ajouter</button></div>
              </form>
            </div>
          </div>
        </div>
      </section>

      <section class="section-card mt-4">
        <div class="section-heading">
          <div>
            <p class="eyebrow">Contrats</p>
            <h2 class="section-title">Types de contrats</h2>
          </div>
        </div>
        <div class="stack-list mb-3">
          <div *ngFor="let c of contractTypes()" class="d-flex justify-content-between align-items-center">
            <div>
              <div class="fw-semibold">{{ c.name }}</div>
              <div class="small text-secondary">{{ c.description || '---' }}</div>
            </div>
          </div>
          <div class="small text-secondary" *ngIf="!contractTypes().length">Aucun type de contrat.</div>
        </div>
        <form class="row g-2" (ngSubmit)="addContractType()">
          <div class="col-md-6"><input class="form-control app-input" [(ngModel)]="newContractType.name" name="ctName" placeholder="Type de contrat" required /></div>
          <div class="col-md-6"><input class="form-control app-input" [(ngModel)]="newContractType.description" name="ctDesc" placeholder="Description" /></div>
          <div class="col-12"><button class="primary-btn w-100" type="submit">Ajouter</button></div>
        </form>
      </section>

      <section class="section-card mt-4">
        <div class="section-heading">
          <div>
            <p class="eyebrow">Rapports RH</p>
            <h2 class="section-title">Effectifs & mobilite interne</h2>
          </div>
        </div>
        <div class="row g-3">
          <div class="col-md-4">
            <article class="metric-card h-100">
              <span class="metric-icon"><app-ui-icon name="users" /></span>
              <span class="metric-value">{{ stats()?.employees ?? 0 }}</span>
              <span class="metric-label">Effectifs</span>
            </article>
          </div>
          <div class="col-md-4">
            <article class="metric-card h-100">
              <span class="metric-icon"><app-ui-icon name="mobility" /></span>
              <span class="metric-value">{{ stats()?.mobilityRate ?? '0%' }}</span>
              <span class="metric-label">Mobilite interne</span>
            </article>
          </div>
          <div class="col-md-4">
            <article class="metric-card h-100">
              <span class="metric-icon"><app-ui-icon name="applications" /></span>
              <span class="metric-value">{{ stats()?.totalApplications ?? 0 }}</span>
              <span class="metric-label">Candidatures</span>
            </article>
          </div>
        </div>
      </section>
    </app-shell>
  `
})
export class UsersPageComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly api = inject(ApiService);
  readonly users = signal<User[]>([]);
  readonly roles = ['EMPLOYEE', 'MANAGER', 'HR_ADMIN', 'RECRUITER', 'CANDIDATE'];
  draftRoles: Record<number, string> = {};
  draftDepartments: Record<number, string> = {};
  draftManagers: Record<number, number | null> = {};
  draftContracts: Record<number, string> = {};
  draftSalaries: Record<number, number | null> = {};
  showAddUser = false;
  newUser = { email: '', full_name: '', password: '', role: 'EMPLOYEE', department: '', manager_id: null as number | null };
  addUserError = '';
  readonly departments = signal<{ id: number; name: string; description?: string }[]>([]);
  readonly positions = signal<{ id: number; title: string; department?: string }[]>([]);
  readonly contractTypes = signal<{ id: number; name: string; description?: string }[]>([]);
  readonly stats = signal<{ employees: number; mobilityRate?: string; totalApplications?: number } | null>(null);
  newDepartment = { name: '', description: '' };
  newPosition = { title: '', department: '' };
  newContractType = { name: '', description: '' };

  ngOnInit(): void {
    this.loadUsers();
    this.loadOrgData();
  }

  addUser(): void {
    this.addUserError = '';
    if (!this.newUser.email?.trim() || !this.newUser.password) {
      this.addUserError = 'Email et mot de passe requis';
      return;
    }
    if (this.newUser.role !== 'CANDIDATE' && !this.newUser.department?.trim()) {
      this.addUserError = 'Departement requis';
      return;
    }
    if (this.newUser.role === 'EMPLOYEE' && !this.newUser.manager_id) {
      this.addUserError = 'Manager requis pour un employe';
      return;
    }
    this.api.createUser({
      email: this.newUser.email.trim(),
      full_name: this.newUser.full_name?.trim() || this.newUser.email.trim(),
      password: this.newUser.password,
      role: this.newUser.role,
      department: this.newUser.department?.trim(),
      manager_id: this.newUser.role === 'EMPLOYEE' ? this.newUser.manager_id : null
    }).subscribe({
      next: () => {
        this.showAddUser = false;
        this.newUser = { email: '', full_name: '', password: '', role: 'EMPLOYEE', department: '', manager_id: null };
        this.loadUsers();
      },
      error: (err) => {
        this.addUserError = err.error?.error || 'Creation impossible';
      }
    });
  }

  loadUsers(): void {
    this.api.getUsers().subscribe({
      next: (items) => {
        const safe = Array.isArray(items) ? items : [];
        this.users.set(safe);
        this.draftRoles = safe.reduce<Record<number, string>>((acc, user) => {
          acc[user.id] = user.role;
          return acc;
        }, {});
        this.draftDepartments = safe.reduce<Record<number, string>>((acc, user) => {
          acc[user.id] = user.department || '';
          return acc;
        }, {});
        this.draftManagers = safe.reduce<Record<number, number | null>>((acc, user) => {
          acc[user.id] = user.manager_id ?? user.managerId ?? null;
          return acc;
        }, {});
        this.draftContracts = safe.reduce<Record<number, string>>((acc, user) => {
          acc[user.id] = user.contract_type ?? user.contractType ?? '';
          return acc;
        }, {});
        this.draftSalaries = safe.reduce<Record<number, number | null>>((acc, user) => {
          acc[user.id] = user.salary ?? null;
          return acc;
        }, {});
      },
      error: () => this.users.set([])
    });
  }

  private loadOrgData(): void {
    this.api.getDepartments().subscribe({
      next: (items) => this.departments.set(Array.isArray(items) ? items : []),
      error: () => this.departments.set([])
    });
    this.api.getPositions().subscribe({
      next: (items) => this.positions.set(Array.isArray(items) ? items : []),
      error: () => this.positions.set([])
    });
    this.api.getContractTypes().subscribe({
      next: (items) => this.contractTypes.set(Array.isArray(items) ? items : []),
      error: () => this.contractTypes.set([])
    });
    this.api.getStats().subscribe({
      next: (items) => this.stats.set(items as { employees: number; mobilityRate?: string; totalApplications?: number }),
      error: () => this.stats.set(null)
    });
  }

  addDepartment(): void {
    if (!this.newDepartment.name.trim()) return;
    this.api.createDepartment(this.newDepartment).subscribe({
      next: () => {
        this.newDepartment = { name: '', description: '' };
        this.loadOrgData();
      }
    });
  }

  addPosition(): void {
    if (!this.newPosition.title.trim()) return;
    this.api.createPosition(this.newPosition).subscribe({
      next: () => {
        this.newPosition = { title: '', department: '' };
        this.loadOrgData();
      }
    });
  }

  deletePosition(id: number): void {
    this.api.deletePosition(id).subscribe({
      next: () => this.loadOrgData()
    });
  }

  addContractType(): void {
    if (!this.newContractType.name.trim()) return;
    this.api.createContractType(this.newContractType).subscribe({
      next: () => {
        this.newContractType = { name: '', description: '' };
        this.loadOrgData();
      }
    });
  }

  managers(): User[] {
    return this.users().filter((u) => u.role === 'MANAGER');
  }

  managerName(managerId?: number | null): string {
    if (!managerId) return '-';
    const manager = this.users().find((u) => u.id === managerId);
    return manager ? manager.full_name : '-';
  }

  saveProfile(id: number): void {
    let department = this.draftDepartments[id];
    const managerId = this.draftManagers[id] ?? null;
    const contractType = this.draftContracts[id] ?? '';
    const salary = this.draftSalaries[id] ?? null;
    if (managerId && !department) {
      const manager = this.users().find((u) => u.id === managerId);
      if (manager?.department) {
        department = manager.department;
        this.draftDepartments[id] = manager.department;
      }
    }
    this.api.updateUser(id, { department, manager_id: managerId, contract_type: contractType || null, salary }).subscribe({
      next: () => this.loadUsers()
    });
  }

  saveRole(id: number): void {
    const role = this.draftRoles[id];
    if (!role) {
      return;
    }

    this.api.updateUserRole(id, role).subscribe({
      next: () => this.loadUsers()
    });
  }
}
