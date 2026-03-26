import { inject } from '@angular/core';
import { ActivatedRouteSnapshot, CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../services/auth.service';
import { User } from '../models';

export const roleGuard: CanActivateFn = (route: ActivatedRouteSnapshot) => {
  const auth = inject(AuthService);
  const router = inject(Router);
  const allowedRoles = (route.data['roles'] as User['role'][] | undefined) ?? [];
  const user = auth.user();

  if (user && allowedRoles.includes(user.role)) {
    return true;
  }

  void router.navigateByUrl(user ? auth.routeForRole(user.role) : '/auth/login');
  return false;
};
