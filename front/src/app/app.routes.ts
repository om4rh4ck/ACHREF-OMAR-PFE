import { Routes } from '@angular/router';
import { authGuard } from './guards/auth.guard';
import { roleGuard } from './guards/role.guard';
import { LandingPageComponent } from './pages/landing-page.component';
import { LoginPageComponent } from './pages/login-page.component';
import { RegisterPageComponent } from './pages/register-page.component';
import { JobsPageComponent } from './pages/jobs-page.component';
import { DashboardPageComponent } from './pages/dashboard-page.component';
import { ProfilePageComponent } from './pages/profile-page.component';
import { NewsPageComponent } from './pages/news-page.component';
import { ApplicationsPageComponent } from './pages/applications-page.component';
import { InterviewsPageComponent } from './pages/interviews-page.component';
import { UsersPageComponent } from './pages/users-page.component';
import { MessagesPageComponent } from './pages/messages-page.component';
import { TeamPageComponent } from './pages/team-page.component';
import { RequestsPageComponent } from './pages/requests-page.component';
import { HrRequestsPageComponent } from './pages/hr-requests-page.component';

export const appRoutes: Routes = [
  { path: '', component: LandingPageComponent },
  { path: 'auth/login', component: LoginPageComponent },
  { path: 'auth/register', component: RegisterPageComponent },
  { path: 'jobs', component: JobsPageComponent },
  { path: 'profile', component: ProfilePageComponent, canActivate: [authGuard] },
  { path: 'news', component: NewsPageComponent, canActivate: [authGuard] },
  { path: 'applications', component: ApplicationsPageComponent, canActivate: [authGuard] },
  { path: 'interviews', component: InterviewsPageComponent, canActivate: [authGuard, roleGuard], data: { roles: ['HR_ADMIN', 'MANAGER', 'RECRUITER'] } },
  { path: 'users', component: UsersPageComponent, canActivate: [authGuard, roleGuard], data: { roles: ['HR_ADMIN'] } },
  { path: 'messages', component: MessagesPageComponent, canActivate: [authGuard] },
  { path: 'requests', component: RequestsPageComponent, canActivate: [authGuard, roleGuard], data: { roles: ['EMPLOYEE'] } },
  { path: 'hr-requests', component: HrRequestsPageComponent, canActivate: [authGuard, roleGuard], data: { roles: ['HR_ADMIN'] } },
  { path: 'team', component: TeamPageComponent, canActivate: [authGuard, roleGuard], data: { roles: ['MANAGER'] } },
  { path: 'employee/dashboard', component: DashboardPageComponent, canActivate: [authGuard, roleGuard], data: { roles: ['EMPLOYEE'] } },
  { path: 'manager', component: DashboardPageComponent, canActivate: [authGuard, roleGuard], data: { roles: ['MANAGER', 'RECRUITER'] } },
  { path: 'admin-rh', component: DashboardPageComponent, canActivate: [authGuard, roleGuard], data: { roles: ['HR_ADMIN'] } },
  { path: 'candidate', component: DashboardPageComponent, canActivate: [authGuard, roleGuard], data: { roles: ['CANDIDATE'] } },
  { path: '**', redirectTo: '' }
];
