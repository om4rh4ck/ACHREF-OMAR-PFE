import { Injectable, computed, inject, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { User } from '../models';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly http = inject(HttpClient);
  private readonly router = inject(Router);
  private readonly keycloakBaseUrl = 'http://localhost:8080';
  private readonly realm = 'vermeg-sirh';
  private readonly clientId = 'vermeg-frontend';

  readonly token = signal<string | null>(localStorage.getItem('token'));
  readonly user = signal<User | null>(null);
  readonly loading = signal<boolean>(true);
  readonly isAuthenticated = computed(() => !!this.token() && !!this.user());

  async restoreSession(): Promise<void> {
    const token = this.token();
    if (!token) {
      this.loading.set(false);
      return;
    }

    try {
      const response = await firstValueFrom(this.http.get<{ user: User }>('/api/auth/me'));
      this.user.set(response.user);
    } catch {
      this.logout(false);
    } finally {
      this.loading.set(false);
    }
  }

  async login(payload: { email: string; password: string }): Promise<User> {
    const response = await firstValueFrom(
      this.http.post<{ token: string; user: User }>('/api/auth/login', payload)
    );

    localStorage.setItem('token', response.token);
    this.token.set(response.token);
    this.user.set(response.user);
    return response.user;
  }

  async register(payload: Record<string, string>): Promise<User | null> {
    const response = await firstValueFrom(
      this.http.post<{ token?: string; user?: User; status?: string; message?: string }>('/api/auth/register', payload)
    );

    if (response?.token && response?.user) {
      localStorage.setItem('token', response.token);
      this.token.set(response.token);
      this.user.set(response.user);
      return response.user;
    }
    return null;
  }

  logout(navigate = true): void {
    localStorage.removeItem('token');
    this.token.set(null);
    this.user.set(null);
    if (navigate) {
      void this.router.navigateByUrl('/');
    }
  }

  forgotPassword(): void {
    const params = new URLSearchParams({
      client_id: this.clientId
    });
    window.location.href = `${this.keycloakBaseUrl}/realms/${this.realm}/login-actions/reset-credentials?${params.toString()}`;
  }

  socialLogin(provider: 'google' | 'facebook'): void {
    const params = new URLSearchParams({
      client_id: this.clientId,
      redirect_uri: `${window.location.origin}/auth/login`,
      response_type: 'code',
      scope: 'openid profile email',
      kc_idp_hint: provider
    });
    window.location.href = `${this.keycloakBaseUrl}/realms/${this.realm}/protocol/openid-connect/auth?${params.toString()}`;
  }

  routeForRole(role: User['role']): string {
    switch (role) {
      case 'EMPLOYEE':
        return '/employee/dashboard';
      case 'MANAGER':
        return '/manager';
      case 'HR_ADMIN':
        return '/admin-rh';
      case 'RECRUITER':
        return '/manager';
      case 'CANDIDATE':
        return '/candidate';
      default:
        return '/';
    }
  }
}
